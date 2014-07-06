package com.ninjabird.firelight.ui
{
    /**
     * Defines bitflags for representing the state of a mouse button.
     */
    public final class MouseState
    {
        /**
         * Indicates that the button is currently released.
         */
        public static const OFF:int   = 0x00;

        /**
         * Indicates that the button is currently pressed.
         */
        public static const ON:int    = 0x01;

        /**
         * Indicates that the button is being pressed.
         */
        public static const BEGIN:int = 0x02;

        /**
         * Indicates that the button is being released.
         */
        public static const END:int   = 0x04;

        /**
         * Indicates that the shift key was pressed.
         */
        public static const SHIFT:int = 0x08;

        /**
         * Indicates that the ALT key was pressed.
         */
        public static const ALT:int   = 0x10;

        /**
         * Indicates that the control key was pressed.
         */
        public static const CTRL:int  = 0x20;
    }
}
