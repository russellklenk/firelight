package com.ninjabird.firelight.ui
{
    /**
     * Represents the state of a pressed key, including the information
     * necessary to support key repeat.
     */
    public final class KeyState
    {

        /**
         * The key code identifier.
         */
        public var keyCode:uint;

        /**
         * The current accumulated time value (in seconds) when the key was last pressed.
         */
        public var timestamp:Number;

        /**
         * A value indicating the amount of time remaining before starting
         * the key repeat logic. This value is set when the key is first pressed.
         */
        public var delay:Number;

        /**
         * Pointer to the next item in the list. A value of null indicates the end of the list.
         */
        public var next:KeyState;

        /**
         * Default Constructor (empty).
         */
        public function KeyState()
        {
            /* empty */
        }

    }
}
