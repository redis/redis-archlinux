#!/usr/bin/env python3
"""Usage: kms-sign.py <kms_key_id> <public_key_file> <file>...

Writes <file>.sig, a detached OpenPGP signature, for each file. The private key
stays in AWS KMS: the file is hashed here and KMS signs only the digest. The
signature verifies with public_key_file, which must hold the same RSA key.
Needs the aws CLI with credentials and openssl.
"""
import base64
import hashlib
import struct
import subprocess
import sys
import tempfile
import time
from pathlib import Path

RSA = 1
SHA512 = 10
BINARY_DOCUMENT = 0x00


def run(*command: str) -> str:
    return subprocess.run(command, check=True, capture_output=True, text=True).stdout.strip()


def kms_modulus(key_id: str) -> int:
    der = base64.b64decode(
        run("aws", "kms", "get-public-key", "--key-id", key_id,
            "--query", "PublicKey", "--output", "text")
    )
    with tempfile.NamedTemporaryFile() as public_key:
        public_key.write(der)
        public_key.flush()
        modulus = run("openssl", "rsa", "-pubin", "-inform", "DER",
                      "-in", public_key.name, "-noout", "-modulus")
    return int(modulus.removeprefix("Modulus="), 16)


def kms_sign(key_id: str, digest: bytes) -> int:
    with tempfile.NamedTemporaryFile() as message:
        message.write(digest)
        message.flush()
        signature = run(
            "aws", "kms", "sign", "--key-id", key_id,
            "--message", f"fileb://{message.name}", "--message-type", "DIGEST",
            "--signing-algorithm", "RSASSA_PKCS1_V1_5_SHA_512",
            "--query", "Signature", "--output", "text",
        )
    return int.from_bytes(base64.b64decode(signature), "big")


def public_key_packet(data: bytes) -> bytes:
    """Body of the leading public key packet of a binary or armored key file."""
    if data.startswith(b"-----BEGIN"):
        lines = data.decode().splitlines()
        start = lines.index("") + 1
        end = next(i for i, line in enumerate(lines) if line.startswith(("=", "-----END")))
        data = base64.b64decode("".join(lines[start:end]))
    first = data[0]
    if first & 0x40:
        tag = first & 0x3F
        if data[1] < 192:
            length, start = data[1], 2
        elif data[1] < 224:
            length, start = ((data[1] - 192) << 8) + data[2] + 192, 3
        else:
            length, start = struct.unpack_from(">I", data, 2)[0], 6
    else:
        tag = (first >> 2) & 0x0F
        size = 1 << (first & 0x03)
        length, start = int.from_bytes(data[1 : 1 + size], "big"), 1 + size
    body = data[start : start + length]
    if tag != 6 or body[0] != 4 or body[5] != RSA:
        sys.exit("The public key file must start with a version 4 RSA key")
    return body


def mpi(value: int) -> bytes:
    return struct.pack(">H", value.bit_length()) + value.to_bytes((value.bit_length() + 7) // 8, "big")


def subpacket(kind: int, data: bytes) -> bytes:
    return bytes([len(data) + 1, kind]) + data


def main() -> None:
    if len(sys.argv) < 4:
        sys.exit(__doc__)
    key_id, public_key_file, *files = sys.argv[1:]

    key = public_key_packet(Path(public_key_file).read_bytes())
    bits = struct.unpack_from(">H", key, 6)[0]
    modulus = int.from_bytes(key[8 : 8 + (bits + 7) // 8], "big")
    # A signature from another key would carry this key's fingerprint and fail for every user
    if modulus != kms_modulus(key_id):
        sys.exit(f"KMS key {key_id} is not the key in {public_key_file}")
    fingerprint = hashlib.sha1(b"\x99" + struct.pack(">H", len(key)) + key).digest()

    for name in files:
        hasher = hashlib.sha512()
        with open(name, "rb") as stream:
            while chunk := stream.read(1 << 20):
                hasher.update(chunk)
        hashed = subpacket(33, b"\x04" + fingerprint) + subpacket(2, struct.pack(">I", int(time.time())))
        header = bytes([4, BINARY_DOCUMENT, RSA, SHA512]) + struct.pack(">H", len(hashed)) + hashed
        hasher.update(header + b"\x04\xff" + struct.pack(">I", len(header)))
        digest = hasher.digest()
        unhashed = subpacket(16, fingerprint[-8:])
        body = (header + struct.pack(">H", len(unhashed)) + unhashed + digest[:2]
                + mpi(kms_sign(key_id, digest)))
        Path(name + ".sig").write_bytes(bytes([0xC2, 0xFF]) + struct.pack(">I", len(body)) + body)
        print(f"Signed {name} with KMS key {key_id}, fingerprint {fingerprint.hex().upper()}")


if __name__ == "__main__":
    main()
