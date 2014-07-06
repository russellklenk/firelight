package com.ninjabird.firelight.content.loaders
{
    import com.ninjabird.firelight.content.archive.TarFile;

    /**
     * Implements the FileLoader interface to load AGAL source code from a
     * file. The source code could be a complete shader, or a shader fragment.
     */
    public final class AGALFileLoader extends FileLoader
    {
        /**
         * The set of file extensions supported by this loader type.
         */
        public static var extensions:Array = ['agal', 'agsl'];

        /**
         * Creates a new AGALFileLoader instance. This function is registered with the FileLoader interface.
         * @return A new AGALFileLoader instance.
         */
        public static function factory() : FileLoader
        {
            return new AGALFileLoader();
        }

        /**
         * Default Constructor (empty).
         */
        public function AGALFileLoader()
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
            var source:String = archive.loadFileText(file);
            if (source) this.notifySuccess(file, source);
            else this.notifyFailure(file, 'Empty AGAL source fragment.');
        }
    }
}
