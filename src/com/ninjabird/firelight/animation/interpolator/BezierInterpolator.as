package com.ninjabird.firelight.animation.interpolator
{
    import com.ninjabird.firelight.animation.keyframes.CubicKeyScalar;
    import com.ninjabird.firelight.animation.keyframes.CubicKeyVec2;
    import com.ninjabird.firelight.animation.keyframes.CubicKeyVec3;
    import com.ninjabird.firelight.animation.keyframes.CubicKeyVec4;
    import com.ninjabird.firelight.animation.keyframes.KeyframePair;

    /**
     * Provides methods for performing Bezier interpolation between keyframes.
     */
    public final class BezierInterpolator
    {
        /**
         * An array of four numbers storing the XYZW interpolated value after a call to one of the evaluation functions.
         */
        public var result:Vector.<Number>;

        /**
         * Constructs a new instance initialized with the specified result array.
         * @param res The result array. If this value is null, a 4-component array is allocated.
         */
        public function BezierInterpolator(res:Vector.<Number>=null)
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
         * Performs Bezier interpolation between two keyframes.
         * @param keyframes The set of keyframe data.
         * @param pair The object providing information about the keys to interpolate.
         */
        public function scalar(keyframes:Vector.<CubicKeyScalar>, pair:KeyframePair) : void
        {
            var inc:CubicKeyScalar = keyframes[pair.upperIndex];
            var out:CubicKeyScalar = keyframes[pair.lowerIndex];
            var t:Number   = pair.normalizedTime;
            var d:Number   = inc.x       -   out.x;
            var a2:Number  = (d * 3.0)   -  (inc.inTanX  + (out.outTanX * 2.0));
            var a3:Number  = out.outTanX +   inc.inTanX  - (d           * 2.0);
            this.result[0] = out.x       + ((out.outTanX + (a2 + (a3    * t)) * t) * t);
        }

        /**
         * Performs Bezier interpolation between two keyframes.
         * @param keyframes The set of keyframe data.
         * @param pair The object providing information about the keys to interpolate.
         */
        public function vector2(keyframes:Vector.<CubicKeyVec2>, pair:KeyframePair) : void
        {
            var inc:CubicKeyVec2 = keyframes[pair.upperIndex];
            var out:CubicKeyVec2 = keyframes[pair.lowerIndex];
            var t:Number    = pair.normalizedTime;
            var dx:Number   = inc.x       -   out.x;
            var dy:Number   = inc.y       -   out.y;
            var a2x:Number  = (dx * 3.0)  -  (inc.inTanX  + (out.outTanX * 2.0));
            var a2y:Number  = (dy * 3.0)  -  (inc.inTanY  + (out.outTanY * 2.0));
            var a3x:Number  = out.outTanX +   inc.inTanX  - (dx          * 2.0);
            var a3y:Number  = out.outTanY +   inc.inTanY  - (dy          * 2.0);
            this.result[0] = out.x        + ((out.outTanX + (a2x + (a3x  * t)) * t) * t);
            this.result[1] = out.y        + ((out.outTanY + (a2y + (a3y  * t)) * t) * t);
        }

        /**
         * Performs Bezier interpolation between two keyframes.
         * @param keyframes The set of keyframe data.
         * @param pair The object providing information about the keys to interpolate.
         */
        public function vector3(keyframes:Vector.<CubicKeyVec3>, pair:KeyframePair) : void
        {
            var inc:CubicKeyVec3 = keyframes[pair.upperIndex];
            var out:CubicKeyVec3 = keyframes[pair.lowerIndex];
            var t:Number   = pair.normalizedTime;
            var dx:Number  = inc.x       -   out.x;
            var dy:Number  = inc.y       -   out.y;
            var dz:Number  = inc.z       -   out.z;
            var a2x:Number = (dx * 3.0)  -  (inc.inTanX  + (out.outTanX * 2.0));
            var a2y:Number = (dy * 3.0)  -  (inc.inTanY  + (out.outTanY * 2.0));
            var a2z:Number = (dz * 3.0)  -  (inc.inTanZ  + (out.outTanZ * 2.0));
            var a3x:Number = out.outTanX +   inc.inTanX  - (dx          * 2.0);
            var a3y:Number = out.outTanY +   inc.inTanY  - (dy          * 2.0);
            var a3z:Number = out.outTanZ +   inc.inTanZ  - (dz          * 2.0);
            this.result[0] = out.x       + ((out.outTanX + (a2x + (a3x  * t)) * t) * t);
            this.result[1] = out.y       + ((out.outTanY + (a2y + (a3y  * t)) * t) * t);
            this.result[2] = out.z       + ((out.outTanZ + (a2z + (a3z  * t)) * t) * t);
        }

        /**
         * Performs Bezier interpolation between two keyframes.
         * @param keyframes The set of keyframe data.
         * @param pair The object providing information about the keys to interpolate.
         */
        public function vector4(keyframes:Vector.<CubicKeyVec4>, pair:KeyframePair) : void
        {
            var inc:CubicKeyVec4 = keyframes[pair.upperIndex];
            var out:CubicKeyVec4 = keyframes[pair.lowerIndex];
            var t:Number   = pair.normalizedTime;
            var dx:Number  = inc.x       -   out.x;
            var dy:Number  = inc.y       -   out.y;
            var dz:Number  = inc.z       -   out.z;
            var dw:Number  = inc.w       -   out.w;
            var a2x:Number = (dx * 3.0)  -  (inc.inTanX  + (out.outTanX * 2.0));
            var a2y:Number = (dy * 3.0)  -  (inc.inTanY  + (out.outTanY * 2.0));
            var a2z:Number = (dz * 3.0)  -  (inc.inTanZ  + (out.outTanZ * 2.0));
            var a2w:Number = (dw * 3.0)  -  (inc.inTanW  + (out.outTanW * 2.0));
            var a3x:Number = out.outTanX +   inc.inTanX  - (dx          * 2.0);
            var a3y:Number = out.outTanY +   inc.inTanY  - (dy          * 2.0);
            var a3z:Number = out.outTanZ +   inc.inTanZ  - (dz          * 2.0);
            var a3w:Number = out.outTanW +   inc.inTanW  - (dw          * 2.0);
            this.result[0] = out.x       + ((out.outTanX + (a2x + (a3x  * t)) * t) * t);
            this.result[1] = out.y       + ((out.outTanY + (a2y + (a3y  * t)) * t) * t);
            this.result[2] = out.z       + ((out.outTanZ + (a2z + (a3z  * t)) * t) * t);
            this.result[3] = out.w       + ((out.outTanW + (a2w + (a3w  * t)) * t) * t);
        }
    }
}
