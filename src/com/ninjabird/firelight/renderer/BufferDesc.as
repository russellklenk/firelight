package com.ninjabird.firelight.renderer
{
    import flash.display3D.Context3DBufferUsage;

    /**
     * Stores metadata associated with a buffer used for storing vertex or index data.
     */
    public dynamic class BufferDesc
    {
        /**
         * One of the values of the Context3DBufferUsage enumeration.
         */
        public var usageType:String;

        /**
         * The total number of elements (vertices or indices) in the buffer.
         */
        public var elementCount:int;

        /**
         * The number of bytes for each logical element (vertex or index).
         */
        public var bytesPerElement:int;

        /**
         * Indicates whether the buffer is used for storing index data.
         */
        public var isIndexBuffer:Boolean;

        /**
         * The handle of the buffer within the resource pool.
         */
        public var bufferHandle:int;

        /**
         * Default constructor. Initializes all fields to their default values.
         */
        public function BufferDesc()
        {
            this.usageType       = Context3DBufferUsage.STATIC_DRAW;
            this.elementCount    = 0;
            this.bytesPerElement = 0;
            this.isIndexBuffer   = false;
            this.bufferHandle    = -1;
        }
    }
}
