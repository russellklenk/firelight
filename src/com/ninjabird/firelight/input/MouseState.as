package com.ninjabird.firelight.input
{
    /**
     * Defines a class storing the state of a mouse and its associated buttons.
     */
    public final class MouseState
    {
        /**
         * Assigns the values from one MouseState instance to another.
         * @param   lhs The object to be written.
         * @param   rhs The object to be read.
         */
        public static function assign(lhs:MouseState, rhs:MouseState) : void
        {
            lhs.x = rhs.x;
            lhs.y = rhs.y;
            lhs.z = rhs.z;
            lhs.buttons = rhs.buttons;
        }

        /**
         * The current x-coordinate of the mouse cursor, relative to the stage.
         */
        public var x:Number;

        /**
         * The current y-coordinate of the mouse cursor, relative to the stage.
         */
        public var y:Number;

        /**
         * The current value of the mouse wheel.
         */
        public var z:Number;

        /**
         * A set of bits storing up to 32 button states.
         */
        public var buttons:uint;

        /**
         * Default Constructor (empty).
         */
        public function MouseState()
        {
            this.x = 0;
            this.y = 0;
            this.z = 0;
            this.buttons = 0;
        }

        /**
         * Resets the button flags.
         */
        public function reset() : void
        {
            this.buttons = 0;
        }
    }
}
