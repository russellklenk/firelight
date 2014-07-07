package com.ninjabird.firelight.animation.keyframes
{
    /**
     * A simple class storing the data necessary to represent a scalar value that will use
     * cubic polynomial (Bezier/Hermite) interpolation.
     */
    public final class CubicKeyScalar
    {
        /**
         * The value stored at the keyframe.
         */
        public var x:Number;

        /**
         * The tangent when coming into the keyframe.
         */
        public var inTanX:Number;

        /**
         * The tangent when leaving the keyframe.
         */
        public var outTanX:Number;

        /**
         * Constructs a new instance initialized with the specified value.
         * @param keyValueX The value stored at the keyframe.
         * @param keyInTanX The tangent when coming into the keyframe.
         * @param keyOutTanX The tangent when leaving the keyframe.
         */
        public function CubicKeyScalar(keyValueX:Number=0.0, keyInTanX:Number=0.0, keyOutTanX:Number=0.0)
        {
            this.x       = keyValueX;
            this.inTanX  = keyInTanX;
            this.outTanX = keyOutTanX;
        }
    }
}
