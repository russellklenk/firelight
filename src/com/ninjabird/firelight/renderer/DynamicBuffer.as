package com.ninjabird.firelight.renderer
{
    import com.ninjabird.firelight.renderer.events.RenderEvents;

    import flash.display3D.Context3DBufferUsage;
    import com.ninjabird.firelight.debug.DebugTrace;
    import com.ninjabird.firelight.renderer.events.ContextLostEvent;
    import com.ninjabird.firelight.renderer.events.ContextReadyEvent;
    import com.ninjabird.firelight.renderer.events.RenderEvents;

    /**
     * Manages updating of dynamic geometry data.
     */
    public final class DynamicBuffer
    {
        /**
         * The number of vertices per-primitive.
         */
        public var vertexPerPrimitive:int;

        /**
         * The current offset (in vertices) into the current vertex buffer.
         */
        public var vertexOffset:int;

        /**
         * The vertex capacity of the geometry buffer.
         */
        public var vertexCount:int;

        /**
         * The size of a single vertex, in bytes.
         */
        public var vertexSize:int;

        /**
         * The number of indices per-primitive.
         */
        public var indexPerPrimitive:int;

        /**
         * The current offset (in indices) into the current index buffer.
         */
        public var indexOffset:int;

        /**
         * The index capacity of the geometry buffer.
         */
        public var indexCount:int;

        /**
         * The size of a single index, in bytes.
         */
        public var indexSize:int;

        /**
         * The zero-based index of the current vertex and index buffer.
         */
        public var bufferIndex:int;

        /**
         * The resource pool in which the geometry buffers are allocated.
         */
        public var resourcePool:ResourcePool;

        /**
         * The set of index buffers. Three index buffers are maintained to
         * reduce the chances of pipeline stalls.
         */
        public var indexBuffers:Vector.<BufferDesc>;

        /**
         * The set of vertex buffers. Three vertex buffers are maintained to
         * reduce the chances of pipeline stalls.
         */
        public var vertexBuffers:Vector.<BufferDesc>;

        /**
         * Callback invoked when the rendering context is lost.
         * @param ev Additional information about the event.
         */
        private function handleContextLost(ev:ContextLostEvent) : void
        {
            /* empty */
        }

        /**
         * Callback invoked when the rendering context becomes ready, either
         * after initial creation or after recovery from a lost context.
         * @param ev Additional information about the event.
         */
        private function handleContextReady(ev:ContextReadyEvent) : void
        {
            if (this.resourcePool)
            {
                // the resource pool recreates all of the resource objects
                // for us, so we just need to upload data into them.
                this.prepareGpuResources();
            }
        }

        /**
         * Default constructor (empty).
         */
        public function DynamicBuffer()
        {
            this.vertexPerPrimitive = 0;
            this.vertexOffset       = 0;
            this.vertexCount        = 0;
            this.vertexSize         = 0;
            this.indexPerPrimitive  = 0;
            this.indexOffset        = 0;
            this.indexCount         = 0;
            this.indexSize          = 0;
            this.bufferIndex        = 0;
            this.indexBuffers       = new Vector.<BufferDesc>(3, true);
            this.vertexBuffers      = new Vector.<BufferDesc>(3, true);
        }

        /**
         * Sets attributes of the vertex and index buffers. This must be performed before creating GPU resources.
         * @param capacity The number of primitives that can be buffered.
         * @param vertexSizeInBytes The size of a single vertex, in bytes.
         * @param primitiveVertices The number of vertices per-primitive.
         * @param primitiveIndices The number of indices per-primitive.
         * @return true if the capacity was changed successfully.
         */
        public function setCapacity(capacity:int, vertexSizeInBytes:int, primitiveVertices:int, primitiveIndices:int) : Boolean
        {
            if (this.resourcePool)
            {
                DebugTrace.out('DynamicBuffer::setCapacity(4) - Destroy GPU resources before changing capacity.');
                return false;
            }
            if (vertexSizeInBytes <= 0)
            {
                DebugTrace.out('DynamicBuffer::setCapacity(4) - Invalid vertex size %d.', vertexSizeInBytes);
                return false;
            }
            if (capacity <= 0)
            {
                DebugTrace.out('DynamicBuffer::setCapacity(4) - Invalid primitive capacity %d.', capacity);
                return false;
            }
            if (primitiveVertices <= 0)
            {
                DebugTrace.out('DynamicBuffer::setCapacity(3) - Invalid vertex capacity %d.', primitiveVertices);
                return false;
            }
            if (primitiveIndices <= 0)
            {
                DebugTrace.out('DynamicBuffer::setCapacity(3) - Invalid index capacity %d.', primitiveIndices);
                return false;
            }
            this.vertexPerPrimitive = primitiveVertices;
            this.vertexCount        = capacity * primitiveVertices;
            this.vertexSize         = vertexSizeInBytes;
            this.indexPerPrimitive  = primitiveIndices;
            this.indexCount         = capacity * primitiveIndices;
            this.indexSize          = 2; // Stage3D limited to uint16_t
            return true;
        }

        /**
         * Specifies the resource pool in which the QuadBatch allocates all of
         * its GPU resources, and creates any shader programs, vertex buffers
         * and index buffers required by the implementation.
         * @param pool The ResourcePool used for managing GPU resources.
         * @return true if GPU resources are created successfully.
         */
        public function createGpuResources(pool:ResourcePool) : Boolean
        {
            if (pool === null)
            {
                DebugTrace.out('DynamicBuffer::createGpuResources(1) - Invalid resource pool.');
                return false;
            }
            if (this.vertexSize <= 0 || this.vertexCount <= 0 || this.indexCount <= 0)
            {
                DebugTrace.out('DynamicBuffer::createGpuResources(1) - Capacity not set.');
                return false;
            }

            var dc:DisplayContext = pool.displayContext;
            if (dc)
            {
                var usage:String  = Context3DBufferUsage.DYNAMIC_DRAW;
                for (var i:int    = 0; i < 3; ++i)
                {
                    var ibo:BufferDesc = pool.createIndexBuffer(this.indexCount, usage);
                    var vbo:BufferDesc = pool.createVertexBuffer(this.vertexCount, this.vertexSize, usage);
                    if (vbo && ibo)
                    {
                        this.indexBuffers[i]  = ibo;
                        this.vertexBuffers[i] = vbo;
                    }
                    else return false;
                }
                this.resourcePool = pool;
                dc.addEventListener(RenderEvents.CONTEXT_LOST,  this.handleContextLost);
                dc.addEventListener(RenderEvents.CONTEXT_READY, this.handleContextReady);
                return this.prepareGpuResources();
            }
            else
            {
                DebugTrace.out('DynamicBuffer::createGpuResources(1) - Invalid display context.');
                return false;
            }
        }

        /**
         * Prepares GPU resources for use when the rendering context becomes
         * ready. This is where vertex and fragment shaders would be assembled
         * and linked into a program object, buffer data should be uploaded,
         * and so on.
         * @return true if GPU resources are ready for use.
         */
        public function prepareGpuResources() : Boolean
        {
            this.vertexOffset = 0;
            this.indexOffset  = 0;
            this.bufferIndex  = 0;
            return true;
        }

        /**
         * Disposes of the GPU resources created and owned by this instance,
         * and detaches the QuadBatch from its associated ResourcePool. The
         * GPU resources must be manually recreated.
         * @return The ResourcePool to which the QuadBatch was attached.
         */
        public function disposeGpuResources() : ResourcePool
        {
            if (this.resourcePool)
            {
                var pool:ResourcePool = this.resourcePool;
                var dc:DisplayContext = pool.displayContext;
                if (dc)
                {
                    dc.removeEventListener(RenderEvents.CONTEXT_LOST,  this.handleContextLost);
                    dc.removeEventListener(RenderEvents.CONTEXT_READY, this.handleContextReady);
                }
                for (var i:int = 0; i < 3; ++i)
                {
                    if (this.indexBuffers[i])
                    {
                        pool.disposeBuffer(this.indexBuffers[i]);
                        this.indexBuffers[i] = null;
                    }
                    if (this.vertexBuffers[i])
                    {
                        pool.disposeBuffer(this.vertexBuffers[i]);
                        this.vertexBuffers[i] = null;
                    }
                }
                this.vertexOffset = 0;
                this.indexOffset  = 0;
                this.bufferIndex  = 0;
                return pool;
            }
            else return null;
        }

        /**
         * Requests a block of buffer space for vertex and index data. The
         * buffer may only be able to satisfy a portion of the request.
         * @param primitiveCount The number of primitives being requested.
         * @param range A BufferRange instance to be filled with information
         * about the portion of buffer space allocated to the application.
         * @return true if the request was satisfied, even partially, or false
         * if the request could not be satisfied.
         */
        public function requestRange(primitiveCount:int, range:BufferRange) : Boolean
        {
            var numVertices:int = this.vertexPerPrimitive * primitiveCount;
            var numIndices:int  = this.indexPerPrimitive  * primitiveCount;
            var maxIndices:int  = this.indexCount;
            var maxVertices:int = this.vertexCount;
            if (numVertices > maxVertices || numIndices > maxIndices)
            {
                DebugTrace.out('DynamicBuffer::requestRange(3) - Request size exceeds capacity.');
                return false;
            }

            if (this.indexOffset + numIndices > maxIndices)
            {
                // not enough space in the current buffer to satisfy the
                // entire request, so return the available buffer space.
                numVertices = maxVertices - this.vertexOffset;
                numIndices  = maxIndices  - this.indexOffset;
            }

            // fill out the range information for the caller.
            var index:int          = this.bufferIndex;
            var pool:ResourcePool  = this.resourcePool;
            range.indexBuffer      = pool.indexBufferFor(this.indexBuffers[index]);
            range.vertexBuffer     = pool.vertexBufferFor(this.vertexBuffers[index]);
            range.baseVertex       = this.vertexOffset;
            range.baseIndex        = this.indexOffset;
            range.vertexCount      = numVertices;
            range.indexCount       = numIndices;
            range.vertexSize       = this.vertexSize;
            range.indexSize        = this.indexSize;

            // update offsets and the current buffer index.
            var increment:int      = 0;
            this.vertexOffset     += numVertices;
            this.indexOffset      += numIndices;
            if (this.indexOffset === maxIndices)
            {
                // we've run out of space in the current buffer, so
                // flip over to the next buffer in the list.
                this.indexOffset   = 0;
                this.vertexOffset  = 0;
                this.bufferIndex   =(this.bufferIndex + 1) % 3;
            }
            return true;
        }
    }
}
