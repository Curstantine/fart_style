// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// SmartTabs indentation utilities.
///
/// This module implements "SmartTabs" style indentation:
/// - **Tabs** are used for block-level indentation (semantic nesting)
/// - **Spaces** are used for alignment (expression wrapping, initializers, etc.)
///
/// This separation allows users to configure their editor's tab width without
/// breaking alignment.
library;

/// The visual width of a tab character for line-length calculations.
///
/// This is used when calculating whether a line exceeds the page width.
/// The actual display width depends on the user's editor settings.
const int tabWidth = 4;

/// Represents an indentation level with separate tab and space counts.
///
/// Use [tabs] for block-level indentation and [spaces] for alignment.
final class Indentation {
	/// The number of tab characters for block indentation.
	final int tabs;

	/// The number of space characters for alignment.
	final int spaces;

	const Indentation(this.tabs, this.spaces);

	/// No indentation.
	static const none = Indentation(0, 0);

	/// Creates an indentation with only tabs.
	const Indentation.tabs(this.tabs) : spaces = 0;

	/// Creates an indentation with only spaces (for alignment).
	const Indentation.spaces(this.spaces) : tabs = 0;

	/// The visual width of this indentation for line-length calculations.
	int get visualWidth => tabs * tabWidth + spaces;

	/// Generates the output string: tabs followed by spaces.
	String toOutput() => '\t' * tabs + ' ' * spaces;

	/// Creates a new indentation by adding [other] to this one.
	Indentation operator +(Indentation other) =>
	    Indentation(tabs + other.tabs, spaces + other.spaces);

	/// Creates a new indentation with additional tabs.
	Indentation addTabs(int count) => Indentation(tabs + count, spaces);

	/// Creates a new indentation with additional spaces.
	Indentation addSpaces(int count) => Indentation(tabs, spaces + count);

	@override
	bool operator ==(Object other) =>
	    other is Indentation && tabs == other.tabs && spaces == other.spaces;

	@override
	int get hashCode => Object.hash(tabs, spaces);

	@override
	String toString() => 'Indentation(tabs: $tabs, spaces: $spaces)';
}

/// Generates an indentation string with [tabs] tab characters followed by
/// [spaces] space characters.
String indent(int tabs, int spaces) => '\t' * tabs + ' ' * spaces;

/// Calculates the visual width of an indentation for line-length calculations.
int visualWidth(int tabs, int spaces) => tabs * tabWidth + spaces;

/// Pre-calculated indentation strings for common tab counts.
///
/// These are generated ahead of time for performance, similar to how the
/// original code pre-calculated space strings.
const Map<int, String> _tabIndents = {
	0: '',
	1: '\t',
	2: '\t\t',
	3: '\t\t\t',
	4: '\t\t\t\t',
	5: '\t\t\t\t\t',
	6: '\t\t\t\t\t\t',
	7: '\t\t\t\t\t\t\t',
	8: '\t\t\t\t\t\t\t\t',
	9: '\t\t\t\t\t\t\t\t\t',
	10: '\t\t\t\t\t\t\t\t\t\t',
	11: '\t\t\t\t\t\t\t\t\t\t\t',
	12: '\t\t\t\t\t\t\t\t\t\t\t\t',
	13: '\t\t\t\t\t\t\t\t\t\t\t\t\t',
	14: '\t\t\t\t\t\t\t\t\t\t\t\t\t\t',
	15: '\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t',
};

/// Pre-calculated space strings for common alignment widths.
const Map<int, String> _spaceAligns = {
	0: '',
	1: ' ',
	2: '  ',
	3: '   ',
	4: '    ',
	5: '     ',
	6: '      ',
	7: '       ',
	8: '        ',
	9: '         ',
	10: '          ',
	11: '           ',
	12: '            ',
	13: '             ',
	14: '              ',
	15: '               ',
	16: '                ',
};

/// Returns the indentation string for [tabs] tabs and [spaces] alignment spaces.
///
/// Uses pre-calculated strings for common values for performance.
String getIndent(int tabs, int spaces) {
	var tabPart = _tabIndents[tabs] ?? ('\t' * tabs);
	var spacePart = _spaceAligns[spaces] ?? (' ' * spaces);
	return tabPart + spacePart;
}

/// Returns a string of [count] tab characters.
String getTabs(int count) => _tabIndents[count] ?? ('\t' * count);

/// Returns a string of [count] space characters.
String getSpaces(int count) => _spaceAligns[count] ?? (' ' * count);
