package com.ninjabird.firelight.renderer
{
    /**
     * Stores metadata associated with a texture.
     */
    public dynamic class TextureDesc
    {
        /**
         * The width of the texture, in pixels.
         */
        public var width:int;

        /**
         * The height of the texture, in pixels.
         */
        public var height:int;

        /**
         * One of the values of the Context3DTextureFormat enumeration.
         */
        public var format:String;

        /**
         * Indicates whether the texture is a cubemap.
         */
        public var isCubeMap:Boolean;

        /**
         * Indicates whether the texture is a render target.
         */
        public var isRenderTarget:Boolean;

        /**
         * The handle of the render target within the owning ResourcePool.
         */
        public var targetHandle:int;

        /**
         * The handle of the texture within the owning ResourcePool.
         */
        public var textureHandle:int;

        /**
         * Default constructor. Initializes all fields to their default values.
         */
        public function TextureDesc()
        {
            this.width          = 0;
            this.height         = 0;
            this.format         = '';
            this.isCubeMap      = false;
            this.isRenderTarget = false;
            this.targetHandle   = -1;
            this.textureHandle  = -1;
        }

    }
}
