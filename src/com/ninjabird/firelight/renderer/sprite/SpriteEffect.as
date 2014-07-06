package com.ninjabird.firelight.renderer.sprite
{
    import flash.utils.Endian;
    import flash.utils.ByteArray;
    import flash.display3D.textures.TextureBase;
    import com.ninjabird.firelight.renderer.DrawContext
    import com.ninjabird.firelight.renderer.ShaderEffect;

    /**
     * Implements a simple effect that renders sprites with a single bitmap.
     */
    public final class SpriteEffect extends ShaderEffect
    {
        /**
         * The number of vertex shader registers used for uniform data.
         */
        public static const VERTEX_SHADER_REGISTERS:int = 5;

        /**
         * The assembly source code of the vertex shader.
         */
        public static const VERTEX_SHADER:String =
            "mov v0     , va1\n"    +  /* copy RGBA tint color to varying 0  */
            "mov v1.xy  , va0.zw\n" +  /* copy the 2d texcoord to varying 1  */
            "mov v1.zw  , vc4.zw\n" +  /* copy 0, 1 to varying 1             */
            "mov vt0.xy , va0.xy\n" +  /* copy position to temporary 0.xy    */
            "mov vt0.z  , va2.x\n"  +  /* copy depth to temporary 0.z        */
            "mov vt0.w  , vc4.x\n"  +  /* copy constant 1.0 to temporary 0.w */
            "m44 op     , vt0, vc0\n"; /* output clip-space position         */

        /**
         * The number of fragment shader registers used for uniform data.
         */
        public static const FRAGMENT_SHADER_REGISTERS:int = 0;

        /**
         * The assembly source code of the fragment shader.
         */
        public static const FRAGMENT_SHADER:String =
            "tex ft0 , v1 , fs0 <2d,linear,nomip>\n" + /* sample diffuse map */
            "mul oc  , v0 , ft0\n"; /* multiply sampled color w/tint color   */

        /**
         * The number of texture samplers exposed by the effect.
         */
        public static const SAMPLER_COUNT:int = 1;

        /**
         * Constructs a new instance of an effect used for rendering sprites
         * with a single texture image, which may be either a standalone image
         * or a texture atlas.
         */
        public function SpriteEffect()
        {
            this.samplerCount               = SpriteEffect.SAMPLER_COUNT;
            this.vertexUniformRegisters     = SpriteEffect.VERTEX_SHADER_REGISTERS;
            this.fragmentUniformRegisters   = SpriteEffect.FRAGMENT_SHADER_REGISTERS;
            this.vertexShaderSource         = SpriteEffect.VERTEX_SHADER;
            this.fragmentShaderSource       = SpriteEffect.FRAGMENT_SHADER;
            this.vertexUniformData.length   = SpriteEffect.VERTEX_SHADER_REGISTERS   * 16;
            this.fragmentUniformData.length = SpriteEffect.FRAGMENT_SHADER_REGISTERS * 16;
            this.vertexUniformData.endian   = Endian.LITTLE_ENDIAN;
            this.fragmentUniformData.endian = Endian.LITTLE_ENDIAN;
        }

        /**
         * Implements a render state application callback for use when rendering a SpriteBatch.
         * @param gl The rendering context used to apply state changes.
         * @param state The application-defined render state identifier.
         */
        public function applyRenderState(gl:DrawContext, state:uint) : void
        {
            var texture:TextureBase = this.resourcePool.texture(int(state));
            if (texture) gl.bindSampler(0, texture);
        }

        /**
         * Sets the viewport dimensions used for rendering.
         * @param width The viewport width, in pixels.
         * @param height The viewport height, in pixels.
         */
        public function applyViewport(width:int, height:int) : void
        {
            var sx:Number = 1.0 / (width  * 0.5);
            var sy:Number = 1.0 / (height * 0.5);

            var uniforms:ByteArray = this.vertexUniformData;
            uniforms.position      = 0;

            // write out the matrix used to transform vertices to clip space.
            // note that this matrix is written out transposed.
            uniforms.writeFloat( sx ); // r0c0
            uniforms.writeFloat( 0.0); // r1c0
            uniforms.writeFloat( 0.0); // r2c0
            uniforms.writeFloat(-1.0); // r3c0

            uniforms.writeFloat( 0.0); // r0c1
            uniforms.writeFloat(-sy ); // r1c1
            uniforms.writeFloat( 0.0); // r2c1
            uniforms.writeFloat( 1.0); // r3c1

            uniforms.writeFloat( 0.0); // r0c2
            uniforms.writeFloat( 0.0); // r1c2
            uniforms.writeFloat( 1.0); // r2c2
            uniforms.writeFloat( 0.0); // r3c2

            uniforms.writeFloat( 0.0); // r0c3
            uniforms.writeFloat( 0.0); // r1c3
            uniforms.writeFloat( 0.0); // r2c3
            uniforms.writeFloat( 1.0); // r3c3

            // write out a vector of numbers representing constant values.
            uniforms.writeFloat( 1.0);
            uniforms.writeFloat( 1.0);
            uniforms.writeFloat( 1.0);
            uniforms.writeFloat( 1.0);
        }
    }
}
