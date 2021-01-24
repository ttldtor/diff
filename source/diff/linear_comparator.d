/**
    Linear comparator

    Authors: ttldtor
    Copyright: © 2019-2021 ttldtor
    License: Subject to the terms of the BSL-1.0 license, as written in the included LICENSE file.
 */

module diff.linear_comparator;

import diff.snake;
import diff.snake_pair;
import diff.v;
import diff.results;
import diff.lcs_snake_provider;
import expected;
import std.range.primitives;
import std.traits;
import std.conv;

/**
    Linear comparator
 
    Params:
        T = The type of the element the snakes will hold
 */
final class LinearComparator(T) {

    /**
        Compares two random access ranges of type <em>T</em> with each other and calculates the shortest edit sequence (SES) as well as
        the longest common subsequence (LCS) to transfer input $(D_PARAM source) to input $(D_PARAM dest). The SES are the necessary
        actions required to perform the transformation.

        Params:
            R              = The source & destination range type
            recursion      = The number of the current recursive step
            snakes         = The possible solution paths for transforming object $(D_PARAM source) to $(D_PARAM dest)
            forwardVs      = All saved end points in forward direction indexed on <em>d</em>
            reverseVs      = All saved end points in backward direction indexed on <em>d</em>
            source         = Elements of the first object. Usually the original object
            sourceStartPos = The starting position in the array of elements from the first object to compare
            sourceSize     = The number of elements of the first object to compare
            dest           = Elements of the second object. Usually the current object
            destStartPos   = The starting position in the array of elements from the second object to compare
            destSize       = The number of elements of the second object to compare
            vForward       = An array of end points for a given k-line in forward direction
            vReverse       = An array of end points for a given k-line in backward direction

        Returns: ok() if the ranges could be compared; Error string (err!void) otherwise

     */
    Expected!void compare(R)(int recursion, ref Snake!T[] snakes, V[]* forwardVs, 
        V[]* reverseVs, R source, int sourceStartPos, int sourceSize, R dest, int destStartPos, 
        int destSize, V vForward, V vReverse)
    if (isRandomAccessRange!R || isSomeString!R)
    {
        if (destSize == 0 && sourceSize > 0) {
            // Add sourceSize (N) deletions to SES
            auto right = new Snake!T(sourceStartPos, sourceSize, destStartPos, destSize, true, sourceStartPos, 
                destStartPos, sourceSize, 0, 0);

            if (snakes.length == 0 || !snakes[$ - 1].append(right)) {
                snakes ~= right;
            }
        }

        if (sourceSize == 0 && destSize > 0) {
            // Add destSize (M) insertions to SES
            auto down = new Snake!T(sourceStartPos, sourceSize, destStartPos, destSize, true, sourceStartPos, 
                destStartPos, 0, destSize, 0);

            if (snakes.length == 0 || !snakes[$ - 1].append(down)) {
                snakes ~= down;
            }
        }

        if (sourceSize <= 0 || destSize <= 0) {
            return ok();
        }

        // Calculate middle snake
        auto snakeProvider = new LcsSnakeProvider!T();
        auto middleOpt = snakeProvider.middle!R(source, sourceStartPos, sourceSize, dest, destStartPos, destSize, 
            vForward, vReverse, forwardVs, reverseVs);

        if (!middleOpt) {
            return err!void("LinearComparator!T.compare: middle snakes pair is empty");
        }

        SnakePair!T middle = middleOpt.value;
        Snake!T forward = middle.forward;
        Snake!T reverse = middle.reverse;

        // Initial setup for recursion
        if (recursion == 0) {
            if (forward !is null) {
                forward.isMiddle = true;
            }

            if (reverse !is null) {
                reverse.isMiddle = true;
            }
        }

        // Check for edge (D = 0 or 1) or middle segment (D > 1)
        if (middle.d > 1) {
            // Solve the rectangles that remain to the top left and bottom right
            // top left .. Compare(A[1..x], x, B[1..y], y)
            auto xy = (forward !is null) ? forward.startPoint : reverse.endPoint;
            auto compareResult = compare(recursion + 1, snakes, null, null, source, sourceStartPos, 
                xy.x - sourceStartPos, dest, destStartPos, xy.y - destStartPos, vForward, vReverse);

            if (!compareResult) {
                return compareResult;
            }

            // Add middle snake to result
            if (forward !is null) {
                if (snakes.length == 0 || !snakes[$ - 1].append(forward)) {
                    snakes ~= forward;
                }
            }

            if (reverse !is null) {
                if (snakes.length == 0 || !snakes[$ - 1].append(reverse)) {
                    snakes ~= reverse;
                }
            }

            // bottom right .. Compare(A[u+1..N], N-u, B[v+1..M], M-v)
            auto uv = (reverse !is null) ? reverse.startPoint : forward.endPoint;
            compareResult = compare(recursion + 1, snakes, null, null, source, uv.x, 
                sourceStartPos + sourceSize - uv.x, dest, uv.y, destStartPos + destSize - uv.y, vForward, vReverse);

            if (!compareResult) {
                return compareResult;
            }
        } else {
            // We found an edge case. If d == 0 than both segments are identical
            // if d == 1 than there is exactly one insertion or deletion which
            // results in a odd delta and therefore a forward snake
            if (forward !is null) {
                if (forward.xStart > sourceStartPos) {
                    if (forward.xStart - sourceStartPos != forward.yStart- destStartPos) {
                        return err!void("LinearComparator!T.compare: missed D0 forward");
                    }

                    auto snake = new Snake!T(sourceStartPos, sourceSize, destStartPos, destSize, true, sourceStartPos, 
                        destStartPos, 0, 0, forward.xStart - sourceStartPos);

                    if (snakes.length == 0 || !snakes[$ - 1].append(snake)) {
                        snakes ~= snake;
                    }
                }

                // Add middle snake to results
                if (snakes.length == 0 || !snakes[$ - 1].append(forward)) {
                    snakes ~= forward;
                }
            }

            if (reverse !is null) {
                // Add middle snake to results
                if (snakes.length == 0 || !snakes[$ - 1].append(reverse)) {
                    snakes ~= reverse;
                }

                // D0
                if (reverse.xStart < sourceStartPos + sourceSize) {
                    if (sourceStartPos + sourceSize - reverse.xStart != destStartPos + destSize - reverse.yStart) {
                        return err!void("LinearComparator!T.compare: missed D0 reverse");
                    }

                    auto snake = new Snake!T(sourceStartPos, sourceSize, destStartPos, destSize, true, reverse.xStart, 
                        reverse.yStart, 0, 0, sourceStartPos + sourceSize - reverse.xStart);

                    if (snakes.length == 0 || !snakes[$ - 1].append(snake)) {
                        snakes ~= snake;
                    }
                }
            }
        }

        return ok();
    }


    /**
        Compares two random access ranges of type <em>T</em> with each other and calculates the shortest edit sequence (SES) as well as
        the longest common subsequence (LCS) to transfer input $(D_PARAM source) to input $(D_PARAM dest). The SES are the necessary
        actions required to perform the transformation.

        Params:
            R              = The source & destination range type
            source         = Elements of the first object. Usually the original object
            dest           = Elements of the second object. Usually the current object

        Returns: The result containing the snake that lead from input $(D_PARAM source) to input $(D_PARAM dest)

     */
    Expected!(Results!T) compare(R)(R source, R dest)
    if (isRandomAccessRange!R || isSomeString!R)
    {
        auto vForward = new V(source.length.to!int, dest.length.to!int, true, true);
        auto vReverse = new V(source.length.to!int, dest.length.to!int, false, true);
        Snake!T[] snakes = [];
        V[] forwardVs = [];
        V[] reverseVs = [];

        auto compareResult = compare!R(0, snakes, &forwardVs, &reverseVs, source, 0, source.length.to!int, dest, 0, 
            dest.length.to!int, vForward, vReverse);

        if (!compareResult) {
            return err!(Results!T)(compareResult.error);
        }

        return ok(new Results!T(snakes, forwardVs, reverseVs));
    }
}

/// The utility class to create linear comparators
class LinearComparatorFabric {
    /**
        Creates the linear comparator by range type

        Params:
            R = The source & destination range type

        Returns: The new linear comparator
     */
    static auto create(R)() {
        return new LinearComparator!(ElementType!R)();
    }
}

/// The helper function to create linear comparator by range type
auto linearComparator(R)() {
    return LinearComparatorFabric.create!R();
}

unittest {
    import std.stdio: writeln;
    
    auto comparator = LinearComparatorFabric.create!string();

    auto result = comparator.compare("abcdabcd", "abcdbcda");

    assert(result.hasValue);
    assert(result.value.snakes.length > 0);

    writeln(result.value.snakes);

    auto comparator2 = linearComparator!(int[])();

    auto result2 = comparator2.compare([0, 1, 2, 0, 0], [1, 2, 0, 0, 0]);

    assert(result2.hasValue);
    assert(result2.value.snakes.length > 0);

    writeln(result2.value.snakes);
}