package com.ninjabird.firelight.animation.keyframes
{
    /**
     * A simple class storing the data necessary to represent a 4-component vector without tangent information.
     */
    public final class BasicKeyVec4
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
         * The w-coordinate value stored at the keyframe.
         */
        public var w:Number;

        /**
         * Constructs a new instance initialized with the specified values.
         * @param keyValueX The x-coordinate value stored at the keyframe.
         * @param keyValueY The y-coordinate value stored at the keyframe.
         * @param keyValueZ The z-coordinate value stored at the keyframe.
         * @param keyValueW The w-coordinate value stored at the keyframe.
         */
        public function BasicKeyVec4(keyValueX:Number=0.0, keyValueY:Number=0.0, keyValueZ:Number=0.0, keyValueW:Number=0.0)
        {
            this.x = keyValueX;
            this.y = keyValueY;
            this.z = keyValueZ;
            this.w = keyValueW;
        }
    }
}
