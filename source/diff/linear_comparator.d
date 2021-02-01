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

            //TODO: fix the snakes' appending
            /* 
            if (snakes.length == 0 || !snakes[$ - 1].append(right)) {
                snakes ~= right;
            }
            */
            snakes ~= right;
        }

        if (sourceSize == 0 && destSize > 0) {
            // Add destSize (M) insertions to SES
            auto down = new Snake!T(sourceStartPos, sourceSize, destStartPos, destSize, true, sourceStartPos, 
                destStartPos, 0, destSize, 0);

            //TODO: fix the snakes' appending
            /* 
            if (snakes.length == 0 || !snakes[$ - 1].append(down)) {
                snakes ~= down;
            }
            */
            snakes ~= down;
        }

        if (sourceSize <= 0 || destSize <= 0) {
            return ok();
        }

        // Calculate middle snake
        auto snakeProvider = new LcsSnakeProvider!T();
        auto middleOpt = snakeProvider.middle!R(source, sourceStartPos, sourceSize, dest, destStartPos, destSize, 
            vForward, vReverse, forwardVs, reverseVs);

        if (!middleOpt) {
            return err("LinearComparator!T.compare: middle snakes pair is empty");
        }

        auto middle = middleOpt.value;
        auto forward = middle.forward;
        auto reverse = middle.reverse;

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
                //TODO: fix the snakes' appending
                /* 
                if (snakes.length == 0 || !snakes[$ - 1].append(forward)) {
                    snakes ~= forward;
                }
                */
                snakes ~= forward;
            }

            if (reverse !is null) {
                //TODO: fix the snakes' appending
                /*
                if (snakes.length == 0 || !snakes[$ - 1].append(reverse)) {
                    snakes ~= reverse;
                }
                */
                snakes ~= reverse;
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
                        return err("LinearComparator!T.compare: missed D0 forward");
                    }

                    auto snake = new Snake!T(sourceStartPos, sourceSize, destStartPos, destSize, true, sourceStartPos, 
                        destStartPos, 0, 0, forward.xStart - sourceStartPos);

                    //TODO: fix the snakes' appending
                    /*
                    if (snakes.length == 0 || !snakes[$ - 1].append(snake)) {
                        snakes ~= snake;
                    }
                    */
                    snakes ~= snake;
                }

                // Add middle snake to results
                //TODO: fix the snakes' appending
                /*
                if (snakes.length == 0 || !snakes[$ - 1].append(forward)) {
                    snakes ~= forward;
                }
                */
                snakes ~= forward;
            }

            if (reverse !is null) {
                // Add middle snake to results
                //TODO: fix the snakes' appending
                /*
                if (snakes.length == 0 || !snakes[$ - 1].append(reverse)) {
                    snakes ~= reverse;
                }
                */
                snakes ~= reverse;

                // D0
                if (reverse.xStart < sourceStartPos + sourceSize) {
                    if (sourceStartPos + sourceSize - reverse.xStart != destStartPos + destSize - reverse.yStart) {
                        return err("LinearComparator!T.compare: missed D0 reverse");
                    }

                    auto snake = new Snake!T(sourceStartPos, sourceSize, destStartPos, destSize, true, reverse.xStart, 
                        reverse.yStart, 0, 0, sourceStartPos + sourceSize - reverse.xStart);

                    //TODO: fix the snakes' appending
                    /*
                    if (snakes.length == 0 || !snakes[$ - 1].append(snake)) {
                        snakes ~= snake;
                    }
                    */
                    snakes ~= snake;
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

version(unittest) {
    template TestCase(alias source, alias dest) {
        import std.format;

        enum TestCase = q{
            import std.stdio: writeln;
        } 
        ~ "auto source = " ~ source ~ ";\n"
        ~ "auto dest = " ~ dest ~ ";\n"
        ~ q{
            auto results = LinearComparatorFabric.create!string().compare(source, dest);

            assert(results.hasValue);
            assert(results.value.snakes.length > 0);

            writeln(results.value.snakes); writeln;
            results.value.dumpResults(source, dest);
            auto sourcePlusDiff = results.value.applyResults(source, dest);
            writeln(sourcePlusDiff);
            assert(sourcePlusDiff == dest);
        };
    }
}

unittest {
    mixin(TestCase!(`""`, `"1"`));
}

unittest {
    mixin(TestCase!(`"0"`, `"1"`));
}

unittest {
    mixin(TestCase!(`"abcdabcd"`, `"abcdbcdaxx"`));
}

unittest {
    mixin(TestCase!(`[0, 1, 2, 0, 0]`, `[1, 2, 0, 0, 0, 3]`));
}

unittest {
    mixin(TestCase!(`"A snake is of the same kind if both are in the same direction and if both have either a positive ADeleted field"`, 
    `"A 3534 is of the same123 kind if are the same direction and if both have either a positive 123 field"`));
}
