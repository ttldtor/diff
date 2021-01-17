/**
    SnakePair

    Authors: ttldtor
    Copyright: © 2019-2021 ttldtor
    License: Subject to the terms of the BSL-1.0 license, as written in the included LICENSE file.
 */

module diff.snake_pair;

import diff.snake;

/**
    Utility class that hold both directional calculations for the segment the snake is used for.
 
    Params:
        T = The type of the element the snakes will hold
 */
final class SnakePair(T) {
    private {
        /// The number of differences for both segment calculations
        int d_;
        /// The segment calculated in forward direction
        Snake!T forward_;
        /// The segment calculated in backward direction
        Snake!T reverse_;
    }

    /**
        Initializes a new instance of this utility class.

        Params:
            d       = The number of differences for both segment calculations
            forward = The segment calculated in a forward direction
            reverse = The segment calculated in a backward direction
     */
    this(int d, Snake!T forward, Snake!T reverse) {
        d_ = d;
        forward_ = forward;
        reverse_ = reverse;
    }


    @property {
        /**
            Sets the number of differences for both calculation directions.

            Params:
                value = The number of differences for both calculation directions
            
            Returns: The new value
         */
        int d(int value) {
            return d_ = value;
        }

        /**
            Returns the number of differences for both calculation directions.

            A value of 0 indicates that compared elements from the first and the second object are equal. A value of 1 
            indicates either an insertion from the second object or a deletion from the first object.

            Moreover, a value of 0 must be a reverse segment, while a value of 1 results from a forward segment.

            Returns: The number of differences for both calculation directions
         */
        int d() const {
            return d_;
        }

        /**
            Sets the new segment calculated in a forward direction.

            Params:
                value = The segment calculated in forward direction

            Returns: The new value
         */
        Snake!T forward(Snake!T value) {
            return forward_ = value;
        }

        /// Returns: The segment which was calculated in forward direction.
        Snake!T forward() {
            return forward_;
        }

        /**
            Sets the new segment calculated in a backward direction.

            Params:
                value = The segment calculated in backward direction

            Returns: The new value
         */
        Snake!T reverse(Snake!T value) {
            return reverse_ = value;
        }

        /// Returns: TReturns the segment which was calculated in backward direction.
        Snake!T reverse() {
            return reverse_;
        }
    }
}