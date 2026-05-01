# 0.1.2-wip

* Require `analyzer: ^13.0.0`.

* Show the supported language versions in `dart format --version --verbose`.

### Bug fixes

* Fix bug where some collections or arguments might split unnecessarily (#1809).

### Style changes

* Support block-formatting parameter lists (#1693). The formatter supports
  "block-formatting" for most bracket-delimited constructs in the language. This
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
  typedefs for large function types:

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

  This change is language versioned and only affects code at 3.13 or higher.

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

  This change is language versioned and only affects code at 3.13 or higher.

* Don't add a blank line before a comment at the end of a compilation unit or
  braced body (#1644).

  In rare cases where you have a declaration with a braced body at the end of a
  block or file and there is a comment immediately after it, the formatter would
  place a blank line before the comment. It wouldn't do that if there was any
  other code after the comment.

  For example, prior to this change, if you ran the formatter on:

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

  It would produce:

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
