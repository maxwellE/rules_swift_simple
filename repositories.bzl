# Copyright Maxwell Elliott. All rights reserved.

# This file is part of ruls_swift_simple. Use of this source code is governed by
# the 3-clause BSD license that can be found in the LICENSE.txt file.

"""Macro for declaring repository dependencies."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def swift_rules_dependencies():
    """ Declares external repositories that rules_swift_simple depends on.

    This function should be loaded and called from WORKSPACE of any project
    that uses rules_swift_simple.
    """

    _maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "b8a1527901774180afc798aeb28c4634bdccf19c4d98e7bdd1ce79d1fe9aaad7",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
        ],
    )

    _maybe(
        http_archive,
        name = "build_bazel_apple_support",
        sha256 = "77a121a0f5d4cd88824429464ad2bfb54bdc8a3bccdb4d31a6c846003a3f5e44",
        urls = [
            "https://github.com/bazelbuild/apple_support/releases/download/1.4.1/apple_support.1.4.1.tar.gz",
        ],
    )

def _maybe(rule, name, **kwargs):
    """Declares an external repository if it hasn't been declared already."""
    if name not in native.existing_rules():
        rule(name = name, **kwargs)
