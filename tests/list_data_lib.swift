// Copyright Maxwell Elliott. All rights reserved.

// This file is part of rules_swift_simple. Use of this source code is governed by
// the 3-clause BSD license that can be found in the LICENSE.txt file.

import Foundation

public enum ListData {
	public static func listFiles() -> [String] {
		guard let pwd: String = ProcessInfo().environment["PWD"]
		else {
			return []
		}
		return findDirectoryContents(path: pwd)
	}

	private static func findDirectoryContents(path: String) -> [String] {
		guard let files: [String] = try? FileManager.default.contentsOfDirectory(atPath: path)
		else {
			return []
		}
		var childrenFiles: [String] = []
		for child in files {
			childrenFiles.append(contentsOf: findDirectoryContents(path: child))
		}
		return files + childrenFiles
	}
}
