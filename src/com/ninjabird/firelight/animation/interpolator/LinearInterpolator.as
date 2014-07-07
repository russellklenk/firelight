package com.ninjabird.firelight.animation.interpolator
{
    import com.ninjabird.firelight.animation.keyframes.BasicKeyScalar;
    import com.ninjabird.firelight.animation.keyframes.BasicKeyVec2;
    import com.ninjabird.firelight.animation.keyframes.BasicKeyVec3;
    import com.ninjabird.firelight.animation.keyframes.BasicKeyVec4;
    import com.ninjabird.firelight.animation.keyframes.KeyframePair;

    /**
     * Provides methods for performing linear interpolation between keyframes.
     */
    public final class LinearInterpolator
    {
        /**
         * An array of four numbers storing the XYZW interpolated value after a call to one of the evaluation functions.
         */
        public var result:Vector.<Number>;

        /**
         * Constructs a new instance initialized with the specified result array.
         * @param res The result array. If this value is null, a 4-component array is allocated.
         */
        public function LinearInterpolator(res:Vector.<Number>=null)
        {
            if (res === null)
            {
                // allocate a 4-component value internally:
                this.result = new Vector.<Number>(4, true);
            }
            else
            {
                // use the caller-supplied value:
                this.result = res;
            }
        }

        /**
         * Performs linear interpolation between two keyframes.
         * @param keyframes The set of keyframe data.
         * @param pair The object providing information about the keys to interpolate.
         */
        public function scalar(keyframes:Vector.<BasicKeyScalar>, pair:KeyframePair) : void
        {
            var inc:BasicKeyScalar = keyframes[pair.upperIndex];
            var out:BasicKeyScalar = keyframes[pair.lowerIndex];
            var t:Number   = pair.normalizedTime;
            this.result[0] = out.x + ((inc.x - out.x) * t);
        }

        /**
         * Performs linear interpolation between two keyframes.
         * @param keyframes The set of keyframe data.
         * @param pair The object providing information about the keys to interpolate.
         */
        public function vector2(keyframes:Vector.<BasicKeyVec2>, pair:KeyframePair) : void
        {
            var inc:BasicKeyVec2 = keyframes[pair.upperIndex];
            var out:BasicKeyVec2 = keyframes[pair.lowerIndex];
            var t:Number   = pair.normalizedTime;
            this.result[0] = out.x + ((inc.x - out.x) * t);
            this.result[1] = out.y + ((inc.y - out.y) * t);
        }

        /**
         * Performs linear interpolation between two keyframes.
         * @param keyframes The set of keyframe data.
         * @param pair The object providing information about the keys to interpolate.
         */
        public function vector3(keyframes:Vector.<BasicKeyVec3>, pair:KeyframePair) : void
        {
            var inc:BasicKeyVec3 = keyframes[pair.upperIndex];
            var out:BasicKeyVec3 = keyframes[pair.lowerIndex];
            var t:Number   = pair.normalizedTime;
            this.result[0] = out.x + ((inc.x - out.x) * t);
            this.result[1] = out.y + ((inc.y - out.y) * t);
            this.result[2] = out.z + ((inc.z - out.z) * t);
        }

        /**
         * Performs linear interpolation between two keyframes.
         * @param keyframes The set of keyframe data.
         * @param pair The object providing information about the keys to interpolate.
         */
        public function vector4(keyframes:Vector.<BasicKeyVec4>, pair:KeyframePair) : void
        {
            var inc:BasicKeyVec4 = keyframes[pair.upperIndex];
            var out:BasicKeyVec4 = keyframes[pair.lowerIndex];
            var t:Number   = pair.normalizedTime;
            this.result[0] = out.x + ((inc.x - out.x) * t);
            this.result[1] = out.y + ((inc.y - out.y) * t);
            this.result[2] = out.z + ((inc.z - out.z) * t);
            this.result[3] = out.w + ((inc.w - out.w) * t);
        }
    }
}
