package com.ninjabird.firelight.font
{
    /**
     * Describes a single glyph defined in a bitmap font. Currently, this is
     * pretty specific to the AngelCode BMFont.
     */
    public final class FontGlyph
    {
        /**
         * Bitmask indicating that the glyph is present in the blue channel.
         */
        public static const CHANNEL_BLUE:int  = (1 << 0);

        /**
         * Bitmask indicating that the glyph is present in the green channel.
         */
        public static const CHANNEL_GREEN:int = (1 << 1);

        /**
         * Bitmask indicating that the glyph is present in the red channel.
         */
        public static const CHANNEL_RED:int   = (1 << 2);

        /**
         * Bitmask indicating that the glyph is present in the alpha channel.
         */
        public static const CHANNEL_ALPHA:int = (1 << 3);

        /**
         * Bitmask indicating that the glyph is present in all color channels.
         */
        public static const CHANNEL_ALL:int   =
            FontGlyph.CHANNEL_BLUE  |
            FontGlyph.CHANNEL_GREEN |
            FontGlyph.CHANNEL_RED   |
            FontGlyph.CHANNEL_ALPHA;

        /**
         * The codepoint of the character associated with the glyph.
         */
        public var codepoint:uint;

        /**
         * The x-coordinate of the upper-left corner of the glyph on the
         * texture page.
         */
        public var x:int;

        /**
         * The y-coordinate of the upper-left corner of the glyph on the
         * texture page.
         */
        public var y:int;

        /**
         * The width of the glyph on the texture page, in pixels.
         */
        public var width:int;

        /**
         * The height of the glyph on the texture page, in pixels.
         */
        public var height:int;

        /**
         * The amount by which the current position should be offset on the
         * x-axis before drawing the glyph.
         */
        public var offsetX:int;

        /**
         * The amount by which the current position should be offset on the
         * y-axis before drawing the glyph.
         */
        public var offsetY:int;

        /**
         * The amount by which the current position should be advanced on the
         * x-axis after drawing the glyph.
         */
        public var advanceX:int;

        /**
         * The zero-based index of the page on which the glyph is located.
         */
        public var pageIndex:int;

        /**
         * A combination of one or more FontGlyph.CHANNEL_x values indicating
         * the color channels in which the glyph data is encoded.
         */
        public var channelFlags:int;

        /**
         * Default constructor. Initializes all fields to zero.
         */
        public function FontGlyph()
        {
            /* empty */
        }
    }
}
