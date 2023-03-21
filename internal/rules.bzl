# Copyright Maxwell Elliott. All rights reserved.

# This file is part of rules_swift_simple. Use of this source code is governed by
# the 3-clause BSD license that can be found in the LICENSE.txt file.

"""Rules for building Swift programs.
Rules take a description of something to build (for example, the sources and
dependencies of a library) and create a plan of how to build it (output files,
actions).
"""

load(":actions.bzl", "swift_compile", "swift_link")
load("@bazel_skylib//lib:dicts.bzl", "dicts")
load(
    "@build_bazel_apple_support//lib:apple_support.bzl",
    "apple_support",
)

def _swift_binary_impl(ctx):
    # Declare an output file for the main package and compile it from srcs. All
    # our output files will start with a prefix to avoid conflicting with
    # other rules.
    prefix = ctx.label.name + "%/"
    main_archive = ctx.actions.declare_file(prefix + "main.a")
    swift_compile(
        ctx,
        srcs = ctx.files.srcs,
        out = main_archive,
    )

    # Declare an output file for the executable and link it. Note that output
    # files may not have the same name as the rule, so we still need to use the
    # prefix here.
    executable = ctx.actions.declare_file(prefix + ctx.label.name)
    swift_link(
        ctx,
        main = main_archive,
        out = executable,
    )

    # Return the DefaultInfo provider. This tells Bazel what files should be
    # built when someone asks to build a swift_binary rules. It also says which
    # one is executable (in this case, there's only one).
    return [DefaultInfo(
        files = depset([executable]),
        executable = executable,
    )]

# Declare the swift_binary rule. This statement is evaluated during the loading
# phase when this file is loaded. The function body above is evaluated only
# during the analysis phase.
swift_binary = rule(
    implementation = _swift_binary_impl,
    attrs = dicts.add(apple_support.action_required_attrs(), {
        "srcs": attr.label_list(
            allow_files = [".swift"],
            doc = "Source files to compile for the main package of this binary",
        ),
    }),
    doc = "Builds an executable program from Swift source code",
    executable = True,
    fragments = ["apple"],
)
