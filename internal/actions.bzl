# Copyright Maxwell Elliott. All rights reserved.

# This file is part of rules_swift_simple. Use of this source code is governed by
# the 3-clause BSD license that can be found in the LICENSE.txt file.

"""Common functions for creating actions to build Swift programs.
Rules should determine input and output files and providers, but they should
call functions to create actions. This allows action code to be shared
by multiple rules.
"""

load(
    "@build_bazel_apple_support//lib:apple_support.bzl",
    "apple_support",
)
load("@bazel_skylib//lib:paths.bzl", "paths")

def swift_compile(ctx, srcs, out):
    """Compiles an archive .a file from Swift sources.

    Args:
        ctx: analysis context.
        srcs: list of source Files to be compiled.
        out: output .a file.
    """
    module_name = ctx.label.package.replace("/", "_")
    args = ctx.actions.args()
    args.add_all([
        "-frontend",
        "-c",
    ])
    args.add_all(srcs)
    args.add_all([
        "-target",
        "arm64-apple-macos10.15",
        "-Xllvm",
        "-aarch64-use-tbi",
        "-stack-check",
        "-sdk",
        apple_support.path_placeholders.sdkroot(),
        "-Onone",
        "-D",
        "DEBUG",
        "-framework",
        "Foundation",
        "-enable-objc-interop",
        "-resource-dir",
        "__BAZEL_XCODE_DEVELOPER_DIR__/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift",
        "-module-name",
        module_name,
        "-o",
        out,
        "-disable-clang-spi",
    ])
    apple_support.run(
        actions = ctx.actions,
        arguments = [args],
        inputs = srcs,
        outputs = [out],
        executable = "/usr/bin/swift",
        mnemonic = "SwiftCreateArchive",
        xcode_config = ctx.attr._xcode_config[apple_common.XcodeVersionConfig],
        apple_fragment = ctx.fragments.apple,
        xcode_path_resolve_level = apple_support.xcode_path_resolve_level.args,
    )

def swift_link(ctx, out, main):
    """Links a Swift executable.

    Args:
        ctx: analysis context.
        out: output executable file.
        main: archive file for the main library.
    """
    static_library = _create_static_library(ctx, main)
    args = ctx.actions.args()
    args.add_all([
        "-demangle",
        "-dynamic",
        "-syslibroot",
        apple_support.path_placeholders.sdkroot(),
        "-arch",
        "arm64",
        "-framework",
        "Foundation",
        "-ObjC",
        "-o",
        out,
        "-L__BAZEL_XCODE_DEVELOPER_DIR__/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx",
        "-L/usr/lib/swift",
        "-force_load",
        static_library,
        "-platform_version",
        "macos",
        "11.0.0",
        "12.3",
        "-lobjc",
        "-lSystem",
        "__BAZEL_XCODE_DEVELOPER_DIR__/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/14.0.0/lib/darwin/libclang_rt.osx.a",
    ])
    apple_support.run(
        actions = ctx.actions,
        arguments = [args],
        inputs = [main, static_library],
        outputs = [out],
        executable = "/usr/bin/ld",
        mnemonic = "SwiftLink",
        xcode_config = ctx.attr._xcode_config[apple_common.XcodeVersionConfig],
        apple_fragment = ctx.fragments.apple,
        xcode_path_resolve_level = apple_support.xcode_path_resolve_level.args,
    )

def _create_static_library(ctx, binary):
    static_library_name = paths.replace_extension(binary.basename, ".lo")
    static_library_path = paths.join("intermediates", static_library_name)
    static_library = ctx.actions.declare_file(static_library_path)

    args = ["/usr/bin/xcrun", "libtool", "-static", binary.path, "-o", static_library.path]

    apple_support.run_shell(
        ctx = ctx,
        command = " ".join(args),
        inputs = depset([binary]),
        mnemonic = "LibToolCreateStatic",
        outputs = [static_library],
        progress_message = "Creating static library using libtool",
    )

    return static_library
