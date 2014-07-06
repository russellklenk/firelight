package com.ninjabird.firelight.content.loaders
{
    import flash.utils.ByteArray;
    import flash.events.EventDispatcher;
    import com.ninjabird.firelight.debug.DebugTrace;
    import com.ninjabird.firelight.content.archive.TarFile;
    import com.ninjabird.firelight.content.events.FileLoadErrorEvent;
    import com.ninjabird.firelight.content.events.FileLoadCompleteEvent;

    /**
     * Defines the base class for an object that performs the conversion from
     * raw content data (like a ByteArray or a String) into some runtime type
     * such as BitmapData or MovieClip.
     */
    public class FileLoader extends EventDispatcher
    {
        /**
         * A table of registered FileLoader implementations. Keys are strings
         * specifying the file extension; values are function () : FileLoader.
         */
        public static var loaderFactories:Object = new Object();

        /**
         * Creates a new FileLoader instance that can load files with a given file extension.
         * @param ext The file extension, without leading period.
         * @return A FileLoader instance, or null.
         */
        public static function create(ext:String) : FileLoader
        {
            if (ext === null || ext.length === 0)
            {
                DebugTrace.out('FileLoader::create(1) - Invalid file extension.');
                return null;
            }

            var key:String       = ext.toUpperCase();
            var factory:Function = FileLoader.loaderFactories[key] as Function;
            if (factory!== null) return factory();
            else return null;
        }

        /**
         * Registers a FileLoader implementation to handle one or more file extensions.
         * @param extensions An array of strings specifying the file extensions
         * handled by the FileLoader implementation. Extensions should be
         * specified without the leading period.
         * @param factory A function () : FileLoader that is used to create
         * instances of the FileLoader implementation.
         */
        public static function register(extensions:Array, factory:Function) : void
        {
            if (extensions === null || extensions.length === 0)
            {
                DebugTrace.out('FileLoader::register(2) - No extensions specified.');
                throw new ArgumentError('extensions');
            }
            if (factory === null)
            {
                DebugTrace.out('FileLoader::register(2) - Invalid factory function.');
                throw new ArgumentError('factory');
            }
            for (var i:int = 0; i < extensions.length; ++i)
            {
                var key:String = extensions[i].toUpperCase();
                if (FileLoader.loaderFactories[key])
                {
                    DebugTrace.out('FileLoader::register(2) - Loader already registered for extension \'%s\'.', extensions[i]);
                    throw new ArgumentError('extensions');
                }
                else FileLoader.loaderFactories[key] = factory;
            }
        }

        /**
         * Raises an event indicating that the file loaded successfully.
         * @param filename The filename.
         * @param reason A brief description of the reason for the error.
         */
        protected final function notifySuccess(filename:String, data:*) : void
        {
            this.dispatchEvent(new FileLoadCompleteEvent(filename, data));
        }

        /**
         * Raises an event indicating that the file failed to load.
         * @param filename The filename.
         * @param reason A brief description of the reason for the error.
         */
        protected final function notifyFailure(filename:String, reason:String) : void
        {
            this.dispatchEvent(new FileLoadErrorEvent(filename, reason));
        }

        /**
         * Default Constructor (empty).
         */
        public function FileLoader()
        {
            /* empty */
        }

        /**
         * Begins loading the data for a file contained within an archive.
         * @param archive The archive containing the file data.
         * @param filename The name of the file to load within the archive.
         */
        public function loadFile(archive:TarFile, filename:String) : void
        {
            this.notifyFailure(filename, 'No implementation provided for FileLoader::loadFile(2).');
        }

        /**
         * Disposes of resources associated with the loader instance.
         */
        public function dispose() : void
        {
            /* empty */
        }
    }
}
