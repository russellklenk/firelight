package com.ninjabird.firelight.animation.interpolator
{
    import com.ninjabird.firelight.animation.keyframes.CubicKeyScalar;
    import com.ninjabird.firelight.animation.keyframes.CubicKeyVec2;
    import com.ninjabird.firelight.animation.keyframes.CubicKeyVec3;
    import com.ninjabird.firelight.animation.keyframes.CubicKeyVec4;
    import com.ninjabird.firelight.animation.keyframes.KeyframePair;

    /**
     * Provides methods for performing Hermite interpolation between keyframes.
     */
    public final class CubicInterpolator
    {
        /**
         * An array of four numbers storing the XYZW interpolated value after a call to one of the evaluation functions.
         */
        public var result:Vector.<Number>;

        /**
         * Constructs a new instance initialized with the specified result array.
         * @param res The result array. If this value is null, a 4-component array is allocated.
         */
        public function CubicInterpolator(res:Vector.<Number>=null)
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
         * Performs Hermite interpolation between two keyframes.
         * @param keyframes The set of keyframe data.
         * @param pair The object providing information about the keys to interpolate.
         */
        public function scalar(keyframes:Vector.<CubicKeyScalar>, pair:KeyframePair) : void
        {
            var inc:CubicKeyScalar = keyframes[pair.upperIndex];
            var out:CubicKeyScalar = keyframes[pair.lowerIndex];
            var t:Number   = pair.normalizedTime;
            var t2:Number  = t  * t;
            var t3:Number  = t2 * t;
            var c0:Number  = 2.0 * t3  - 3.0 * t2 + 1.0;
            var c1:Number  =-2.0 * t3  + 3.0 * t2;
            var c2:Number  = t3  - 2.0 * t2  + t;
            var c3:Number  = t3  - t2;
            this.result[0] = c0  * out.x + c1 * inc.x + c2 * out.outTanX + c3 * inc.inTanX;
        }

        /**
         * Performs Hermite interpolation between two keyframes.
         * @param keyframes The set of keyframe data.
         * @param pair The object providing information about the keys to interpolate.
         */
        public function vector2(keyframes:Vector.<CubicKeyVec2>, pair:KeyframePair) : void
        {
            var inc:CubicKeyVec2 = keyframes[pair.upperIndex];
            var out:CubicKeyVec2 = keyframes[pair.lowerIndex];
            var t:Number   = pair.normalizedTime;
            var t2:Number  = t  * t;
            var t3:Number  = t2 * t;
            var c0:Number  = 2.0 * t3  - 3.0 * t2 + 1.0;
            var c1:Number  =-2.0 * t3  + 3.0 * t2;
            var c2:Number  = t3  - 2.0 * t2  + t;
            var c3:Number  = t3  - t2;
            this.result[0] = c0  * out.x + c1 * inc.x + c2 * out.outTanX + c3 * inc.inTanX;
            this.result[1] = c0  * out.y + c1 * inc.y + c2 * out.outTanY + c3 * inc.inTanY;
        }

        /**
         * Performs Hermite interpolation between two keyframes.
         * @param keyframes The set of keyframe data.
         * @param pair The object providing information about the keys to interpolate.
         */
        public function vector3(keyframes:Vector.<CubicKeyVec3>, pair:KeyframePair) : void
        {
            var inc:CubicKeyVec3 = keyframes[pair.upperIndex];
            var out:CubicKeyVec3 = keyframes[pair.lowerIndex];
            var t:Number   = pair.normalizedTime;
            var t2:Number  = t   * t;
            var t3:Number  = t2  * t;
            var c0:Number  = 2.0 * t3  - 3.0 * t2 + 1.0;
            var c1:Number  =-2.0 * t3  + 3.0 * t2;
            var c2:Number  = t3  - 2.0 * t2  + t;
            var c3:Number  = t3  - t2;
            this.result[0] = c0  * out.x + c1 * inc.x + c2 * out.outTanX + c3 * inc.inTanX;
            this.result[1] = c0  * out.y + c1 * inc.y + c2 * out.outTanY + c3 * inc.inTanY;
            this.result[2] = c0  * out.z + c1 * inc.z + c2 * out.outTanZ + c3 * inc.inTanZ;
        }

        /**
         * Performs Hermite interpolation between two keyframes.
         * @param keyframes The set of keyframe data.
         * @param pair The object providing information about the keys to interpolate.
         */
        public function vector4(keyframes:Vector.<CubicKeyVec4>, pair:KeyframePair) : void
        {
            var inc:CubicKeyVec4 = keyframes[pair.upperIndex];
            var out:CubicKeyVec4 = keyframes[pair.lowerIndex];
            var t:Number   = pair.normalizedTime;
            var t2:Number  = t   * t;
            var t3:Number  = t2  * t;
            var c0:Number  = 2.0 * t3  - 3.0 * t2 + 1.0;
            var c1:Number  =-2.0 * t3  + 3.0 * t2;
            var c2:Number  = t3  - 2.0 * t2  + t;
            var c3:Number  = t3  - t2;
            this.result[0] = c0  * out.x + c1 * inc.x + c2 * out.outTanX + c3 * inc.inTanX;
            this.result[1] = c0  * out.y + c1 * inc.y + c2 * out.outTanY + c3 * inc.inTanY;
            this.result[2] = c0  * out.z + c1 * inc.z + c2 * out.outTanZ + c3 * inc.inTanZ;
            this.result[3] = c0  * out.w + c1 * inc.w + c2 * out.outTanW + c3 * inc.inTanW;
        }
    }
}
