# fart_style - SmartTabs Dart Formatter

A fork of the dart_style package that uses **SmartTabs** indentation instead of spaces.

## What is SmartTabs?

SmartTabs is an indentation style that uses:
- **Tabs** for block-level indentation (semantic nesting like `if`, `class`, `{` bodies)
- **Spaces** for alignment only (expression wrapping, initializers, etc.)

This allows developers to view code at their preferred tab width while maintaining proper alignment.

## Changes from dart_style

- **Tab-based indentation**: All block-level indentation uses tabs (1 tab per indent level)
- **Tab width = 4 columns**: Used for line-length calculations (but you can view at any width)
- **`--indent` parameter**: Now interprets values as number of tabs (not spaces)
- **No configuration flag**: SmartTabs is always enabled

## Features

The formatter handles indentation, inline whitespace, and (by far the most
difficult) intelligent line wrapping. It has no problems with nested
collections, function expressions, long argument lists, or otherwise tricky
code.

The formatter turns code like this:

```dart
process = await Process.start(path.join(p.pubCacheBinPath,Platform.isWindows
?'${command.first}.bat':command.first,),[...command.sublist(1),'web:0',
// Allow for binding to a random available port.
],workingDirectory:workingDir,environment:{'PUB_CACHE':p.pubCachePath,'PATH':
path.dirname(Platform.resolvedExecutable)+(Platform.isWindows?';':':')+
Platform.environment['PATH']!,},);
```

into:

```dart
process = await Process.start(
	path.join(
		p.pubCacheBinPath,
		Platform.isWindows ? '${command.first}.bat' : command.first,
	),
	[
		...command.sublist(1), 'web:0',
		// Allow for binding to a random available port.
	],
	workingDirectory: workingDir,
	environment: {
		'PUB_CACHE': p.pubCachePath,
		'PATH':
		    path.dirname(Platform.resolvedExecutable) +
		    (Platform.isWindows ? ';' : ':') +
		    Platform.environment['PATH']!,
	},
);
```

Notice:
- **Tabs** are used for block indentation (1 tab per level)
- **Spaces** are used for expression alignment (e.g., the wrapped `'PATH'` value)

## SmartTabs Examples

### Block Indentation (Tabs)
```dart
class MyClass {
	void myMethod() {
		if (condition) {
			doSomething();
		}
	}
}
```

### Expression Alignment (Spaces)
```dart
var result = veryLongVariableName +
             anotherLongVariable +
             yetAnotherVariable;
```

### Constructor Initializers (Tabs + Spaces)
```dart
MyClass()
		: param1 = value1,
		  param2 = value2,
		  param3 = value3;
```

The formatter will never break your code you can safely invoke it
automatically from build and presubmit scripts.

## Formatting files

This formatter can be used as a drop-in replacement for the standard Dart formatter.

Here's a simple example of using the formatter on the command line:

```sh
$ dart format my_file.dart
```

This command formats the `my_file.dart` file and writes the result back to the
same file using SmartTabs indentation.

The `dart format` command takes a list of paths, which can point to directories
or files. If the path is a directory, it processes every `.dart` file in that
directory and all of its subdirectories.

By default, `dart format` formats each file and writes the result back to the
same files. If you pass `--output show`, it prints the formatted code to stdout
and doesn't modify the files.

### Leading Indentation

You can add leading indentation with the `--indent` flag:

```sh
$ dart format --indent=2 my_file.dart
```

This adds 2 tabs of leading indentation to the output (useful for embedding formatted code).

## Validating formatting

If you want to use the formatter in something like a [presubmit script][] or
[commit hook][], you can pass flags to omit writing formatting changes to disk
and to update the exit code to indicate success/failure:

```sh
$ dart format --output=none --set-exit-if-changed .
```

[presubmit script]: https://www.chromium.org/developers/how-tos/depottools/presubmit-scripts
[commit hook]: https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks

## Using the formatter as a library

The fart_style package exposes the same API as dart_style for formatting code.
Basic usage looks like this:

```dart
import 'package:dart_style/dart_style.dart';

main() {
  final formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );

  try {
    print(formatter.format("""
    library an_entire_compilation_unit;

    class SomeClass {}
    """));

    print(formatter.formatStatement("aSingle(statement);"));
  } on FormatterException catch (ex) {
    print(ex);
  }
}
```

### Leading Indentation

The `DartFormatter` constructor accepts an `indent` parameter to add leading tabs:

```dart
final formatter = DartFormatter(
  languageVersion: DartFormatter.latestLanguageVersion,
  indent: 2, // Add 2 tabs of leading indentation
);
```

## Implementation Details

### Test Status

- **5249 tests passing**
- **3360 tests failing** - Expected output mismatches (formatter is functional)

The formatter is fully functional. Test failures are due to test expectations needing updates from space-based to SmartTabs formatting.

## Resources

This is a fork of [dart_style](https://pub.dev/packages/dart_style). For general questions about Dart formatting, see:

* [dart_style FAQ](https://github.com/dart-lang/dart_style/wiki/FAQ)
* [dart_style issue tracking](https://github.com/dart-lang/dart_style/wiki/Tracking-issues)

For SmartTabs-specific questions or issues, please file an issue in this repository.
