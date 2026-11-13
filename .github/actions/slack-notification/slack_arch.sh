#!/bin/bash

# shellcheck source=SCRIPTDIR/../common/func.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/../common/func.sh"

source_helper_file slack.sh

# Reads the uploaded packages JSON ({repo: {arch: [file, ...]}}) from stdin.
# Parameters: channel, release_tag, url_prefix, footer, env, slack_thread_ts (optional)
slack_format_success_message() {
    local channel=$1
    local release_tag=$2
    local url_prefix=$3
    local footer=$4
    local env=$5
    local slack_thread_ts=$6

    jq --arg channel "$channel" --arg release_tag "$release_tag" --arg url_prefix "$url_prefix" \
        --arg footer "$footer" --arg env "$env" --arg slack_thread_ts "$slack_thread_ts" '
        {
            channel: $channel,
            icon_emoji: ":redis-circle:",
            text: (":package: Arch Linux Packages Published for Redis: " + $release_tag + " (" + $env + ")"),
            blocks: (
                [
                    {
                        type: "header",
                        text: { type: "plain_text", text: (":package: Arch Linux Packages Published for Release " + $release_tag + " (" + $env + ")") }
                    },
                    {
                        type: "section",
                        text: { type: "mrkdwn", text: "The following packages have been published:" }
                    }
                ] +
                [
                    to_entries[] | .key as $repo | .value | to_entries[] | .key as $arch |
                    {
                        type: "section",
                        text: {
                            type: "mrkdwn",
                            text: (
                                "Repository: *[" + $repo + "]* (" + $arch + ")\n" +
                                (.value | map("• <" + $url_prefix + "/" + $arch + "/" + . + "|" + . + ">") | join("\n"))
                            )
                        }
                    }
                ] +
                [
                    {
                        type: "context",
                        elements: [ { type: "mrkdwn", text: $footer } ]
                    }
                ]
            )
        } | if $slack_thread_ts != "" then . + {thread_ts: $slack_thread_ts} else . end
        '
}

# Parameters: channel, header, workflow_url, footer, slack_thread_ts (optional)
slack_format_failure_message() {
    local channel=$1
    local header=${2:- }
    local workflow_url=$3
    local footer=${4:- }
    local slack_thread_ts=$5

    jq -n --arg channel "$channel" --arg header "$header" --arg workflow_url "$workflow_url" \
        --arg footer "$footer" --arg slack_thread_ts "$slack_thread_ts" '
        {
            channel: $channel,
            icon_emoji: ":redis-circle:",
            text: $header,
            blocks: [
                {
                    type: "header",
                    text: { type: "plain_text", text: ("❌  " + $header) }
                },
                {
                    type: "section",
                    text: { type: "mrkdwn", text: ("Workflow run: " + $workflow_url) }
                },
                {
                    type: "context",
                    elements: [ { type: "mrkdwn", text: $footer } ]
                }
            ]
        } | if $slack_thread_ts != "" then . + {thread_ts: $slack_thread_ts} else . end
        '
}

# Parameters: channel, message, slack_thread_ts (optional)
slack_format_simple_msg() {
    local channel=$1
    local message=$2
    local slack_thread_ts=$3

    jq -n --arg channel "$channel" --arg text "$message" --arg slack_thread_ts "$slack_thread_ts" '
        {
            channel: $channel,
            text: $text
        } | if $slack_thread_ts != "" then . + {thread_ts: $slack_thread_ts} else . end
        '
}
