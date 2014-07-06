package com.ninjabird.firelight.font
{
    /**
     * Defines the data associated with a single entry in a kerning table,
     * which controls the spacing between two glyphs when one appears
     * immediately following another.
     */
    public final class KerningEntry
    {
        /**
         * The codepoint of the first glyph.
         */
        public var first:uint;

        /**
         * The codepoint of the second glyph.
         */
        public var second:uint;

        /**
         * The amount to advance the cursor on the x-axis after drawing the
         * first glyph, when the second glyph appears after the first.
         */
        public var advanceX:int;

        /**
         * Default constructor.
         * @param a The codepoint associated with the first glyph.
         * @param b The codepoint associated with the second glyph.
         * @param amount The amount to advance the cursor on the x-axis when
         * glyph @a b appears immediately following glyph @a a.
         */
        public function KerningEntry(a:uint=0, b:uint=0, amount:int=0)
        {
            this.first    = a;
            this.second   = b;
            this.advanceX = amount;
        }
    }
}
