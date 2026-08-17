## 0.2.1-wip

### API changes

* `DartFormatter.lineEnding` is no longer mutable. If no line ending is
  provided, then a line ending is inferred from the source as usual, but the
  result is not stored back in the `lineEnding` field. Instead, accessing
  `lineEnding` always returns the value you passed in the constructor.

  This means you can use the same `DartFormatter` instance to format code with
  different line endings by not providing an explicit line ending. Each call
  to `format()` will infer a separate line ending for only that call's code
  (#1337).

  The setter for `lineEnding` is still available but is marked deprecated and
  does nothing. This is technically a **breaking change**, but I believe no code
  in the wild is affected by it. To be affected by the setter doing nothing,
  code would have to call the setter and then call `format()`, or call the
  `lineEnding` getter. I haven't found any code on pub that sets or gets
  `lineEnding`, so I suspect this change is harmless. In a future major version
  release, the setter will be removed.

## 0.2.0

* Synchronized with upstream `dart_style` (up to version 3.1.12 / Dart 3.13 formatting rules), incorporating:
  * Support for Analyzer `14.x.x` and `package_config` `3.x.x`.
  * Support for Dart 3.13 tall style features (such as block-formatting parameter lists, `as`/`is` expressions, and guard clauses).
  * Various upstream bug fixes and formatting improvements.
* Fully updated and verified all tab-indentation test expectations and CLI options to correctly support the SmartTabs strategy.

## 0.1.2

* Require `analyzer: ^13.0.0`.
* Show the supported language versions in `dart format --version --verbose`.

### Internal changes

* Allow package_config version 3 (#1876).
* Migrate off grinder.
* Allow analyzer version 14.

### Bug fixes

* Don't crash if an `analysis_options.yaml` file has an `include` that points to
  a non-existent or unreadable file (#1840).

### Style changes

The following minor style bug fixes are not language versioned and apply to all
formatted code:

* Fix a bug in eager splitting optimization that in rare cases would lead to a
  collection or argument list splitting unnecessarily (#1809).

* Don't add a blank line before a comment at the end of a compilation unit or
  braced body (#1644).

  If you have already formatted code using dart_style that encounters this bug,
  then reformatting it even after this fix will have no effect since the
  unneeded blank line was already added.

The following changes only apply when formatting code at language version 3.13
or higher:

* Fix a bug in an eager splitting optimization that would lead the formatter to
  prefer less desirable solutions (#1847).

  Typically, the code affected by this bug is a call chain that contains an
  argument list with a large collection literal, as in:

  ```dart
  // Before:
  await MethodChannelContainer()
      .onMethodChannelInvoke("reportCrash", <String, dynamic>{
        "time": nowTime,
        "errorValue": errorName,
        "reason": reason,
        "stacktrace": stacktrace,
      });

  // After:
  await MethodChannelContainer().onMethodChannelInvoke(
    "reportCrash",
    <String, dynamic>{
      "time": nowTime,
      "errorValue": errorName,
      "reason": reason,
      "stacktrace": stacktrace,
    },
  );
  ```

* Prefer to split call chains for single-element targets (#1732).

  When formatting a method call chain whose target can also split, the formatter
  must decide whether to split the target or the call chain (or both). For
  example:

  ```dart
  // Split target:
  function(
    argument,
  ).method().another();

  // Or split chain:
  function(argument)
      .method()
      .another();
  ```

  We've tried various heuristics for this over the years but most make some code
  look better while making other code look worse. This version introduces a
  relatively simple rule that seems to work well in practice: If the call chain
  target has only one element or argument, then prefer to split the call chain
  and keep the target together. So in the above example, if prefers the second
  output.

* Allow block formatting parameter lists (#1693). The formatter supports
  "block formatting" for most bracket-delimited constructs in the language. This
  is what enables a multi-line list literal in an assignment to look like this:

  ```dart
  variable = [
    some,
    list,
    elements,
  ];
  ```

  Instead of:

  ```dart
  variable =
      [
        some,
        list,
        elements,
      ];
  ```

  This style applies to most language constructs, but function parameter lists
  were omitted. Now they are not. This rarely shows up in real code, except for
  typedefs of large function types:

  ```dart
  // Before:
  typedef DataViewBuilder<T> =
      Widget Function(
        BuildContext context,
        PagingState<int, T> state,
        NextPageCallback fetchNextPage,
      );
  // After:
  typedef DataViewBuilder<T> = Widget Function(
    BuildContext context,
    PagingState<int, T> state,
    NextPageCallback fetchNextPage,
  );
  ```

* Allow `as`, `is`, and `is!` expressions to be block formatted (#1542).

  ```dart
  // Before:
  variable =
      function(
            argument,
            argument,
            argument,
          )
          as Type;
  // After:
  variable = function(
    argument,
    argument,
    argument,
  ) as Type;
  ```

* Separate imports into sections (#1120). Following the guidelines in
  ["Effective Dart"][sections], the formatter inserts a blank line between
  "dart:", "package:", and other imports:

  ```dart
  // Before:
  import 'dart:io';
  import 'dart:math';
  import 'package:args/args.dart';
  import 'package:test/test.dart';
  import 'my_library.dart';

  // After:
  import 'dart:io';
  import 'dart:math';

  import 'package:args/args.dart';
  import 'package:test/test.dart';

  import 'my_library.dart';
  ```

[sections]: https://dart.dev/effective-dart/style#ordering

* In if-case statements and elements, split the guard if the pattern
  block-splits (#1596).

  This tends to lead to code where the pattern is kept on one line and the
  guard splits:

  ```dart
  // Before:
  if (expression case SomeClass(
    property: var x,
  ) when guardClause(x)) {
    ...
  }

  // After:
  if (expression case SomeClass(property: var x)
      when guardClause(x)) {
    ...
  }
  ```

* When no solution fits the page width, prefer solutions where the overflowing
  lines have trailing string literals or comments (#1802, #1803, #1837).

  Sometimes the formatter is unable to split the code in a way that fits it all
  within the page width. When this happens, the formatter prefers whatever
  solution has the fewest overflowing characters.

  In practice, overflowing solutions are usually caused by long string literals
  or comments that the user should split manually. To help the user do that, the
  formatter now treats overflowing characters caused by trailing string
  literals, comments, and a few other things that often follow a string literal
  like `,`, `;`, `() {`, or `() async {`, as "less bad" when comparing the
  amount of overflow between two solutions.

  The effect is that when no solution fits, the formatter tends to prefer a
  solution with hanging strings or comments, which makes it clearer to the user
  which code they need to go back and manually split.

  ```dart
  main() {
    a() {
      ;
    }
    // Comment 1.
    b() {
      ;
    }
    // Comment 2.
  }
  ```

  Prior to Dart 3.13, extension type representation clauses didn't allow
  trailing commas even though they syntactically appear like formal parameter
  lists. In Dart 3.13, that was fixed, so now the formatter formats them the
  same way as other parameter lists in primary constructors.

  ```dart
  main() {
    a() {
      ;
    }
    // Comment 1.
    b() {
      ;
    }
    // Comment 2.
  }
  ```

  Note how a blank line was added above `// Comment 2.` but not `// Comment 1.`.
  Now, it won't add a blank line before the last comment.

## 0.1.1
Added configurable tabWidth support

## 0.1.0

Initial release of fart_style.
