package com.ninjabird.firelight.renderer
{
    import com.ninjabird.firelight.renderer.events.RenderEvents;

    import flash.utils.Endian;
    import flash.utils.ByteArray;
    import flash.display3D.Program3D;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.display3D.textures.Texture;
    import flash.display3D.textures.TextureBase;
    import flash.display3D.textures.CubeTexture;
    import com.ninjabird.firelight.debug.DebugTrace;
    import com.ninjabird.firelight.renderer.events.ContextLostEvent;
    import com.ninjabird.firelight.renderer.events.ContextReadyEvent;
    import com.ninjabird.firelight.renderer.events.RenderEvents;

    /**
     * Manages the creation and tracking of GPU resources. Resources can be
     * automatically re-created when a rendering context is lost and then
     * restored (though the data they contain must still be re-uploaded by
     * the application).
     */
    public final class ResourcePool
    {
        /**
         * The display context attached to this resource pool.
         */
        public var displayContext:DisplayContext;

        /**
         * The width of the framebuffer, in pixels.
         */
        public var framebufferWidth:int;

        /**
         * The height of the framebuffer, in pixels.
         */
        public var framebufferHeight:int;

        /**
         * The set of shader programs defined in the resource pool.
         */
        public var programs:Vector.<Program3D>;

        /**
         * Descriptors for the shader programs defined in the pool.
         */
        public var programDesc:Vector.<ProgramDesc>;

        /**
         * The set of textures defined in the resource pool.
         */
        public var textures:Vector.<TextureBase>;

        /**
         * Descriptors for the textures defined in the pool.
         */
        public var textureDesc:Vector.<TextureDesc>;

        /**
         * The set of render targets defined in the resource pool.
         */
        public var renderTargets:Vector.<TextureBase>;

        /**
         * The set of index buffers defined in the resource pool.
         */
        public var indexBuffers:Vector.<IndexBuffer3D>;

        /**
         * The set of vertex buffers defined in the resource pool.
         */
        public var vertexBuffers:Vector.<VertexBuffer3D>;

        /**
         * Descriptors for the vertex and index buffers.
         */
        public var bufferDesc:Vector.<BufferDesc>;

        /**
         * Disposes of all resources in the pool, but does not delete the
         * resource descriptors.
         */
        private function deleteResources() : void
        {
            try
            {
                var i:int = 0;
                for (i = 0; i < this.programs.length; ++i)
                {
                    if (this.programs[i])
                    {
                        this.programs[i].dispose();
                        this.programs[i]  = null;
                    }
                }
                for (i = 0; i < this.textures.length; ++i)
                {
                    if (this.textures[i])
                    {
                        this.textures[i].dispose();
                        this.textures[i]  = null;
                    }
                }
                for (i = 0; i < this.renderTargets.length; ++i)
                {
                    // render targets are freed as textures, above.
                    this.renderTargets[i] = null;
                }
                for (i = 0; i < this.indexBuffers.length; ++i)
                {
                    if (this.indexBuffers[i])
                    {
                        this.indexBuffers[i].dispose();
                        this.indexBuffers[i] = null;
                    }
                }
                for (i = 0; i < this.vertexBuffers.length; ++i)
                {
                    if (this.vertexBuffers[i])
                    {
                        this.vertexBuffers[i].dispose();
                        this.vertexBuffers[i] = null;
                    }
                }
            }
            catch (e:*)
            {
                // some kind of error occurred; just null all references.
                for (i = 0; i < this.programs.length; ++i)
                {
                    this.programs[i] = null;
                }
                for (i = 0; i < this.textures.length; ++i)
                {
                    this.textures[i] = null;
                }
                for (i = 0; i < this.renderTargets.length; ++i)
                {
                    this.renderTargets[i] = null;
                }
                for (i = 0; i < this.indexBuffers.length; ++i)
                {
                    this.indexBuffers[i] = null;
                }
                for (i = 0; i < this.vertexBuffers.length; ++i)
                {
                    this.vertexBuffers[i] = null;
                }
            }
        }

        /**
         * Callback invoked when the graphics context is lost. This sets the
         * reference for each GPU resource to null.
         * @param ev Additional information about the event.
         */
        private function handleContextLost(ev:ContextLostEvent) : void
        {
            var i:int = 0;
            for (i = 0; i < this.programs.length; ++i)
            {
                this.programs[i] = null;
            }
            for (i = 0; i < this.textures.length; ++i)
            {
                this.textures[i] = null;
            }
            for (i = 0; i < this.renderTargets.length; ++i)
            {
                this.renderTargets[i] = null;
            }
            for (i = 0; i < this.indexBuffers.length; ++i)
            {
                this.indexBuffers[i] = null;
            }
            for (i = 0; i < this.vertexBuffers.length; ++i)
            {
                this.vertexBuffers[i] = null;
            }
        }

        /**
         * Callback invoked when the graphics context is created, or re-created
         * after a context loss. This triggers the re-creation of all GPU
         * resources managed by this pool.
         * @param ev Additional information about the event.
         */
        private function handleContextReady(ev:ContextReadyEvent) : void
        {
            var i:int = 0;
            for (i = 0; i < this.programDesc.length; ++i)
            {
                if (!this.recreateProgram(this.programDesc[i]))
                {
                    this.deleteResources();
                    return;
                }
            }
            for (i = 0; i < this.textureDesc.length; ++i)
            {
                if (!this.recreateTexture(this.textureDesc[i]))
                {
                    this.deleteResources();
                    return;
                }
            }
            for (i = 0; i < this.bufferDesc.length; ++i)
            {
                if (!this.recreateBuffer(this.bufferDesc[i]))
                {
                    this.deleteResources();
                    return;
                }
            }
        }

        /**
         * Constructs a new instance, optionally attaching to the specified display context.
         * @param dc The display context to attach to.
         * @param priority The priority level of the resource pool. This is a
         * positive integer, greater than zero, used to control the order in
         * which resource pools are restored after a context loss.
         */
        public function ResourcePool(dc:DisplayContext=null, priority:int=1)
        {
            if (!dc)
            {
                this.displayContext    = null;
                this.framebufferWidth  = 0;
                this.framebufferHeight = 0;
                this.programs          = new Vector.<Program3D>();
                this.programDesc       = new Vector.<ProgramDesc>();
                this.textures          = new Vector.<TextureBase>();
                this.textureDesc       = new Vector.<TextureDesc>();
                this.renderTargets     = new Vector.<TextureBase>();
                this.indexBuffers      = new Vector.<IndexBuffer3D>();
                this.vertexBuffers     = new Vector.<VertexBuffer3D>();
                this.bufferDesc        = new Vector.<BufferDesc>();
            }
            else this.attachDisplayContext(dc, priority);
        }

        /**
         * Attaches the resource list to a display context and clears the resource lists.
         * @param dc The display context to attach to.
         * @param priority The priority level of the resource pool. This is a
         * positive integer, greater than zero, used to control the order in
         * which resource pools are restored after context loss.
         * @return true if the display context is valid.
         */
        public function attachDisplayContext(dc:DisplayContext, priority:int=1) : Boolean
        {
            if (dc === null)
            {
                DebugTrace.out('ResourcePool::attachDisplayContext(2) - Invalid display context.');
                return false;
            }
            if (priority <= 0)
            {
                DebugTrace.out('ResourcePool::attachDisplayContext(2) - Invalid priority %d; using 1.', priority);
                priority  = 1;
            }
            if (this.displayContext !== null)
            {
                DebugTrace.out('ResourcePool::attachDisplayContext(2) - Detaching existing context.');
                this.detachDisplayContext();
            }
            this.displayContext    = dc;
            this.framebufferWidth  = 0;
            this.framebufferHeight = 0;
            this.programs          = new Vector.<Program3D>();
            this.programDesc       = new Vector.<ProgramDesc>();
            this.textures          = new Vector.<TextureBase>();
            this.textureDesc       = new Vector.<TextureDesc>();
            this.renderTargets     = new Vector.<TextureBase>();
            this.indexBuffers      = new Vector.<IndexBuffer3D>();
            this.vertexBuffers     = new Vector.<VertexBuffer3D>();
            this.bufferDesc        = new Vector.<BufferDesc>();
            dc.addEventListener(RenderEvents.CONTEXT_LOST,  this.handleContextLost, false, priority);
            dc.addEventListener(RenderEvents.CONTEXT_READY, this.handleContextReady, false, priority);
            return true;
        }

        /**
         * Detaches the display context and clears the resource lists.
         */
        public function detachDisplayContext() : DisplayContext
        {
            var dc:DisplayContext = this.displayContext;
            if (dc)
            {
                dc.removeEventListener(RenderEvents.CONTEXT_LOST,  this.handleContextLost);
                dc.removeEventListener(RenderEvents.CONTEXT_READY, this.handleContextReady);
                this.displayContext       = null;
                this.framebufferWidth     = 0;
                this.framebufferHeight    = 0;
                this.programs.length      = 0;
                this.programDesc.length   = 0;
                this.textures.length      = 0;
                this.textureDesc.length   = 0;
                this.indexBuffers.length  = 0;
                this.renderTargets.length = 0;
                this.vertexBuffers.length = 0;
                this.bufferDesc.length    = 0;
            }
            return dc;
        }

        /**
         * Calculate the next positive power of two greater than or equal to a
         * given value. For negative inputs or zero, one is returned.
         * @param value The input value.
         * @return The next positive power of two greater than or equal to the
         * input value.
         */
        public function nextPowerOfTwo(value:int) : int
        {
            if (value <= 0)
            {
                return 1;
            }

            --value; // in case value is already a power-of-two.
            value  = (value >>  1) | value;
            value  = (value >>  2) | value;
            value  = (value >>  4) | value;
            value  = (value >>  8) | value;
            value  = (value >> 16) | value;
            ++value; // value is now the next power of two >= input value.

            return value;
        }

        /**
         * Creates the framebuffer (color plus depth and stencil buffers) for the current rendering context.
         * @param width The width of the framebuffer, in pixels. Specify zero to use the current width of the stage.
         * @param height The height of the framebuffer, in pixels. Specify zero to use the current height of the stage.
         * @param antialias Specify true to use multisample antialiasing. This increases display quality, but comes with a performance cost.
         * @return true if the framebuffer was created successfully.
         */
        public function createFramebuffer(width:int=0, height:int=0, antialias:Boolean=true) : Boolean
        {
            var res:Boolean       = false;
            var dc:DisplayContext = this.displayContext;
            if (dc === null)
            {
                DebugTrace.out('ResourcePool::createFramebuffer(3) - Invalid display context.');
                return false;
            }
            if (dc.context3d === null)
            {
                DebugTrace.out('ResourcePool::createFramebuffer(3) - Invalid rendering context.');
                return false;
            }
            if (dc.isContextLost)
            {
                DebugTrace.out('ResourcePool::createFramebuffer(3) - Cannot create framebuffer during lost context.');
                return false;
            }
            if (width === 0 && height === 0)
            {
                width  = dc.stage2d.width;
                height = dc.stage2d.height;
            }
            if (width  < 50)
            {
                DebugTrace.out('ResourcePool::createFramebuffer(3) - Using minimum supported width of 50px.');
                width  = 50;
            }
            if (height < 50)
            {
                DebugTrace.out('ResourcePool::createFramebuffer(3) - Using minimum supported height of 50px.');
                height = 50;
            }
            try
            {
                // note that we always request a framebuffer with depth/stencil
                // capability, and we always set wantsBestResolution to true in
                // order to support HiDPI/retina displays.
                var quality:int = antialias ? 4 : 0; // use high quality AA.
                dc.context3d.configureBackBuffer(width, height, quality, true, true);
                this.framebufferWidth  = width  * dc.stage2d.contentsScaleFactor;
                this.framebufferHeight = height * dc.stage2d.contentsScaleFactor;
                res = true;
            }
            catch (e:Error)
            {
                DebugTrace.out('ResourcePool::createFramebuffer(3): %s.', e.message);
                dc.notifyContextLost();
                res = false;
            }
            return res;
        }

        /**
         * Creates a shader program object.
         * @return The program descriptor, or null.
         */
        public function createProgram() : ProgramDesc
        {
            var desc:ProgramDesc = null;
            try
            {
                var dc:DisplayContext = this.displayContext;
                var rc:Context3D      = dc.context3d;
                var program:Program3D = rc.createProgram();
                desc                  = new ProgramDesc();
                desc.programHandle    = this.programs.length;
                this.programs.push(program);
                this.programDesc.push(desc);
            }
            catch (e:Error)
            {
                DebugTrace.out('ResourcePool::createProgram(0): %s.', e.message);
                this.displayContext.notifyContextLost();
                return null;
            }
            return desc;
        }

        /**
         * Creates a standard 2D texture resource.
         * @param width The width of the texture, in pixels.
         * @param height The height of the texture, in pixels.
         * @param format One of Context3DTextureFormat specifying the format.
         * @return The texture descriptor, or null.
         */
        public function createTexture(width:int, height:int, format:String) : TextureDesc
        {
            var desc:TextureDesc = null;
            width  = this.nextPowerOfTwo(width);
            height = this.nextPowerOfTwo(height);

            try
            {
                var dc:DisplayContext = this.displayContext;
                var rc:Context3D      = dc.context3d;
                var texture:Texture   = rc.createTexture(width, height, format, false);
                desc                  = new TextureDesc();
                desc.width            = width;
                desc.height           = height;
                desc.format           = format;
                desc.isCubeMap        = false;
                desc.isRenderTarget   = false;
                desc.targetHandle     = -1;
                desc.textureHandle    = this.textures.length;
                this.textures.push(texture);
                this.textureDesc.push(desc);
            }
            catch (a:ArgumentError)
            {
                DebugTrace.out('ResourcePool::createTexture(3): %s.', a.message);
                return null;
            }
            catch (e:Error)
            {
                DebugTrace.out('ResourcePool::createTexture(3): %s.', e.message);
                this.displayContext.notifyContextLost();
                return null;
            }
            return desc;
        }

        /**
         * Creates a cubemap texture resource.
         * @param dimension The width and height of each cube face.
         * @param format One of Context3DTextureFormat specifying the format.
         * @return The texture descriptor, or null.
         */
        public function createCubemap(dimension:int, format:String) : TextureDesc
        {
            var desc:TextureDesc = null;
            dimension = this.nextPowerOfTwo(dimension);

            try
            {
                var dc:DisplayContext   = this.displayContext;
                var rc:Context3D        = dc.context3d;
                var texture:CubeTexture = rc.createCubeTexture(dimension, format, false);
                desc                    = new TextureDesc();
                desc.width              = dimension;
                desc.height             = dimension;
                desc.format             = format;
                desc.isCubeMap          = true;
                desc.isRenderTarget     = false;
                desc.targetHandle       = -1;
                desc.textureHandle      = this.textures.length;
                this.textures.push(texture);
                this.textureDesc.push(desc);
            }
            catch (a:ArgumentError)
            {
                DebugTrace.out('ResourcePool::createCubemap(2): %s.', a.message);
                return null;
            }
            catch (e:Error)
            {
                DebugTrace.out('ResourcePool::createCubemap(2): %s.', e.message);
                this.displayContext.notifyContextLost();
                return null;
            }
            return desc;
        }

        /**
         * Creates a texture that can also be used as the target of rendering
         * operations. The texture is always created with a BGRA8888 format.
         * @param width The render target width, in pixels.
         * @param height The render target height, in pixels.
         * @return The texture descriptor, or null.
         */
        public function createRenderTarget(width:int, height:int) : TextureDesc
        {
            var desc:TextureDesc = null;
            width  = this.nextPowerOfTwo(width);
            height = this.nextPowerOfTwo(height);

            try
            {
                var dc:DisplayContext = this.displayContext;
                var rc:Context3D      = dc.context3d;
                var format:String     = Context3DTextureFormat.BGRA;
                var texture:Texture   = rc.createTexture(width, height, format, true);
                desc                  = new TextureDesc();
                desc.width            = width;
                desc.height           = height;
                desc.format           = format;
                desc.isCubeMap        = false;
                desc.isRenderTarget   = true;
                desc.targetHandle     = this.renderTargets.length;
                desc.textureHandle    = this.textures.length;
                this.textures.push(texture);
                this.textureDesc.push(desc);
                this.renderTargets.push(texture);
            }
            catch (a:ArgumentError)
            {
                DebugTrace.out('ResourcePool::createRenderTarget(2): %s.', a.message);
                return null;
            }
            catch (e:Error)
            {
                DebugTrace.out('ResourcePool::createRenderTarget(2): %s.', e.message);
                this.displayContext.notifyContextLost();
                return null;
            }
            return desc;
        }

        /**
         * Creates a cubemap texture that can also be used as the target of
         * rendering operations. The texture is always created with a BGRA8888 format.
         * @param dimension The width and height of the cubemap, in pixels.
         * @return The texture descriptor, or null.
         */
        public function createCubeRenderTarget(dimension:int) : TextureDesc
        {
            var desc:TextureDesc = null;
            dimension = this.nextPowerOfTwo(dimension);

            try
            {
                var dc:DisplayContext   = this.displayContext;
                var rc:Context3D        = dc.context3d;
                var format:String       = Context3DTextureFormat.BGRA;
                var texture:CubeTexture = rc.createCubeTexture(dimension, format, true);
                desc                    = new TextureDesc();
                desc.width              = dimension;
                desc.height             = dimension;
                desc.format             = format;
                desc.isCubeMap          = true;
                desc.isRenderTarget     = true;
                desc.targetHandle       = this.renderTargets.length;
                desc.textureHandle      = this.textures.length;
                this.textures.push(texture);
                this.textureDesc.push(desc);
                this.renderTargets.push(texture);
            }
            catch (a:ArgumentError)
            {
                DebugTrace.out('ResourcePool::createCubeRenderTarget(1): %s.', a.message);
                return null;
            }
            catch (e:Error)
            {
                DebugTrace.out('ResourcePool::createCubeRenderTarget(1): %s.', e.message);
                this.displayContext.notifyContextLost();
                return null;
            }
            return desc;
        }

        /**
         * Creates an index buffer used for defining triangle primitives.
         * @param count The number of indices that can be stored in the buffer.
         * @param usage One of the values of the Context3DBufferUsage
         * enumeration defining the update frequency for the data in the buffer.
         * @return The buffer descriptor, or null.
         */
        public function createIndexBuffer(count:int, usage:String) : BufferDesc
        {
            var desc:BufferDesc = null;
            try
            {
                var dc:DisplayContext    = this.displayContext;
                var rc:Context3D         = dc.context3d;
                var buffer:IndexBuffer3D = rc.createIndexBuffer(count, usage);
                desc                     = new BufferDesc();
                desc.usageType           = usage;
                desc.elementCount        = count;
                desc.bytesPerElement     = 2; // indices are uint16_t
                desc.isIndexBuffer       = true;
                desc.bufferHandle        = this.indexBuffers.length;

                // the index buffer data must be completely specified at least
                // once, or else partial updates will fail with the error
                // 'No valid index buffer set' during a drawTriangles() call.
                // to prevent this, upload a ByteArray filled with zeroes.
                var zeroes:ByteArray = new ByteArray();
                zeroes.endian = Endian.LITTLE_ENDIAN;
                zeroes.length = count * 2;
                buffer.uploadFromByteArray(zeroes, 0, 0, count);
                zeroes.length = 0;
                zeroes = null;

                this.indexBuffers.push(buffer);
                this.bufferDesc.push(desc);
            }
            catch (e:Error)
            {
                DebugTrace.out('ResourcePool::createIndexBuffer(2): %s.', e.message);
                this.displayContext.notifyContextLost();
                return null;
            }
            return desc;
        }

        /**
         * Creates a vertex buffer.
         * @param count The number of vertices that can be stored in the buffer.
         * @param sizeInBytes The size of a single vertex, in bytes.
         * @param usage One of the values of the Context3DBufferUsage
         * enumeration defining the update frequency for the data in the buffer.
         * @return The buffer descriptor, or null.
         */
        public function createVertexBuffer(count:int, sizeInBytes:int, usage:String) : BufferDesc
        {
            var desc:BufferDesc = null;
            sizeInBytes = ((sizeInBytes + 3) & (~3)); // align to multiple of 4

            try
            {
                var dc:DisplayContext     = this.displayContext;
                var rc:Context3D          = dc.context3d;
                var buffer:VertexBuffer3D = rc.createVertexBuffer(count, sizeInBytes / 4, usage);
                desc                      = new BufferDesc();
                desc.usageType            = usage;
                desc.elementCount         = count;
                desc.bytesPerElement      = sizeInBytes;
                desc.isIndexBuffer        = false;
                desc.bufferHandle         = this.vertexBuffers.length;

                // the vertex buffer data must be completely specified at least
                // once, or else partial updates will fail. to prevent any
                // issues, upload a ByteArray filled with zeroes.
                var zeroes:ByteArray = new ByteArray();
                zeroes.endian = Endian.LITTLE_ENDIAN;
                zeroes.length = count * sizeInBytes;
                buffer.uploadFromByteArray(zeroes, 0, 0, count);
                zeroes.length = 0;
                zeroes = null;

                this.vertexBuffers.push(buffer);
                this.bufferDesc.push(desc);
            }
            catch (a:ArgumentError)
            {
                DebugTrace.out('ResourcePool::createVertexBuffer(3): %s.', a.message);
                return null;
            }
            catch (e:Error)
            {
                DebugTrace.out('ResourcePool::createVertexBuffer(3): %s.', e.message);
                this.displayContext.notifyContextLost();
                return null;
            }
            return desc;
        }

        /**
         * Recreates a shader program resource given its descriptor.
         * @param desc The shader program descriptor.
         * @return true if the shader program was recreated.
         */
        public function recreateProgram(desc:ProgramDesc) : Boolean
        {
            var dc:DisplayContext = this.displayContext;
            var rc:Context3D      = dc.context3d;
            var res:Boolean       = false;

            try
            {
                var program:Program3D = rc.createProgram();
                this.programs[desc.programHandle] = program;
                res = true;
            }
            catch (e:Error)
            {
                DebugTrace.out('ResourcePool::recreateProgram(1): %s.', e.message);
                this.displayContext.notifyContextLost();
                res = false;
            }
            return res;
        }

        /**
         * Recreates a texture resource given its texture descriptor.
         * @param desc The texture descriptor.
         * @return true if the texture was recreated.
         */
        public function recreateTexture(desc:TextureDesc) : Boolean
        {
            var dc:DisplayContext   = this.displayContext;
            var rc:Context3D        = dc.context3d;
            var res:Boolean         = false;
            var texture:TextureBase = null;

            try
            {
                if (desc.isRenderTarget)
                {
                    if (desc.isCubeMap) texture = rc.createCubeTexture(desc.width, desc.format, true);
                    else texture = rc.createTexture(desc.width, desc.height, desc.format, true);
                    this.textures[desc.textureHandle] = texture;
                    this.renderTargets[desc.targetHandle] = texture;
                }
                else
                {
                    if (desc.isCubeMap) texture = rc.createCubeTexture(desc.width, desc.format, false);
                    else texture = rc.createTexture(desc.width, desc.height, desc.format, false);
                    this.textures[desc.textureHandle] = texture;
                }
                res = true;
            }
            catch (e:Error)
            {
                DebugTrace.out('ResourcePool::recreateTexture(1): %s.', e.message);
                this.displayContext.notifyContextLost();
                res = false;
            }
            return res;
        }

        /**
         * Recreates a buffer resource given its descriptor.
         * @param desc The buffer descriptor.
         * @return true if the buffer was recreated.
         */
        public function recreateBuffer(desc:BufferDesc) : Boolean
        {
            var dc:DisplayContext = this.displayContext;
            var rc:Context3D      = dc.context3d;
            var res:Boolean       = false;

            try
            {
                if (desc.isIndexBuffer)
                {
                    var ib:IndexBuffer3D = rc.createIndexBuffer(desc.elementCount, desc.usageType);
                    this.indexBuffers[desc.bufferHandle] = ib;
                }
                else
                {
                    var vb:VertexBuffer3D = rc.createVertexBuffer(desc.elementCount, desc.bytesPerElement / 4, desc.usageType);
                    this.vertexBuffers[desc.bufferHandle] = vb;
                }
                res = true;
            }
            catch (e:Error)
            {
                DebugTrace.out('ResourcePool::recreateBuffer(1): %s.', e.message);
                this.displayContext.notifyContextLost();
                res = false;
            }
            return res;
        }

        /**
         * Disposes of a shader program object. The program object descriptor
         * remains valid, and the shader program can be recreated using the
         * ResourcePool.recreateProgram() function.
         * @desc The shader program descriptor.
         */
        public function disposeProgram(desc:ProgramDesc) : void
        {
            var program:Program3D = this.programFor(desc);
            if (program)
            {
                try
                {
                    program.dispose();
                }
                catch (e:*)
                {
                    DebugTrace.out('ResourcePool::disposeProgram(1): %s.', e.message);
                }
                finally
                {
                    this.programs[desc.programHandle] = null;
                }
            }
        }

        /**
         * Disposes of a texture resource or render target. The texture object
         * descriptor remains valid, and the texture or render target can be
         * recreated using the ResourcePool.recreateTexture() function.
         * @param desc The texture object descriptor.
         */
        public function disposeTexture(desc:TextureDesc) : void
        {
            var texture:TextureBase = this.textureFor(desc);
            if (texture)
            {
                try
                {
                    texture.dispose();
                }
                catch (e:*)
                {
                    DebugTrace.out('ResourcePool::disposeTexture(1): %s.', e.message);
                }
                finally
                {
                    this.textures[desc.textureHandle] = null;
                    if (desc.isRenderTarget)
                    {
                        this.renderTargets[desc.targetHandle] = null;
                    }
                }
            }
        }

        /**
         * Disposes of a vertex or index buffer resource. The buffer object
         * descriptor remains valid, and the buffer can be recreated using the
         * ResourcePool::recreateBuffer() function.
         * @param desc The buffer object descriptor.
         */
        public function disposeBuffer(desc:BufferDesc) : void
        {
            if (desc.isIndexBuffer)
            {
                var ib:IndexBuffer3D = this.indexBufferFor(desc);
                if (ib)
                {
                    try
                    {
                        ib.dispose();
                    }
                    catch (e1:*)
                    {
                        DebugTrace.out('ResourcePool::disposeBuffer(1): %s.', e1.message);
                    }
                    finally
                    {
                        this.indexBuffers[desc.bufferHandle] = null;
                    }
                }
            }
            else
            {
                var vb:VertexBuffer3D = this.vertexBufferFor(desc);
                if (vb)
                {
                    try
                    {
                        vb.dispose();
                    }
                    catch (e2:*)
                    {
                        DebugTrace.out('ResourcePool::disposeBuffer(1): %s.', e2.message);
                    }
                    finally
                    {
                        this.vertexBuffers[desc.bufferHandle] = null;
                    }
                }
            }
        }

        /**
         * Retrieves a shader program object given its handle.
         * @param handle The shader program handle.
         * @return The shader program object, or null.
         */
        public function program(handle:int) : Program3D
        {
            if (handle < 0 || handle >= this.programs.length)
            {
                DebugTrace.out('ResourcePool::program(1) - Invalid handle %d.', handle);
                return null;
            }
            return this.programs[handle];
        }

        /**
         * Retrieves a shader program object given its descriptor.
         * @param desc The shader program descriptor.
         * @return The shader program object.
         */
        public function programFor(desc:ProgramDesc) : Program3D
        {
            return this.program(desc.programHandle);
        }

        /**
         * Retrieves a texture object given its handle.
         * @oaram handle The texture handle.
         * @return The texture object, or null.
         */
        public function texture(handle:int) : TextureBase
        {
            if (handle < 0 || handle >= this.textures.length)
            {
                DebugTrace.out('ResourcePool::texture(1) - Invalid handle %d.', handle);
                return null;
            }
            return this.textures[handle];
        }

        /**
         * Retrieves a texture given its descriptor.
         * @param desc The texture descriptor.
         * @return The texture object.
         */
        public function textureFor(desc:TextureDesc) : TextureBase
        {
            return this.texture(desc.textureHandle);
        }

        /**
         * Retrieves a texture object given its handle.
         * @oaram handle The texture handle.
         * @return The texture object, or null.
         */
        public function renderTarget(handle:int) : TextureBase
        {
            if (handle < 0 || handle >= this.renderTargets.length)
            {
                DebugTrace.out('ResourcePool::renderTarget(1) - Invalid handle %d.', handle);
                return null;
            }
            return this.renderTargets[handle];
        }

        /**
         * Retrieves a texture given its descriptor.
         * @param desc The texture descriptor.
         * @return The texture object.
         */
        public function renderTargetFor(desc:TextureDesc) : TextureBase
        {
            return this.renderTarget(desc.targetHandle);
        }

        /**
         * Retrieves an index buffer object given its handle.
         * @oaram handle The buffer handle.
         * @return The index buffer object, or null.
         */
        public function indexBuffer(handle:int) : IndexBuffer3D
        {
            if (handle < 0 || handle >= this.indexBuffers.length)
            {
                DebugTrace.out('ResourcePool::indexBuffer(1) - Invalid handle %d.', handle);
                return null;
            }
            return this.indexBuffers[handle];
        }

        /**
         * Retrieves an index buffer given its descriptor.
         * @param desc The index buffer descriptor.
         * @return The index buffer object.
         */
        public function indexBufferFor(desc:BufferDesc) : IndexBuffer3D
        {
            if (desc.isIndexBuffer === false)
            {
                DebugTrace.out('ResourcePool::indexBuffer(1) - Buffer is not an index buffer.');
                return null;
            }
            return this.indexBuffer(desc.bufferHandle);
        }

        /**
         * Retrieves a vertex buffer object given its handle.
         * @oaram handle The buffer handle.
         * @return The vertex buffer object, or null.
         */
        public function vertexBuffer(handle:int) : VertexBuffer3D
        {
            if (handle < 0 || handle >= this.vertexBuffers.length)
            {
                DebugTrace.out('ResourcePool::vertexBuffer(1) - Invalid handle %d.', handle);
                return null;
            }
            return this.vertexBuffers[handle];
        }

        /**
         * Retrieves a vertex buffer given its descriptor.
         * @param desc The vertex buffer descriptor.
         * @return The vertex buffer object.
         */
        public function vertexBufferFor(desc:BufferDesc) : VertexBuffer3D
        {
            if (desc.isIndexBuffer === true)
            {
                DebugTrace.out('ResourcePool::vertexBuffer(1) - Buffer is not a vertex buffer.');
                return null;
            }
            return this.vertexBuffer(desc.bufferHandle);
        }

        /**
         * Disposes of all resources in the pool. The display context is not
         * detached from the pool.
         */
        public function dispose() : void
        {
            this.deleteResources();
            this.programs.length = 0;
            this.textures.length = 0;
            this.indexBuffers.length  = 0;
            this.renderTargets.length = 0;
            this.vertexBuffers.length = 0;
            this.programDesc.length = 0;
            this.textureDesc.length = 0;
            this.bufferDesc.length  = 0;
        }

    }
}
