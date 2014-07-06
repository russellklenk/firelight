package com.ninjabird.firelight.renderer.states
{
    import flash.geom.Rectangle;
    import flash.display3D.Context3DTriangleFace;

    /**
     * Encapsulates render state associated with primitive rasterization.
     */
    public final class RasterState
    {
        /**
         * Specifies whether writes to the red channel are enabled.
         */
        public var writeR:Boolean;

        /**
         * Specifies whether writes to the green channel are enabled.
         */
        public var writeG:Boolean

        /**
         * Specifies whether writes to the blue channel are enabled.
         */
        public var writeB:Boolean;

        /**
         * Specifies whether writes to the alpha channel are enabled.
         */
        public var writeA:Boolean;

        /**
         * One of the values of the Context3DTriangleFace enumeration.
         */
        public var cullFace:String;

        /**
         * The scissor rectangle. This is always a valid flash.geom.Rectangle.
         * Use the RasterState.scissorTestEnabled flag to specify whether the
         * scissor test should be enabled.
         */
        public var scissor:Rectangle;

        /**
         * Specifies whether the scissor test is enabled.
         */
        public var scissorTestEnabled:Boolean;

        /**
         * Constructs a new instance initialized with the specified state.
         */
        public function RasterState(cullMode:String=Context3DTriangleFace.NONE, writeRed:Boolean=true, writeGreen:Boolean=true, writeBlue:Boolean=true, writeAlpha:Boolean=true)
        {
            this.writeR   = writeRed;
            this.writeG   = writeGreen;
            this.writeB   = writeBlue;
            this.writeA   = writeAlpha;
            this.cullFace = cullMode;
            this.scissor  = new Rectangle();
            this.scissorTestEnabled = false;
        }

        /**
         * Compares two instances to deteremine whether they represent the same
         * state values.
         * @param other The instance to compare to.
         * @return true if the state values are identical.
         */
        public function equalTo(other:RasterState) : Boolean
        {
            if (!other) return false;
            if (this.scissorTestEnabled !== other.scissorTestEnabled) return false;
            if (this.cullFace !== other.cullFace) return false;
            if (this.writeR !== other.writeR) return false;
            if (this.writeG !== other.writeG) return false;
            if (this.writeB !== other.writeB) return false;
            if (this.writeA !== other.writeA) return false;
            if (this.scissor.x !== other.scissor.x) return false;
            if (this.scissor.y !== other.scissor.y) return false;
            if (this.scissor.width !== other.scissor.width) return false;
            if (this.scissor.height !== other.scissor.height) return false;
            return true;
        }
    }
}
