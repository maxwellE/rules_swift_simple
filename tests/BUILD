load("//:def.bzl", "swift_binary", "swift_library")

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

sh_test(
    name = "bin_with_libs_test",
    srcs = ["bin_with_libs_test.sh"],
    args = ["$(location :bin_with_libs)"],
    data = [":bin_with_libs"],
)

swift_binary(
    name = "bin_with_libs",
    srcs = ["bin_with_libs.swift"],
    deps = [":foo"],
)

swift_library(
    name = "foo",
    srcs = ["foo.swift"],
    deps = [
        ":bar",
        ":baz",
    ],
)

swift_library(
    name = "bar",
    srcs = ["bar.swift"],
    deps = [":baz"],
)

swift_library(
    name = "baz",
    srcs = ["baz.swift"],
)

sh_test(
    name = "data_test",
    srcs = ["data_test.sh"],
    args = ["$(location :list_data_bin)"],
    data = [":list_data_bin"],
)

swift_binary(
    name = "list_data_bin",
    srcs = ["list_data_bin.swift"],
    data = ["foo.txt"],
    deps = [":list_data_lib"],
)

swift_library(
    name = "list_data_lib",
    srcs = ["list_data_lib.swift"],
    data = ["bar.txt"],
)
