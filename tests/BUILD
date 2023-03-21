load("//:def.bzl", "swift_binary")

sh_test(
    name = "hello_test",
    srcs = ["hello_test.sh"],
    args = ["$(location :hello)"],
    data = [":hello"],
)

swift_binary(
    name = "hello",
    srcs = [
        "main.swift",
        "message.swift",
    ],
)
