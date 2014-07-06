package com.ninjabird.firelight.renderer.states
{
    import flash.display3D.Context3DBlendFactor;

    /**
     * Encapsulates render state associated with alpha blending.
     */
    public final class BlendState
    {
        /**
         * Alpha blending is disabled.
         */
        public static const NONE:BlendState          = new BlendState(false, Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);

        /**
         * Standard non-premultiplied alpha blending.
         */
        public static const ALPHA:BlendState         = new BlendState(true, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

        /**
         * Non-premultiplied additive blending.
         */
        public static const ADD:BlendState           = new BlendState(true, Context3DBlendFactor.ONE, Context3DBlendFactor.DESTINATION_ALPHA);

        /**
         * Non-premultiplied multiplicative blending.
         */
        public static const MULTIPLY:BlendState      = new BlendState(true, Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

        /**
         * Non-premultiplied screen blend mode.
         * http://en.wikipedia.org/wiki/Blend_modes#Screen
         */
        public static const SCREEN:BlendState        = new BlendState(true, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);

        /**
         * Non-premultiplied erase blend mode.
         * Erases the background based on the alpha value of the source.
         */
        public static const ERASE:BlendState         = new BlendState(true, Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

        /**
         * Non-premultiplied below blend mode.
         * The content appears below existing content.
         */
        public static const BELOW:BlendState         = new BlendState(true, Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA);

        /**
         * Standard pre-multiplied alpha blending.
         */
        public static const PREMULTIPLIED:BlendState = new BlendState(true, Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

        /**
         * Indicates whether alpha blending is enabled.
         */
        public var blendEnabled:Boolean;

        /**
         * The blend factor for the source color and alpha channels.
         */
        public var sourceFactor:String;

        /**
         * The blend factor for the destination color and alpha channels.
         */
        public var targetFactor:String;

        /**
         * Constructs a new instance initialized with the specified state.
         * @param enabled true if alpha blending should be enabled.
         * @param source The blend factor for the source color channels.
         * @param destination The blend factor for the destination channels.
         */
        public function BlendState(enabled:Boolean=false, source:String=Context3DBlendFactor.ONE, destination:String=Context3DBlendFactor.ZERO)
        {
            if (enabled)
            {
                this.blendEnabled = true;
                this.sourceFactor = source;
                this.targetFactor = destination;
            }
            else
            {
                // there's no way to actually disable alpha blending...
                this.blendEnabled = false;
                this.sourceFactor = Context3DBlendFactor.ONE;
                this.targetFactor = Context3DBlendFactor.ZERO;
            }
        }

        /**
         * Compares two instances to determine whether they represent the same state values.
         * @param other The instance to compare to.
         * @return true if the state values are identical.
         */
        public function equalTo(other:BlendState) : Boolean
        {
            if (!other) return false;
            if (this.blendEnabled !== other.blendEnabled) return false;
            if (this.sourceFactor !== other.sourceFactor) return false;
            if (this.targetFactor !== other.targetFactor) return false;
            return true;
        }
    }
}
