/**
    V

    Authors: ttldtor
    Copyright: © 2019-2020 ttldtor
    License: Subject to the terms of the BSL-1.0 license, as written in the included LICENSE file.
*/

module diff.v;

/**
 * This class is a helper class to store the actual x-positions of end-points on a k-line.
 * It further provides a method to calculate the y-position for end-points based on the x-position and the k-line the
 * end point is lying on.
 *
 * Params:
 *     T = Source and destination element's type
 */
final class V(T)
{
    private
    {

        /// Comparison direction flag
        bool isForward_;
        /// Length of the first input
        int sourceSize_;
        /// Length of the second input "string"
        int destSize_;
        /// The maximum number of end points to store
        int maxSize_;
        /**
         * As the length of A (source) and B (destination) can be different, the k lines of the forward and reverse
         * algorithms can be different. It is useful to isolate this as a variable
         */
        int deltaSize_;
        /// Stores the actual x-position
        int[] data_;

    }

    /// V[k]
    int opIndex(int k)
    in
    {
        assert(k - deltaSize_ + maxSize_ >= 0);
        assert(k - deltaSize_ + maxSize_ < data_.length);
    }
    do
    {
        auto index = cast(size_t)(k - deltaSize_ + maxSize_);

        return data_[index];
    }

    /// V[k] = value
    int opIndexAssign(int value, size_t k)
    in
    {
        assert(k - deltaSize_ + maxSize_ >= 0);
        assert(k - deltaSize_ + maxSize_ < data_.length);
    }
    do
    {
        auto index = cast(size_t)(k - deltaSize_ + maxSize_);

        return data_[index] = value;
    }

    @property size_t length()
    {
        return data_.length;
    }

    @property bool isForward() {
        return isForward_;
    }

    @property int sourceSize() {
        return sourceSize_;
    }

    @property int destSize() {
        return destSize_;
    }

    override string toString() const {
        import std.conv : to;

        return "V[" ~ data_.length.to!string ~ "][" ~ (deltaSize_ - maxSize_).to!string ~ ".." ~ deltaSize_.to!string
               ~ ".." ~ (deltaSize_ + maxSize_).to!string ~ "]";
    }

    /**
     * Initializes the k-line based on the comparison direction.
     *
     * Params:
     *      sourceSize = The length of the first object to compare
     *      destSize   = The length of the second object to compare
     */
    void initStub(int sourceSize, int destSize)
    {
        if (isForward)
        {
            opIndexAssign(0, 1);
        }
        else
        {
            deltaSize_ = sourceSize - destSize;

            opIndexAssign(sourceSize, sourceSize - destSize - 1);
        }
    }

    this() {}

    /**
     * Creates a new instance of this helper class.
     *
     * Params:
     *      sourceSize = The length of the first object which gets compared to the second
     *      destSize   = The length of the second object which gets compared to the first
     *      isForward  = The comparison direction; True if forward, false otherwise
     *      isLinear   = True if a linear comparison should be used for comparing two objects or the greedy method (false)
     */
    this(int sourceSize, int destSize, bool isForward, bool isLinear)
    in
    {
        assert(sourceSize >= 0 && destSize >= 0);
    }
    do
    {
        isForward_ = isForward;
        sourceSize_ = sourceSize;
        destSize_ = destSize;
        maxSize_ = isLinear ? (sourceSize + destSize) / 2 + 1 : sourceSize + destSize;

        if (maxSize_ <= 0)
        {
            maxSize_ = 1;
        }

        data_.length = maxSize_ * 2 + 1;
        initStub(sourceSize, destSize);
    }

    /**
     * Creates a new deep copy of this object.
     *
     * Params:
     *      numberOfDifferences = The number of differences for the same trace
     *      isForward           = The comparison direction; True if forward, false otherwise
     *      deltaSize           = Keeps track of the differences between the first and the second object to compare as
     *                            they may differ in length
     *
     * Returns: The deep copy of this object or empty
     */
    V!T createCopy(int numberOfDifferences, bool isForward, int deltaSize)
    in
    {
        assert(!(isForward && deltaSize != 0));
    }
    do
    {
        auto calculatedNumberOfDifferences = numberOfDifferences;

        if (calculatedNumberOfDifferences == 0) {
            calculatedNumberOfDifferences++;
        }

        auto copy = new V!T();

        copy.isForward_ = isForward;
        copy.maxSize_ = calculatedNumberOfDifferences;

        if (!isForward) {
            copy.deltaSize_ = deltaSize;
        }

        auto newSize = cast(size_t)(2 * calculatedNumberOfDifferences + 1);

        copy.data_.length = newSize;

        if (calculatedNumberOfDifferences <= maxSize_) {
            auto startPos = (maxSize_ - deltaSize) - (copy.maxSize_ - copy.deltaSize_);

            for (size_t idx = 0; idx < newSize; idx++) {
                copy.data_[idx] = data_[cast(size_t)(cast(int)(idx) + startPos)];
            }
        } else {
            return null;
        }

        return copy;
    }
}
