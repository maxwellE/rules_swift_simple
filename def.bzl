# Copyright Maxwell Elliott. All rights reserved.

# This file is part of rules_swift_simple. Use of this source code is governed by
# the 3-clause BSD license that can be found in the LICENSE.txt file.

"""def.bzl contains public definitions for rules_swift_simple.
These definitions may be used by Bazel projects for building Swift programs.
These definitions should be loaded from here, not any internal directory.
Internal definitions may change without notice.
"""

load(
    "//internal:rules.bzl",
    _swift_binary = "swift_binary",
    _swift_library = "swift_library",
)
load(
    "//internal:providers.bzl",
    _SwiftLibraryInfo = "SwiftLibraryInfo",
)

swift_binary = _swift_binary
swift_library = _swift_library
SwiftLibraryInfo = _SwiftLibraryInfo
