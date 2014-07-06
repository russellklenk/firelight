package com.ninjabird.firelight.content.loaders
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.system.LoaderContext;
    import flash.system.ImageDecodingPolicy;
    import flash.utils.ByteArray;
    import com.ninjabird.firelight.content.archive.TarFile;

    /**
     * Implements the FileLoader interface to load a PNG, JPEG or GIF image
     * file into a flash.display.Bitmap instance.
     */
    public final class BitmapFileLoader extends FileLoader
    {
        /**
         * The set of file extensions supported by this loader type.
         */
        public static var extensions:Array = ['jpg', 'png', 'gif', 'jpeg'];

        /**
         * Creates a new BitmapFileLoader instance. This function is registered with the FileLoader interface.
         * @return A new BitmapFileLoader instance.
         */
        public static function factory() : FileLoader
        {
            return new BitmapFileLoader();
        }

        /**
         * The flash.display.Loader instance used to transform the raw file
         * bytes into a flash.display.Bitmap instance.
         */
        private var loader:Loader;

        /**
         * The filename of the file being loaded (within the archive.)
         */
        private var filename:String;

        /**
         * Callback invoked when a completion event is raised by the Loader.
         * @param ev Additional information about the event.
         */
        private function handleComplete(ev:Event) : void
        {
            var bitmap:Bitmap = this.loader.content as Bitmap;
            if (bitmap !== null) this.notifySuccess(this.filename, bitmap);
            else this.notifyFailure(this.filename, 'Expected Bitmap, got '+this.loader.content);
        }

        /**
         * Callback invoked when an I/O error event is raised by the Loader.
         * @param ev Additional information about the event.
         */
        private function handleIOError(ev:IOErrorEvent) : void
        {
            this.notifyFailure(this.filename, ev.text);
        }

        /**
         * Default Constructor (empty).
         */
        public function BitmapFileLoader()
        {
            /* empty */
        }

        /**
         * Begins loading the data for a file contained within an archive.
         * @param archive The archive containing the file data.
         * @param filename The name of the file to load within the archive.
         */
        override public function loadFile(archive:TarFile, file:String) : void
        {
            var data:ByteArray = archive.loadFileBytes(file);
            if (data)
            {
                this.filename  = file;
                this.loader    = new Loader();
                this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.handleComplete);
                this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.handleIOError);
                var context:LoaderContext   = new LoaderContext();
                context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
                try
                {
                    this.loader.loadBytes(data, context);
                }
                catch (e:Error)
                {
                    this.notifyFailure(file, e.message);
                }
            }
            else this.notifyFailure(file, 'File not found in archive.');
        }

        /**
         * Disposes of resources associated with the loader instance.
         */
        override public function dispose() : void
        {
            if (this.loader)
            {
                this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.handleComplete);
                this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.handleIOError);
                this.loader.unload();
                this.loader = null;
            }
        }
    }
}
