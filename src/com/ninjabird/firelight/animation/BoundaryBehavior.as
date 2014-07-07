package com.ninjabird.firelight.animation
{
    /**
     * Defines a set of constant values used to indicate the behavior of an
     * animation controller at interval boundaries.
     */
    public final class BoundaryBehavior
    {
        /**
         * Indicates that a constant value in the interval is always returned.
         */
        public static const CONSTANT:int = 0;

        /**
         * Indicates that when the end of the interval is reached, the
         * interval end value is returned (the sequence plays once and stops).
         */
        public static const CLAMP:int    = 1;

        /**
         * Indicates that when the end of the interval is reached, the
         * sequence restarts from the beginning (it loops).
         */
        public static const WRAP:int     = 2;

        /**
         * Indicates that when the end of the interval is reached, the
         * sequence will be reversed (it plays backwards and loops).
         */
        public static const CYCLE:int    = 3;

        /**
         * Indicates that a user-defined function will determine behavior
         * at interval boundaries.
         */
        public static const CUSTOM:int   = 4;
    }
}
