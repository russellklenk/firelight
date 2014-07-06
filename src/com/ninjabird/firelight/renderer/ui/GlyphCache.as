package com.ninjabird.firelight.renderer.ui
{
    import flash.display.Bitmap;
    import flash.geom.Rectangle;
    import com.ninjabird.firelight.debug.DebugTrace;
    import com.ninjabird.firelight.font.FontGlyph;
    import com.ninjabird.firelight.font.FontDefinition;
    import com.ninjabird.firelight.font.KerningTable;
    import com.ninjabird.firelight.renderer.atlas.AtlasEntry;
    import com.ninjabird.firelight.renderer.atlas.ImageCache;
    import com.ninjabird.firelight.renderer.sprite.SpriteBatch;
    import com.ninjabird.firelight.renderer.sprite.SpriteDefinition;
    import com.ninjabird.firelight.renderer.sprite.SpritePool;
    import com.ninjabird.firelight.renderer.ResourcePool;

    /**
     * Implements a text rendering system based on bitmap fonts. Font pages are
     * combined into texture pages using an internal ImageCache and a sprite pool
     * is used to generate sprites for the glyphs to be drawn.
     */
    public final class GlyphCache
    {
        /**
         * The default capacity of the font table, representing the maximum
         * number of glyphs that are expected to be on the screen at any given time.
         */
        public static const DEFAULT_CAPACITY:int = 1024;

        /**
         * The newline character.
         */
        public static const EOL:String           = '\n';

        /**
         * A table mapping font name to the corresponding FontDefinition.
         */
        public var fonts:Object;

        /**
         * The current offset within the sprite pool. Intended for internal use.
         */
        public var poolIndex:int;

        /**
         * The PageTable used to combine font pages into texture pages. This is
         * specified and owned by the application.
         */
        public var pageTable:ImageCache;

        /**
         * The pool of sprites used to represent glyphs to be rendered.
         */
        public var spritePool:SpritePool;

        /**
         * The resource pool in which all textures are created.
         */
        public var resourcePool:ResourcePool;

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
                if (match.pad === '0' || nosign)
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
                if (match.pad === '0' || nosign)
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
            if (fmt === null)
            {
                // return an empty string:
                return '';
            }
            if (fmt.length === 0 || fmt.indexOf('%') < 0)
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
                matches.push({
                        match:     match[0],
                        left:      match[3] ? true : false,
                        sign:      match[4] || '',
                        pad:       match[5] || ' ',
                        min:       match[6] || 0,
                        precision: match[8],
                        code:      match[9] || '%',
                        negative:  parseInt(varargs[convCount - 1]) < 0,
                        argument:    String(varargs[convCount - 1])
                    }
                );
            }
            strings.push(fmt.substring(matchPosEnd));

            if (matches.length === 0)
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

                if (code === '%')
                {
                    // %% - escaped percent sign.
                    subst = '%';
                }
                else if (code === 'b')
                {
                    // binary-formatted value.
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(2));
                    subst               = this.sprintfCvt(matches[i], true);
                }
                else if (code === 'c')
                {
                    // character code value.
                    matches[i].argument = String(String.fromCharCode(Math.abs(parseInt(matches[i].argument))));
                    subst               = this.sprintfCvt(matches[i], true);
                }
                else if (code === 'd')
                {
                    // signed decimal value.
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)));
                    subst               = this.sprintfCvt(matches[i], false);
                }
                else if (code === 'u')
                {
                    // unsigned decimal value.
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)));
                    subst               = this.sprintfCvt(matches[i], true);
                }
                else if (code === 'f')
                {
                    // floating-point value.
                    matches[i].argument = String(Math.abs(parseFloat(matches[i].argument)).toFixed(matches[i].precision ? matches[i].precision : 6));
                    subst               = this.sprintfCvt(matches[i], false);
                }
                else if (code === 'o')
                {
                    // octal value.
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(8));
                    subst               = this.sprintfCvt(matches[i], false);
                }
                else if (code === 's')
                {
                    // string value.
                    matches[i].argument = matches[i].argument.substring(0, matches[i].precision ? matches[i].precision : matches[i].argument.length);
                    subst               = this.sprintfCvt(matches[i], true);
                }
                else if (code === 'x')
                {
                    // hexadecimal value (lower-case digits).
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(16));
                    subst               = this.sprintfCvt(matches[i], false);
                }
                else if (code === 'X')
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
         * Constructs a new instance with no fonts defined.
         * @param cache The image cache to which the font pages will be uploaded. The application
         * remains responsible for management of the image cache.
         * @param initialCapacity The maximum expected number of glyphs displayed at any one time.
         */
        public function GlyphCache(cache:ImageCache, initialCapacity:int=0)
        {
            if (cache === null)
            {
                DebugTrace.out('GlyphCache::ctor(2) - Invalid ImageCache specified.');
                throw new ArgumentError('cache');
            }
            if (initialCapacity <= 0)
            {
                initialCapacity  = GlyphCache.DEFAULT_CAPACITY;
            }
            this.fonts           = new Object();
            this.spritePool      = new SpritePool(initialCapacity);
            this.pageTable       = cache;
            this.resourcePool    = null;
            this.poolIndex       = 0;
        }

        /**
         * Retrieves the FontDefinition for a given font.
         * @param name The name of the font face.
         * @return The corresponding FontDefinition, or null.
         */
        public function font(name:String) : FontDefinition
        {
            return this.fonts[name];
        }

        /**
         * Adds a font to the table, adding any font pages to the page table.
         * @param name The name used to reference the font.
         * @param font The font to add.
         * @param pages The array of flash.display.Bitmap objects representing the font page images.
         */
        public function addFont(name:String, font:FontDefinition, pages:Array) : void
        {
            if (name === null || name.length === 0)
            {
                name = font.name;
            }
            var table:ImageCache        = this.pageTable;
            var existing:FontDefinition = this.fonts[name];
            if (existing === null)
            {
                // upload the image data for each page into the page table.
                for (var i:int = 0, n:int = font.pageCount; i < n; ++i)
                {
                    var pageName:String   = font.pageFiles[i];
                    var pageData:Bitmap   = pages[i] as Bitmap;
                    if (table.entriesByName[pageName] === undefined)
                    {
                        table.addBitmap(pageName, pageData, false);
                    }
                }
                this.fonts[name] = font;
            }
        }

        /**
         * Explicitly flushes the current font texture page. This blocks the
         * calling thread until the texture upload has completed.
         */
        public function flushPage() : void
        {
            this.pageTable.flushPage();
        }

        /**
         * Indicates that no more font definitions or images will be uploaded to
         * the underlying image cache, and flushes any pending texture uploads.
         */
        public function finalize() : void
        {
            this.pageTable.finalize();
        }

        /**
         * Adds some text to be rendered in a previously registered font.
         * @param fontName The name of the font to use.
         * @param bounds The bounding rectangle of the text. The x and y fields
         * should be specified by the caller, and the function will update the
         * width and height accordingly.
         * @param text The string to add, which may contain newlines.
         * @param layer The layer depth at which the text should be rendered.
         * @param color The packed 32-bit ABGR tint color of the text.
         */
        public function addText(fontName:String, bounds:Rectangle, text:String, layer:int, color:uint=0xFFFFFFFF) : void
        {
            var font:FontDefinition = this.fonts[fontName];
            if (font)
            {
                var k:KerningTable   = font.kerningTable;
                var g:Array          = font.glyphTable;
                var pool:SpritePool  = this.spritePool;
                var table:ImageCache = this.pageTable;
                var maxWidth:Number  = 0;
                var maxHeight:Number = 0;
                var lastPage:int     =-1;
                var textureId:int    = 0;
                var entry:AtlasEntry = null;
                var currX:int        = bounds.x;
                var currY:int        = bounds.y;
                var len:int          = text.length;
                var eol:int          = GlyphCache.EOL.charCodeAt(0);

                for (var i:int = 0; i < len; ++i)
                {
                    var cn:int = 0;
                    var ch:int = text.charCodeAt(i);
                    var glyph:FontGlyph = g[ch] as FontGlyph;
                    if (glyph)
                    {
                        if (lastPage !== glyph.pageIndex)
                        {
                            lastPage   = glyph.pageIndex;
                            entry      = table.entriesByName[font.pageFiles[lastPage]] as AtlasEntry;
                            textureId  = table.pageList[entry.framePage[0]].textureHandle;
                        }

                        // populate the sprite attributes.
                        var s:SpriteDefinition = pool.next();
                        s.renderState  = uint(textureId);
                        s.screenX      = currX + glyph.offsetX;
                        s.screenY      = currY + glyph.offsetY;
                        s.originX      = 0;
                        s.originY      = 0;
                        s.layer        = layer;
                        s.scaleX       = 1.0;
                        s.scaleY       = 1.0;
                        s.orientation  = 0.0;
                        s.tintColor    = color;
                        s.imageX       = entry.frameX[0] + glyph.x;
                        s.imageY       = entry.frameY[0] + glyph.y;
                        s.imageWidth   = glyph.width;
                        s.imageHeight  = glyph.height;
                        s.textureWidth = table.textureWidth;
                        s.textureHeight= table.textureHeight;

                        // advance the cursor by the appropriate amount.
                        if  (i + 1 < len) cn = text.charCodeAt(i + 1);
                        currX += k.value(ch, cn, glyph.advanceX);
                    }
                    if (eol === ch)
                    {
                        if (currX > maxWidth)
                        {
                            maxWidth   = currX;
                        }
                        if (i + 1 < len)
                        {
                            maxHeight += font.lineHeight;
                        }
                        currY += font.lineHeight;
                        currX  = bounds.x;
                    }
                }

                // we may not have ever hit an EOL, so update width/height.
                if (currX > maxWidth)
                {
                    maxWidth  = currX;
                }
                maxHeight    += font.lineHeight;
                bounds.width  = maxWidth - bounds.x;
                bounds.height = maxHeight;
            }
        }

        /**
         * Adds some text to be rendered in a previously registered font. This
         * function can be used to render a substring of a given string, but
         * does not support embedded newline characters.
         * @param fontName The name of the font to use.
         * @param bounds The bounding rectangle of the text. The x and y fields
         * should be specified by the caller, and the function will update the
         * width and height accordingly.
         * @param text The string to add, which cannot contain newlines.
         * @param startIndex The zero-based index of the starting character.
         * @param count The number of characters in the range.
         * @param color The packed 32-bit ABGR tint color of the text.
         */
        public function addTextRange(fontName:String, bounds:Rectangle, text:String, startIndex:int, count:int, color:uint=0xFFFFFFFF) : void
        {
            var font:FontDefinition  = this.fonts[fontName];
            if (font)
            {
                var k:KerningTable   = font.kerningTable;
                var g:Array          = font.glyphTable;
                var pool:SpritePool  = this.spritePool;
                var table:ImageCache = this.pageTable;
                var maxWidth:Number  = 0;
                var maxHeight:Number = 0;
                var lastPage:int     =-1;
                var textureId:int    = 0;
                var entry:AtlasEntry = null;
                var currX:int        = bounds.x;
                var currY:int        = bounds.y;
                var len:int          = text.length;

                for (var i:int = startIndex; i < startIndex + count && i < len; ++i)
                {
                    var cn:int = 0;
                    var ch:int = text.charCodeAt(i);
                    var glyph:FontGlyph = g[ch] as FontGlyph;
                    if (glyph)
                    {
                        if (lastPage !== glyph.pageIndex)
                        {
                            lastPage   = glyph.pageIndex;
                            entry      = table.entriesByName[font.pageFiles[lastPage]] as AtlasEntry;
                            textureId  = table.pageList[entry.framePage[0]].textureHandle;
                        }

                        // populate the sprite attributes.
                        var s:SpriteDefinition = pool.next();
                        s.renderState  = uint(textureId);
                        s.screenX      = currX + glyph.offsetX;
                        s.screenY      = currY + glyph.offsetY;
                        s.originX      = 0;
                        s.originY      = 0;
                        s.scaleX       = 1.0;
                        s.scaleY       = 1.0;
                        s.orientation  = 0.0;
                        s.tintColor    = color;
                        s.imageX       = entry.frameX[0] + glyph.x;
                        s.imageY       = entry.frameY[0] + glyph.y;
                        s.imageWidth   = glyph.width;
                        s.imageHeight  = glyph.height;
                        s.textureWidth = table.textureWidth;
                        s.textureHeight= table.textureHeight;

                        // advance the cursor by the appropriate amount.
                        if  (i + 1 < len) cn = text.charCodeAt(i + 1);
                        currX += k.value(ch, cn, glyph.advanceX);
                    }
                }

                // we may not have ever hit an EOL, so update width/height.
                if (currX > maxWidth)
                {
                    maxWidth  = currX;
                }
                maxHeight    += font.lineHeight;
                bounds.width  = maxWidth - bounds.x;
                bounds.height = maxHeight;
            }
        }

        /**
         * Flushes buffered glyphs to a SpriteBatch for rendering.
         * @param batch The sprite batch used to render the glyphs.
         * @param flushPool true to flush the underlying sprite pool. Specify
         * true only if you intend on submitting the sprite batch for rendering
         * prior to adding any additional text.
         */
        public function flushText(batch:SpriteBatch, flushPool:Boolean=false) : void
        {
            var pool:SpritePool = this.spritePool;
            for (var i:int = this.poolIndex, n:int = pool.length; i < n; ++i)
            {
                batch.add(pool.sprites[i]);
                this.poolIndex++;
            }
            if (flushPool) this.clearText();
        }

        /**
         * Clears all cached glyphs.
         */
        public function clearText() : void
        {
            this.poolIndex = 0;
            this.spritePool.flush();
        }

        /**
         * Disposes of all resources associated with this instance and detaches
         * from the GPU resource pool.
         */
        public function dispose() : void
        {
            this.pageTable  = null;
            this.spritePool = null;
            this.fonts      = null;
        }
    }
}
