/**
    Snake

    Authors: ttldtor
    Copyright: © 2019-2020 ttldtor
    License: Subject to the terms of the BSL-1.0 license, as written in the included LICENSE file.
*/

module diff.snake;

import diff.v;
import std.typecons;

/**
    A simple 2D point type

    Params:
        T = The type of coordinates `x` and `y`
*/
alias Point(T) = Tuple!(T, "x", T, "y");

/**
    Creates a point
*/
Point!T point(T)(T x, T y) {
    return Point!T(x, y);
}

/**
    A snake is a segment along a path which converts an object A to object B by either eliminating elements from 
    object A or inserting elements from object B.
 
    Params:
        T = The type of the element the snake will hold
 */
final class Snake(T)
{
    private
    {
        /// The x-position of a starting point
        int xStart_;

        /// The y-position of a starting point
        int yStart_;

        /// Defines the number of deleted elements from the first object to match the second object (ADeleted)
        int deleted_;

        /// Defines the number of inserted elements from the second object to match the first object (BInserted)
        int inserted_;

        /// Defines the number of equal elements in both objects
        int diagonalLength_;

        /// Defines the comparison direction of both objects
        bool isForward_ = true;

        /// The difference in length between the first and second object to compare. This value is used as an
        /// offset between the forward k lines to the reverse ones (DELTA)
        int delta_;

        /// Defines if this snake is a middle segment
        bool isMiddle_;

        /// A value of 0 or 1 indicate an edge, where 0 means both objects are equal while 1 means there is either one
        /// insertion or one deletion. A value of greater than needs to be checked in both directions
        int d_ = -1;
    }

    /**
        Removes the effects of a single insertion (down or up movement in the graph) if the x-position of the 
        starting vertex equals sourceStartPos and the y-position of the starting vertex equals the y-position of 
        $(D_PARAM destStartPos) before the insertion.

        Params:
            sourceStartPos = The starting position in the array of elements from the first object to compare (a0)
            sourceSize     = The index of the last element from the first object to compare (N)
            destStartPos   = The starting position in the array of elements from the second object to compare (b0)
            destSize       = The index of the last element from the second object to compare (M)
    */
    private void removeStubs(int sourceStartPos, int sourceSize, int destStartPos, int destSize) {
        if (inserted_ != 1) {
            return;
        }

        if (isForward_ && xStart_ == sourceStartPos && yStart_ == destStartPos - 1) {
            yStart_++;
            inserted_ = 0;
        } else if (!isForward_ && xStart_ == sourceStartPos + sourceSize && yStart_ == destStartPos + destSize + 1) {
            yStart_--;
            inserted_ = 0;
        }
    }

    /**
        Calculates a new snake segment for a forward comparison direction.

        Params:
            SourceRange    = The source range type
            DestRange      = The destination range type
            v              = An array of end points for a given k-line
            k              = The k-line the snake should get calculated for
            d              = Number of differences for the same trace
            source         = Elements of the first object. Usually the original object
            sourceStartPos = The starting position in the array of elements from the first object to compare
            sourceSize     = The index of the last element from the first object to compare
            dest           = Elements of the second object. Usually the current object
            destStartPos   = The starting position in the array of elements from the second object to compare
            destSize       = The index of the last element from the second object to compare
    */
    private void calculateForward(SourceRange, DestRange)(V!T v, int k, int d, SourceRange source, int sourceStartPos, 
        int sourceSize, DestRange dest, int destStartPos, int destSize) 
    if (isRandomAccessRange!SourceRange && isRandomAccessRange!DestRange 
        && (is(ElementType!SourceRange.init == ElementType!DestRange.init)))
    {
        const auto down = (k == -d || (k != d && v[k - 1] < v[k + 1]));
        const int xStart = down ? v[K - 1] : v[k + 1];
        const int yStart = xStart - (down ? k + 1 : k - 1);
        int xEnd = down ? xStart : xStart + 1;
        int yEnd = xEnd - k;
        int snake = 0;

        while (xEnd < sourceSize && yEnd < destSize 
            && source[(xEnd + sourceStartPos).to!size_t] == dest[(yEnd + destStartPos).to!size_t]) 
        {
            xEnd++;
            yEnd++;
            snake++;
        }

        xStart_ = xStart + sourceStartPos;
        yStart_ = yStart + destStartPos;
        deleted_ = down ? 0 : 1;
        inserted_ = down ? 1 : 0;
        diagonalLength_ = snake;

        removeStubs(sourceStartPos, sourceSize, destStartPos, destSize);
    }

    /**
        Calculates a new snake segment for a backward comparison direction.

        Params:
            SourceRange    = The source range type
            DestRange      = The destination range type
            v              = An array of end points for a given k-line
            k              = The k-line the snake should get calculated for
            d              = Number of differences for the same trace
            source         = Elements of the first object. Usually the original object
            sourceStartPos = The starting position in the array of elements from the first object to compare
            sourceSize     = The index of the last element from the first object to compare
            dest           = Elements of the second object. Usually the current object
            destStartPos   = The starting position in the array of elements from the second object to compare
            destSize       = The index of the last element from the second object to compare
    */
    private void calculateBackward(SourceRange, DestRange)(V!T v, int k, int d, SourceRange source, int sourceStartPos, 
        int sourceSize, DestRange dest, int destStartPos, int destSize) 
    if (isRandomAccessRange!SourceRange && isRandomAccessRange!DestRange 
        && (is(ElementType!SourceRange.init == ElementType!DestRange.init)))
    {
        const auto up = (k == d + deltaSize_ || (k != -d + deltaSize_ && v[k - 1] < v[k + 1]));
        const int xStart = up ? v[k - 1] : v[k + 1];
        const int yStart = xStart - (up ? k - 1 : k + 1);
        int xEnd = up ? xStart : xStart - 1;
        int yEnd = xEnd - k;
        int snake = 0;

        while (xEnd > 0 && yEnd > 0 
            && source[(xEnd - 1).to!size_t] == dest[(yEnd - 1).to!size_t]) {
            xEnd--;
            yEnd--;
            snake++;
        }

        xStart_ = xStart;
        yStart_ = yStart;
        deleted_ = up ? 0 : 1;
        inserted_ = up ? 1 : 0;
        diagonalLength_ = snake;

        removeStubs(sourceStartPos, sourceSize, destStartPos, destSize);
    }

    /**
        Calculates a new snake segment depending on the current comparison direction.

        Params:
            SourceRange    = The source range type
            DestRange      = The destination range type
            v              = An array of end points for a given k-line
            k              = The k-line the snake should get calculated for
            d              = Number of differences for the same trace
            source         = Elements of the first object. Usually the original object
            sourceStartPos = The starting position in the array of elements from the first object to compare
            sourceSize     = The index of the last element from the first object to compare
            dest           = Elements of the second object. Usually the current object
            destStartPos   = The starting position in the array of elements from the second object to compare
            destSize       = The index of the last element from the second object to compare
    */
    private void calculate(SourceRange, DestRange)(V!T v, int k, int d, SourceRange source, int sourceStartPos, 
        int sourceSize, DestRange dest, int destStartPos, int destSize) 
        if (isRandomAccessRange!SourceRange && isRandomAccessRange!DestRange 
        && (is(ElementType!SourceRange.init == ElementType!DestRange.init)))
    {
        if (isForward_) {
            calculateForward(v, k, d, source, sourceStartPos, sourceSize, dest, destStartPos, destSize);
        } else {
            calculateBackward(v, k, d, source, sourceStartPos, sourceSize, dest, destStartPos, destSize);
        }
    }

    /**
        Initializes a new snake. The comparison direction can be defined via the isForward parameter.
        If set to true, the comparison will be done from start till end, while a value of false will result in a 
        backward comparison from end to start. delta defines the difference in length between the first and the 
        second object to compare.

        Params:
            isForward = If set to true a forward comparison will be done; else a backward comparison
            delta     = The difference in length between the first and the second object to compare
    */
    this(bool isForward, int delta) {
        isForward_ = isForward;

        if (!isForward_) {
            delta_ = delta;
        }
    }

    /**
        Initializes a new snake segment.

        Params:
            sourceStartPos = The starting position in the array of elements from the first object to compare (a0)
            sourceSize     = The index of the last element from the first object to compare (N)
            destStartPos   = The starting position in the array of elements from the second object to compare (b0)
            destSize       = The index of the last element from the second object to compare (M)
            isForward      = If set to true a forward comparison will be done; else a backward comparison
            xStart         = The x-position of the current node
            yStart         = The y-position of the current node
            deleted        = Defines the number of removed elements from the first object (right movements in the 
                             graph) (ADeleted)
            inserted       = Defines the number of inserted elements from the second object (down movement in the
                             graph) (BInserted)
            diagonalLength = Defines the number of equal elements in both objects for a given segment

    */
    this(int sourceStartPos, int sourceSize, int destStartPos, int destSize, bool isForward, int xStart, int yStart, 
        int deleted, int inserted, int diagonalLength) 
    {
        xStart_ = xStart;
        yStart_ = yStart;
        deleted_ = deleted;
        inserted_ = inserted;
        diagonalLength_ = diagonalLength;
        isForward_ = isForward;

        removeStubs(sourceStartPos, sourceSize, destStartPos, destSize);
    }

    /**
        Initializes a new snake segment.

        Params:
            sourceStartPos = The starting position in the array of elements from the first object to compare (a0)
            sourceSize     = The index of the last element from the first object to compare (N)
            destStartPos   = The starting position in the array of elements from the second object to compare (b0)
            destSize       = The index of the last element from the second object to compare (M)
            isForward      = If set to true a forward comparison will be done; else a backward comparison
            xStart         = The x-position of the current node
            yStart         = The y-position of the current node
            down           = Defines if insertion (down movement; true) or a deletion (right movement; false) should
                             be done
            diagonalLength = Defines the number of equal elements in both objects for a given segment

    */
    this(int sourceStartPos, int sourceSize, int destStartPos, int destSize, bool isForward, int xStart, int yStart, 
        bool down, int diagonalLength) 
    {
        xStart_ = xStart;
        yStart_ = yStart;
        deleted_ = down ? 0 : 1;
        inserted_ = down ? 1 : 0;
        diagonalLength_ = diagonalLength;
        isForward_ = isForward;

        removeStubs(sourceStartPos, sourceSize, destStartPos, destSize);
    }

    /**
        Creates a new instance and calculates the segment based on the provided data.

        Params:
            SourceRange    = The source range type
            DestRange      = The destination range type
            sourceStartPos = The starting position in the array of elements from the first object to compare
            sourceSize     = The index of the last element from the first object to compare
            destStartPos   = The starting position in the array of elements from the second object to compare
            destSize       = The index of the last element from the second object to compare
            isForward      = If set to `true` a forward comparison will be done; else a backward comparison
            delta          = The difference in length between the first and second object to compare. This value is used as an
                             offset between the forward k lines to the reverse ones (DELTA)
            v              = An array of end points for a given k-line
            k              = The k-line the snake should get calculated for
            d              = Number of differences for the same trace
            source         = Elements of the first object. Usually the original object
            dest           = Elements of the second object. Usually the current object
    */
    static Snake!T create(SourceRange, DestRange)(int sourceStartPos, int sourceSize, int destStartPos, int destSize,
        bool isForward, int delta, V!T v, int k, int d, SourceRange source, DestRange dest)
        if (isRandomAccessRange!SourceRange && isRandomAccessRange!DestRange 
        && (is(ElementType!SourceRange.init == ElementType!DestRange.init)))
    {
        auto snake = new Snake!T(isForward, delta);
        
        snake.calculate(v, k, d, source, sourceStartPos, sourceSize, dest, destStartPos, destSize);

        return snake;
    }

    /// Returns the x-position of a starting point
    @property int xStart() {
        return xStart_;
    }

    /// Returns the y-position of a starting point
    @property int yStart() {
        return yStart_;
    }

    /// Returns the starting point
    @property auto startPoint() {
        return point(xStart_, yStart_);
    }

    @property int xMid() {
        return isForward_ ? (xStart_ + deleted_) : (xStart_ - deleted_);
    }

    @property int yMid() {
        isForward_ ? (yStart_ + inserted_) : (yStart_ - inserted_);
    }

    @property auto midPoint() {
        return point(xMid, yMid);
    }

    @property int xEnd() {
        return isForward_ ? (xStart_ + deleted_ + diagonalLength_) : (xStart_ - deleted_ - diagonalLength_);
    }

    @property int yEnd() {
        return isForward_ ? (yStart_ + inserted_ + diagonalLength_) : (yStart_ - inserted_ - diagonalLength_);
    }

    @property auto endPoint() {
        return point(xEnd, yEnd);
    }

    @property bool isMiddle(bool value) {
        return isMiddle_ = value;
    }

    @property int inserted() {
        return inserted_;
    }

    @property int deleted() {
        return deleted_;
    }

    @property int diagonalLength() {
        return diagonalLength_;
    }

    @property bool isForward() {
        return isForward_;
    }

    override string toString() const {
        return format!"Snake{type = %s, start = (%s, %s), del = %s, ins = %s, diagLen = %s, end = (%s, %s), k = %s}"(
            (isForward_) ? "F" : "R", xStart_, yStart_, deleted_, inserted_, diagonalLength_, xEnd, yEnd, xMid - yMid);
    }
}