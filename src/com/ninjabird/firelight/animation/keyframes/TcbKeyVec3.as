package com.ninjabird.firelight.animation.keyframes
{
    /**
     * A simple class storing the data necessary to represent a 3-component vector that will use
     * cubic polynomial interpolation, with tangent values specified using tension, continuity and bias.
     * Tension controls how sharply the curve bends, Continuity controls how rapid the change in speed
     * and direction is, and Bias controls the direction of the curve as it passes through the value.
     */
    public final class TcbKeyVec3
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
         * A value controlling how sharply the curve bends.
         */
        public var tension:Number;

        /**
         * A value controlling how rapid the change in speed and direction is.
         */
        public var continuity:Number;

        /**
         * A value controlling the direction of the curve as it passes through
         * the value.
         */
        public var bias:Number;

        /**
         * Constructs a new instance initialized with the specified values.
         * @param keyValueX The x-coordinate value stored at the keyframe.
         * @param keyValueY The y-coordinate value stored at the keyframe.
         * @param keyValueZ The z-coordinate value stored at the keyframe.
         * @param keyTens The tension value stored at the keyframe.
         * @param keyCont The continuity value stored at the keyframe.
         * @param keyBias The bias value stored at the keyframe.
         */
        public function TcbKeyVec3(keyValueX:Number=0.0, keyValueY:Number=0.0, keyValueZ:Number=0.0, keyTens:Number=0.0, keyCont:Number=0.0, keyBias:Number=0.0)
        {
            this.x          = keyValueX;
            this.y          = keyValueY;
            this.z          = keyValueZ;
            this.tension    = keyTens;
            this.continuity = keyCont;
            this.bias       = keyBias;
        }
    }
}
