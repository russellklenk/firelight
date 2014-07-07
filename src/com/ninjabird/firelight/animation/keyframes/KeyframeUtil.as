package com.ninjabird.firelight.animation.keyframes
{
    /**
     * Provides a number of methods for preprocessing a set of keyframes for cubic polynomial
     * (Bezier/Hermite) interpolation. The formulas can be found at http://www.cubic.org/docs/hermite.htm
     */
    public final class KeyframeUtil
    {

        /**
         * Adjusts the incoming and outgoing tangents of a set of keyframes to prevent sudden changes in speed and direction.
         * @param timeValues The array of time values, one per-keyframe.
         * @param keyframes The array of keyframe values.
         */
        public static function adjustForConstantSpeedScalar(timeValues:Vector.<Number>, keyframes:Vector.<CubicKeyScalar>) : void
        {
            // no need to adjust the first key at t = 0. j is always equal to i - 1.
            for (var i:int = 1,  j:int = 0; i < timeValues.length; ++i, ++j)
            {
                var timePrev:Number    = timeValues[j];
                var timeCurr:Number    = timeValues[i];
                var rcp:Number         = 1.0 / (timePrev + timeCurr);
                var key:CubicKeyScalar = keyframes[i];
                key.inTanX  *= (2.0 * timeCurr) * rcp;
                key.outTanX *= (2.0 * timePrev) * rcp;
            }
        }

        /**
         * Adjusts the incoming and outgoing tangents of a set of keyframes to prevent sudden changes in speed and direction.
         * @param timeValues The array of time values, one per-keyframe.
         * @param keyframes The array of keyframe values.
         */
        public static function adjustForConstantSpeedVec2(timeValues:Vector.<Number>, keyframes:Vector.<CubicKeyVec2>) : void
        {
            // no need to adjust the first key at t = 0. j is always equal to i - 1.
            for (var i:int = 1, j:int = 0; i < timeValues.length; ++i, ++j)
            {
                var timePrev:Number   = timeValues[j];
                var timeCurr:Number   = timeValues[i];
                var rcp:Number        = 1.0 / (timePrev + timeCurr);
                var sclIn:Number      = 2.0 *  timeCurr * rcp;
                var sclOut:Number     = 2.0 *  timePrev * rcp;
                var key:CubicKeyVec2  = keyframes[i];
                key.inTanX           *= sclIn;
                key.inTanY           *= sclIn;
                key.outTanX          *= sclOut;
                key.outTanY          *= sclOut;
            }
        }

        /**
         * Adjusts the incoming and outgoing tangents of a set of keyframes to prevent sudden changes in speed and direction.
         * @param timeValues The array of time values, one per-keyframe.
         * @param keyframes The array of keyframe values.
         */
        public static function adjustForConstantSpeedVec3(timeValues:Vector.<Number>, keyframes:Vector.<CubicKeyVec3>) : void
        {
            // no need to adjust the first key at t = 0. j is always equal to i - 1.
            for (var i:int = 1, j:int = 0; i < timeValues.length; ++i, ++j)
            {
                var timePrev:Number   = timeValues[j];
                var timeCurr:Number   = timeValues[i];
                var rcp:Number        = 1.0 / (timePrev + timeCurr);
                var sclIn:Number      = 2.0 *  timeCurr * rcp;
                var sclOut:Number     = 2.0 *  timePrev * rcp;
                var key:CubicKeyVec3  = keyframes[i];
                key.inTanX           *= sclIn;
                key.inTanY           *= sclIn;
                key.inTanZ           *= sclIn;
                key.outTanX          *= sclOut;
                key.outTanY          *= sclOut;
                key.outTanZ          *= sclOut;
            }
        }

        /**
         * Adjusts the incoming and outgoing tangents of a set of keyframes to prevent sudden changes in speed and direction.
         * @param timeValues The array of time values, one per-keyframe.
         * @param keyframes The array of keyframe values.
         */
        public static function adjustForConstantSpeedVec4(timeValues:Vector.<Number>, keyframes:Vector.<CubicKeyVec4>) : void
        {
            // no need to adjust the first key at t = 0. j is always equal to i - 1.
            for (var i:int = 1, j:int = 0; i < timeValues.length; ++i, ++j)
            {
                var timePrev:Number   = timeValues[j];
                var timeCurr:Number   = timeValues[i];
                var rcp:Number        = 1.0 / (timePrev + timeCurr);
                var sclIn:Number      = 2.0 *  timeCurr * rcp;
                var sclOut:Number     = 2.0 *  timePrev * rcp;
                var key:CubicKeyVec4  = keyframes[i];
                key.inTanX           *= sclIn;
                key.inTanY           *= sclIn;
                key.inTanZ           *= sclIn;
                key.inTanW           *= sclIn;
                key.outTanX          *= sclOut;
                key.outTanY          *= sclOut;
                key.outTanZ          *= sclOut;
                key.outTanW          *= sclOut;
            }
        }

        /**
         * Generates a catmull-rom spline from a set of keyframes originally intended for linear interpolation.
         * @param keyframes The input keyframes.
         * @return A corresponding set of keyframes that can be smoothly interpolated.
         */
        public static function catmullRomFromScalar(keyframes:Vector.<BasicKeyScalar>) : Vector.<CubicKeyScalar>
        {
            var result:Vector.<CubicKeyScalar> = new Vector.<CubicKeyScalar>(keyframes.length, keyframes.fixed);
            var keyPrev:BasicKeyScalar         = null;
            var keyNext:BasicKeyScalar         = null;
            var tan:Number                     = 0.0;
            var max:int                        = keyframes.length - 1;

            // compute the tangents for the middle keys:
            for (var i:int = 1; i < max; ++i)
            {
                var keyOut:CubicKeyScalar = new CubicKeyScalar();
                keyPrev = keyframes[i - 1];
                keyNext = keyframes[i + 1];
                tan     = 0.5 * (keyNext.x - keyPrev.x);
                keyOut.x       = keyframes[i].x;
                keyOut.inTanX  = tan;
                keyOut.outTanX = tan;
                result[i]      = keyOut;
            }

            // compute the tangents for the first and last keys:
            if (keyframes.length > 2)
            {
                // start key:
                keyPrev     = keyframes[0];
                keyNext     = keyframes[1];
                tan         = 0.5 * (keyNext.x - keyPrev.x);
                result[0]   = new CubicKeyScalar(keyframes[0].x, 0.0, tan);

                // end key:
                keyPrev     = keyframes[keyframes.length - 2];
                keyNext     = keyframes[keyframes.length - 1];
                tan         = 0.5 * (keyNext.x - keyPrev.x);
                result[max] = new CubicKeyScalar(keyNext.x, tan, 0.0);
            }
            else if (keyframes.length === 2)
            {
                keyPrev   = keyframes[0];
                keyNext   = keyframes[1];
                tan       = 0.5 * (keyNext.x - keyPrev.x);
                result[0] = new CubicKeyScalar(keyframes[0].x, 0.0, tan);
                result[1] = new CubicKeyScalar(keyframes[1].x, tan, 0.0);
            }
            else if (keyframes.length === 1)
            {
                // copy the value; tangents are zero.
                result[0] = new CubicKeyScalar(keyframes[0].x);
            }

            return result;
        }

        /**
         * Generates a catmull-rom spline from a set of keyframes originally intended for linear interpolation.
         * @param keyframes The input keyframes.
         * @return A corresponding set of keyframes that can be smoothly interpolated.
         */
        public static function catmullRomFromVec2(keyframes:Vector.<BasicKeyVec2>) : Vector.<CubicKeyVec2>
        {
            var result:Vector.<CubicKeyVec2> = new Vector.<CubicKeyVec2>(keyframes.length, keyframes.fixed);
            var keyPrev:BasicKeyVec2         = null;
            var keyCurr:BasicKeyVec2         = null;
            var keyNext:BasicKeyVec2         = null;
            var tanX:Number                  = 0.0;
            var tanY:Number                  = 0.0;
            var max:int                      = keyframes.length - 1;

            // compute the tangents for the middle keys:
            for (var i:int = 1; i < max; ++i)
            {
                var keyOut:CubicKeyVec2 = new CubicKeyVec2();
                keyCurr = keyframes[i];
                keyPrev = keyframes[i - 1];
                keyNext = keyframes[i + 1];
                tanX    = 0.5 * (keyNext.x - keyPrev.x);
                tanY    = 0.5 * (keyNext.y - keyPrev.y);
                keyOut.x       = keyCurr.x;
                keyOut.y       = keyCurr.y;
                keyOut.inTanX  = tanX;
                keyOut.inTanY  = tanY;
                keyOut.outTanX = tanX;
                keyOut.outTanY = tanY;
                result[i]      = keyOut;
            }

            // compute the tangents for the first and last keys:
            if (keyframes.length > 2)
            {
                // start key:
                keyPrev     = keyframes[0];
                keyCurr     = keyframes[0];
                keyNext     = keyframes[1];
                tanX        = 0.5 * (keyNext.x - keyPrev.x);
                tanY        = 0.5 * (keyNext.y - keyPrev.y);
                result[0]   = new CubicKeyVec2(keyCurr.x, keyCurr.y, 0.0, 0.0, tanX, tanY);

                // end key:
                keyPrev     = keyframes[keyframes.length - 2];
                keyNext     = keyframes[keyframes.length - 1];
                keyCurr     = keyframes[keyframes.length - 1];
                tanX        = 0.5 * (keyNext.x - keyPrev.x);
                tanY        = 0.5 * (keyNext.y - keyPrev.y);
                result[max] = new CubicKeyVec2(keyCurr.x, keyCurr.y, tanX, tanY, 0.0, 0.0);
            }
            else if (keyframes.length === 2)
            {
                keyPrev   = keyframes[0];
                keyNext   = keyframes[1];
                tanX      = 0.5 * (keyNext.x - keyPrev.x);
                tanY      = 0.5 * (keyNext.y - keyPrev.y);
                result[0] = new CubicKeyVec2(keyframes[0].x, keyframes[0].y, 0.0, 0.0, tanX, tanY);
                result[1] = new CubicKeyVec2(keyframes[1].x, keyframes[1].y, tanX, tanY, 0.0, 0.0);
            }
            else if (keyframes.length === 1)
            {
                // copy the value; tangents are zero.
                result[0] = new CubicKeyVec2(keyframes[0].x, keyframes[0].y);
            }

            return result;
        }

        /**
         * Generates a catmull-rom spline from a set of keyframes originally intended for linear interpolation.
         * @param keyframes The input keyframes.
         * @return A corresponding set of keyframes that can be smoothly interpolated.
         */
        public static function catmullRomFromVec3(keyframes:Vector.<BasicKeyVec3>) : Vector.<CubicKeyVec3>
        {
            var result:Vector.<CubicKeyVec3> = new Vector.<CubicKeyVec3>(keyframes.length, keyframes.fixed);
            var keyPrev:BasicKeyVec3         = null;
            var keyCurr:BasicKeyVec3         = null;
            var keyNext:BasicKeyVec3         = null;
            var tanX:Number                  = 0.0;
            var tanY:Number                  = 0.0;
            var tanZ:Number                  = 0.0;
            var max:int                      = keyframes.length - 1;

            // compute the tangents for the middle keys:
            for (var i:int = 1; i < max; ++i)
            {
                var keyOut:CubicKeyVec3 = new CubicKeyVec3();

                keyCurr = keyframes[i];
                keyPrev = keyframes[i - 1];
                keyNext = keyframes[i + 1];
                tanX    = 0.5 * (keyNext.x - keyPrev.x);
                tanY    = 0.5 * (keyNext.y - keyPrev.y);
                tanZ    = 0.5 * (keyNext.z - keyPrev.z);
                keyOut.x       = keyCurr.x;
                keyOut.y       = keyCurr.y;
                keyOut.z       = keyCurr.z;
                keyOut.inTanX  = tanX;
                keyOut.inTanY  = tanY;
                keyOut.inTanZ  = tanZ;
                keyOut.outTanX = tanX;
                keyOut.outTanY = tanY;
                keyOut.outTanZ = tanZ;
                result[i]      = keyOut;
            }

            // compute the tangents for the first and last keys:
            if (keyframes.length > 2)
            {
                // start key:
                keyPrev     = keyframes[0];
                keyCurr     = keyframes[0];
                keyNext     = keyframes[1];
                tanX        = 0.5 * (keyNext.x - keyPrev.x);
                tanY        = 0.5 * (keyNext.y - keyPrev.y);
                tanZ        = 0.5 * (keyNext.z - keyPrev.z);
                result[0]   = new CubicKeyVec3(keyCurr.x, keyCurr.y, keyCurr.z, 0.0, 0.0, 0.0, tanX, tanY, tanZ);

                // end key:
                keyPrev     = keyframes[keyframes.length - 2];
                keyNext     = keyframes[keyframes.length - 1];
                keyCurr     = keyframes[keyframes.length - 1];
                tanX        = 0.5 * (keyNext.x - keyPrev.x);
                tanY        = 0.5 * (keyNext.y - keyPrev.y);
                tanZ        = 0.5 * (keyNext.z - keyPrev.z);
                result[max] = new CubicKeyVec3(keyCurr.x, keyCurr.y, keyCurr.z, tanX, tanY, tanZ, 0.0, 0.0, 0.0);
            }
            else if (keyframes.length === 2)
            {
                keyPrev   = keyframes[0];
                keyNext   = keyframes[1];
                tanX      = 0.5 * (keyNext.x - keyPrev.x);
                tanY      = 0.5 * (keyNext.y - keyPrev.y);
                tanZ      = 0.5 * (keyNext.z - keyPrev.z);
                result[0] = new CubicKeyVec3(keyframes[0].x, keyframes[0].y, keyframes[0].z, 0.0, 0.0, 0.0, tanX, tanY, tanZ);
                result[1] = new CubicKeyVec3(keyframes[1].x, keyframes[1].y, keyframes[1].z, tanX, tanY, tanZ, 0.0, 0.0, 0.0);
            }
            else if (keyframes.length === 1)
            {
                // copy the value; tangents are zero.
                result[0] = new CubicKeyVec3(keyframes[0].x, keyframes[0].y, keyframes[0].z);
            }

            return result;
        }

        /**
         * Generates a catmull-rom spline from a set of keyframes originally intended for linear interpolation.
         * @param keyframes The input keyframes.
         * @return A corresponding set of keyframes that can be smoothly interpolated.
         */
        public static function catmullRomFromVec4(keyframes:Vector.<BasicKeyVec4>) : Vector.<CubicKeyVec4>
        {
            var result:Vector.<CubicKeyVec4> = new Vector.<CubicKeyVec4>(keyframes.length, keyframes.fixed);
            var keyPrev:BasicKeyVec4         = null;
            var keyCurr:BasicKeyVec4         = null;
            var keyNext:BasicKeyVec4         = null;
            var tanX:Number                  = 0.0;
            var tanY:Number                  = 0.0;
            var tanZ:Number                  = 0.0;
            var tanW:Number                  = 0.0;
            var max:int                      = keyframes.length - 1;

            // compute the tangents for the middle keys:
            for (var i:int = 1; i < max; ++i)
            {
                var keyOut:CubicKeyVec4 = new CubicKeyVec4();

                keyCurr = keyframes[i];
                keyPrev = keyframes[i - 1];
                keyNext = keyframes[i + 1];
                tanX    = 0.5 * (keyNext.x - keyPrev.x);
                tanY    = 0.5 * (keyNext.y - keyPrev.y);
                tanZ    = 0.5 * (keyNext.z - keyPrev.z);
                tanW    = 0.5 * (keyNext.w - keyPrev.w);
                keyOut.x       = keyCurr.x;
                keyOut.y       = keyCurr.y;
                keyOut.z       = keyCurr.z;
                keyOut.w       = keyCurr.w;
                keyOut.inTanX  = tanX;
                keyOut.inTanY  = tanY;
                keyOut.inTanZ  = tanZ;
                keyOut.inTanW  = tanW;
                keyOut.outTanX = tanX;
                keyOut.outTanY = tanY;
                keyOut.outTanZ = tanZ;
                keyOut.outTanW = tanW;
                result[i]      = keyOut;
            }

            // compute the tangents for the first and last keys:
            if (keyframes.length > 2)
            {
                // start key:
                keyPrev     = keyframes[0];
                keyCurr     = keyframes[0];
                keyNext     = keyframes[1];
                tanX        = 0.5 * (keyNext.x - keyPrev.x);
                tanY        = 0.5 * (keyNext.y - keyPrev.y);
                tanZ        = 0.5 * (keyNext.z - keyPrev.z);
                tanW        = 0.5 * (keyNext.w - keyPrev.w);
                result[0]   = new CubicKeyVec4(keyCurr.x, keyCurr.y, keyCurr.z, keyCurr.w, 0.0, 0.0, 0.0, 0.0, tanX, tanY, tanZ, tanW);

                // end key:
                keyPrev     = keyframes[keyframes.length - 2];
                keyNext     = keyframes[keyframes.length - 1];
                keyCurr     = keyframes[keyframes.length - 1];
                tanX        = 0.5 * (keyNext.x - keyPrev.x);
                tanY        = 0.5 * (keyNext.y - keyPrev.y);
                tanZ        = 0.5 * (keyNext.z - keyPrev.z);
                tanW        = 0.5 * (keyNext.w - keyPrev.w);
                result[max] = new CubicKeyVec4(keyCurr.x, keyCurr.y, keyCurr.z, keyCurr.w, tanX, tanY, tanZ, tanW, 0.0, 0.0, 0.0, 0.0);
            }
            else if (keyframes.length === 2)
            {
                keyPrev   = keyframes[0];
                keyNext   = keyframes[1];
                tanX      = 0.5 * (keyNext.x - keyPrev.x);
                tanY      = 0.5 * (keyNext.y - keyPrev.y);
                tanZ      = 0.5 * (keyNext.z - keyPrev.z);
                tanW      = 0.5 * (keyNext.w - keyPrev.w);
                result[0] = new CubicKeyVec4(keyframes[0].x, keyframes[0].y, keyframes[0].z, keyframes[0].w, 0.0, 0.0, 0.0, 0.0, tanX, tanY, tanZ, tanW);
                result[1] = new CubicKeyVec4(keyframes[1].x, keyframes[1].y, keyframes[1].z, keyframes[1].w, tanX, tanY, tanZ, tanW, 0.0, 0.0, 0.0, 0.0);
            }
            else if (keyframes.length === 1)
            {
                // copy the value; tangents are zero.
                result[0] = new CubicKeyVec4(keyframes[0].x, keyframes[0].y, keyframes[0].z, keyframes[0].w);
            }

            return result;
        }

        /**
         * Converts a set of keyframes specified with tension-continuity-bias form into standard keyframes that can be interpolated.
         * @param keyframes The set of TCB keyframes.
         * @return The corresponding set of cubic keyframes.
         */
        private static function tcbToCubicScalar(keyframes:Vector.<TcbKeyScalar>) : Vector.<CubicKeyScalar>
        {
            var result:Vector.<CubicKeyScalar> = new Vector.<CubicKeyScalar>(keyframes.length, keyframes.fixed);
            var keyPrev:TcbKeyScalar           = null;
            var keyCurr:TcbKeyScalar           = null;
            var keyNext:TcbKeyScalar           = null;
            var inCoeff0:Number                = 0.0;
            var inCoeff1:Number                = 0.0;
            var outCoeff0:Number               = 0.0;
            var outCoeff1:Number               = 0.0;
            var inTan:Number                   = 0.0;
            var outTan:Number                  = 0.0;
            var vp:Number                      = 0.0;
            var vc:Number                      = 0.0;
            var vn:Number                      = 0.0;
            var max:int                        = keyframes.length - 1;

            // compute the tangents for the middle keys:
            for (var i:int = 1; i < max; ++i)
            {
                var keyOut:CubicKeyScalar = new CubicKeyScalar();
                var t:Number = 0.0;
                var c:Number = 0.0;
                var b:Number = 0.0;
                keyCurr   = keyframes[i];
                keyPrev   = keyframes[i - 1];
                keyNext   = keyframes[i + 1];
                t         = keyCurr.tension;
                c         = keyCurr.continuity;
                b         = keyCurr.bias;
                vc        = keyCurr.x;
                vp        = keyPrev.x;
                vn        = keyNext.x;
                inCoeff0  = 0.5 * ((1.0 - t) * (1.0 - c) * (1.0 + b));
                inCoeff1  = 0.5 * ((1.0 - t) * (1.0 + c) * (1.0 - b));
                outCoeff0 = 0.5 * ((1.0 - t) * (1.0 + c) * (1.0 + b));
                outCoeff1 = 0.5 * ((1.0 - t) * (1.0 - c) * (1.0 - b));
                keyOut.x        = vc;
                keyOut.inTanX   = inCoeff0  * (vc - vp) + inCoeff1  * (vn - vc);
                keyOut.outTanX  = outCoeff0 * (vc - vp) + outCoeff1 * (vn - vc);
                result[i]       = keyOut;
            }

            // compute the tangents for the first and last keys:
            if (keyframes.length > 2)
            {
                // start key:
                keyPrev     = keyframes[0];
                keyCurr     = keyframes[0];
                keyNext     = keyframes[1];
                vc          = keyCurr.x;
                vp          = keyPrev.x;
                vn          = keyNext.x;
                outTan      = ((vn - vc) * 1.5 - (result[1].inTanX * 0.5) * (1.0 - keyCurr.tension));
                result[0]   = new CubicKeyScalar(keyframes[0].x, 0.0, outTan);

                // end key:
                keyPrev     = keyframes[keyframes.length - 2];
                keyCurr     = keyframes[keyframes.length - 1];
                keyNext     = keyframes[keyframes.length - 1];
                vc          = keyCurr.x;
                vp          = keyPrev.x;
                vn          = keyNext.x;
                inTan       = ((vc - vp) * 1.5 - (result[max-1].outTanX * 0.5) * (1.0 - keyCurr.tension));
                result[max] = new CubicKeyScalar(keyNext.x, inTan, 0.0);
            }
            else if (keyframes.length === 2)
            {
                keyCurr     = keyframes[0];
                keyNext     = keyframes[1];
                outTan      = ((keyNext.x - keyCurr.x) * (1.0 - keyCurr.tension));
                inTan       = ((keyNext.x - keyCurr.x) * (1.0 - keyNext.tension));
                result[0]   = new CubicKeyScalar(keyCurr.x, 0.0, outTan);
                result[1]   = new CubicKeyScalar(keyNext.x, inTan, 0.0);
            }
            else if (keyframes.length === 1)
            {
                // copy the value; tangents are zero.
                result[0] = new CubicKeyScalar(keyframes[0].x);
            }

            return result;
        }

        /**
         * Converts a set of keyframes specified with tension-continuity-bias form into standard keyframes that can be interpolated.
         * @param keyframes The set of TCB keyframes.
         * @return The corresponding set of cubic keyframes.
         */
        private static function tcbToCubicVec2(keyframes:Vector.<TcbKeyVec2>) : Vector.<CubicKeyVec2>
        {
            var result:Vector.<CubicKeyVec2> = new Vector.<CubicKeyVec2>(keyframes.length, keyframes.fixed);
            var keyPrev:TcbKeyVec2           = null;
            var keyCurr:TcbKeyVec2           = null;
            var keyNext:TcbKeyVec2           = null;
            var inCoeff0:Number              = 0.0;
            var inCoeff1:Number              = 0.0;
            var outCoeff0:Number             = 0.0;
            var outCoeff1:Number             = 0.0;
            var inTanX:Number                = 0.0;
            var inTanY:Number                = 0.0;
            var outTanX:Number               = 0.0;
            var outTanY:Number               = 0.0;
            var vpx:Number                   = 0.0;
            var vpy:Number                   = 0.0;
            var vcx:Number                   = 0.0;
            var vcy:Number                   = 0.0;
            var vnx:Number                   = 0.0;
            var vny:Number                   = 0.0;
            var max:int                      = keyframes.length - 1;

            // compute the tangents for the middle keys:
            for (var i:int = 1; i < max; ++i)
            {
                var keyOut:CubicKeyVec2 = new CubicKeyVec2();
                var t:Number = 0.0;
                var c:Number = 0.0;
                var b:Number = 0.0;
                keyCurr   = keyframes[i];
                keyPrev   = keyframes[i - 1];
                keyNext   = keyframes[i + 1];
                t         = keyCurr.tension;
                c         = keyCurr.continuity;
                b         = keyCurr.bias;
                vcx       = keyCurr.x; vcy = keyCurr.y;
                vpx       = keyPrev.x; vpy = keyPrev.y;
                vnx       = keyNext.x; vny = keyNext.y;
                inCoeff0  = 0.5 * ((1.0 - t) * (1.0 - c) * (1.0 + b));
                inCoeff1  = 0.5 * ((1.0 - t) * (1.0 + c) * (1.0 - b));
                outCoeff0 = 0.5 * ((1.0 - t) * (1.0 + c) * (1.0 + b));
                outCoeff1 = 0.5 * ((1.0 - t) * (1.0 - c) * (1.0 - b));
                keyOut.x        = vcx;
                keyOut.y        = vcy;
                keyOut.inTanX   = inCoeff0  * (vcx - vpx) + inCoeff1  * (vnx - vcx);
                keyOut.inTanY   = inCoeff0  * (vcy - vpy) + inCoeff1  * (vny - vcy);
                keyOut.outTanX  = outCoeff0 * (vcx - vpx) + outCoeff1 * (vnx - vcx);
                keyOut.outTanY  = outCoeff0 * (vcy - vpy) + outCoeff1 * (vny - vcy);
                result[i]       = keyOut;
            }

            // compute the tangents for the first and last keys:
            if (keyframes.length > 2)
            {
                // start key:
                keyPrev     = keyframes[0];
                keyCurr     = keyframes[0];
                keyNext     = keyframes[1];
                vcx         = keyCurr.x; vcy = keyCurr.y;
                vpx         = keyPrev.x; vpy = keyPrev.y;
                vnx         = keyNext.x; vny = keyNext.y;
                outTanX     = ((vnx - vcx) * 1.5 - (result[1].inTanX * 0.5) * (1.0 - keyCurr.tension));
                outTanY     = ((vny - vcy) * 1.5 - (result[1].inTanY * 0.5) * (1.0 - keyCurr.tension));
                result[0]   = new CubicKeyVec2(vcx, vcy, 0.0, 0.0, outTanX, outTanY);

                // end key:
                keyPrev     = keyframes[keyframes.length - 2];
                keyCurr     = keyframes[keyframes.length - 1];
                keyNext     = keyframes[keyframes.length - 1];
                vcx         = keyCurr.x; vcy = keyCurr.y;
                vpx         = keyPrev.x; vpy = keyPrev.y;
                vnx         = keyNext.x; vny = keyNext.y;
                inTanX      = ((vcx - vpx) * 1.5 - (result[max-1].outTanX * 0.5) * (1.0 - keyCurr.tension));
                inTanY      = ((vcy - vpy) * 1.5 - (result[max-1].outTanY * 0.5) * (1.0 - keyCurr.tension));
                result[max] = new CubicKeyVec2(vcx, vcy, inTanX, inTanY, 0.0, 0.0);
            }
            else if (keyframes.length === 2)
            {
                keyCurr     = keyframes[0];
                keyNext     = keyframes[1];
                outTanX     = ((keyNext.x - keyCurr.x) * (1.0 - keyCurr.tension));
                outTanY     = ((keyNext.y - keyCurr.y) * (1.0 - keyCurr.tension));
                inTanX      = ((keyNext.x - keyCurr.x) * (1.0 - keyNext.tension));
                inTanY      = ((keyNext.y - keyCurr.y) * (1.0 - keyNext.tension));
                result[0]   = new CubicKeyVec2(keyCurr.x, keyCurr.y, 0.0, 0.0, outTanX, outTanY);
                result[1]   = new CubicKeyVec2(keyNext.x, keyNext.y, inTanX, inTanY, 0.0, 0.0);
            }
            else if (keyframes.length === 1)
            {
                // copy the value; tangents are zero.
                result[0] = new CubicKeyVec2(keyframes[0].x, keyframes[0].y);
            }

            return result;
        }

        /**
         * Converts a set of keyframes specified with tension-continuity-bias form into standard keyframes that can be interpolated.
         * @param keyframes The set of TCB keyframes.
         * @return The corresponding set of cubic keyframes.
         */
        private static function tcbToCubicVec3(keyframes:Vector.<TcbKeyVec3>) : Vector.<CubicKeyVec3>
        {
            var result:Vector.<CubicKeyVec3> = new Vector.<CubicKeyVec3>(keyframes.length, keyframes.fixed);
            var keyPrev:TcbKeyVec3           = null;
            var keyCurr:TcbKeyVec3           = null;
            var keyNext:TcbKeyVec3           = null;
            var inCoeff0:Number              = 0.0;
            var inCoeff1:Number              = 0.0;
            var outCoeff0:Number             = 0.0;
            var outCoeff1:Number             = 0.0;
            var inTanX:Number                = 0.0;
            var inTanY:Number                = 0.0;
            var inTanZ:Number                = 0.0;
            var outTanX:Number               = 0.0;
            var outTanY:Number               = 0.0;
            var outTanZ:Number               = 0.0;
            var vpx:Number                   = 0.0;
            var vpy:Number                   = 0.0;
            var vpz:Number                   = 0.0;
            var vcx:Number                   = 0.0;
            var vcy:Number                   = 0.0;
            var vcz:Number                   = 0.0;
            var vnx:Number                   = 0.0;
            var vny:Number                   = 0.0;
            var vnz:Number                   = 0.0;
            var max:int                      = keyframes.length - 1;

            // compute the tangents for the middle keys:
            for (var i:int = 1; i < max; ++i)
            {
                var keyOut:CubicKeyVec3 = new CubicKeyVec3();
                var t:Number = 0.0;
                var c:Number = 0.0;
                var b:Number = 0.0;
                keyCurr   = keyframes[i];
                keyPrev   = keyframes[i - 1];
                keyNext   = keyframes[i + 1];
                t         = keyCurr.tension;
                c         = keyCurr.continuity;
                b         = keyCurr.bias;
                vcx       = keyCurr.x; vcy = keyCurr.y; vcz = keyCurr.z;
                vpx       = keyPrev.x; vpy = keyPrev.y; vpz = keyPrev.z;
                vnx       = keyNext.x; vny = keyNext.y; vnz = keyNext.z;
                inCoeff0  = 0.5 * ((1.0 - t) * (1.0 - c) * (1.0 + b));
                inCoeff1  = 0.5 * ((1.0 - t) * (1.0 + c) * (1.0 - b));
                outCoeff0 = 0.5 * ((1.0 - t) * (1.0 + c) * (1.0 + b));
                outCoeff1 = 0.5 * ((1.0 - t) * (1.0 - c) * (1.0 - b));
                keyOut.x        = vcx;
                keyOut.y        = vcy;
                keyOut.z        = vcz;
                keyOut.inTanX   = inCoeff0  * (vcx - vpx) + inCoeff1  * (vnx - vcx);
                keyOut.inTanY   = inCoeff0  * (vcy - vpy) + inCoeff1  * (vny - vcy);
                keyOut.inTanZ   = inCoeff0  * (vcz - vpz) + inCoeff1  * (vnz - vcz);
                keyOut.outTanX  = outCoeff0 * (vcx - vpx) + outCoeff1 * (vnx - vcx);
                keyOut.outTanY  = outCoeff0 * (vcy - vpy) + outCoeff1 * (vny - vcy);
                keyOut.outTanZ  = outCoeff0 * (vcz - vpz) + outCoeff1 * (vnz - vcz);
                result[i]       = keyOut;
            }

            // compute the tangents for the first and last keys:
            if (keyframes.length > 2)
            {
                // start key:
                keyPrev     = keyframes[0];
                keyCurr     = keyframes[0];
                keyNext     = keyframes[1];
                vcx         = keyCurr.x; vcy = keyCurr.y; vcz = keyCurr.z;
                vpx         = keyPrev.x; vpy = keyPrev.y; vpz = keyPrev.z;
                vnx         = keyNext.x; vny = keyNext.y; vnz = keyNext.z;
                outTanX     = ((vnx - vcx) * 1.5 - (result[1].inTanX * 0.5) * (1.0 - keyCurr.tension));
                outTanY     = ((vny - vcy) * 1.5 - (result[1].inTanY * 0.5) * (1.0 - keyCurr.tension));
                outTanZ     = ((vnz - vcz) * 1.5 - (result[1].inTanZ * 0.5) * (1.0 - keyCurr.tension));
                result[0]   = new CubicKeyVec3(vcx, vcy, vcz, 0.0, 0.0, 0.0, outTanX, outTanY, outTanZ);

                // end key:
                keyPrev     = keyframes[keyframes.length - 2];
                keyCurr     = keyframes[keyframes.length - 1];
                keyNext     = keyframes[keyframes.length - 1];
                vcx         = keyCurr.x; vcy = keyCurr.y; vcz = keyCurr.z;
                vpx         = keyPrev.x; vpy = keyPrev.y; vpz = keyPrev.z;
                vnx         = keyNext.x; vny = keyNext.y; vnz = keyNext.z;
                inTanX      = ((vcx - vpx) * 1.5 - (result[max-1].outTanX * 0.5) * (1.0 - keyCurr.tension));
                inTanY      = ((vcy - vpy) * 1.5 - (result[max-1].outTanY * 0.5) * (1.0 - keyCurr.tension));
                inTanZ      = ((vcz - vpz) * 1.5 - (result[max-1].outTanZ * 0.5) * (1.0 - keyCurr.tension));
                result[max] = new CubicKeyVec3(vcx, vcy, vcz, inTanX, inTanY, inTanZ, 0.0, 0.0, 0.0);
            }
            else if (keyframes.length === 2)
            {
                keyCurr     = keyframes[0];
                keyNext     = keyframes[1];
                outTanX     = ((keyNext.x - keyCurr.x) * (1.0 - keyCurr.tension));
                outTanY     = ((keyNext.y - keyCurr.y) * (1.0 - keyCurr.tension));
                outTanZ     = ((keyNext.z - keyCurr.z) * (1.0 - keyCurr.tension));
                inTanX      = ((keyNext.x - keyCurr.x) * (1.0 - keyNext.tension));
                inTanY      = ((keyNext.y - keyCurr.y) * (1.0 - keyNext.tension));
                inTanZ      = ((keyNext.z - keyCurr.z) * (1.0 - keyNext.tension));
                result[0]   = new CubicKeyVec3(keyCurr.x, keyCurr.y, keyCurr.z, 0.0, 0.0, 0.0, outTanX, outTanY, outTanZ);
                result[1]   = new CubicKeyVec3(keyNext.x, keyNext.y, keyNext.z, inTanX, inTanY, inTanZ, 0.0, 0.0, 0.0);
            }
            else if (keyframes.length === 1)
            {
                // copy the value; tangents are zero.
                result[0] = new CubicKeyVec3(keyframes[0].x, keyframes[0].y, keyframes[0].z);
            }

            return result;
        }

        /**
         * Converts a set of keyframes specified with tension-continuity-bias form into standard keyframes that can be interpolated.
         * @param keyframes The set of TCB keyframes.
         * @return The corresponding set of cubic keyframes.
         */
        private static function tcbToCubicVec4(keyframes:Vector.<TcbKeyVec4>) : Vector.<CubicKeyVec4>
        {
            var result:Vector.<CubicKeyVec4> = new Vector.<CubicKeyVec4>(keyframes.length, keyframes.fixed);
            var keyPrev:TcbKeyVec4           = null;
            var keyCurr:TcbKeyVec4           = null;
            var keyNext:TcbKeyVec4           = null;
            var inCoeff0:Number              = 0.0;
            var inCoeff1:Number              = 0.0;
            var outCoeff0:Number             = 0.0;
            var outCoeff1:Number             = 0.0;
            var inTanX:Number                = 0.0;
            var inTanY:Number                = 0.0;
            var inTanZ:Number                = 0.0;
            var inTanW:Number                = 0.0;
            var outTanX:Number               = 0.0;
            var outTanY:Number               = 0.0;
            var outTanZ:Number               = 0.0;
            var outTanW:Number               = 0.0;
            var vpx:Number                   = 0.0;
            var vpy:Number                   = 0.0;
            var vpz:Number                   = 0.0;
            var vpw:Number                   = 0.0;
            var vcx:Number                   = 0.0;
            var vcy:Number                   = 0.0;
            var vcz:Number                   = 0.0;
            var vcw:Number                   = 0.0;
            var vnx:Number                   = 0.0;
            var vny:Number                   = 0.0;
            var vnz:Number                   = 0.0;
            var vnw:Number                   = 0.0;
            var max:int                      = keyframes.length - 1;

            // compute the tangents for the middle keys:
            for (var i:int = 1; i < max; ++i)
            {
                var keyOut:CubicKeyVec4 = new CubicKeyVec4();
                var t:Number = 0.0;
                var c:Number = 0.0;
                var b:Number = 0.0;
                keyCurr   = keyframes[i];
                keyPrev   = keyframes[i - 1];
                keyNext   = keyframes[i + 1];
                t         = keyCurr.tension;
                c         = keyCurr.continuity;
                b         = keyCurr.bias;
                vcx       = keyCurr.x; vcy = keyCurr.y; vcz = keyCurr.z; vcw = keyCurr.w;
                vpx       = keyPrev.x; vpy = keyPrev.y; vpz = keyPrev.z; vpw = keyPrev.w;
                vnx       = keyNext.x; vny = keyNext.y; vnz = keyNext.z; vnw = keyNext.w;
                inCoeff0  = 0.5 * ((1.0 - t) * (1.0 - c) * (1.0 + b));
                inCoeff1  = 0.5 * ((1.0 - t) * (1.0 + c) * (1.0 - b));
                outCoeff0 = 0.5 * ((1.0 - t) * (1.0 + c) * (1.0 + b));
                outCoeff1 = 0.5 * ((1.0 - t) * (1.0 - c) * (1.0 - b));
                keyOut.x        = vcx;
                keyOut.y        = vcy;
                keyOut.z        = vcz;
                keyOut.w        = vcw;
                keyOut.inTanX   = inCoeff0  * (vcx - vpx) + inCoeff1  * (vnx - vcx);
                keyOut.inTanY   = inCoeff0  * (vcy - vpy) + inCoeff1  * (vny - vcy);
                keyOut.inTanZ   = inCoeff0  * (vcz - vpz) + inCoeff1  * (vnz - vcz);
                keyOut.inTanW   = inCoeff0  * (vcw - vpw) + inCoeff1  * (vnw - vcw);
                keyOut.outTanX  = outCoeff0 * (vcx - vpx) + outCoeff1 * (vnx - vcx);
                keyOut.outTanY  = outCoeff0 * (vcy - vpy) + outCoeff1 * (vny - vcy);
                keyOut.outTanZ  = outCoeff0 * (vcz - vpz) + outCoeff1 * (vnz - vcz);
                keyOut.outTanW  = outCoeff0 * (vcw - vpw) + outCoeff1 * (vnw - vcw);
                result[i]       = keyOut;
            }
            // compute the tangents for the first and last keys:
            if (keyframes.length > 2)
            {
                // start key:
                keyPrev     = keyframes[0];
                keyCurr     = keyframes[0];
                keyNext     = keyframes[1];
                vcx         = keyCurr.x; vcy = keyCurr.y; vcz = keyCurr.z; vcw = keyCurr.w;
                vpx         = keyPrev.x; vpy = keyPrev.y; vpz = keyPrev.z; vpw = keyPrev.w;
                vnx         = keyNext.x; vny = keyNext.y; vnz = keyNext.z; vnw = keyNext.w;
                outTanX     = ((vnx - vcx) * 1.5 - (result[1].inTanX * 0.5) * (1.0 - keyCurr.tension));
                outTanY     = ((vny - vcy) * 1.5 - (result[1].inTanY * 0.5) * (1.0 - keyCurr.tension));
                outTanZ     = ((vnz - vcz) * 1.5 - (result[1].inTanZ * 0.5) * (1.0 - keyCurr.tension));
                outTanW     = ((vnw - vcw) * 1.5 - (result[1].inTanW * 0.5) * (1.0 - keyCurr.tension));
                result[0]   = new CubicKeyVec4(vcx, vcy, vcz, vcw, 0.0, 0.0, 0.0, 0.0, outTanX, outTanY, outTanZ, outTanW);

                // end key:
                keyPrev     = keyframes[keyframes.length - 2];
                keyCurr     = keyframes[keyframes.length - 1];
                keyNext     = keyframes[keyframes.length - 1];
                vcx         = keyCurr.x; vcy = keyCurr.y; vcz = keyCurr.z; vcw = keyCurr.w;
                vpx         = keyPrev.x; vpy = keyPrev.y; vpz = keyPrev.z; vpw = keyPrev.w;
                vnx         = keyNext.x; vny = keyNext.y; vnz = keyNext.z; vnw = keyNext.w;
                inTanX      = ((vcx - vpx) * 1.5 - (result[max-1].outTanX * 0.5) * (1.0 - keyCurr.tension));
                inTanY      = ((vcy - vpy) * 1.5 - (result[max-1].outTanY * 0.5) * (1.0 - keyCurr.tension));
                inTanZ      = ((vcz - vpz) * 1.5 - (result[max-1].outTanZ * 0.5) * (1.0 - keyCurr.tension));
                inTanW      = ((vcw - vpw) * 1.5 - (result[max-1].outTanW * 0.5) * (1.0 - keyCurr.tension));
                result[max] = new CubicKeyVec4(vcx, vcy, vcz, vcw, inTanX, inTanY, inTanZ, inTanW, 0.0, 0.0, 0.0, 0.0);
            }
            else if (keyframes.length === 2)
            {
                keyCurr     = keyframes[0];
                keyNext     = keyframes[1];
                outTanX     = ((keyNext.x - keyCurr.x) * (1.0 - keyCurr.tension));
                outTanY     = ((keyNext.y - keyCurr.y) * (1.0 - keyCurr.tension));
                outTanZ     = ((keyNext.z - keyCurr.z) * (1.0 - keyCurr.tension));
                outTanW     = ((keyNext.w - keyCurr.w) * (1.0 - keyCurr.tension));
                inTanX      = ((keyNext.x - keyCurr.x) * (1.0 - keyNext.tension));
                inTanY      = ((keyNext.y - keyCurr.y) * (1.0 - keyNext.tension));
                inTanZ      = ((keyNext.z - keyCurr.z) * (1.0 - keyNext.tension));
                inTanZ      = ((keyNext.w - keyCurr.w) * (1.0 - keyNext.tension));
                result[0]   = new CubicKeyVec4(keyCurr.x, keyCurr.y, keyCurr.z, keyCurr.w, 0.0, 0.0, 0.0, 0.0, outTanX, outTanY, outTanZ, outTanW);
                result[1]   = new CubicKeyVec4(keyNext.x, keyNext.y, keyNext.z, keyNext.w, inTanX, inTanY, inTanZ, inTanW, 0.0, 0.0, 0.0, 0.0);
            }
            else if (keyframes.length === 1)
            {
                // copy the value; tangents are zero.
                result[0] = new CubicKeyVec4(keyframes[0].x, keyframes[0].y, keyframes[0].z, keyframes[0].w);
            }

            return result;
        }
    }
}
