/**
    V

    Authors: ttldtor
    Copyright: © 2019-2021 ttldtor
    License: Subject to the terms of the BSL-1.0 license, as written in the included LICENSE file.
 */

module diff.v;

import std.conv;
import std.format;
import expected;

/**
    This class is a helper class to store the actual x-positions of end-points on a k-line.
    It further provides a method to calculate the y-position for end-points based on the x-position and the k-line the
    end point is lying on.
 
    Params:
        T = Source and destination element's type
 */
final class V(T) {
    private {

        /// Comparison direction flag
        bool isForward_;
        /// N. Length of the first input "string"
        int sourceSize_;
        /// M. Length of the second input "string"
        int destSize_;
        /// The maximum number of end points to store
        int maxSize_;
        /**
            As the length of A (source) and B (destination) can be different, the k lines of the forward and reverse
            algorithms can be different. It is useful to isolate this as a variable
         */
        int delta_;
        /// Stores the actual x-position
        int[] data_;

    }

    /// V[k]
    int opIndex(int k) const
    in (k - delta_ + maxSize_ >= 0)
    in (k - delta_ + maxSize_ < data_.length)
    {
        return data_[(k - delta_ + maxSize_).to!size_t];
    }

    /// V[k] = value
    int opIndexAssign(int value, size_t k)
    in (k - delta_ + maxSize_ >= 0)
    in (k - delta_ + maxSize_ < data_.length)
    {
        return data_[(k - delta_ + maxSize_).to!size_t] = value;
    }

    /// Calculates the y-position of an end point based on the x-position and the k-line.
    int y(int k) const {
        return this[k] - k;
    }

    /// Returns: Comparison direction flag
    @property bool isForward() const {
        return isForward_;
    }

    /// Returns: Length of the first input "string"
    @property int sourceSize() const {
        return sourceSize_;
    }

    /// Returns: Length of the second input "string"
    @property int destSize() const {
        return destSize_;
    }

    override string toString() const {
        return format!"V[%s][%s..%s..%s]"(data_.length, delta_ - maxSize_, delta_, delta_ + maxSize_);
    }

    /**
        Initializes the k-line based on the comparison direction.
        
        Params:
            sourceSize = The length of the first object to compare
            destSize   = The length of the second object to compare
     */
    void initStub(int sourceSize, int destSize) {
        if (isForward) {
            this[1] = 0; // stub for forward
        } else {
            delta_ = sourceSize - destSize;
            this[delta_ - 1] = sourceSize; // stub for forward
        }
    }

    /// Default c-tor
    this() {}

    /**
        Creates a new instance of this helper class.
        
        Params:
            sourceSize = The length of the first object which gets compared to the second
            destSize   = The length of the second object which gets compared to the first
            isForward  = The comparison direction; True if forward, false otherwise
            isLinear   = True if a linear comparison should be used for comparing two objects or the greedy method (false)
     */
    this(int sourceSize, int destSize, bool isForward, bool isLinear)
    in (sourceSize >= 0 && destSize >= 0)
    {
        isForward_ = isForward;
        sourceSize_ = sourceSize;
        destSize_ = destSize;
        maxSize_ = isLinear ? (sourceSize + destSize) / 2 + 1 : sourceSize + destSize;

        if (maxSize_ <= 0) {
            maxSize_ = 1;
        }

        data_.length = maxSize_ * 2 + 1;
        initStub(sourceSize, destSize);
    }

    /**
        Creates a new deep copy of this object.
        
        Params:
            numberOfDifferences = The number of differences for the same trace
            isForward           = The comparison direction; True if forward, false otherwise
            deltaSize           = Keeps track of the differences between the first and the second object to compare as
                                  they may differ in length
        
        Returns: The deep copy of this object or error
     */
    Expected!(V!T, string) createCopy(int numberOfDifferences, bool isForward, int deltaSize)
    in (!(isForward && deltaSize != 0))
    {
        auto calculatedNumberOfDifferences = numberOfDifferences;

        if (calculatedNumberOfDifferences == 0) {
            calculatedNumberOfDifferences++;
        }

        auto copy = new V!T();

        copy.isForward_ = isForward;
        copy.maxSize_ = calculatedNumberOfDifferences;

        if (!isForward) {
            copy.delta_ = deltaSize;
        }

        immutable auto newSize = (2 * calculatedNumberOfDifferences + 1).to!size_t;

        copy.data_.length = newSize;

        if (calculatedNumberOfDifferences <= maxSize_) {
            auto startPos = (maxSize_ - deltaSize) - (copy.maxSize_ - copy.delta_);

            for (size_t idx = 0; idx < newSize; idx++) {
                copy.data_[idx] = data_[(idx.to!int + startPos).to!size_t];
            }
        } else {
            return err!(V!T)("V!T.createCopy: calculatedNumberOfDifferences > maxSize");
        }

        return ok(copy);
    }
}

unittest {
    import std.stdio: writeln;
    auto v = new V!int(30, 50, true, true);

    writeln(v);

    auto v2 = v.createCopy(1, true, 0);

    writeln(v2);
}
