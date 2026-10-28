# Extend the LTO wrapper's linker settings without accumulating cached flags.
foreach(kind EXE SHARED MODULE)
  string(APPEND CMAKE_${kind}_LINKER_FLAGS " $ENV{LDFLAGS}")
endforeach()
