package com.ninjabird.firelight.content.assemblers
{
    import flash.display.Bitmap;
    import com.ninjabird.firelight.content.Content;

    /**
     * Implements a content assembler that exposes a loaded image as a
     * flash.display.Bitmap object in the bitmap property of the runtime data
     * of the content item.
     */
    public final class BitmapAssembler extends ContentAssembler
    {
        /**
         * Creates a new BitmapAssembler instance. This function is registered
         * with the ContentAssembler interface.
         * @return A new BitmapAssembler instance.
         */
        public static function factory() : ContentAssembler
        {
            return new BitmapAssembler();
        }

        /**
         * Default constructor (empty).
         */
        public function BitmapAssembler()
        {
            /* empty */
        }

        /**
         * Performs content assembly after all data files have been loaded
         * successfully. Data is exposed as properties of the runtimeData field
         * of the content item.
         * @param content The content item to assemble.
         * @param fileCache An object mapping filename to runtime data. Do not
         * modify the file cache table.
         */
        override public function assemble(content:Content, fileCache:Object) : void
        {
            var bitmap:Bitmap = fileCache[content.dataFiles[0]];
            if (bitmap)
            {
                content.runtimeData.bitmap  = bitmap;
                content.attributes.width    = int(bitmap.width);
                content.attributes.height   = int(bitmap.height);
                this.notifySuccess(content);
            }
            else this.notifyFailure(content, 'BitmapAssembler::assemble(2) - No Bitmap in file cache.');
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
