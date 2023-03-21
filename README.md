# rules_swift_simple

A simple set of Swift rules for Bazel, used for learning and experimentation.

The rules are divided into versions (v1, v2, etc.). Each version builds
upon the last and includes all the functionality of the previous
versions.

* **[v1](https://github.com/maxwellE/rules_swift_simple/tree/v1)**: A minimal
  example of a rule that produces an executable ([`swift_binary`](https://github.com/bazelbuild/rules_swift/blob/master/doc/rules.md#swift_binary)).
* **[v2](https://github.com/maxwellE/rules_swift_simple/tree/v2)**: Adds a small
  rule that produces a library ([`swift_library`](https://github.com/bazelbuild/rules_swift/blob/master/doc/rules.md#swift_library)).
* **[v3](https://github.com/maxwellE/rules_swift_simple/tree/v3)**: Adds a `data`
  attribute.
