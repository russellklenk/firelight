package com.ninjabird.firelight.renderer
{
    import flash.display3D.VertexBuffer3D;
    import com.ninjabird.firelight.debug.DebugTrace;

    /**
     * Describes the format of data in a vertex buffer.
     */
    public final class VertexFormat
    {
        /**
         * The maximum number of vertex attributes supported by the
         * implementation.
         */
        public static const MAX_VERTEX_ATTRIBUTES:int = 8;

        /**
         * The vertex buffer used as the source for each vertex attribute.
         */
        public var buffers:Vector.<VertexBuffer3D>;

        /**
         * The byte offset of the attribute from the start of the vertex.
         */
        public var offsets:Vector.<int>;

        /**
         * One of the values of the Context3DVertexBufferFormat enumeration
         * specifying the data format of the attribute.
         */
        public var formats:Vector.<String>;

        /**
         * The number of attributes defined for the vertex format.
         */
        public var attributeCount:int;

        /**
         * Constructs an empty vertex format definition.
         */
        public function VertexFormat()
        {
            this.buffers = new Vector.<VertexBuffer3D>(VertexFormat.MAX_VERTEX_ATTRIBUTES, true);
            this.offsets = new Vector.<int>(VertexFormat.MAX_VERTEX_ATTRIBUTES, true);
            this.formats = new Vector.<String>(VertexFormat.MAX_VERTEX_ATTRIBUTES, true);
            this.attributeCount = 0;
        }

        /**
         * Sets the vertex buffer used as the source for a vertex attribute.
         * @param index The zero-based index of the vertex attribute.
         * @param buffer The vertex buffer supplying the attribute data.
         */
        public function setAttributeSource(index:int, buffer:VertexBuffer3D) : void
        {
            if (index < 0 || index >= VertexFormat.MAX_VERTEX_ATTRIBUTES)
            {
                DebugTrace.out('VertexFormat::setAttributeSource(2) - Invalid attribute index %d.', index);
                return;
            }
            else this.buffers[index] = buffer;
        }

        /**
         * Defines a new vertex attribute.
         * @param offset The byte offset of the attribute from the start of the vertex.
         * @param format One of the values of the Context3DVertexBufferFormat
         * enumeration specifying the data format of the attribute.
         * @return The zero-based index of the attribute, or -1.
         */
        public function defineAttribute(offset:int, format:String) : int
        {
            if (this.attributeCount < VertexFormat.MAX_VERTEX_ATTRIBUTES)
            {
                var index:int       = this.attributeCount;
                this.buffers[index] = null;
                this.offsets[index] = offset;
                this.formats[index] = format;
                this.attributeCount++;
                return index;
            }
            else
            {
                DebugTrace.out('VertexFormat::defineAttribute(2) - Max attribute count exceeded.');
                return -1;
            }
        }

        /**
         * Resets the vertex format definition so no attributes are defined.
         */
        public function clearAttributes() : void
        {
            var attribCount:int = VertexFormat.MAX_VERTEX_ATTRIBUTES;
            for (var i:int = 0; i < attribCount; ++i)
            {
                this.buffers[i] = null;
                this.offsets[i] = 0;
                this.formats[i] = null;
            }
            this.attributeCount = 0;
        }

        /**
         * Nulls the references to the vertex buffers held by the format.
         * The offset and format values remain unchanged.
         */
        public function dispose() : void
        {
            var attribCount:int = VertexFormat.MAX_VERTEX_ATTRIBUTES;
            for (var i:int = 0; i < attribCount; ++i)
            {
                this.buffers[i] = null;
            }
        }
    }
}
