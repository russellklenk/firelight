package com.ninjabird.firelight.animation.keyframes
{
    /**
     * A simple class storing the data necessary to represent a scalar key value without tangent information.
     */
    public final class BasicKeyScalar
    {
        /**
         * The value stored at the keyframe.
         */
        public var x:Number;

        /**
         * Constructs a new instance initialized with the specified value.
         * @param keyValueX The value stored at the keyframe.
         */
        public function BasicKeyScalar(keyValueX:Number=0.0)
        {
            this.x = keyValueX;
        }
    }
}
