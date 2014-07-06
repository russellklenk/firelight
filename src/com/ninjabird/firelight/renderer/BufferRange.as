package com.ninjabird.firelight.renderer
{
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;

    /**
     * Describes a range of data in a dynamic vertex and index buffer.
     */
    public final class BufferRange
    {
        /**
         * The vertex buffer to write to.
         */
        public var vertexBuffer:VertexBuffer3D;

        /**
         * The index buffer to write to.
         */
        public var indexBuffer:IndexBuffer3D;

        /**
         * The zero-based index of the first vertex to write to.
         */
        public var baseVertex:int;

        /**
         * The zero-based index of the first index to write to.
         */
        public var baseIndex:int;

        /**
         * The number of vertices available in the vertex buffer. This may be
         * less than the number of vertices requested.
         */
        public var vertexCount:int;

        /**
         * The number of indices available in the index buffer. This may be
         * less than the number of indices requested.
         */
        public var indexCount:int;

        /**
         * The size of a single vertex, in bytes.
         */
        public var vertexSize:int;

        /**
         * The size of a single index, in bytes.
         */
        public var indexSize:int;

        /**
         * Default constructor (empty).
         */
        public function BufferRange()
        {
            this.vertexBuffer = null;
            this.indexBuffer  = null;
            this.baseVertex   = 0;
            this.baseIndex    = 0;
            this.vertexCount  = 0;
            this.indexCount   = 0;
            this.vertexSize   = 0;
            this.indexSize    = 0;
        }
    }
}
