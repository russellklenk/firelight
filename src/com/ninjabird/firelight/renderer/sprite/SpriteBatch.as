package com.ninjabird.firelight.renderer.sprite
{
    import avm2.intrinsics.memory.lf32;
    import avm2.intrinsics.memory.li16;
    import avm2.intrinsics.memory.li32;
    import avm2.intrinsics.memory.sf32;
    import avm2.intrinsics.memory.si16;
    import avm2.intrinsics.memory.si32;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.system.ApplicationDomain;
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    import com.ninjabird.firelight.debug.DebugTrace;
    import com.ninjabird.firelight.renderer.states.BlendState;
    import com.ninjabird.firelight.renderer.BufferRange;
    import com.ninjabird.firelight.renderer.DrawContext;
    import com.ninjabird.firelight.renderer.DynamicBuffer;
    import com.ninjabird.firelight.renderer.VertexFormat;

    /**
     * Represents a collection of sprites to be sent to the renderer. Sprites
     * are transformed into vertex data and sent to the GPU each frame. Vertex
     * data is generated as position+texture coordinate (FLOAT_4), tint color
     * (BYTE_4) and depth+corner index+sprite id (FLOAT_3) for a total of 32
     * bytes per-vertex. The sprite texture may be either a standalone or an
     * atlas style texture.
     */
    public final class SpriteBatch
    {
        /**
         * The minimum capacity of a SpriteBatch. Ideally, this would be 1,
         * which makes for easier debugging, but to use domain memory, buffers
         * must be a minimum of 1024 bytes. We get the minimum capacity from
         * 1024 / 2 = 512, and ceil(512 / 6) = 86, as each index is 2 bytes,
         * and there are 6 indices per-sprite.
         */
        public static const MINIMUM_CAPACITY:int    = 86;

        /**
         * The number of vertices generated for each sprite.
         */
        public static const VERTICES_PER_SPRITE:int = 4;

        /**
         * The number of indices generates for each sprite.
         */
        public static const INDICES_PER_SPRITE:int  = 6;

        /**
         * The size of a single vertex, in bytes.
         */
        public static const VERTEX_SIZE:int         = 32;

        /**
         * The size of a single vertex index, in bytes. Indices are always
         * stored as uint16_t values.
         */
        public static const INDEX_SIZE:int          = 2;

        /**
         * Corner offsets for the x-axis components of each sprite vertex.
         */
        public static const XCO:Vector.<Number>     = Vector.<Number>([0.0, 1.0, 1.0, 0.0]);

        /**
         * Corner offsets for the y-axis components of each sprite vertex.
         */
        public static const YCO:Vector.<Number>     = Vector.<Number>([0.0, 0.0, 1.0, 1.0]);

        /**
         * The sprites in the batch should not be sorted, and will be submitted
         * in the order they were added.
         */
        public static const SORT_NONE:int = 0;

        /**
         * The sprites in the batch will be ordered back-to-front, by layer
         * depth. This is necessary for correct blending when translucent
         * sprites are present. Sprites on the same layer will be submitted
         * in the order they were added.
         */
        public static const SORT_BACK_TO_FRONT:int = 1;

        /**
         * The sprites in the batch will be ordered back-to-front, by layer
         * depth. This is necessary for correct blending when translucent
         * sprites are present. Sprites on the same layer will be further
         * ordered by render state identifier, and finally by the order in
         * which they were added.
         */
        public static const SORT_BACK_TO_FRONT_BY_STATE:int = 2;

        /**
         * The sprites in the batch will be ordered front-to-back, by layer
         * depth. This is ideal when the batch consists of sprites that are
         * entirely opaque. Sprites on the same layer will be submitted in
         * the order they were added.
         */
        public static const SORT_FRONT_TO_BACK:int = 3;

        /**
         * The sprites in the batch will be ordered front-to-back, by layer
         * depth. This is ideal when the batch consists of sprites that are
         * entirely opaque. Sprites on the same layer will be further ordered
         * by render state identifier, and finally by the order in which they
         * were added.
         */
        public static const SORT_FRONT_TO_BACK_BY_STATE:int = 4;

        /**
         * The sprites in the batch will be ordered by render state identifier.
         * This helps to reduce unnecessary state changes.
         */
        public static const SORT_BY_STATE:int = 5;

        /**
         * Calculates the number of indices required to describe the specified number of sprites.
         * @param spriteCount The number of sprites.
         * @return The number of vertices required to represent the specified number of sprites.
         */
        public static function indexCount(spriteCount:int) : int
        {
            return spriteCount * 6;
        }

        /**
         * Calculates the number of vertices required to describe the specified number of sprites.
         * @param spriteCount The number of sprites.
         * @return The number of vertices required to represent the specified number of sprites.
         */
        public static function vertexCount(spriteCount:int) : int
        {
            return spriteCount * 4;
        }

        /**
         * The maximum number of vertices that can be stored by the batch. This
         * is always a multiple of four.
         */
        public var vertexCapacity:int;

        /**
         * The size of a single vertex, in bytes. This value is constant.
         */
        public var vertexSize:int;

        /**
         * The maximum number of indices that can be stored by the batch. This
         * is always a multiple of six.
         */
        public var indexCapacity:int;

        /**
         * The size of a single index, in bytes. This value is constant.
         */
        public var indexSize:int;

        /**
         * The render state identifier associated with the current sprite
         * sub-batch.
         */
        public var currentState:uint;

        /**
         * The alpha blending state applied for the entire sprite batch.
         */
        public var blendState:BlendState;

        /**
         * The vertex format descriptor for this batch.
         */
        public var vertexFormat:VertexFormat;

        /**
         * The raw vertex data generated for the sprites. This data is uploaded
         * into a region of the vertex buffer each frame.
         */
        public var vertexData:ByteArray;

        /**
         * The raw index data generated for the sprites. This data is uploaded
         * into a region of the index buffer each frame.
         */
        public var indexData:ByteArray;

        /**
         * The current range of the GPU vertex and index buffers mapped for use.
         */
        public var gpuRange:BufferRange;

        /**
         * The manager for the GPU vertex and index buffers written to by the
         * sprite batch.
         */
        public var gpuBuffer:DynamicBuffer;

        /**
         * A function (gl:DrawContext, state:uint) : void used to transform an
         * application render state identifier into a render state transition.
         */
        public var applyState:Function;

        /**
         * The set of sprites currently added to the batch.
         */
        public var sprites:Vector.<SpriteDefinition>;

        /**
         * The number of sprites currently defined in the batch.
         */
        public var count:int;

        /**
         * One of the SpriteBatch.SORT_n identifiers indicating how sprites in
         * the batch should be ordered.
         */
        public var sortMode:int;

        /**
         * This value is set to true if the sprite batch has been modified and
         * needs to be re-sorted prior to rendering.
         */
        public var resort:Boolean;

        /**
         * Implements a sort comparison function for ordering sprites
         * back-to-front, as determined by layer depth. Sprites on the same
         * layer are submitted in the order they were added.
         * @param a A sprite definition to compare.
         * @param b A sprite definition to compare.
         * @return A value indicating the sort order.
         */
        private function compareBackToFront(a:SpriteDefinition, b:SpriteDefinition) : Number
        {
            // larger depth values are 'further away' from the screen.
            var depth_a:int = a.layer;
            var depth_b:int = b.layer;
            if (depth_a > depth_b) return -1;
            if (depth_a < depth_b) return +1;
            var order_a:int = a.order;
            var order_b:int = b.order;
            if (order_a < order_b) return -1;
            if (order_a > order_b) return +1;
            return 0;
        }

        /**
         * Implements a sort comparison function for ordering sprites
         * back-to-front, as determined by layer depth. Sprites on the same
         * layer are submitted in the order they were added.
         * @param a A sprite definition to compare.
         * @param b A sprite definition to compare.
         * @return A value indicating the sort order.
         */
        private function compareBackToFrontByState(a:SpriteDefinition, b:SpriteDefinition) : Number
        {
            // larger depth values are 'further away' from the screen.
            var depth_a:int = a.layer;
            var depth_b:int = b.layer;
            if (depth_a > depth_b) return -1;
            if (depth_a < depth_b) return +1;
            var state_a:uint = a.renderState;
            var state_b:uint = b.renderState;
            if (state_a < state_b) return -1;
            if (state_a > state_b) return +1;
            var order_a:int = a.order;
            var order_b:int = b.order;
            if (order_a < order_b) return -1;
            if (order_a > order_b) return +1;
            return 0;
        }

        /**
         * Implements a sort comparison function for ordering sprites
         * front-to-back, as determined by layer depth. Sprites on the same
         * layer are submitted in the reverse order they were added.
         * @param a A sprite definition to compare.
         * @param b A sprite definition to compare.
         * @return A value indicating the sort order.
         */
        private function compareFrontToBack(a:SpriteDefinition, b:SpriteDefinition) : Number
        {
            // larger depth values are 'further away' from the screen.
            var depth_a:int  = a.layer;
            var depth_b:int  = b.layer;
            if (depth_a < depth_b) return +1;
            if (depth_a > depth_b) return -1;
            var order_a:int  = a.order;
            var order_b:int  = b.order;
            if (order_a < order_b) return -1;
            if (order_a > order_b) return +1;
            return 0;
        }

        /**
         * Implements a sort comparison function for ordering sprites
         * front-to-back, as determined by layer depth. Sprites on the same
         * layer are submitted in the reverse order they were added.
         * @param a A sprite definition to compare.
         * @param b A sprite definition to compare.
         * @return A value indicating the sort order.
         */
        private function compareFrontToBackByState(a:SpriteDefinition, b:SpriteDefinition) : Number
        {
            // larger depth values are 'further away' from the screen.
            var depth_a:int  = a.layer;
            var depth_b:int  = b.layer;
            if (depth_a < depth_b) return +1;
            if (depth_a > depth_b) return -1;
            var state_a:uint = a.renderState;
            var state_b:uint = b.renderState;
            if (state_a < state_b) return -1;
            if (state_a > state_b) return +1;
            var order_a:int  = a.order;
            var order_b:int  = b.order;
            if (order_a < order_b) return -1;
            if (order_a > order_b) return +1;
            return 0;
        }

        /**
         * Implements a sort comparison function for ordering sprites by render
         * state identifier. Sprites with the same state are submitted in the
         * order they were added.
         * @param a A sprite definition to compare.
         * @param b A sprite definition to compare.
         * @return A value indicating the sort order.
         */
        private function compareByState(a:SpriteDefinition, b:SpriteDefinition) : Number
        {
            var state_a:uint = a.renderState;
            var state_b:uint = b.renderState;
            if (state_a < state_b) return -1;
            if (state_a > state_b) return +1;
            var order_a:int  = a.order;
            var order_b:int  = b.order;
            if (order_a < order_b) return -1;
            if (order_a > order_b) return +1;
            return 0;
        }

        /**
         * Generates index data for one or more sprites.
         * @param buffer The ByteArray to write to.
         * @param bufferOffset The byte offset within the buffer of the first index value to write.
         * @param baseVertex The zero-based index of the first vertex of the region within the vertex buffer.
         * @param spriteCount The number of sprites to generate indices for. There are six index values generated for each sprite.
         */
        private function generateIndices(buffer:ByteArray, bufferOffset:int, baseVertex:int, spriteCount:int) : void
        {
            ApplicationDomain.currentDomain.domainMemory = buffer;
            for (var i:int = 0; i < spriteCount; ++i)
            {
                // note that the Flash runtime considers clockwise winding
                // as front-facing, and counter-clockwise back-facing.
                si16(baseVertex + 0, bufferOffset + 0);
                si16(baseVertex + 1, bufferOffset + 2);
                si16(baseVertex + 2, bufferOffset + 4);
                si16(baseVertex + 2, bufferOffset + 6);
                si16(baseVertex + 3, bufferOffset + 8);
                si16(baseVertex + 0, bufferOffset + 10);
                baseVertex     += 4;
                bufferOffset   += 12;
            }
        }

        /**
         * Generates transformed vertex data for one or more sprites.
         * @param batchOffset The zero-based index of the first sprite within the batch that makes up the current sub-region.
         * @param buffer The destination ByteArray. 32 bytes are written for each vertex, and there are four vertices generated per-sprite.
         * @param bufferOffset The byte offset within the buffer of the first vertex to write.
         * @param spriteCount The number of sprites to generate vertices for. There are four vertices generated for each sprite.
         */
        private function generateVertices(batchOffset:int, buffer:ByteArray, bufferOffset:int, spriteCount:int) : void
        {
            ApplicationDomain.currentDomain.domainMemory = buffer;
            var sprites:Vector.<SpriteDefinition>  = this.sprites;
            var xco:Vector.<Number> = SpriteBatch.XCO;
            var yco:Vector.<Number> = SpriteBatch.YCO;

            for (var i:int = 0; i < spriteCount; ++i)
            {
                var index:int = batchOffset + i;
                var sprite:SpriteDefinition = sprites[index];

                // pre-calculate values that are constant across the quad.
                // note that flash transforms the depth values as z * 2 - 1.
                var src_x:Number = sprite.imageX;
                var src_y:Number = sprite.imageY;
                var src_w:Number = sprite.imageWidth;
                var src_h:Number = sprite.imageHeight;
                var dst_x:Number = sprite.screenX;
                var dst_y:Number = sprite.screenY;
                var dst_w:Number = sprite.imageWidth  * sprite.scaleX;
                var dst_h:Number = sprite.imageHeight * sprite.scaleY;
                var ctr_x:Number = sprite.originX / src_w;
                var ctr_y:Number = sprite.originY / src_h;
                var scl_u:Number = 1.0 /  sprite.textureWidth;
                var scl_v:Number = 1.0 /  sprite.textureWidth;
                var depth:Number = sprite.layer  / 2147483647.0;
                var angle:Number = sprite.orientation;
                var sin_o:Number = Math.sin(angle);
                var cos_o:Number = Math.cos(angle);
                var color:uint   = sprite.tintColor;
                var quad:Number  = sprite.order;

                // calculate values that change per-vertex. this math could
                // be moved to the GPU if necessary, but that entails changing
                // the vertex format and may not be a win.
                for (var j:int = 0; j < 4; ++j)
                {
                    var ofs_x:Number  = xco[j];
                    var ofs_y:Number  = yco[j];
                    var corner:Number = j;
                    var x_dst:Number  =(ofs_x - ctr_x)  * dst_w;
                    var y_dst:Number  =(ofs_y - ctr_y)  * dst_h;

                    sf32((dst_x + (x_dst * cos_o)) - (y_dst * sin_o), bufferOffset +  0); // position.x
                    sf32((dst_y + (x_dst * sin_o)) + (y_dst * cos_o), bufferOffset +  4); // position.y
                    sf32((src_x + (ofs_x * src_w)) *  scl_u,          bufferOffset +  8); // texture.u
                    sf32((src_y + (ofs_y * src_h)) *  scl_v,          bufferOffset + 12); // texture.v
                    si32( color,                                      bufferOffset + 16); // color.rgba
                    sf32( depth,                                      bufferOffset + 20); // attrs.x (layer depth)
                    sf32( corner,                                     bufferOffset + 24); // attrs.y (corner index)
                    sf32( quad,                                       bufferOffset + 28); // attrs.z (unique quad ID)

                    bufferOffset += 32;
                }
            }
        }

        /**
         * Fills the CPU buffers with vertex and index data and transfers the
         * data to the GPU for the currently mapped range.
         * @param spriteOffset The zero-based index of the first sprite.
         * @param spriteCount The number of sprites to render within the batch.
         * @param range The region of the GPU vertex and index to write to.
         * @return The number of sprites actually buffered. This may be less
         * than the number of sprites requested if the end of the buffer is
         * reached, in which case, a second draw call will occur.
         */
        private function bufferData(spriteOffset:int, spriteCount:int, range:BufferRange) : int
        {
            var maxVertices:int = this.vertexCapacity;
            var maxIndices:int  = this.indexCapacity;
            var numVertices:int = spriteCount * 4;
            var numIndices:int  = spriteCount * 6;
            if (numVertices > maxVertices)
            {
                // not enough space in the CPU buffer to fit everything.
                // only a portion of the desired data will be buffered.
                numVertices = maxVertices;
                numIndices  = maxIndices;
            }

            // calculate the number of sprites that will be buffered.
            var baseIndex:int   = range.baseIndex;
            var baseVertex:int  = range.baseVertex;
            var bufferCount:int = numVertices / 4;
            if (bufferCount === 0) return 0;

            // generate the vertex and index data in the CPU buffers.
            var indices:ByteArray  = this.indexData;
            var vertices:ByteArray = this.vertexData;
            this.generateVertices(spriteOffset, vertices, 0, bufferCount);
            this.generateIndices(indices, 0, baseVertex, bufferCount);

            // now, upload the data to the GPU memory buffers.
            range.indexBuffer.uploadFromByteArray(indices, 0, baseIndex, numIndices);
            range.vertexBuffer.uploadFromByteArray(vertices, 0, baseVertex, numVertices);
            return bufferCount;
        }

        /**
         * Submits a buffered range of sprites to the GPU for rendering.
         * @param gl The rendering context.
         * @param spriteOffset The zero-based index of the first sprite to draw.
         * @param spriteCount The number of sprites to render.
         * @param range The region of the GPU vertex and index data to read.
         */
        private function drawRange(gl:DrawContext, spriteOffset:int, spriteCount:int, range:BufferRange) : void
        {
            var sprites:Vector.<SpriteDefinition> = this.sprites;
            var state0:uint = this.currentState;
            var state1:uint = this.currentState;
            var baseIdx:int = range.baseIndex;
            var index:int   = 0;
            var nquad:int   = 0;
            for (var i:int  = 0; i < spriteCount; ++i)
            {
                var sprite:SpriteDefinition = sprites[spriteOffset+i];
                state1 = sprite.renderState;

                if (state0 !== state1)
                {
                    if (i > index)
                    {
                        nquad    = i - index;
                        gl.drawTriangles(range.indexBuffer, baseIdx, nquad * 2);
                        baseIdx += nquad * 6;
                    }
                    // now apply the new state and start a new sub-batch.
                    this.applyState(gl, state1);
                    this.currentState = state1;
                    state0 = state1;
                    index  = i;
                }
            }
            // submit the remainder of the sub-batch.
            nquad = spriteCount - index;
            gl.drawTriangles(range.indexBuffer, baseIdx, nquad * 2);
        }

        /**
         * Constructs a new instance with the specified initial capacity.
         * @param initialCapacity The initial capacity of the batch.
         * @param bufferCapacity The number of sprites that can be buffered
         * on the CPU. If this value is zero, change the capacity later using
         * the SpriteBatch.changeCapacity() method.
         */
        public function SpriteBatch(initialCapacity:int=0, bufferCapacity:int=0)
        {
            this.vertexCapacity = 0;
            this.vertexSize     = 0;
            this.indexCapacity  = 0;
            this.indexSize      = 0;
            this.currentState   = 0;
            this.blendState     = null;
            this.vertexFormat   = null;
            this.vertexData     = null;
            this.indexData      = null;
            this.gpuRange       = new BufferRange();
            this.gpuBuffer      = null;
            this.sprites        = new Vector.<SpriteDefinition>(initialCapacity, false);
            this.count          = 0;
            this.sortMode       = SpriteBatch.SORT_NONE;
            this.resort         = false;
            if (bufferCapacity) this.changeBufferCapacity(bufferCapacity);
        }

        /**
         * Allocates CPU-side resources required to meet the specified capacity.
         * @param capacity The maximum number of sprites expected to be
         * specified in a single frame through this SpriteBatch. This value is
         * used for allocating CPU buffer storage.
         * @return true if resources were allocated successfully.
         */
        public function changeBufferCapacity(capacity:int) : Boolean
        {
            if (capacity <= SpriteBatch.MINIMUM_CAPACITY)
            {
                DebugTrace.out('SpriteBatch::changeBufferCapacity(1) - Using minimum capacity.');
                capacity  = SpriteBatch.MINIMUM_CAPACITY;
            }

            this.vertexCapacity = capacity * 4;
            this.vertexSize     = SpriteBatch.VERTEX_SIZE;
            this.indexCapacity  = capacity * 6;
            this.indexSize      = SpriteBatch.INDEX_SIZE;
            this.currentState   = 0xFFFFFFFF;
            this.blendState     = BlendState.NONE;
            this.vertexFormat   = new VertexFormat();
            this.vertexData     = new ByteArray();
            this.indexData      = new ByteArray();

            // initialize the vertex format. there are three attributes, all
            // of which will be sourced from the same GPU vertex buffer.
            this.vertexFormat.defineAttribute( 0, Context3DVertexBufferFormat.FLOAT_4);
            this.vertexFormat.defineAttribute(16, Context3DVertexBufferFormat.BYTES_4);
            this.vertexFormat.defineAttribute(20, Context3DVertexBufferFormat.FLOAT_3);

            // initialize the CPU-side ByteArrays. with the exception of the
            // uniform data, these ByteArrays are filled using AVM2 intrinsics,
            // so their length must be set, and must use LITTLE_ENDIAN order.
            this.vertexData.length = this.vertexCapacity * this.vertexSize;
            this.vertexData.endian = Endian.LITTLE_ENDIAN;
            this.indexData.length  = this.indexCapacity  * this.indexSize;
            this.indexData.endian  = Endian.LITTLE_ENDIAN;
            return true;
        }

        /**
         * Adds a new sprite to the batch. The SpriteDefinition.order field is
         * assigned the index of the sprite within the batch.
         * @param sprite The sprite to add to the batch.
         * @return The zero-based index of the sprite within the batch.
         */
        public function add(sprite:SpriteDefinition) : int
        {
            var index:int       = this.count++;
            sprite.order        = index;
            this.sprites[index] = sprite;
            this.resort         = true;
            return index;
        }

        /**
         * Orders the sprites in the batch using the currently defined sorting
         * order. This can be used to obtain correct blending, fewer fragment
         * operations, or minimal render state changes.
         */
        public function sort() : void
        {
            var mode:int = this.sortMode;
            this.resort  = false;
            if (mode === SpriteBatch.SORT_NONE)
            {
                // no sorting is necessary.
                return;
            }
            if (mode === SpriteBatch.SORT_BACK_TO_FRONT)
            {
                this.sprites.length = this.count;
                this.sprites.sort(this.compareBackToFront);
                return;
            }
            if (mode === SpriteBatch.SORT_BACK_TO_FRONT_BY_STATE)
            {
                this.sprites.length = this.count;
                this.sprites.sort(this.compareBackToFrontByState);
                return;
            }
            if (mode === SpriteBatch.SORT_FRONT_TO_BACK)
            {
                this.sprites.length = this.count;
                this.sprites.sort(this.compareFrontToBack);
                return;
            }
            if (mode === SpriteBatch.SORT_FRONT_TO_BACK_BY_STATE)
            {
                this.sprites.length = this.count;
                this.sprites.sort(this.compareFrontToBackByState);
                return;
            }
            if (mode === SpriteBatch.SORT_BY_STATE)
            {
                this.sprites.length = this.count;
                this.sprites.sort(this.compareByState);
                return;
            }
        }

        /**
         * Resizes the sprite batch. Existing sprite definitions are lost.
         * @param newCapacity The new capacity of the batch.
         */
        public function resize(newCapacity:int) : void
        {
            this.sprites = new Vector.<SpriteDefinition>(newCapacity, false);
            this.count   = 0;
        }

        /**
         * Flushes the batch, setting the number of sprites to zero.
         */
        public function flush() : void
        {
            this.count = 0;
        }

        /**
         * Submits the buffered sprites for rendering.
         * @param gl The rendering context.
         */
        public function draw(gl:DrawContext) : void
        {
            if (this.gpuBuffer === null)
            {
                DebugTrace.out('SpriteBatch::draw(1) - No GPU buffer set.');
                return;
            }
            if (this.applyState === null)
            {
                DebugTrace.out('SpriteBatch::draw(1) - No applyState function set.');
                return;
            }
            if (this.vertexCapacity === 0)
            {
                DebugTrace.out('SpriteBatch::draw(1) - No CPU buffer capacity set.');
                return;
            }

            var quadCount:int = this.count;
            var quadIndex:int = 0;
            var baseIndex:int = 0;
            var gpuQuads:int  = 0;
            var cpuQuads:int  = 0;
            var cpuVerts:int  = 0;
            var cpuIndex:int  = 0;

            // sort the sprites by the user-defined sorting criteria.
            if (this.resort)
            {
                this.sort();
            }

            // reset the current state identifier to ensure that we properly
            // apply render state for the quads, since it could have been
            // changed externally on the draw context.
            gl.applyBlendState(this.blendState);
            this.currentState = 0xFFFFFFFF;

            var vf:VertexFormat   = this.vertexFormat;
            var range:BufferRange = this.gpuRange;
            while (quadCount > 0)
            {
                // request space in the GPU buffer and then set the vertex
                // buffer as the source for all vertex attributes. we
                // change the vertex format each time because the vertex
                // buffer returned by the DynamicBuffer may have changed.
                this.gpuBuffer.requestRange(quadCount, range);
                vf.setAttributeSource(0, range.vertexBuffer);
                vf.setAttributeSource(1, range.vertexBuffer);
                vf.setAttributeSource(2, range.vertexBuffer);
                gl.changeVertexFormat(vf);

                // calculate the number of quads we can fit into the GPU buffer.
                gpuQuads = range.vertexCount / 4;
                while (gpuQuads > 0)
                {
                    // generate the vertex and index data in the CPU buffers,
                    // and then upload it into the mapped GPU buffer space.
                    cpuQuads = this.bufferData(quadIndex, gpuQuads, range);

                    // submit the generated primitives to the GPU. this results
                    // in one or more drawTriangles calls.
                    this.drawRange(gl, quadIndex, cpuQuads, range);
                    range.baseVertex += cpuQuads * 4; // look at this
                    range.baseIndex  += cpuQuads * 6; // look at this
                    quadIndex        += cpuQuads;
                    quadCount        -= cpuQuads;
                    gpuQuads         -= cpuQuads;
                }
            }
        }

        /**
         * Disposes of all sprite references currently held by the batch. The
         * storage is freed. Use the SpriteBatch.resize() method to allocate
         * new storage.
         */
        public function dispose() : void
        {
            this.vertexFormat.clearAttributes();
            this.indexData       = null;
            this.vertexData      = null;
            this.vertexFormat    = null;
            this.blendState      = null;
            this.vertexCapacity  = 0;
            this.vertexSize      = 0;
            this.indexCapacity   = 0;
            this.indexSize       = 0;
            this.sprites         = null;
            this.count           = 0;
        }
    }
}
