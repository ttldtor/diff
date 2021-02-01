/**
    Results of comaparators

    Authors: ttldtor
    Copyright: © 2019-2021 ttldtor
    License: Subject to the terms of the BSL-1.0 license, as written in the included LICENSE file.
 */

module diff.results;

import diff.v;
import diff.snake;

/**
    Utility class that provides results of comparators
 
    Params:
        T = The type of the element the snakes will hold
 */
final class Results(T) {
    private {
        Snake!T[] snakes_;
        V[] forwardVs_;
        V[] reverseVs_;
    }

    /**
        Constructs the results by snake segments, end points in forward direction and end points in backward direction

        Params:
            snakes    = The snake segments
            forwardVs = The end points in forward direction
            reverseVs = The end points in backward direction
     */
    this(Snake!T[] snakes, V[] forwardVs, V[] reverseVs) {
        snakes_ = snakes;
        forwardVs_ = forwardVs;
        reverseVs_ = reverseVs;
    }

    /**
        Constructs the results by snake segments, direction flag and end points in the specified direction

        Params:
            snakes    = The snake segments
            forward   = The direction flag. `True` - forward direction, `False` - backward direction.
            vs = The end points
     */
    this(Snake!T[] snakes, bool forward, V[] vs) {
        snakes_ = snakes;

        if (forward) {
            forwardVs_ = vs;
        } else {
            reverseVs_ = vs;
        }
    }

    @property {
        /// Returns: The snake segments
        Snake!T[] snakes() {
            return snakes_;
        }

        /// Returns: The end points in forward direction 
        V[] forwardVs() {
            return forwardVs_;
        }

        /// Returns: The end points in backward direction 
        V[] reverseVs() {
            return reverseVs_;
        }
    }

    /**
        Dumps the results of comapre (i.e. diff)

        Params:
            R      = The source & destination range type
            source = Elements of the first object. Usually the original object
            dest   = Elements of the second object. Usually the current object
     */
    void dumpResults(R)(R source, R dest) {
        import std.stdio: writefln;

        writefln("%s ~ %s", source, dest);
        foreach(s; snakes_) {
            if (s.isForward) {
                auto xStart = s.xStart;
                auto yStart = s.yStart;
                auto xEnd = s.xEnd;
                auto yEnd = s.yEnd;

                if (s.deleted > 0) {
                    writefln("- |F|%s", source[xStart .. xEnd - s.diagonalLength]);
                }

                if (s.inserted > 0) {
                    writefln("+ |F|%s", dest[yStart .. yEnd - s.diagonalLength]);
                }

                if (s.diagonalLength > 0) {
                    writefln("  |F|%s", source[xStart + s.deleted .. xEnd]);
                }
            } else {
                auto xStart = s.xEnd;
                auto yStart = s.yEnd;
                auto xEnd = s.xStart;
                auto yEnd = s.yStart;

                if (s.diagonalLength > 0) {
                    writefln("  |R|%s", source[xStart .. xEnd - s.deleted]);
                }

                if (s.deleted > 0) {
                    writefln("- |R|%s", source[xStart + s.diagonalLength .. xEnd]);
                }

                if (s.inserted > 0) {
                    writefln("+ |R|%s", dest[yStart + s.diagonalLength .. yEnd]);
                }
            }
        }
    }

    /**
        Applies the results of comapre (i.e. diff) to `source`

        Params:
            R      = The source & destination range type
            source = Elements of the first object. Usually the original object
            dest   = Elements of the second object. Usually the current object
        
        Returns: The result of applying
     */
    R applyResults(R)(R source, R dest) {
        R result;

        foreach(s; snakes_) {
            if (s.isForward) {
                if (s.inserted > 0) {
                    result ~= dest[s.yStart .. s.yEnd - s.diagonalLength];
                }

                if (s.diagonalLength > 0) {
                    result ~= source[s.xStart + s.deleted .. s.xEnd];
                }
            } else {
                if (s.diagonalLength > 0) {
                    result ~= source[s.xEnd .. s.xStart - s.deleted];
                }

                if (s.inserted > 0) {
                    result ~= dest[s.yEnd + s.diagonalLength .. s.yStart];
                }
            }
        }

        return result;
    }
}


