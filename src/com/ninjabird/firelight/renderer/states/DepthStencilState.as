package com.ninjabird.firelight.renderer.states
{
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DTriangleFace;
    import flash.display3D.Context3DStencilAction;

    /**
     * Encapsulates the render state associated with depth and stencil testing.
     */
    public final class DepthStencilState
    {
        /**
         * Specifies whether writes to the depth buffer are enabled.
         */
        public var depthWriteEnabled:Boolean;

        /**
         * One of the values of the Context3DCompareMode enumeration, specifying
         * how the depth test should be performed.
         */
        public var depthFunction:String;

        /**
         * Specifies whether stencil testing is enabled.
         */
        public var stencilTestEnabled:Boolean;

        /**
         * One of the values of the Context3DCompareMode enumeration, specifying
         * how the stencil test should be performed.
         */
        public var stencilFunction:String;

        /**
         * One of the values of the Context3DTriangleFace enumeration,
         * specifying which faces of the triangle perform the stencil operation.
         */
        public var stencilFace:String;

        /**
         * One of the values of the Context3DStencilAction enumeration,
         * specifying the action to take when both the stencil and depth tests pass.
         */
        public var stencilPassZPassOp:String;

        /**
         * One of the values of the Context3DStencilAction enumeration,
         * specifying the action to take when both the stencil test passes,
         * but the depth test fails.
         */
        public var stencilPassZFailOp:String;

        /**
         * One of the values of the Context3DStencilAction enumeration,
         * specifying the action to take when both the stencil test fails,
         * but the depth test passes.
         */
        public var stencilFailZPassOp:String;

        /**
         * The stencil reference value, used during the stencil test.
         */
        public var stencilReference:uint;

        /**
         * An 8-bit mask applied to both the stencil value and the reference
         * value prior to performing the stencil test.
         */
        public var stencilReadMask:uint;

        /**
         * An 8-bit mask applied before updating the stored stencil value.
         */
        public var stencilWriteMask:uint;

        /**
         * Constructs a new instance with the specified state.
         * @param depthWrite true to enable writes to the depth buffer.
         * @param depthFunc One of the values of the Context3DCompareMode
         * enumeration, specifying how the depth test should be performed.
         * @param stencilTest true to enable stencil testing.
         * @param stencilFunc One of the values of the Context3DCompareMode
         * enumeration, specifying how the stencil test should be performed.
         * @param stencilFaces One of the values of the Context3DTriangleFace
         * enumeration, specifying which faces of the triangle perform the
         * stencil operation.
         * @param bothPassOp One of the values of the Context3DStencilAction
         * enumeration, specifying what to do with the stencil value when both
         * the stencil test and the depth test pass.
         * @param zFailOp One of the values of the Context3DStencilAction
         * enumeration, specifying what to do with the stencil value when the
         * stencil test passes but the depth test fails.
         * @param stencilFailOp One of the values of the Context3DStencilAction
         * enumeration, specifying what to do with the stencil value when the
         * @param stencilRef The reference value used during the stencil test.
         * @param readMask The 8-bit mask to apply when reading values prior to
         * performing the stencil test.
         * @param writeMask The 8-bit mask to apply when writing values to the
         * stencil buffer.
         */
        public function DepthStencilState(
            depthWrite:Boolean=true,
            depthFunc:String=Context3DCompareMode.LESS,
            stencilTest:Boolean=false,
            stencilFunc:String=Context3DCompareMode.ALWAYS,
            stencilFaces:String=Context3DTriangleFace.FRONT_AND_BACK,
            bothPassOp:String=Context3DStencilAction.KEEP,
            zFailOp:String=Context3DStencilAction.KEEP,
            stencilFailOp:String=Context3DStencilAction.KEEP,
            stencilRef:uint=0,
            readMask:uint=0xFF,
            writeMask:uint=0xFF)
        {
            this.depthWriteEnabled  = depthWrite;
            this.depthFunction      = depthFunc;
            this.stencilTestEnabled = stencilTest;
            this.stencilFunction    = stencilFunc;
            this.stencilFace        = stencilFaces;
            this.stencilPassZPassOp = bothPassOp;
            this.stencilPassZFailOp = zFailOp;
            this.stencilFailZPassOp = stencilFailOp;
            this.stencilReference   = stencilRef;
            this.stencilReadMask    = readMask;
            this.stencilWriteMask   = writeMask;
        }

        /**
         * Compares two instances to deteremine whether they represent the same state values.
         * @param other The instance to compare to.
         * @return true if the state values are identical.
         */
        public function equalTo(other:DepthStencilState) : Boolean
        {
            if (!other) return false;
            if (this.depthWriteEnabled !== other.depthWriteEnabled) return false;
            if (this.stencilTestEnabled !== other.stencilTestEnabled) return false;
            if (this.stencilReference !== other.stencilReference) return false;
            if (this.stencilReadMask !== other.stencilReadMask) return false;
            if (this.stencilWriteMask !== other.stencilWriteMask) return false;
            if (this.depthFunction !== other.depthFunction) return false;
            if (this.stencilFunction !== other.stencilFunction) return false;
            if (this.stencilFace !== other.stencilFace) return false;
            if (this.stencilPassZPassOp !== other.stencilPassZPassOp) return false;
            if (this.stencilPassZFailOp !== other.stencilPassZFailOp) return false;
            if (this.stencilFailZPassOp !== other.stencilFailZPassOp) return false;
            return true;
        }
    }
}
