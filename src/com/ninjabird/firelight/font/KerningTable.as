package com.ninjabird.firelight.font
{
    /**
     * Represents a table of kerning information used to control spacing
     * between specific pairs of glyphs.
     */
    public final class KerningTable
    {
        /**
         * An object mapping the codepoint of character A to a Vector.<KerningEntry>.
         */
        public var codeTable:Array;

        /**
         * The number of entries in the kerning table.
         */
        public var length:int;

        /**
         * Constructs an empty kerning table.
         */
        public function KerningTable()
        {
            this.codeTable = new Array();
            this.length    = 0;
        }

        /**
         * Adds an entry to the kerning table for a glyph pair.
         * @param first The codepoint of the first glyph.
         * @param second The codepoint of the second glyph.
         * @param advanceX The amount to advance the cursor on the x-axis when
         * the glyph identified by codepoint @a second appears immediately
         * after the glyph identified by codepoint @a first.
         */
        public function add(first:uint, second:uint, advanceX:int) : void
        {
            var entry:KerningEntry = new KerningEntry(first, second, advanceX);
            var list:Vector.<KerningEntry> = this.codeTable[first];
            if (list === null)
            {
                list = new Vector.<KerningEntry>();
                this.codeTable[first] = list;
            }
            list[list.length] = entry;
            this.length++;
        }

        /**
         * Retrieves the x-advance amount for a given character combination.
         * @param first The codepoint of the first glyph.
         * @param second The codepoint of the second glyph.
         * @param advanceX The default x-axis advance value for glyph @a first,
         * which will be returned if there is no kerning information defined
         * for the specified pair of glyphs.
         * @return The amount by which to advance the cursor on the x-axis
         * after drawing the first glyph.
         */
        public function value(first:uint, second:uint, advanceX:int=0) : int
        {
            var list:Vector.<KerningEntry> = this.codeTable[first];
            if (list)
            {
                var count:int  = list.length;
                for (var i:int = 0; i < count; ++i)
                {
                    if (list[i].second === second)
                        return list[i].advanceX;
                }
                return advanceX;
            }
            else return advanceX;
        }
    }
}
