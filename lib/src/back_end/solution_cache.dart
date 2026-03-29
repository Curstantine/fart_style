// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../indentation.dart' show tabWidth;
import '../piece/piece.dart';
import 'solution.dart';
import 'solver.dart';

/// Maintains a cache of [Piece] subtrees that have been previously solved.
///
/// If a given [Piece] has newlines before and after it, then (in most cases,
/// assuming there are no other constraints) the way it is formatted only
/// depends on its leading indentation. In that case, we can format that piece
/// using a separate Solver and insert the results in any Solution that has
/// that piece at that leading indentation.
///
/// This cache stores those previously formatted subtree pieces so that
/// [CodeWriter] can reuse them across [Solution]s.
///
/// Note that this cache is shared across all Solvers and Solutions for an
/// entire format operation. Different Solvers and Solutions may end up reaching
/// the same child Piece and wanting to format it separately with the same
/// indentation. When that happens, sharing this cache allows us to reuse that
/// cached subtree Solution.
final class SolutionCache {
	/// Whether this cache and all solutions in it use the 3.7 style solver.
	final bool is3Dot7;

	final _cache = <_Key, Solution>{};

	SolutionCache({required this.is3Dot7});

	/// Returns a previously cached solution for formatting [root] with leading
	/// indentation of [leadingTabs] tabs and [leadingSpaces] spaces (and
	/// [subsequentTabs]/[subsequentSpaces] for lines after the first) or produces
	/// a new solution, caches it, and returns it.
	///
	/// If [root] is already bound to a state in the surrounding piece tree's
	/// [Solution], then [stateIfBound] is that state. Otherwise, it is treated
	/// as unbound and the cache will find a state for [root] as well as its
	/// children.
	Solution find(
		Piece root,
		State? stateIfBound, {
		required int pageWidth,
		required int leadingTabs,
		required int leadingSpaces,
		required int subsequentTabs,
		required int subsequentSpaces,
	}) {
		// Use visual width for caching - pieces with equivalent visual indentation
		// can share cached solutions.
		var leadingVisualWidth = leadingTabs * tabWidth + leadingSpaces;
		var subsequentVisualWidth = subsequentTabs * tabWidth + subsequentSpaces;

		// See if we've already formatted this piece at this indentation. If not,
		// format it and store the result.
		return _cache.putIfAbsent(
			(root, indent: leadingVisualWidth, subsequentIndent: subsequentVisualWidth),
			() => Solver(
				this,
				pageWidth: pageWidth,
				leadingTabs: leadingTabs,
				leadingSpaces: leadingSpaces,
				subsequentTabs: subsequentTabs,
				subsequentSpaces: subsequentSpaces,
			).format(root, stateIfBound),
		);
	}
}

/// The key used to uniquely identify a previously formatted Piece.
///
/// Each subtree solution depends only on the Piece and the amount of leading
/// indentation in the context where it appears (which may vary based on how
/// surrounding pieces end up splitting).
///
/// Uses visual width for the indent so that equivalent indentations (e.g.,
/// 1 tab vs 4 spaces when tabWidth=4) share cache entries.
typedef _Key = (Piece, {int indent, int subsequentIndent});
