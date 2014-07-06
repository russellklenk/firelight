package com.ninjabird.firelight.font
{
    import flash.geom.Rectangle;

    /**
     * Stores the data associated with a font, where the glyph data is encoded
     * in one or more bitmap images, and provides methods for measuring strings.
     */
    public final class FontDefinition
    {
        /**
         * The newline character.
         */
        public static const EOL:String            = '\n';

        /**
         * Indicates that the font is output antialiased.
         */
        public static const FLAG_SMOOTHING:int    = (1 << 0);

        /**
         * Indicates that the font contains unicode codepoints.
         */
        public static const FLAG_UNICODE:int      = (1 << 1);

        /**
         * Indicates that the font is italicised.
         */
        public static const FLAG_ITALIC:int       = (1 << 2);

        /**
         * Indicates that the font is boldface.
         */
        public static const FLAG_BOLD:int         = (1 << 3);

        /**
         * Indicates that the font glyphs have a fixed height.
         */
        public static const FLAG_FIXED_HEIGHT:int = (1 << 4);

        /**
         * Indicates that the channel contains glyph data.
         */
        public static const CONTENT_GLYPH:int     = 0;

        /**
         * Indicates that the channel contains glyph and outline data.
         */
        public static const CONTENT_OUTLINE:int   = 1;

        /**
         * Indicates that the channel contains both glyph and outline data.
         */
        public static const CONTENT_COMBINED:int  = 2;

        /**
         * Indicates that the channel contains all zeroes.
         */
        public static const CONTENT_ZERO:int      = 3;

        /**
         * Indicates that the channel contains all ones.
         */
        public static const CONTENT_ONE:int       = 4;

        /**
         * The name of the font face.
         */
        public var name:String;

        /**
         * The font size, specified in points.
         */
        public var baseSize:int;

        /**
         * Bitflags (FontDefinition.FLAG_x values) specifying font attributes.
         */
        public var flags:int;

        /**
         * The width of a glyph page image, in pixels.
         */
        public var pageWidth:int;

        /**
         * The height of a glyph page image, in pixels.
         */
        public var pageHeight:int;

        /**
         * The distance between each line of glyphs, in pixels.
         */
        public var lineHeight:int;

        /**
         * The number of pixels from the top of a line of text to the common
         * base of the glyphs.
         */
        public var baseline:int;

        /**
         * One of the FontDefinition.CONTENT_x values indicating the type of
         * data encoded by the red channel.
         */
        public var redContent:int;

        /**
         * One of the FontDefinition.CONTENT_x values indicating the type of
         * data encoded by the green channel.
         */
        public var greenContent:int;

        /**
         * One of the FontDefinition.CONTENT_x values indicating the type of
         * data encoded by the blue channel.
         */
        public var blueContent:int;

        /**
         * One of the FontDefinition.CONTENT_x values indicating the type of
         * data encoded by the alpha channel.
         */
        public var alphaContent:int;

        /**
         * The number of glyph pages defined in the font.
         */
        public var pageCount:int;

        /**
         * The set of filenames of the images containing the glyph data.
         */
        public var pageFiles:Vector.<String>;

        /**
         * A table mapping glyph codepoint to FontGlyph instance. This is a
         * sparse array, so we can't use a Vector.<FontGlyph>.
         */
        public var glyphTable:Array;

        /**
         * The number of glyphs defined in the font.
         */
        public var glyphCount:int;

        /**
         * The width of the smallest glyph in the font, in pixels.
         */
        public var minimumWidth:int;

        /**
         * The width of the largest glyph in the font, in pixels.
         */
        public var maximumWidth:int;

        /**
         * The average width of glyphs in the font, in pixels.
         */
        public var averageWidth:int;

        /**
         * For internal use only. Stores the summed width of all glyphs.
         */
        public var widthBucket:int;

        /**
         * The kerning table used to control glyph spacing.
         */
        public var kerningTable:KerningTable;

        /**
         * Internal helper function used by sprintf to handle formatting.
         * @param match The match object to process.
         * @param nosign A value indicating whether sign should be suppressed.
         * @return The formatted value.
         */
        private function sprintfCvt(match:*, nosign:Boolean) : String
        {
            if (nosign)
            {
                match.sign = '';
            }
            else
            {
                match.sign = match.negative ? '-' : match.sign;
            }

            var len:int    = match.min - match.argument.length + 1 - match.sign.length;
            var pad:String = new Array(len < 0 ? 0 : len).join(match.pad);
            var res:String = '';

            if (!match.left)
            {
                if (match.pad == '0' || nosign)
                {
                    res = match.sign + pad + match.argument;
                }
                else
                {
                    res = pad + match.sign + match.argument;
                }
            }
            else
            {
                if (match.pad == '0' || nosign)
                {
                    res = match.sign + match.argument + pad.replace(/0/g, ' ');
                }
                else
                {
                    res = match.sign + match.argument + pad;
                }
            }
            return res;
        }

        /**
         * Performs string formatting equivalent to the sprintf function from the CRT.
         * @param fmt The format string (required).
         * @param varargs Substitution arguments (variable-length).
         * @return The formatted string.
         */
        private function sprintfArray(fmt:String, varargs:Array) : String
        {
            if (null == fmt)
            {
                // return an empty string:
                return '';
            }
            if (0 == fmt.length || fmt.indexOf('%') < 0)
            {
                // early out - no formatting needed:
                return fmt;
            }

            var exp:RegExp              = /(%([%]|(\-)?(\+|\x20)?(0)?(\d+)?(\.(\d)?)?([bcdfosxX])))/g;
            var matches:Vector.<Object> = new Vector.<Object>();
            var strings:Vector.<Object> = new Vector.<Object>();
            var convCount:int           = 0;
            var strPosStart:int         = 0;
            var strPosEnd:int           = 0;
            var matchPosEnd:int         = 0;
            var formatted:String        = '';
            var code:String             = null;
            var subst:String            = '';
            var match:*                 = null;

            while ((match = exp.exec(fmt)) !== null)
            {
                if (match[9])
                {
                    convCount += 1;
                }
                strPosStart             = matchPosEnd;
                strPosEnd               = exp.lastIndex - match[0].length;
                strings[strings.length] = fmt.substring(strPosStart, strPosEnd);
                matchPosEnd             = exp.lastIndex;
                matches.push(
                {
                    match:     match[0],
                    left:      match[3] ? true : false,
                    sign:      match[4] || '',
                    pad:       match[5] || ' ',
                    min:       match[6] || 0,
                    precision: match[8],
                    code:      match[9] || '%',
                    negative:  parseInt(varargs[convCount - 1]) < 0 ? true : false,
                    argument:  String(varargs[convCount - 1])
                });
            }
            strings.push(fmt.substring(matchPosEnd));

            if (0 == matches.length)
            {
                // no formatting needed:
                return fmt;
            }
            if (convCount > varargs.length)
            {
                // argument count mismatch:
                return fmt;
            }

            for (var i:int = 0; i < matches.length; ++i)
            {
                code = matches[i].code;

                if ('%' == code)
                {
                    // %% - escaped percent sign.
                    subst = '%';
                }
                else if ('b' == code)
                {
                    // binary-formatted value.
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(2));
                    subst               = this.sprintfCvt(matches[i], true);
                }
                else if ('c' == code)
                {
                    // character code value.
                    matches[i].argument = String(String.fromCharCode(Math.abs(parseInt(matches[i].argument))));
                    subst               = this.sprintfCvt(matches[i], true);
                }
                else if ('d' == code)
                {
                    // signed decimal value.
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)));
                    subst               = this.sprintfCvt(matches[i], false);
                }
                else if ('u' == code)
                {
                    // unsigned decimal value.
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)));
                    subst               = this.sprintfCvt(matches[i], true);
                }
                else if ('f' == code)
                {
                    // floating-point value.
                    matches[i].argument = String(Math.abs(parseFloat(matches[i].argument)).toFixed(matches[i].precision ? matches[i].precision : 6));
                    subst               = this.sprintfCvt(matches[i], false);
                }
                else if ('o' == code)
                {
                    // octal value.
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(8));
                    subst               = this.sprintfCvt(matches[i], false);
                }
                else if ('s' == code)
                {
                    // string value.
                    matches[i].argument = matches[i].argument.substring(0, matches[i].precision ? matches[i].precision : matches[i].argument.length);
                    subst               = this.sprintfCvt(matches[i], true);
                }
                else if ('x' == code)
                {
                    // hexadecimal value (lower-case digits).
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(16));
                    subst               = this.sprintfCvt(matches[i], false);
                }
                else if ('X' == code)
                {
                    // hexadecimal value (upper-case digits).
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(16));
                    subst               = this.sprintfCvt(matches[i], false).toUpperCase();
                }
                else
                {
                    // unknown format specifier - do nothing.
                    subst = matches[i].match;
                }

                formatted += strings[i];
                formatted += subst;
            }
            formatted += strings[i];
            return formatted;
        }

        /**
         * Constructs an empty font definition.
         */
        public function FontDefinition()
        {
            this.name         = null;
            this.baseSize     = 0;
            this.flags        = 0;
            this.pageWidth    = 1;
            this.pageHeight   = 1;
            this.lineHeight   = 0;
            this.baseline     = 0;
            this.redContent   = FontDefinition.CONTENT_GLYPH;
            this.greenContent = FontDefinition.CONTENT_GLYPH;
            this.blueContent  = FontDefinition.CONTENT_GLYPH;
            this.alphaContent = FontDefinition.CONTENT_GLYPH;
            this.pageCount    = 0;
            this.pageFiles    = new Vector.<String>();
            this.glyphTable   = new Array();
            this.glyphCount   = 0;
            this.widthBucket  = 0;
            this.minimumWidth = int.MAX_VALUE;
            this.maximumWidth = 0;
            this.averageWidth = 0;
            this.kerningTable = new KerningTable();
        }

        /**
         * Registers a glyph defined in the font.
         * @param glyph The glyph.
         */
        public function addGlyph(glyph:FontGlyph) : void
        {
            // update the codepoint => glyph table.
            this.glyphTable[glyph.codepoint] = glyph;
            this.glyphCount++;

            // update min/max/average width:
            this.widthBucket += glyph.width;
            this.averageWidth = this.widthBucket / this.glyphCount;
            if (glyph.width < this.minimumWidth)
                this.minimumWidth = glyph.width;
            if (glyph.width > this.maximumWidth)
                this.maximumWidth = glyph.width;
        }

        /**
         * Preallocates storage for the page filenames. This should be
         * performed prior to assigning page filenames.
         * @param count The number of texture pages defined in the font.
         */
        public function setPageCount(count:int) : void
        {
            this.pageCount        = count;
            this.pageFiles.length = count;
        }

        /**
         * Sets the filename associated with a font page.
         * @param id The index used as the page identifier.
         * @param filename The relative path and filename of the page image.
         */
        public function addPage(id:int, filename:String) : void
        {
            this.pageFiles[id] = filename;
        }

        /**
         * Calculates the dimensions of a text string.
         * @param bound The bounding rectangle to update.
         * @param text The string to measure.
         * @param scaleX The scale factor to apply along the horizontal axis.
         * @param scaleY The scale factor to apply along the vertical axis.
         */
        public function measure(bound:Rectangle, text:String, scaleX:Number=1.0, scaleY:Number=1.0) : void
        {
            if (text === null || text.length === 0)
            {
                bound.width  = 0;
                bound.height = 0;
                return;
            }

            var eol:int               = FontDefinition.EOL.charCodeAt(0);
            var kernings:KerningTable = this.kerningTable;
            var glyphs:Array          = this.glyphTable;
            var len:int               = text.length;
            var lineWidth:int         = 0;
            var width:int             = 0;
            var height:int            = 0;

            // initialize the output rectangle.
            bound.width    = 0;
            bound.height   = 0;

            // measure the string.
            for (var i:int = 0; i < len; ++i)
            {
                var cn:int          = 0;
                var ch:int          = text.charCodeAt(i);
                var glyph:FontGlyph = glyphs[ch] as FontGlyph;
                if (glyph)
                {
                    if  (i + 1 < len)  cn = text.charCodeAt(i + 1);
                    lineWidth += kernings.value(ch, cn, glyph.advanceX);
                }
                if (eol === ch)
                {
                    if (lineWidth > width)
                    {
                        // update the maximum line width:
                        width   = lineWidth;
                    }
                    if (i + 1 < len)
                    {
                        height += this.lineHeight;
                    }
                    lineWidth = 0;
                }
            }

            // we may not have ever hit the EOL, so update the width/height.
            if (lineWidth > width)
            {
                width = lineWidth;
            }
            height += this.lineHeight;

            // now update the bounding rectangle:
            bound.width  = Math.round(width  * scaleX) | 0;
            bound.height = Math.round(height * scaleY) | 0;
        }

        /**
         * Calculates the dimensions of a string using printf-style substitution.
         * @param bound The bounding rectangle to update.
         * @param str The format string.
         * @param ...varargs The variable-length argument substitution list.
         */
        public function measuref(bound:Rectangle, str:String, ...varargs) : void
        {
            var text:String = this.sprintfArray(str, varargs);
            this.measure(bound, text);
        }

        /**
         * Calculates the dimensions of a subset of characters within a string.
         * Note that multi-line text is not supported.
         * @param bound The bounding rectangle to update.
         * @param text The string to measure.
         * @param startIndex The zero-based index of the starting character.
         * @param count The number of characters in the range.
         * @param scaleX The scale factor to apply on the horizontal axis.
         * @param scaleY The scale factor to apply on the vertical axis.
         */
        public function measureRange(bound:Rectangle, text:String, startIndex:int, count:int, scaleX:Number=1.0, scaleY:Number=1.0) : void
        {
            if (text === null || text.length === 0)
            {
                bound.width  = 0;
                bound.height = 0;
                return;
            }

            var kernings:KerningTable = this.kerningTable;
            var glyphs:Array          = this.glyphTable;
            var len:int               = text.length;
            var lineWidth:int         = 0;
            var width:int             = 0;
            var height:int            = 0;

            // initialize the output rectangle.
            bound.width    = 0;
            bound.height   = 0;

            // measure the substring.
            for (var i:int = startIndex; i < startIndex + count && i < len; ++i)
            {
                var cn:int          = 0;
                var ch:int          = text.charCodeAt(i);
                var glyph:FontGlyph = glyphs[ch] as FontGlyph;
                if (glyph)
                {
                    if  (i + 1 < len)  cn = text.charCodeAt(i + 1);
                    lineWidth += kernings.value(ch, cn, glyph.advanceX);
                }
            }

            // we may not have ever hit the EOL, so update the width/height.
            if (lineWidth > width)
            {
                width = lineWidth;
            }
            height += this.lineHeight;

            // now update the bounding rectangle:
            bound.width  = Math.round(width  * scaleX) | 0;
            bound.height = Math.round(height * scaleY) | 0;
        }
    }
}
