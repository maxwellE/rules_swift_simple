# Copyright Maxwell Elliott. All rights reserved.

# This file is part of rules_swift_simple. Use of this source code is governed by
# the 3-clause BSD license that can be found in the LICENSE.txt file.

"""Providers returned by Swift rules.

Providers are objects produced by rules, consumed by rules they depend on.
Each provider holds some metadata about the rule. For example, most rules
provide DefaultInfo, a built-in provider that contains a list of output files.
"""

SwiftLibraryInfo = provider(
    doc = "Contains information about a Swift library",
    fields = {
        "info": """A struct containing information about this library.
        Has the following fields:
            archive: The .a file compiled from the library's sources.
            swiftmodule: The .swiftmodule file compiled from the library's sources.
        """,
        "deps": "A depset of info structs for this library's dependencies",
    },
)
