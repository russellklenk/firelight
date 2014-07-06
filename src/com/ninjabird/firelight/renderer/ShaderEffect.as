package com.ninjabird.firelight.renderer
{
    import com.ninjabird.firelight.renderer.events.RenderEvents;

    import flash.utils.Endian;
    import flash.utils.ByteArray;
    import flash.display3D.Program3D;
    import flash.display3D.Context3DProgramType;
    import com.adobe.utils.AGALMacroAssembler;
    import com.ninjabird.firelight.debug.DebugTrace;
    import com.ninjabird.firelight.renderer.events.ContextLostEvent;
    import com.ninjabird.firelight.renderer.events.ContextReadyEvent;
    import com.ninjabird.firelight.renderer.events.RenderEvents;

    /**
     * Defines the base class for a GPU shader-based effect.
     */
    public class ShaderEffect
    {
        /**
         * The source code for the vertex shader of the effect.
         */
        public var vertexShaderSource:String;

        /**
         * The source code for the fragment shader of the effect.
         */
        public var fragmentShaderSource:String;

        /**
         * The number of registers used in the vertex shader stage.
         */
        public var vertexUniformRegisters:int;

        /**
         * The number of registers used in the fragment shader stage.
         */
        public var fragmentUniformRegisters:int;

        /**
         * The number of samplers exposed by the effect.
         */
        public var samplerCount:int;

        /**
         * A buffer for storing uniform data to be uploaded to the vertex
         * shader. The effect controls when and how often this is updated.
         */
        public var vertexUniformData:ByteArray;

        /**
         * A buffer for storing uniform data to be uploaded to the fragment
         * shader. The effect controls when and how often this is updated.
         */
        public var fragmentUniformData:ByteArray;

        /**
         * The shader program used for rendering.
         */
        public var shaderProgram:ProgramDesc;

        /**
         * The resource pool in which the shader program and any other required
         * GPU resources are created.
         */
        public var resourcePool:ResourcePool;

        /**
         * Callback invoked when the rendering context is lost.
         * @param ev Additional information about the event.
         */
        protected function handleContextLost(ev:ContextLostEvent) : void
        {
            /* empty */
        }

        /**
         * Callback invoked when the rendering context becomes ready, either
         * after initial creation or after recovery from a lost context.
         * @param ev Additional information about the event.
         */
        protected function handleContextReady(ev:ContextReadyEvent) : void
        {
            if (this.resourcePool)
            {
                // the resource pool recreates all of the resource objects
                // for us, so we just need to upload data into them.
                this.prepareGpuResources();
            }
        }

        /**
         * Default constructor. Allocates empty storage for vertex and fragment
         * shader uniforms.
         */
        public function ShaderEffect()
        {
            this.samplerCount               = 0;
            this.vertexUniformRegisters     = 0;
            this.fragmentUniformRegisters   = 0;
            this.vertexShaderSource         = '';
            this.fragmentShaderSource       = '';
            this.vertexUniformData          = new ByteArray();
            this.fragmentUniformData        = new ByteArray();
            this.shaderProgram              = null;
            this.resourcePool               = null;
            this.vertexUniformData.endian   = Endian.LITTLE_ENDIAN;
            this.fragmentUniformData.endian = Endian.LITTLE_ENDIAN;
        }

        /**
         * Specifies the resource pool in which the effect allocates all of
         * its GPU resources, and creates any GPU resources required by the
         * implementation.
         * @param pool The ResourcePool used for managing GPU resources.
         * @return true if GPU resources are created successfully.
         */
        public function createGpuResources(pool:ResourcePool) : Boolean
        {
            var dc:DisplayContext = pool.displayContext;
            if (dc)
            {
                var program:ProgramDesc = pool.createProgram();
                if (program)
                {
                    this.shaderProgram  = program;
                    this.resourcePool   = pool;
                }
                else return false;

                dc.addEventListener(RenderEvents.CONTEXT_LOST,  this.handleContextLost);
                dc.addEventListener(RenderEvents.CONTEXT_READY, this.handleContextReady);
                return this.prepareGpuResources();
            }
            else
            {
                DebugTrace.out('ShaderEffect::createGpuResources(1) - Invalid display context.');
                return false;
            }
        }

        /**
         * Prepares GPU resources for use when the rendering context becomes
         * ready. This is where vertex and fragment shaders are assembled and
         * linked into a program object.
         * @return true if GPU resources are ready for use.
         */
        public function prepareGpuResources() : Boolean
        {
            var pool:ResourcePool     = this.resourcePool;
            var program:Program3D     = pool.programFor(this.shaderProgram);
            var vs:AGALMacroAssembler = new AGALMacroAssembler();
            var fs:AGALMacroAssembler = new AGALMacroAssembler();

            vs.assemble(Context3DProgramType.VERTEX,   this.vertexShaderSource);
            fs.assemble(Context3DProgramType.FRAGMENT, this.fragmentShaderSource);
            program.upload(vs.agalcode, fs.agalcode);
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
                if (this.shaderProgram)
                {
                    pool.disposeProgram(this.shaderProgram);
                    this.shaderProgram = null;
                }
                this.shaderProgram   = null;
                this.resourcePool    = null;
                return pool;
            }
            else return null;
        }

        /**
         * Activates the effect in the draw context, uploading the current
         * uniform data and setting texture samplers.
         * @param dc The draw context to bind to.
         */
        public function makeCurrent(dc:DrawContext) : void
        {
            var pool:ResourcePool = this.resourcePool;
            var program:Program3D = pool.programFor(this.shaderProgram);
            if (program)
            {
                dc.changeProgram(program);
                if (this.vertexUniformRegisters > 0)
                {
                    dc.uniformData(
                            Context3DProgramType.VERTEX,
                            0, this.vertexUniformRegisters,
                            this.vertexUniformData, 0);
                }
                if (this.fragmentUniformRegisters > 0)
                {
                    dc.uniformData(
                            Context3DProgramType.FRAGMENT,
                            0, this.fragmentUniformRegisters,
                            this.fragmentUniformData, 0);
                }
            }
        }
    }
}
