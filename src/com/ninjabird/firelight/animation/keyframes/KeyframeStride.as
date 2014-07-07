package com.ninjabird.firelight.animation.keyframes
{
    /**
     * Defines constants for the number of Number instances that make up keyframes of various types.
     */
    public final class KeyframeStride
    {
        /**
         * A 1-component keyframe value with no stored tangent data.
         */
        public static const BASIC_1:int = 1;

        /**
         * A 2-component keyframe value with no stored tangent data.
         */
        public static const BASIC_2:int = 2;

        /**
         * A 3-component keyframe value with no stored tangent data.
         */
        public static const BASIC_3:int = 3;

        /**
         * A 4-component keyframe value with no stored tangent data.
         */
        public static const BASIC_4:int = 4;

        /**
         * A 1-component keyframe value with explicit tangent data.
         */
        public static const CUBIC_1:int = 3;

        /**
         * A 2-component keyframe value with explicit tangent data.
         */
        public static const CUBIC_2:int = 6;

        /**
         * A 3-component keyframe value with explicit tangent data.
         */
        public static const CUBIC_3:int = 9;

        /**
         * A 4-component keyframe value with explicit tangent data.
         */
        public static const CUBIC_4:int = 12;

        /**
         * A 1-component keyframe value with implicit tangent data specified as tension-continuity-bias.
         */
        public static const TCB_1:int   = 4;

        /**
         * A 2-component keyframe value with implicit tangent data specified as tension-continuity-bias.
         */
        public static const TCB_2:int   = 5;

        /**
         * A 3-component keyframe value with implicit tangent data specified as tension-continuity-bias.
         */
        public static const TCB_3:int   = 6;

        /**
         * A 4-component keyframe value with implicit tangent data specified as tension-continuity-bias.
         */
        public static const TCB_4:int   = 7;
    }
}
