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

def declare_archive(ctx, module_name):
    """Declares a new .a file the compiler should produce.

    .a files are consumed by the compiler (for dependency type information)
    and the linker. Both tools locate archives using lists of search paths.

    Args:
        ctx: analysis context.
        module_name: the name by which the library may be imported.
    Returns:
        A File that should be written by the compiler.
    """
    return ctx.actions.declare_file("{name}/{module_name}.a".format(
        name = ctx.label.name,
        module_name = module_name,
    ))

def declare_swiftmodule(ctx, module_name):
    """Declares a new .swiftmodule file the compiler should produce.

    .swiftmodule files are consumed by the linker for dependency
    resolution.
    Args:
        ctx: analysis context.
        module_name: the name by which the library may be imported.
    Returns:
        A File that should be written by the compiler.
    """
    return ctx.actions.declare_file("{name}/{module_name}.swiftmodule".format(
        name = ctx.label.name,
        module_name = module_name,
    ))

def swift_compile(ctx, srcs, archive, swiftmodule, is_library, deps):
    """Compiles a single Swift package from sources.

    Args:
        ctx: analysis context.
        srcs: list of source Files to be compiled.
        archive: output .a file. Should have the importpath as a suffix,
            for example, library "example.com/foo" should have the path
            "somedir/example.com/foo.a".
        swiftmodule: Output "swiftmodule" `File`.
        is_library: Controls if library based flags are provided to swift compilation
        deps: `depset` of `SwiftLibraryInfo` objects.
    """
    module_name = ctx.label.name
    _create_swiftmodule_file(ctx, swiftmodule, module_name, srcs, is_library, deps.to_list())
    _create_archive_file(ctx, archive, module_name, srcs, is_library, deps.to_list())

def swift_link(ctx, out, main, deps = []):
    """Links a Swift executable.

    Args:
        ctx: analysis context.
        out: output executable file.
        main: archive file for the main library.
        deps: depset of `SwiftLibraryInfo` objects.
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
    ])
    archive_files = [dep.archive for dep in deps.to_list()]
    if len(archive_files):
        args.add_all(archive_files)
    args.add_all([
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
        inputs = [main, static_library] + archive_files,
        outputs = [out],
        executable = "/usr/bin/ld",
        mnemonic = "SwiftLink",
        xcode_config = ctx.attr._xcode_config[apple_common.XcodeVersionConfig],
        apple_fragment = ctx.fragments.apple,
        xcode_path_resolve_level = apple_support.xcode_path_resolve_level.args,
    )

def _create_static_library(ctx, binary):
    static_library_name = paths.replace_extension(binary.basename, ".lo")
    static_library_path = paths.join("intermediates", ctx.label.name, static_library_name)
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

def _create_archive_file(ctx, archive_file, module_name, srcs, is_library, deps):
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
        "-no-serialize-debugging-options",
        "-no-clang-module-breadcrumbs",
        "-enable-bare-slash-regex",
        "-Onone",
        "-D",
        "DEBUG",
        "-framework",
        "Foundation",
        "-enable-objc-interop",
        "-empty-abi-descriptor",
        "-resource-dir",
        "__BAZEL_XCODE_DEVELOPER_DIR__/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift",
        "-module-name",
        module_name,
        "-disable-clang-spi",
        "-target-sdk-version",
        "12.3",
        "-o",
        archive_file,
        "-disable-clang-spi",
    ])
    swiftmodule_files = [dep.swiftmodule for dep in deps]
    for swiftmodule in swiftmodule_files:
        args.add_all([
            "-I",
            paths.dirname(swiftmodule.path),
        ])
    if is_library:
        args.add("-parse-as-library")
    apple_support.run(
        actions = ctx.actions,
        arguments = [args],
        inputs = srcs + swiftmodule_files,
        outputs = [archive_file],
        executable = "/usr/bin/swift",
        mnemonic = "SwiftCreateArchive",
        xcode_config = ctx.attr._xcode_config[apple_common.XcodeVersionConfig],
        apple_fragment = ctx.fragments.apple,
        xcode_path_resolve_level = apple_support.xcode_path_resolve_level.args,
    )
    return archive_file

def _create_swiftmodule_file(ctx, swiftmodule_file, module_name, srcs, is_library, deps):
    args = ctx.actions.args()
    args.add_all([
        "-frontend",
        "-emit-module",
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
        "-empty-abi-descriptor",
        "-resource-dir",
        "__BAZEL_XCODE_DEVELOPER_DIR__/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift",
        "-module-name",
        module_name,
        "-disable-clang-spi",
        "-target-sdk-version",
        "12.3",
        "-o",
        swiftmodule_file,
        "-disable-clang-spi",
        "-target-sdk-version",
        "12.3",
    ])
    swiftmodule_files = [dep.swiftmodule for dep in deps]
    for swiftmodule in swiftmodule_files:
        args.add_all([
            "-I",
            paths.dirname(swiftmodule.path),
        ])
    if is_library:
        args.add("-parse-as-library")
    apple_support.run(
        actions = ctx.actions,
        arguments = [args],
        inputs = srcs + swiftmodule_files,
        outputs = [swiftmodule_file],
        executable = "/usr/bin/swift",
        mnemonic = "SwiftCreateSwiftmodule",
        xcode_config = ctx.attr._xcode_config[apple_common.XcodeVersionConfig],
        apple_fragment = ctx.fragments.apple,
        xcode_path_resolve_level = apple_support.xcode_path_resolve_level.args,
    )
    return swiftmodule_file
