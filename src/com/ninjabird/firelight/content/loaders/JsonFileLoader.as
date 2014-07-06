package com.ninjabird.firelight.content.loaders
{
    import com.ninjabird.firelight.content.archive.TarFile;

    /**
     * Implements the FileLoader interface to load an object from a JSON file.
     */
    public final class JsonFileLoader extends FileLoader
    {
        /**
         * The set of file extensions supported by this loader type.
         */
        public static var extensions:Array = ['json'];

        /**
         * Creates a new JsonFileLoader instance. This function is registered with the FileLoader interface.
         * @return A new JsonFileLoader instance.
         */
        public static function factory() : FileLoader
        {
            return new JsonFileLoader();
        }

        /**
         * Default Constructor (empty).
         */
        public function JsonFileLoader()
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
            try
            {
                var obj:Object = archive.loadFileJSON(file, null);
                this.notifySuccess(file, obj);
            }
            catch (e:Error)
            {
                this.notifyFailure(file, e.message);
            }
        }
    }
}
