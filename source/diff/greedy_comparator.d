/**
    Greedy comparator

    Authors: ttldtor
    Copyright: © 2019-2021 ttldtor
    License: Subject to the terms of the BSL-1.0 license, as written in the included LICENSE file.
 */

module diff.greedy_comparator;

import diff.snake;
import diff.snake_pair;
import diff.v;
import diff.results;
import diff.lcs_snake_provider;
import expected;
import std.range.primitives;
import std.traits;
import std.conv;
import std.format;

/**
    Greedy comparator
 
    Params:
        T = The type of the element the snakes will hold
 */
final class GreedyComparator(T) {

    /**
        Finds all snakes that lead to the solution by taking a snapshot of each end point after each iteration of d and
        then working backwards from d<sub>solution</sub> to 0.

        Params:
            R              = The source & destination range type
            snakes         = The possible solution paths for transforming object $(D_PARAM source) to $(D_PARAM dest)
            vs             = All saved end points indexed on <em>d</em>
            source         = Elements of the first object. Usually the original object
            sourceSize     = The number of elements of the first object to compare
            dest           = Elements of the second object. Usually the current object
            destSize       = The number of elements of the second object to compare

        Returns: ok() if the solution was found; Error string (err!void) otherwise

     */
    Expected!void solveForward(R)(ref Snake!T[] snakes, const ref V[] vs, R source, int sourceSize, R dest, 
        int destSize)
    if (isRandomAccessRange!R || isSomeString!R)
    in (vs.length > 0)
    {
        auto p = point(sourceSize, destSize);

        for (int d = vs.length.to!int - 1; p.x > 0 || p.y > 0; d--) {
            auto k = p.x - p.y;
            auto xEnd = vs[d][k];
            auto yEnd = xEnd - k;

            if (xEnd != p.x || yEnd != p.y) {
                return err(
                    format!"GreedyComparator!T.solveForward: No solution for d: %s, k: %s, p:(%s, %s), V:(%s, %s)"(d, k, 
                        p.x, p.y, xEnd, yEnd));
            }

            const solution = Snake!T.create(0, p.x, 0, p.y, true, 0, vs[d], k, d, source, dest);

            if (solution.xEnd != p.x || solution.yEnd != p.y) {
                return err(
                    format!"GreedyComparator!T.solveForward: Missed solution for d: %s, k: %s, p:(%s, %s), V:(%s, %s)"(
                        d, k, p.x, p.y, xEnd, yEnd));
            }

            //TODO: #1 fix the snakes' appending
            /*
            if (snakes.length == 0 || !snakes[0].append(solution)) {
                snakes = solution ~ snakes;
            }
            */
            snakes = solution ~ snakes;

            p.x = solution.xStart;
            p.y = solution.yStart;
        }

        return ok();
    }

    /**
        Finds all snakes that lead to the solution by taking a snapshot of each end point after each iteration of d and
        then working forward from 0 to d<sub>solution</sub>.

        Params:
            R              = The source & destination range type
            snakes         = The possible solution paths for transforming object $(D_PARAM source) to $(D_PARAM dest)
            vs             = All saved end points indexed on <em>d</em>
            source         = Elements of the first object. Usually the original object
            sourceSize     = The number of elements of the first object to compare
            dest           = Elements of the second object. Usually the current object
            destSize       = The number of elements of the second object to compare

        Returns: ok() if the solution was found; Error string (err!void) otherwise

     */
    Expected!void solveReverse(R)(ref Snake!T[] snakes, const ref V[] vs, R source, int sourceSize, R dest, 
        int destSize)
    if (isRandomAccessRange!R || isSomeString!R)
    in (vs.length > 0)
    {
        auto p = point(0, 0);

        for (int d = vs.length.to!int - 1; p.x < sourceSize || p.y < destSize; d--) {
            auto k = p.x - p.y;
            auto xEnd = vs[d][k];
            auto yEnd = xEnd - k;

            if (xEnd != p.x || yEnd != p.y) {
                return err(
                    format!"GreedyComparator!T.solveReverse: No solution for d: %s, k: %s, p:(%s, %s), V:(%s, %s)"(d, k, 
                        p.x, p.y, xEnd, yEnd));
            }

            const solution = Snake!T.create(p.x, sourceSize - p.x, p.y, destSize - p.y, false, sourceSize - destSize, 
                vs[d], k, d, source, dest);

            if (solution.xEnd != p.x || solution.yEnd != p.y) {
                return err(
                    format!"GreedyComparator!T.solveReverse: Missed solution for d: %s, k: %s, p:(%s, %s), V:(%s, %s)"(
                        d, k, p.x, p.y, xEnd, yEnd));
            }

            //TODO: #1 fix the snakes' appending
            /*
            if (snakes.length == 0 || !snakes[$ - 1].append(snake)) {
                snakes ~= snake;
            }
            */
            snakes ~= solution;

            p.x = solution.xStart;
            p.y = solution.yStart;
        }

        return ok();
    }
}