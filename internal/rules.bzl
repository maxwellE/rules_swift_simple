# Copyright Maxwell Elliott. All rights reserved.

# This file is part of rules_swift_simple. Use of this source code is governed by
# the 3-clause BSD license that can be found in the LICENSE.txt file.

"""Rules for building Swift programs.
Rules take a description of something to build (for example, the sources and
dependencies of a library) and create a plan of how to build it (output files,
actions).
"""

def _swift_binary_impl(ctx):
    # EXERCISE: declare output file, call swift_compile, swift_link to create
    # actions, return DefaultInfo.
    pass

# Declare the swift_binary rule. This statement is evaluated during the loading
# phase when this file is loaded. The function body above is evaluated only
# during the analysis phase.
swift_binary = None
