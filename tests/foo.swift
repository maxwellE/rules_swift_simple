// Copyright Maxwell Elliott. All rights reserved.

// This file is part of rules_swift_simple. Use of this source code is governed by
// the 3-clause BSD license that can be found in the LICENSE.txt file.

import bar
import baz

public enum Foo {
	public static func foo() {
		print("foo")
		Bar.bar()
		Baz.baz()
	}
}
