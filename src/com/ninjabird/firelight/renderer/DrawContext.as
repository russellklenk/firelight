package com.ninjabird.firelight.renderer
{
    import flash.geom.Matrix3D;
    import flash.utils.ByteArray;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DWrapMode;
    import flash.display3D.Context3DMipFilter;
    import flash.display3D.Context3DTextureFilter;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DTriangleFace;
    import flash.display3D.Context3DStencilAction;
    import flash.display3D.Program3D;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.textures.TextureBase;
    import com.ninjabird.firelight.debug.DebugTrace;
    import com.ninjabird.firelight.renderer.events.ContextReadyEvent;
    import com.ninjabird.firelight.renderer.events.RenderEvents;
    import com.ninjabird.firelight.renderer.states.BlendState;
    import com.ninjabird.firelight.renderer.states.ClearState;
    import com.ninjabird.firelight.renderer.states.DepthStencilState;
    import com.ninjabird.firelight.renderer.states.RasterState;

    /**
     * Maintains cached state data associated with a rendering context, and
     * provides methods for applying state and rendering, eliminating duplicate
     * state changes. Do not modify the cached state values exposed by this class.
     */
    public final class DrawContext
    {
        /**
         * The maximum number of texture samplers supported by the profile.
         */
        public static const MAX_TEXTURE_SAMPLERS:int  = 8;

        /**
         * The maximum number of active vertex attributes supported.
         */
        public static const MAX_VERTEX_ATTRIBUTES:int = 8;

        /**
         * The active display context, defining the display we render into.
         */
        public var displayContext:DisplayContext;

        /**
         * The width of the framebuffer, in pixels, scaled for the device.
         */
        public var framebufferWidth:int;

        /**
         * The height of the framebuffer, in pixels, scaled for the device.
         */
        public var framebufferHeight:int;

        /**
         * Cached render state relating to alpha blending.
         */
        public var blendState:BlendState;

        /**
         * Cached render state relating to framebuffer clearing.
         */
        public var clearState:ClearState;

        /**
         * Cached render state relating to rasterization.
         */
        public var rasterState:RasterState;

        /**
         * Cached render state relating to depth and stencil testing.
         */
        public var depthStencilState:DepthStencilState;

        /**
         * The active shader program object, or null.
         */
        public var program:Program3D;

        /**
         * The active render target, or null if the backbuffer is the current
         * render target.
         */
        public var renderTarget:TextureBase;

        /**
         * The set of vertex buffers bound as vertex attributes.
         */
        public var vertexFormat:VertexFormat;

        /**
         * The set of textures bound to texture samplers.
         */
        public var samplers:Vector.<TextureBase>;

        /**
         * Callback invoked when the rendering context becomes ready, either
         * after initial creation or after a context loss.
         * @param ev Additional information about the event.
         */
        private function handleContextReady(ev:ContextReadyEvent) : void
        {
            this.applyDefaultState();
        }

        /**
         * Constructs a new instance initialized with the default state.
         */
        public function DrawContext()
        {
            this.displayContext    = null;
            this.framebufferWidth  = 0;
            this.framebufferHeight = 0;
            this.blendState        = new BlendState();
            this.clearState        = new ClearState();
            this.rasterState       = new RasterState();
            this.depthStencilState = new DepthStencilState();
            this.program           = null;
            this.renderTarget      = null;
            this.vertexFormat      = null;
            this.samplers          = new Vector.<TextureBase>(DrawContext.MAX_TEXTURE_SAMPLERS, true);
        }

        /**
         * Resets the rendering context to its default state.
         */
        public function applyDefaultState() : void
        {
            var dc:DisplayContext = this.displayContext;
            if (dc && dc.isContextLost === false)
            {
                try
                {
                    var keep:String        = Context3DStencilAction.KEEP;
                    var rc:Context3D       = dc.context3d;
                    var i:int = 0;

                    // reset internal state; just throw the old stuff away.
                    this.blendState        = new BlendState();
                    this.clearState        = new ClearState();
                    this.rasterState       = new RasterState();
                    this.depthStencilState = new DepthStencilState();
                    this.program           = null;
                    this.renderTarget      = null;
                    this.vertexFormat      = null;
                    this.samplers          = new Vector.<TextureBase>(DrawContext.MAX_TEXTURE_SAMPLERS, true);

                    // reset the render state on the render context.
                    rc.setRenderToBackBuffer();
                    rc.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
                    rc.setColorMask(true, true, true, true);
                    rc.setCulling(Context3DTriangleFace.NONE);
                    rc.setDepthTest(true, Context3DCompareMode.LESS);
                    rc.setScissorRectangle(null);
                    rc.setStencilReferenceValue(0, 0xFF, 0xFF);
                    rc.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.ALWAYS, keep, keep, keep);;

                    // unbind all texture samplers, and reset sampler states.
                    for (i = 0; i < DrawContext.MAX_TEXTURE_SAMPLERS; ++i)
                    {
                        rc.setTextureAt(i, null);
                        rc.setSamplerStateAt(i, Context3DWrapMode.REPEAT, Context3DTextureFilter.NEAREST, Context3DMipFilter.MIPNONE);
                    }

                    // unbind all vertex attributes.
                    for (i = 0; i < DrawContext.MAX_VERTEX_ATTRIBUTES; ++i)
                    {
                        rc.setVertexBufferAt(i, null);
                    }
                }
                catch (e:Error)
                {
                    dc.notifyContextLost();
                }
            }
        }

        /**
         * Changes the current state of the alpha blending unit.
         * @param state The new blending state to apply.
         */
        public function applyBlendState(state:BlendState) : void
        {
            var dc:DisplayContext = this.displayContext;
            if (dc && dc.isContextLost === false)
            {
                var rc:Context3D           = dc.context3d;
                var current:BlendState     = this.blendState;
                if (current.blendEnabled !== state.blendEnabled ||
                        current.sourceFactor !== state.sourceFactor ||
                        current.targetFactor !== state.targetFactor)
                {
                    rc.setBlendFactors(state.sourceFactor, state.targetFactor);
                    current.blendEnabled   = state.blendEnabled;
                    current.sourceFactor   = state.sourceFactor;
                    current.targetFactor   = state.targetFactor;
                }
            }
        }

        /**
         * Changes the current framebuffer clear values. The new values take
         * effect on the next frame.
         * @param state The framebuffer clear values to apply.
         */
        public function applyClearState(state:ClearState) : void
        {
            this.clearState.r       = state.r;
            this.clearState.g       = state.g;
            this.clearState.b       = state.b;
            this.clearState.a       = state.a;
            this.clearState.depth   = state.depth;
            this.clearState.stencil = state.stencil;
            this.clearState.mask    = state.mask;
        }

        /**
         * Changes the current rasterizer state.
         * @param state The rasterizer state to apply.
         */
        public function applyRasterState(state:RasterState) : void
        {
            var dc:DisplayContext = this.displayContext;
            if (dc && dc.isContextLost === false)
            {
                var rc:Context3D        = dc.context3d;
                var current:RasterState = this.rasterState;
                if (current.writeR    !== state.writeR ||
                    current.writeG    !== state.writeG ||
                    current.writeB    !== state.writeB ||
                    current.writeA    !== state.writeA)
                {
                    rc.setColorMask(state.writeR, state.writeG, state.writeB, state.writeA);
                    current.writeR = state.writeR;
                    current.writeG = state.writeG;
                    current.writeB = state.writeB;
                    current.writeA = state.writeA;
                }
                if (current.cullFace  !== state.cullFace)
                {
                    rc.setCulling(state.cullFace);
                    current.cullFace = state.cullFace;
                }
                if (current.scissorTestEnabled !== state.scissorTestEnabled)
                {
                    if (state.scissorTestEnabled === false)
                    {
                        rc.setScissorRectangle(null);
                        current.scissorTestEnabled = false;
                    }
                    else
                    {
                        rc.setScissorRectangle(state.scissor);
                        current.scissor.copyFrom(state.scissor);
                        current.scissorTestEnabled = true;
                    }
                }
                if (current.scissor.equals(state.scissor) === false)
                {
                    if (state.scissorTestEnabled)
                    {
                        rc.setScissorRectangle(state.scissor);
                        current.scissor.copyFrom(state.scissor);
                        current.scissorTestEnabled = true;
                    }
                }
            }
        }

        /**
         * Changes the current depth and stencil test state.
         * @param state The depth and stencil test state to apply.
         */
        public function applyDepthStencilState(state:DepthStencilState) : void
        {
            var dc:DisplayContext = this.displayContext;
            if (dc && dc.isContextLost === false)
            {
                var rc:Context3D                = dc.context3d;
                var current:DepthStencilState   = this.depthStencilState;
                if (current.depthWriteEnabled !== state.depthWriteEnabled ||
                    current.depthFunction     !== state.depthFunction)
                {
                    rc.setDepthTest(state.depthWriteEnabled, state.depthFunction);
                    current.depthWriteEnabled = state.depthWriteEnabled;
                    current.depthFunction     = state.depthFunction;
                }
                if (current.stencilReference !== state.stencilReference   ||
                    current.stencilReadMask  !== state.stencilReadMask    ||
                    current.stencilWriteMask !== state.stencilWriteMask)
                {
                    rc.setStencilReferenceValue(state.stencilReference, state.stencilReadMask, state.stencilWriteMask);
                    current.stencilReference  = state.stencilReference;
                    current.stencilReadMask   = state.stencilReadMask;
                    current.stencilWriteMask  = state.stencilWriteMask;
                }
                if (current.stencilTestEnabled !== state.stencilTestEnabled ||
                    current.stencilFunction    !== state.stencilFunction    ||
                    current.stencilFace        !== state.stencilFace        ||
                    current.stencilPassZPassOp !== state.stencilPassZPassOp ||
                    current.stencilPassZFailOp !== state.stencilPassZFailOp ||
                    current.stencilFailZPassOp !== state.stencilFailZPassOp)
                {
                    var face:String = state.stencilTestEnabled ? state.stencilFace : Context3DTriangleFace.NONE;
                    rc.setStencilActions(face, state.stencilFunction, state.stencilPassZPassOp, state.stencilPassZFailOp, state.stencilFailZPassOp);
                    current.stencilTestEnabled = state.stencilTestEnabled;
                    current.stencilFunction    = state.stencilFunction;
                    current.stencilFace        = face;
                    current.stencilPassZPassOp = state.stencilPassZPassOp;
                    current.stencilPassZFailOp = state.stencilPassZFailOp;
                    current.stencilFailZPassOp = state.stencilFailZPassOp;
                }
            }
        }

        /**
         * Signals the beginning of the frame and clears the framebuffer using
         * the active clear state values. The render target is changed to the
         * back buffer. The back buffer is always cleared at the start of the
         * frame because the Stage3D implementation requires it.
         * @return true if the render context is active, or false if the render
         * context is lost and the frame should be cancelled.
         */
        public function beginFrame() : Boolean
        {
            var dc:DisplayContext = this.displayContext;
            if (dc && dc.isContextLost === false)
            {
                var rc:Context3D  = dc.context3d;
                var cs:ClearState = this.clearState;
                var res:Boolean   = false;
                try
                {
                    rc.setRenderToBackBuffer();
                    rc.clear(cs.r, cs.g, cs.b, cs.a, cs.depth, cs.stencil, cs.mask);
                    res = true;
                }
                catch (e:Error)
                {
                    DebugTrace.out('DrawContext::beginFrame(0): %s.', e.message);
                    dc.notifyContextLost();
                    res = false;
                }
                return res;
            }
            else return false;
        }

        /**
         * Signals the end of the frame by calling Context3D.present() to
         * display the framebuffer context. Note that this operation only
         * flushes the command queue to the GPU.
         * @return true if the render context is active, or false if the render context is lost.
         */
        public function endFrame() : Boolean
        {
            var dc:DisplayContext = this.displayContext;
            if (dc && dc.isContextLost === false)
            {
                var res:Boolean = false;
                try
                {
                    dc.context3d.present();
                    res = true;
                }
                catch (e:Error)
                {
                    DebugTrace.out('DrawContext::endFrame(0): %s.', e.message);
                    dc.notifyContextLost();
                    res = false;
                }
                return res;
            }
            else return false;
        }

        /**
         * Selects a different shader program for use during rendering.
         * @param program The shader program to select.
         * @return true if the change was performed successfully, or false if
         * a lost context was detected.
         */
        public function changeProgram(program:Program3D) : Boolean
        {
            if (program === this.program)
            {
                // this is already the active shader program.
                return true;
            }

            var dc:DisplayContext = this.displayContext;
            if (dc && dc.isContextLost === false)
            {
                var rc:Context3D  = dc.context3d;
                var res:Boolean   = false;
                try
                {
                    // change the active shader program.
                    rc.setProgram(program);
                    // reset all of the texture sampler bindings.
                    var numSamplers:int = DrawContext.MAX_TEXTURE_SAMPLERS;
                    for (var i:int = 0; i < numSamplers; ++i)
                    {
                        rc.setTextureAt(i, null);
                    }
                    this.program = program;
                    res = true;
                }
                catch (e:Error)
                {
                    DebugTrace.out('DrawContext::changeProgram(1): %s.', e.message);
                    dc.notifyContextLost();
                    res = false;
                }
                return res;
            }
            else return false;
        }

        /**
         * Sets program uniform data from a ByteArray.
         * @param shader One of the Context3DProgramType values indicating
         * which shader the uniform data is associated with.
         * @param register The zero-based index of the first register to update.
         * @param count The number of registers to set. Each register holds
         * four 32-bit floating point values.
         * @param data The ByteArray containing the uniform data.
         * @param offset The byte offset within @a data at which to begin reading the uniform data.
         * @return true if the uniform data was applied, or false if a lost context was detected.
         */
        public function uniformData(shader:String, register:int, count:int, data:ByteArray, offset:uint=0) : Boolean
        {
            if (this.program === null)
            {
                DebugTrace.out('DrawContext::uniformData(5) - No active program.');
                return true;
            }

            var dc:DisplayContext = this.displayContext;
            if (dc && dc.isContextLost === false)
            {
                var rc:Context3D  = dc.context3d;
                var res:Boolean   = false;
                try
                {
                    rc.setProgramConstantsFromByteArray(shader, register, count, data, offset);
                    res = true;
                }
                catch (e:Error)
                {
                    DebugTrace.out('DrawContext::uniformData(5): %s.', e.message);
                    res = false;
                }
                return res;
            }
            else return false;
        }

        /**
         * Sets program uniform data from a 4x4 matrix. This consumes four program registers.
         * @param shader One of the Context3DProgramType values indicating which shader the uniform data is associated with.
         * @param register The zero-based index of the first register to update.
         * @param matrix The matrix to write to uniform memory.
         * @param transpose true to transpose the matrix in uniform memory.
         * @return true if the uniform data was applied, or false if a lost context was detected.
         */
        public function uniformMatrix(shader:String, register:int, matrix:Matrix3D, transpose:Boolean=false) : Boolean
        {
            if (this.program === null)
            {
                DebugTrace.out('DrawContext::uniformMatrix(4) - No active program.');
                return true;
            }

            var dc:DisplayContext = this.displayContext;
            if (dc && dc.isContextLost === false)
            {
                var rc:Context3D  = dc.context3d;
                var res:Boolean   = false;
                try
                {
                    rc.setProgramConstantsFromMatrix(shader, register, matrix, transpose);
                    res = true;
                }
                catch (e:*)
                {
                    DebugTrace.out('DrawContext::uniformMatrix(4): %s.', e.message);
                    res = false;
                }
                return res;
            }
            else return false;
        }

        /**
         * Sets program uniform data from a vector.
         * @param shader One of the Context3DProgramType values indicating which shader the uniform data is associated with.
         * @param register The zero-based index of the first register to update.
         * @param data The vector containing uniform data.
         * @param count The number of registers to set, or -1 to set registers based on available data.
         * @return true if the uniform data was applied, or false if a lost context was detected.
         */
        public function uniformVector(shader:String, register:int, data:Vector.<Number>, count:int=-1) : Boolean
        {
            if (this.program === null)
            {
                DebugTrace.out('DrawContext::uniformVector(4) - No active program.');
                return true;
            }

            var dc:DisplayContext = this.displayContext;
            if (dc && dc.isContextLost === false)
            {
                var rc:Context3D  = dc.context3d;
                var res:Boolean   = false;
                try
                {
                    rc.setProgramConstantsFromVector(shader, register, data, count);
                    res = true;
                }
                catch (e:*)
                {
                    DebugTrace.out('DrawContext::uniformVector(4): %s.', e.message);
                    res = false;
                }
                return res;
            }
            else return false;
        }

        /**
         * Binds a texture to a texture sampler unit.
         * @param index The zero-based index of the texture sampler.
         * @param texture The texture to bind to the sampler, or null to unbind the active texture from the sampler.
         * @return true if the texture was bound to the sampling unit, or false if a lost context was detected.
         */
        public function bindSampler(index:int, texture:TextureBase) : Boolean
        {
            if (index < 0 || index >= 8)
            {
                DebugTrace.out('DrawContext::bindSampler(2) - Invalid sampler index.');
                return true;
            }
            if (this.samplers[index] === texture)
            {
                // this texture is already bound to the sampler.
                return true;
            }

            var dc:DisplayContext = this.displayContext;
            if (dc && dc.isContextLost === false)
            {
                var rc:Context3D  = dc.context3d;
                var res:Boolean   = false;
                try
                {
                    rc.setTextureAt(index, texture);
                    this.samplers[index] = texture;
                    res = true;
                }
                catch (e:*)
                {
                    DebugTrace.out('DrawContext::bindSampler(2): %s.', e.message);
                    res = false;
                }
                return res;
            }
            else return false;
        }

        /**
         * Changes the active vertex format.
         * @param format The new vertex format, or null to unbind all vertex attributes.
         * @return true if the vertex format is changed successfully.
         */
        public function changeVertexFormat(format:VertexFormat) : Boolean
        {
            var dc:DisplayContext = this.displayContext;
            if (dc && dc.isContextLost === false)
            {
                var rc:Context3D  = dc.context3d;
                var res:Boolean   = false;
                var i:int = 0;
                try
                {
                    if (format === null)
                    {
                        var attribCount:int = DrawContext.MAX_VERTEX_ATTRIBUTES;
                        for (i = 0; i < attribCount; ++i)
                        {
                            rc.setVertexBufferAt(i, null);
                        }
                    }
                    else
                    {
                        for (i = 0; i < format.attributeCount; ++i)
                        {
                            rc.setVertexBufferAt(i, format.buffers[i], format.offsets[i] / 4, format.formats[i]);
                        }
                    }
                    this.vertexFormat = format;
                    res = true;
                }
                catch (e:*)
                {
                    DebugTrace.out('DrawContext::changeVertexFormat(1): %s.', e.message);
                    res = false;
                }
                return res;
            }
            else return false;
        }

        /**
         * Changes the current render target to a texture.
         * @param target The render target texture.
         * @param depthStencil true if the render target requires writing to the depth and stencil buffer.
         * @param cubeFace A value in [0, 5] specifying the face of the cubemap to select for rendering.
         * Standard 2D render targets should specify 0.
         * @return true if the change was performed successfully, or false if a lost context was detected.
         */
        public function changeRenderTarget(target:TextureBase, depthStencil:Boolean=true, cubeFace:int=0) : Boolean
        {
            if (target === this.renderTarget)
            {
                // this is already the active render target.
                return true;
            }

            var dc:DisplayContext = this.displayContext;
            if (dc && dc.isContextLost === false)
            {
                var rc:Context3D  = dc.context3d;
                var res:Boolean   = false;
                try
                {
                    // @note: antialiasing is always disabled for RTT.
                    rc.setRenderToTexture(target, depthStencil, 0, cubeFace);
                    this.renderTarget = target;
                    res = true;
                }
                catch (e:Error)
                {
                    DebugTrace.out('DrawContext::changeRenderTarget(3): %s.', e.message);
                    dc.notifyContextLost();
                    res = false;
                }
                return res;
            }
            else return false;
        }

        /**
         * Restores the backbuffer as the current render target.
         * @return true if the change was performed successfully, or false if a lost context was detected.
         */
        public function restoreRenderTarget() : Boolean
        {
            if (this.renderTarget === null)
            {
                // the backbuffer is already the active render target.
                return true;
            }

            var dc:DisplayContext = this.displayContext;
            if (dc && dc.isContextLost === false)
            {
                var rc:Context3D  = dc.context3d;
                var res:Boolean   = false;
                try
                {
                    rc.setRenderToBackBuffer();
                    this.renderTarget = null;
                    res = true;
                }
                catch (e:Error)
                {
                    DebugTrace.out('DrawContext::restoreRenderTarget(0): %s.', e.message);
                    dc.notifyContextLost();
                    res = false;
                }
                return res;
            }
            else return false;
        }

        /**
         * Clears the current render target. Note that the backbuffer does not
         * need to be cleared manually; it is cleared by calling the function
         * DrawContext::beginFrame().
         * @param r The red channel clear value, in [0, 1].
         * @param g The green channel clear value, in [0, 1].
         * @param b The blue channel clear value, in [0, 1].
         * @param a The alpha channel clear value, in [0, 1].
         * @param depth The depth buffer clear value, in [0, 1].
         * @param stencil The stencil buffer clear value, in [0, 255].
         * @param mask A combination of Context3DClearMask indicating which
         * portions of the render target should be cleared. By default, all
         * buffer components (color, depth and stencil) are cleared. For best
         * performance, always clear the depth and stencil buffer together.
         * @return true if the clear was performed successfully, or false if a
         * lost context was detected.
         */
        public function clearRenderTarget(r:Number, g:Number, b:Number, a:Number, depth:Number, stencil:uint, mask:uint=0xFFFFFFFF) : Boolean
        {
            var dc:DisplayContext = this.displayContext;
            if (dc && dc.isContextLost === false)
            {
                var rc:Context3D  = dc.context3d;
                var res:Boolean   = false;
                try
                {
                    rc.clear(r, g, b, a, depth, stencil, mask);
                    res = true;
                }
                catch (e:Error)
                {
                    DebugTrace.out('DrawContext::clearRenderTarget(7): %s.', e.message);
                    dc.notifyContextLost();
                    res = false;
                }
                return res;
            }
            else return false;
        }

        /**
         * Submits a batch of triangle primitives for rendering.
         * @param buffer The index buffer defining the primitives. Three indices are read for each triangle.
         * @param offset The zero-based offset of the first index to read.
         * @param count The number of triangles in the batch.
         * @return true if the batch was submitted successfully, or false if a lost context was detected.
         */
        public function drawTriangles(buffer:IndexBuffer3D, offset:int=0, count:int=-1) : Boolean
        {
            var dc:DisplayContext = this.displayContext;
            if (dc && dc.isContextLost === false)
            {
                var rc:Context3D  = dc.context3d;
                var res:Boolean   = false;
                try
                {
                    rc.drawTriangles(buffer, offset, count);
                    res = true;
                }
                catch (e:Error)
                {
                    DebugTrace.out('DrawContext::drawTriangles(3): %s.', e.message);
                    dc.notifyContextLost();
                    res = false;
                }
                return res;
            }
            else return false;
        }

        /**
         * Changes the display context associated with this DrawContext and
         * sets the rendering context to its default state. The display context
         * must already have a backbuffer initialized.
         * @param dc The display context to attach to.
         * @param width The width of the framebuffer, in pixels.
         * @param height The height of the framebuffer, in pixels.
         */
        public function changeDisplayContext(dc:DisplayContext, width:int, height:int) : void
        {
            if (dc === null)
            {
                DebugTrace.out('DrawContext::changeDisplayContext(1) - Invalid display context.');
                return;
            }
            if (this.displayContext !== null)
            {
                DebugTrace.out('DrawContext::changeDisplayContext(1) - Detaching existing context.');
                this.detachDisplayContext();
            }
            dc.addEventListener(RenderEvents.CONTEXT_READY, this.handleContextReady);
            this.displayContext    = dc;
            this.framebufferWidth  = width;
            this.framebufferHeight = height;
            this.applyDefaultState();
        }

        /**
         * Detaches the DrawContext from its attached DisplayContext.
         * @return The detached display context.
         */
        public function detachDisplayContext() : DisplayContext
        {
            var dc:DisplayContext  = this.displayContext;
            if (dc)
            {
                dc.removeEventListener(RenderEvents.CONTEXT_READY, this.handleContextReady);
            }
            this.displayContext    = null;
            this.framebufferWidth  = 0;
            this.framebufferHeight = 0;
            this.blendState        = new BlendState();
            this.clearState        = new ClearState();
            this.rasterState       = new RasterState();
            this.depthStencilState = new DepthStencilState();
            this.program           = null;
            this.renderTarget      = null;
            this.vertexFormat      = null;
            this.samplers          = new Vector.<TextureBase>(DrawContext.MAX_TEXTURE_SAMPLERS, true);
            return dc;
        }
    }
}
