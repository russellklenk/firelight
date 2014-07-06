package com.ninjabird.firelight.renderer.sprite
{
    /**
     * Defines a sprite from the perspective of the application. The
     * application can represent a visible thing however it wants, and then
     * convert that to a SpriteDefinition for submission to the renderer.
     */
    public final class SpriteDefinition
    {
        /**
         * The layer depth of the sprite, with increasing (positive) values
         * being further away from the screen.
         */
        public var layer:int;

        /**
         * The insertion order of the sprite in its SpriteBatch. This is
         * automatically assigned by the SpriteBatch when the sprite is added,
         * and is used during sorting when matching sort keys are encountered.
         */
        public var order:int;

        /**
         * A 32-bit value the application can use to define the render state
         * associated with the sprite.
         */
        public var renderState:uint;

        /**
         * The horizontal axis component of the origin point of the sprite on
         * the screen.
         */
        public var screenX:int;

        /**
         * The vertical axis component of the origin point of the sprite on
         * the screen.
         */
        public var screenY:int;

        /**
         * The origin of rotation, relative to the upper-left corner of the
         * sprite, in pixels.
         */
        public var originX:Number;

        /**
         * The origin of rotation, relative to the upper-left corner of the
         * sprite, in pixels.
         */
        public var originY:Number;

        /**
         * The scaling factor to apply in the horizontal direction, with a
         * value of 1.0 representing no scale.
         */
        public var scaleX:Number;

        /**
         * Tbe scaling factor to apply in the vertical direction, with a
         * value of 1.0 representing no scale.
         */
        public var scaleY:Number;

        /**
         * The angle of orientation, in radians.
         */
        public var orientation:Number;

        /**
         * A packed 32-bit ABGR tint color.
         */
        public var tintColor:uint;

        /**
         * The horizontal offset of the upper-left corner of the sprite image
         * on the texture, in pixels.
         */
        public var imageX:int;

        /**
         * The vertical offset of the upper-left corner of the sprite image on
         * the texture, in pixels.
         */
        public var imageY:int;

        /**
         * The width of the sprite image, in pixels.
         */
        public var imageWidth:int;

        /**
         * The height of the sprite image, in pixels.
         */
        public var imageHeight:int;

        /**
         * The width of the whole texture image, in pixels.
         */
        public var textureWidth:int;

        /**
         * The height of the whole texture image, in pixels.
         */
        public var textureHeight:int;

        /**
         * Default constructor. Typically large numbers of SpriteDefinitions
         * may be allocated, so no extra initialization is performed here,
         * and all values have their default 0 or null value.
         */
        public function SpriteDefinition()
        {
            /* empty */
        }
    }
}
