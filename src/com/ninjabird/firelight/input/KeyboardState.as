package com.ninjabird.firelight.input
{
    /**
     * Represents the state of keys on the keyboard as a series of bits.
     */
    public final class KeyboardState
    {

        /**
         * Assigns the values from one KeyboardState instance to another.
         * @param lhs The object to be written.
         * @param rhs The object to be read.
         */
        public static function assign(lhs:KeyboardState, rhs:KeyboardState) : void
        {
            lhs.states[0] = rhs.states[0];
            lhs.states[1] = rhs.states[1];
            lhs.states[2] = rhs.states[2];
            lhs.states[3] = rhs.states[3];
            lhs.states[4] = rhs.states[4];
            lhs.states[5] = rhs.states[5];
            lhs.states[6] = rhs.states[6];
            lhs.states[7] = rhs.states[7];
        }

        /**
         * An array of 256 bits (32 bytes) representing the key states, where 1 = key down and 0 = key up.
         */
        public var states:Vector.<uint>;

        /**
         * Default Constructor (empty).
         */
        public function KeyboardState()
        {
            this.states    = new Vector.<uint>(8, true);
            this.states[0] = 0;
            this.states[1] = 0;
            this.states[2] = 0;
            this.states[3] = 0;
            this.states[4] = 0;
            this.states[5] = 0;
            this.states[6] = 0;
            this.states[7] = 0;
        }

        /**
         * Resets all key state bits.
         */
        public function reset() : void
        {
            this.states[0] = 0;
            this.states[1] = 0;
            this.states[2] = 0;
            this.states[3] = 0;
            this.states[4] = 0;
            this.states[5] = 0;
            this.states[6] = 0;
            this.states[7] = 0;
        }
    }
}
