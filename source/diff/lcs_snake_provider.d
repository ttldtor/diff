/**
    LCS (longest common subsequence) snake provider

    Authors: ttldtor
    Copyright: © 2019-2021 ttldtor
    License: Subject to the terms of the BSL-1.0 license, as written in the included LICENSE file.
 */

module diff.lcs_snake_provider;

import diff.v;
import diff.snake;
import diff.snake_pair;
import expected;
import std.typecons;

/**
    Utility class that provides functions to calculate the longest common subsequence (LCS) for forward, backward and 
    in-between estimations.
 
    Params:
        T = The type of the element the snakes will hold
 */
final class LcsSnakeProvider(T) {

    /**
        Calculates the longest common subsequence (LCS) in a forward manner for two objects.

        Params:
            SourceRange    = The source range type
            DestRange      = The destination range type
            source         = Elements of the first object. Usually the original object
            sourceSize     = The index of the last element from the first object to compare
            dest           = Elements of the second object. Usually the current object
            destSize       = The index of the last element from the second object to compare
            v              = An array of end points for a given k-line
            d              = Number of differences for the same trace

        Returns: The new snake that represents LCS or an error
     */
    Expected!(Snake!T, string) forward(SourceRange, DestRange)(SourceRange source, int sourceSize, DestRange dest, 
        int destSize, V!T v, int d)
        if (isRandomAccessRange!SourceRange && isRandomAccessRange!DestRange 
            && (is(ElementType!SourceRange.init == ElementType!DestRange.init)))
    {
        for (int k = -d; k <= d; k += 2) {
            auto down = (k == -d || (k != d && v[k - 1] < v[k + 1]));
            auto xStart = down ? v[k + 1] : v[k - 1];
            auto yStart = xStart - (down ? k + 1 : k - 1);
            auto xEnd = down ? xStart : xStart + 1;
            auto yEnd = xEnd - k;
            auto diagonalLength = 0;

            while (xEnd < sourceSize && yEnd < destSize && source[xEnd] == dest[yEnd]) {
                xEnd++;
                yEnd++;
                diagonalLength++;
            }
            
            v[k] = xEnd;
            
            if (xEnd >= sourceSize && yEnd >= destSize) {
                return ok(new Snake!T(0, sourceSize, 0, destSize, true, xStart, yStart, down, diagonalLength));
            }
        }

        return err!(Snake!T)("LcsSnakeProvider!T.forward: Can't create a snake");
    }

    /**
        Calculates the longest common subsequence (LCS) in a backward manner for two objects.

        Params:
            SourceRange    = The source range type
            DestRange      = The destination range type
            source         = Elements of the first object. Usually the original object
            sourceSize     = The index of the last element from the first object to compare
            dest           = Elements of the second object. Usually the current object
            destSize       = The index of the last element from the second object to compare
            v              = An array of end points for a given k-line
            d              = Number of differences for the same trace

        Returns: The new snake that represents LCS or an error
     */
    Expected!(Snake!T, string) reverse(SourceRange, DestRange)(SourceRange source, int sourceSize, DestRange dest, 
        int destSize, V!T v, int d)
        if (isRandomAccessRange!SourceRange && isRandomAccessRange!DestRange 
            && (is(ElementType!SourceRange.init == ElementType!DestRange.init)))
    {
        const deltaSize = sourceSize - destSize;

        for (auto k = -d + deltaSize; k <= d + deltaSize; k += 2) {
            auto up = (k == d + deltaSize || (k != -d + deltaSize && v[k - 1] < v[k + 1]));
            auto xStart = up ? v[k - 1] : v[k + 1];
            auto yStart = xStart - (up ? k - 1 : k + 1);
            auto xEnd = up ? xStart : xStart - 1;
            auto yEnd = xEnd - k;
            auto diagonalLength = 0;

            while (xEnd > 0 && yEnd > 0 && source[xEnd - 1] == dest[yEnd - 1]) {
                xEnd--;
                yEnd--;
                diagonalLength++;
            }
            
            v[k] = xEnd;
            
            if (xEnd <= 0 && yEnd <= 0) {
                return ok(new Snake!T(0, sourceSize, 0, destSize, false, xStart, yStart, up, diagonalLength));
            }
        }

        return err!(Snake!T)("LcsSnakeProvider!T.reverse: Can't create a snake");
    }

    /**
        Calculates the middle snake segment by comparing object $(D_PARAM source) with $(D_PARAM dest) in both directions.
        The overlap of both comparisons is the so called middle snake which is already a part of the solution as proven by Myers.

        Params:
            SourceRange    = The source range type
            DestRange      = The destination range type
            source         = Elements of the first object. Usually the original object
            sourceStartPos = The starting position in the array of elements from the first object to compare (a0)
            sourceSize     = The index of the last element from the first object to compare
            dest           = Elements of the second object. Usually the current object
            destStartPos   = The starting position in the array of elements from the second object to compare (b0)
            destSize       = The index of the last element from the second object to compare
            vForward       = An array of end points for a given k-line for the forward comparison
            vReverse       = An array of end points for a given k-line for the backward comparison
            forwardVs      = All saved end points indexed on <em>d</em> for the forward comparison
            reverseVs      = All saved end points indexed on <em>d</em> for the backward comparison

        Returns: The first segment found by both comparison directions which is also called the middle snake or an error
     */
    Expected!(SnakePair!T, string) middle(SourceRange, DestRange)(SourceRange source, int sourceStartPos, 
        int sourceSize, DestRange dest, int destStartPos, int destSize, V!T vForward, V!T vReverse, V!T[]* forwardVs, 
        V!T[]* reverseVs)
        if (isRandomAccessRange!SourceRange && isRandomAccessRange!DestRange 
            && (is(ElementType!SourceRange.init == ElementType!DestRange.init)))
    {
        const maxSize = (sourceSize + destSize + 1) / 2;
        auto deltaSize = sourceSize - destSize;

        vForward.initStub(sourceSize, destSize);
        vReverse.initStub(sourceSize, destSize);

        const deltaIsEven = (deltaSize % 2 == 0);

        for (auto d = 0; d <= maxSize; d++) {
            //forward
            {
                scope(exit) {
                    if (forwardVs !is null) {
                        auto vForwardCopyOpt = vForward.createCopy(d, true, 0);

                        if (vForwardCopyOpt.hasValue) {
                            *forwardVs ~= vForwardCopyOpt.value;
                        }
                    }
                }

                for (auto k = -d; k <= d; k += 2) {
                    const down = k == -d || (k != d && vForward[k - 1] < vForward[k + 1]);
                    const xStart = down ? vForward[k + 1] : vForward[k - 1];
                    const yStart = xStart - (down ? k + 1 : k - 1);
                    auto xEnd = down ? xStart : xStart + 1;
                    auto yEnd = xEnd - k;
                    auto diagonalLength = 0;

                    while (xEnd < sourceSize && yEnd < destSize 
                        && source[xEnd + sourceStartPos] ==  dest[yEnd + destStartPos])
                    {
                        xEnd++;
                        yEnd++;
                        diagonalLength++;
                    }

                    vForward[k] = xEnd;

                    if (deltaIsEven || k < deltaSize - (d - 1) || k > deltaSize + (d - 1)) {
                        continue;
                    }

                    if (vForward[k] < vReverse[k]) {
                        continue;
                    }

                    auto forward = new Snake!T(sourceStartPos, sourceSize, destStartPos, destSize, true, 
                        xStart + sourceStartPos, yStart + destStartPos, down, diagonalLength, d);

                    return new SnakePair!T(2 * d - 1, forward, null);
                }
            }

            //backward
            {
                scope(exit) {
                    if (reverseVs !is null) {
                        auto vReverseCopyOpt = vReverse.createCopy(d, false, deltaSize);

                        if (vReverseCopyOpt.hasValue) {
                            *reverseVs ~= vReverseCopyOpt.value;
                        }
                    }
                }

                for (auto k = -d + deltaSize; k <= d + deltaSize; k += 2) {
                    const up = k == d + deltaSize || (k != -d + deltaSize && vReverse[k - 1] < vReverse[k + 1]);
                    const xStart = up ? vReverse[k - 1] : vReverse[k + 1];
                    const yStart = xStart - (up ? k - 1 : k + 1);
                    auto xEnd = up ? xStart : xStart - 1;
                    auto yEnd = xEnd - k;
                    auto diagonalLength = 0;

                    while (xEnd > 0 && yEnd > 0
                        && source[xEnd + sourceStartPos - 1] == dest[yEnd + destStartPos - 1]) 
                    {
                        xEnd--;
                        yEnd--;
                        diagonalLength++;
                    }

                    vReverse[k] = xEnd;

                    if (!deltaIsEven || k < -d || k > d) {
                        continue;
                    }

                    if (vReverse[k] > vForward[k]) {
                        continue;
                    }

                    auto reverse = new Snake!T(sourceStartPos, sourceSize, destStartPos, destSize, false, 
                        xStart + sourceStartPos, yStart + destStartPos, up, diagonalLength, d);

                    return new SnakePair!T(2 * d, null, reverse);
                }
            }
        }

        return err!(SnakePair!T)("LcsSnakeProvider!T.middle: Can't create a snake pair");
    }  
}

