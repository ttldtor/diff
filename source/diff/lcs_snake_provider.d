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
            isForward      = If set to `true` a forward comparison will be done; else a backward comparison
            delta          = The difference in length between the first and second object to compare. This value is used as an
                             offset between the forward k lines to the reverse ones (DELTA)
            v              = An array of end points for a given k-line
            d              = Number of differences for the same trace

        Returns: The new snake that represents LCS or error
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
}

