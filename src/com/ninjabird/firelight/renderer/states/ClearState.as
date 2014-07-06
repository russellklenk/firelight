package com.ninjabird.firelight.renderer.states
{
    import flash.display3D.Context3DClearMask;

    /**
     * Specifies the clear color for the color buffer and clear values for the
     * depth and stencil buffers.
     */
    public final class ClearState
    {
        /**
         * The red channel value to set, in [0, 1].
         */
        public var r:Number;

        /**
         * The green channel value to set, in [0, 1].
         */
        public var g:Number;

        /**
         * The blue channel value to set, in [0, 1].
         */
        public var b:Number;

        /**
         * The alpha channel value to set, in [0, 1].
         */
        public var a:Number;

        /**
         * The depth buffer value to set, in [0, 1].
         */
        public var depth:Number;

        /**
         * The stencil value to set, in [0, 1].
         */
        public var stencil:uint;

        /**
         * The bitwise OR of flash.display3D.Context3DClearMask values
         * indicating which buffers should be cleared. For best performance,
         * the depth and stencil buffers should always be cleared at the same time.
         */
        public var mask:uint;

        /**
         * Constructs a new instance initialized with the specified clear
         * values. By default, the color, depth and stencil buffer are cleared.
         * @param R The red channel value of the color buffer, in [0, 1].
         * @param G The green channel value of the color buffer, in [0, 1].
         * @param B The blue channel value of the color buffer, in [0, 1].
         * @param A The alpha channel value of the color buffer, in [0, 1].
         * @param Depth The depth buffer clear value, in [0, 1].
         * @param Stencil The stencil buffer clear value, in [0, 255].
         */
        public function ClearState(R:Number=0.0, G:Number=0.0, B:Number=0.0, A:Number=0.0, Depth:Number=1.0, Stencil:uint=0xFF)
        {
            this.r = R;
            this.g = G;
            this.b = B;
            this.a = A;
            this.depth = Depth;
            this.stencil = Stencil;
            this.mask = Context3DClearMask.ALL;
        }

        /**
         * Compares two instances to determine whether they represent the same state values.
         * @param other The instance to compare to.
         * @return true if the state values are identical.
         */
        public function equalTo(other:ClearState) : Boolean
        {
            if (!other) return false;
            if (this.mask !== other.mask) return false;
            if (this.stencil !== other.stencil) return false;
            if (this.depth !== other.depth) return false;
            if (this.r !== other.r) return false;
            if (this.g !== other.g) return false;
            if (this.b !== other.b) return false;
            if (this.a !== other.a) return false;
            return true;
        }
    }
}
