package com.ninjabird.firelight.content.assemblers
{
    import flash.display.Bitmap;
    import com.ninjabird.firelight.font.FontDefinition;
    import com.ninjabird.firelight.content.Content;
    import com.ninjabird.firelight.content.PathHelper;

    /**
     * Implements a content assembler that exposes a loaded font as a
     * com.ninjabird.font.FontDefinition in the font property of the runtime
     * data, and the associated glyph bitmap pages as an array of flash.display.Bitmap
     * in the pages property of the runtime data of the content item.
     */
    public final class FontAssembler extends ContentAssembler
    {
        /**
         * Creates a new FontAssembler instance. This function is registered
         * with the ContentAssembler interface.
         * @return A new FontAssembler instance.
         */
        public static function factory() : ContentAssembler
        {
            return new FontAssembler();
        }

        /**
         * Default constructor (empty).
         */
        public function FontAssembler()
        {
            /* empty */
        }

        /**
         * Performs content assembly after all data files have been loaded
         * successfully. Data is exposed as properties of the runtimeData field of the content item.
         * @param content The content item to assemble.
         * @param fileCache An object mapping filename to runtime data. Do not modify the file cache table.
         */
        override public function assemble(content:Content, fileCache:Object) : void
        {
            var fontIndex:int         = content.fileWithExtension('fnt');
            var fontPath:String       = content.dataFiles[fontIndex];
            var font:FontDefinition   = fileCache[fontPath];
            var dirname:String        = PathHelper.dirname(fontPath);
            content.runtimeData.font  = font;
            content.runtimeData.pages = new Array(font.pageCount);
            for (var i:int = 0, n:int = font.pageCount; i < n; ++i)
            {
                var pagePath:String   = font.pageFiles[i];
                if (dirname.length > 0)
                {
                    // paths within the font definition are relative, so
                    // transform the page file path to have the same directory
                    // info as the main font definition file.
                    pagePath          = PathHelper.join(dirname, pagePath);
                    font.pageFiles[i] = pagePath;
                }
                var pageData:Bitmap   = fileCache[pagePath];
                content.runtimeData.pages[i] = pageData;
            }
            this.notifySuccess(content);
        }

        /**
         * Disposes of any resources associated with the content assembler.
         */
        override public function dispose() : void
        {
            /* empty */
        }
    }
}
