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
        V!T[] forwardVs_;
        V!T[] reverseVs_;
    }

    this(Snake!T[] snakes, V!T[] forwardVs, V!T[] reverseVs) {
        snakes_ = snakes;
        forwardVs_ = forwardVs;
        reverseVs_ = reverseVs;
    }

    this(Snake!T[] snakes, bool forward, V!T[] vs) {
        snakes_ = snakes;

        if (forward) {
            forwardVs_ = vs;
        } else {
            reverseVs_ = vs;
        }
    }

    @property {
        Snake!T[] snakes() const {
            return snakes_;
        }

        V!T[] forwardVs() const {
            return forwardVs_;
        }

        V!T[] reverseVs() const {
            return reverseVs_;
        }
    }
}