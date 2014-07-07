package com.ninjabird.firelight.animation.keyframes
{
    /**
     * Defines constants for recognized keyframe types.
     */
    public final class KeyframeType
    {
        /**
         * A 1-component keyframe value using linear interpolation.
         */
        public static const LINEAR_1:int           = 0;

        /**
         * A 2-component keyframe value using linear interpolation.
         */
        public static const LINEAR_2:int           = 1;

        /**
         * A 3-component keyframe value using linear interpolation.
         */
        public static const LINEAR_3:int           = 2;

        /**
         * A 4-component keyframe value using linear interpolation.
         */
        public static const LINEAR_4:int           = 3;

        /**
         * A 1-component keyframe value using hermite interpolation with explicit tangent information.
         */
        public static const CUBIC_1:int            = 4;

        /**
         * A 2-component keyframe value using hermite interpolation with explicit tangent information.
         */
        public static const CUBIC_2:int            = 5;

        /**
         * A 3-component keyframe value using hermite interpolation with explicit tangent information.
         */
        public static const CUBIC_3:int            = 6;

        /**
         * A 4-component keyframe value using hermite interpolation with explicit tangent information.
         */
        public static const CUBIC_4:int            = 7;

        /**
         * A 1-component keyframe value using bezier interpolation with explicit tangent information.
         */
        public static const BEZIER_1:int           = 8;

        /**
         * A 2-component keyframe value using bezier interpolation with explicit tangent information.
         */
        public static const BEZIER_2:int           = 9;

        /**
         * A 3-component keyframe value using bezier interpolation with explicit tangent information.
         */
        public static const BEZIER_3:int           = 10;

        /**
         * A 4-component keyframe value using bezier interpolation with explicit tangent information.
         */
        public static const BEZIER_4:int           = 11;

        /**
         * A 1-component keyframe value using hermite interpolation with implicit tangent information specified using tension, continuity and bias.
         */
        public static const TCB_1:int              = 12;

        /**
         * A 2-component keyframe value using hermite interpolation with implicit tangent information specified using tension, continuity and bias.
         */
        public static const TCB_2:int              = 13;

        /**
         * A 3-component keyframe value using hermite interpolation with implicit tangent information specified using tension, continuity and bias.
         */
        public static const TCB_3:int              = 14;

        /**
         * A 4-component keyframe value using hermite interpolation with implicit tangent information specified using tension, continuity and bias.
         */
        public static const TCB_4:int              = 15;

        /**
         * A 1-component keyframe value using cubic interpolation with no explicit tangent information specified.
         */
        public static const CATMULLROM_NOTAN_1:int = 16;

        /**
         * A 2-component keyframe value using cubic interpolation with no explicit tangent information specified.
         */
        public static const CATMULLROM_NOTAN_2:int = 17;

        /**
         * A 3-component keyframe value using cubic interpolation with no explicit tangent information specified.
         */
        public static const CATMULLROM_NOTAN_3:int = 18;

        /**
         * A 4-component keyframe value using cubic interpolation with no explicit tangent information specified.
         */
        public static const CATMULLROM_NOTAN_4:int = 19;

        /**
         * Computes the stride, in bytes, for a particular keyframe value type.
         * @param type The type of keyframe value.
         * @return The stride, in bytes, for a single keyframe value.
         */
        public static function byteStrideForType(type:int) : int
        {
            switch (type)
            {
                case KeyframeType.LINEAR_1:
                    return 4;  // 4 bytes/component * 1 component
                case KeyframeType.LINEAR_2:
                    return 8;  // 4 bytes/component * 2 components
                case KeyframeType.LINEAR_3:
                    return 12; // 4 bytes/component * 3 components
                case KeyframeType.LINEAR_4:
                    return 16; // 4 bytes/component * 4 components
                case KeyframeType.CUBIC_1:
                    return 12; // 4 bytes/component * 3 components
                case KeyframeType.CUBIC_2:
                    return 24; // 4 bytes/component * 6 components
                case KeyframeType.CUBIC_3:
                    return 36; // 4 bytes/component * 9 components
                case KeyframeType.CUBIC_4:
                    return 48; // 4 bytes/component * 12 components
                case KeyframeType.BEZIER_1:
                    return 12; // 4 bytes/component * 3 components
                case KeyframeType.BEZIER_2:
                    return 24; // 4 bytes/component * 6 components
                case KeyframeType.BEZIER_3:
                    return 36; // 4 bytes/component * 9 components
                case KeyframeType.BEZIER_4:
                    return 48; // 4 bytes/component * 12 components
                case KeyframeType.TCB_1:
                    return 16; // 4 bytes/component * 4 components
                case KeyframeType.TCB_2:
                    return 20; // 4 bytes/component * 5 components
                case KeyframeType.TCB_3:
                    return 24; // 4 bytes/component * 6 components
                case KeyframeType.TCB_4:
                    return 28; // 4 bytes/component * 7 components
                case KeyframeType.CATMULLROM_NOTAN_1:
                    return 4;  // 4 bytes/component * 1 component
                case KeyframeType.CATMULLROM_NOTAN_2:
                    return 8;  // 4 bytes/component * 2 components
                case KeyframeType.CATMULLROM_NOTAN_3:
                    return 12; // 4 bytes/component * 3 components
                case KeyframeType.CATMULLROM_NOTAN_4:
                    return 16; // 4 bytes/component * 4 components
                default:
                    return 0;  // unrecognized type
            }
        }

        /**
         * Computes the number of components for a particular keyframe value type.
         * @param type The type of keyframe value.
         * @return The number of components for a single keyframe value.
         */
        public static function componentCountForType(type:int) : int
        {
            switch (type)
            {
                case KeyframeType.LINEAR_1:
                    return 1;  // 4 bytes/component * 1 component
                case KeyframeType.LINEAR_2:
                    return 2;  // 4 bytes/component * 2 components
                case KeyframeType.LINEAR_3:
                    return 3;  // 4 bytes/component * 3 components
                case KeyframeType.LINEAR_4:
                    return 4;  // 4 bytes/component * 4 components
                case KeyframeType.CUBIC_1:
                    return 3;  // 4 bytes/component * 3 components
                case KeyframeType.CUBIC_2:
                    return 6;  // 4 bytes/component * 6 components
                case KeyframeType.CUBIC_3:
                    return 9;  // 4 bytes/component * 9 components
                case KeyframeType.CUBIC_4:
                    return 12; // 4 bytes/component * 12 components
                case KeyframeType.BEZIER_1:
                    return 3;  // 4 bytes/component * 3 components
                case KeyframeType.BEZIER_2:
                    return 6;  // 4 bytes/component * 6 components
                case KeyframeType.BEZIER_3:
                    return 9;  // 4 bytes/component * 9 components
                case KeyframeType.BEZIER_4:
                    return 12; // 4 bytes/component * 12 components
                case KeyframeType.TCB_1:
                    return 4;  // 4 bytes/component * 4 components
                case KeyframeType.TCB_2:
                    return 5;  // 4 bytes/component * 5 components
                case KeyframeType.TCB_3:
                    return 6;  // 4 bytes/component * 6 components
                case KeyframeType.TCB_4:
                    return 7;  // 4 bytes/component * 7 components
                case KeyframeType.CATMULLROM_NOTAN_1:
                    return 1;  // 4 bytes/component * 1 component
                case KeyframeType.CATMULLROM_NOTAN_2:
                    return 2;  // 4 bytes/component * 2 components
                case KeyframeType.CATMULLROM_NOTAN_3:
                    return 3;  // 4 bytes/component * 3 components
                case KeyframeType.CATMULLROM_NOTAN_4:
                    return 4;  // 4 bytes/component * 4 components
                default:
                    return 0;  // unrecognized type
            }
        }
    }
}
