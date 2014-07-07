package com.ninjabird.firelight.animation.keyframes
{
    /**
     * Represents a pair of keyframes and their associated time values.
     */
    public final class KeyframePair
    {
        /**
         * The zero-based index of the lower-bound keyframe.
         */
        public var lowerIndex:uint;

        /**
         * The zero-based index of the upper-bound keyframe.
         */
        public var upperIndex:uint;

        /**
         * The time value at the lower-bound keyframe.
         */
        public var lowerTime:Number;

        /**
         * The time value at the upper-bound keyframe.
         */
        public var upperTime:Number;

        /**
         * The distance between the lower and upper bound keyframes of the
         * current controller time value, in [0, 1]. This value can be used
         * for interpolation between the two keyframes.
         */
        public var normalizedTime:Number;

        /**
         * Default Constructor (empty).
         */
        public function KeyframePair()
        {
            this.lowerIndex     = 0;
            this.upperIndex     = 1;
            this.lowerTime      = 0.0;
            this.upperTime      = 1.0;
            this.normalizedTime = 0.0;
        }

        /**
         * Sets the default values for all member variables.
         */
        public function setDefaults() : void
        {
            this.lowerIndex     = 0;
            this.upperIndex     = 1;
            this.lowerTime      = 0.0;
            this.upperTime      = 1.0;
            this.normalizedTime = 0.0;
        }
    }
}
