load(
    "//:def.bzl",
    "swift_library",
)

swift_library(
    name = "LibraryA",
    srcs = [
        "LibraryA.swift",
    ],
    deps = [
        "//examples/visibility/LibraryB",
    ],
)
