// Copyright Maxwell Elliott. All rights reserved.

// This file is part of rules_swift_simple. Use of this source code is governed by
// the 3-clause BSD license that can be found in the LICENSE.txt file.

import list_data_lib

for path in ListData.listFiles() {
	print(path)
}
