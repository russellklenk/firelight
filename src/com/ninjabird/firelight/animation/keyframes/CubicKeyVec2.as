package com.ninjabird.firelight.animation.keyframes
{
    /**
     * A simple class storing the data necessary to represent a 2-component vector that will use
     * cubic polynomial (Bezier/Hermite) interpolation.
     */
    public final class CubicKeyVec2
    {
        /**
         * The x-coordinate value stored at the keyframe.
         */
        public var x:Number;

        /**
         * The y-coordinate value stored at the keyframe.
         */
        public var y:Number;

        /**
         * The tangent x-coordinate when coming into the keyframe.
         */
        public var inTanX:Number;

        /**
         * The tangent y-coordinate when coming into the keyframe.
         */
        public var inTanY:Number;

        /**
         * The tangent x-coordinate when leaving the keyframe.
         */
        public var outTanX:Number;

        /**
         * The tangent y-coordinate when leaving the keyframe.
         */
        public var outTanY:Number;

        /**
         * Constructs a new instance initialized with the specified value.
         * @param keyValueX The x-coordinate value stored at the keyframe.
         * @param keyValueY The y-coordinate value stored at the keyframe.
         * @param keyInTanX The tangent x-coordinate when coming into the keyframe.
         * @param keyInTanY The tangent y-coordinate when coming into the keyframe.
         * @param keyOutTanX The tangent x-coordinate when leaving the keyframe.
         * @param keyOutTanY The tangent y-coordinate when leaving the keyframe.
         */
        public function CubicKeyVec2(keyValueX:Number=0.0, keyValueY:Number=0.0, keyInTanX:Number=0.0, keyInTanY:Number=0.0, keyOutTanX:Number=0.0, keyOutTanY:Number=0.0)
        {
            this.x       = keyValueX;
            this.y       = keyValueY;
            this.inTanX  = keyInTanX;
            this.inTanY  = keyInTanY;
            this.outTanX = keyOutTanX;
            this.outTanY = keyOutTanY;
        }
    }
}
