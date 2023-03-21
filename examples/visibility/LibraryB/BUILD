load(
    "//:def.bzl",
    "swift_library",
)

swift_library(
    name = "LibraryB",
    srcs = [
        "LibraryB.swift",
    ],
    visibility = [
        "//examples/visibility/LibraryA:__pkg__",
    ],
)
