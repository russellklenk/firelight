package com.ninjabird.firelight.input
{
    /**
     * Combines mouse and keyboard state into a single object.
     */
    public final class InputState
    {
        /**
         * Copies the state values from one InputState instance to another.
         * @param lhs The object being written to.
         * @param rhs The object to read from.
         */
        public static function assign(lhs:InputState, rhs:InputState) : void
        {
            MouseState.assign(lhs.mouse, rhs.mouse);
            KeyboardState.assign(lhs.keyboard, rhs.keyboard);
        }

        /**
         * The mouse state.
         */
        public var mouse:MouseState;

        /**
         * The keyboard state.
         */
        public var keyboard:KeyboardState;

        /**
         * Default Constructor.
         */
        public function InputState()
        {
            this.mouse    = new MouseState();
            this.keyboard = new KeyboardState();
        }
    }
}
