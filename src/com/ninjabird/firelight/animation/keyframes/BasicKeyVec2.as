package com.ninjabird.firelight.animation.keyframes
{
    /**
     * A simple class storing the data necessary to represent a 2-component vector without tangent information.
     */
    public final class BasicKeyVec2
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
         * Constructs a new instance initialized with the specified values.
         * @param keyValueX The x-coordinate value stored at the keyframe.
         * @param keyValueY The y-coordinate value stored at the keyframe.
         */
        public function BasicKeyVec2(keyValueX:Number=0.0, keyValueY:Number=0.0)
        {
            this.x = keyValueX;
            this.y = keyValueY;
        }
    }
}
