package com.ninjabird.firelight.animation.keyframes
{
    /**
     * A simple class storing the data necessary to represent a 3-component vector that will use
     * cubic polynomial (Bezier/Hermite) interpolation.
     */
    public final class CubicKeyVec3
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
         * The z-coordinate value stored at the keyframe.
         */
        public var z:Number;

        /**
         * The tangent x-coordinate when coming into the keyframe.
         */
        public var inTanX:Number;

        /**
         * The tangent y-coordinate when coming into the keyframe.
         */
        public var inTanY:Number;

        /**
         * The tangent z-coordinate when coming into the keyframe.
         */
        public var inTanZ:Number;

        /**
         * The tangent x-coordinate when leaving the keyframe.
         */
        public var outTanX:Number;

        /**
         * The tangent y-coordinate when leaving the keyframe.
         */
        public var outTanY:Number;

        /**
         * The tangent z-coordinate when leaving the keyframe.
         */
        public var outTanZ:Number;

        /**
         * Constructs a new instance initialized with the specified value.
         * @param keyValueX The x-coordinate value stored at the keyframe.
         * @param keyValueY The y-coordinate value stored at the keyframe.
         * @param keyValueZ The z-coordinate value stored at the keyframe.
         * @param keyInTanX The tangent x-coordinate when coming into the keyframe.
         * @param keyInTanY The tangent y-coordinate when coming into the keyframe.
         * @param keyInTanZ The tangent z-coordinate when coming into the keyframe.
         * @param keyOutTanX The tangent x-coordinate when leaving the keyframe.
         * @param keyOutTanY The tangent y-coordinate when leaving the keyframe.
         * @param keyOutTanZ The tangent z-coordinate when leaving the keyframe.
         */
        public function CubicKeyVec3(keyValueX:Number=0.0, keyValueY:Number=0.0, keyValueZ:Number=0.0, keyInTanX:Number=0.0, keyInTanY:Number=0.0, keyInTanZ:Number=0.0, keyOutTanX:Number=0.0, keyOutTanY:Number=0.0, keyOutTanZ:Number=0.0)
        {
            this.x       = keyValueX;
            this.y       = keyValueY;
            this.z       = keyValueZ;
            this.inTanX  = keyInTanX;
            this.inTanY  = keyInTanY;
            this.inTanZ  = keyInTanZ;
            this.outTanX = keyOutTanX;
            this.outTanY = keyOutTanY;
            this.outTanZ = keyOutTanZ;
        }
    }
}
