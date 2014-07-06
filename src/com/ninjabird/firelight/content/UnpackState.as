package com.ninjabird.firelight.content
{
    /**
     * An enumeration of state identifiers for unpacking a content archive, and
     * a small bit of state associated with the unpacking process.
     */
    public final class UnpackState
    {
        /**
         * The archive has been parsed, and the next content item in the
         * archive is being prepared for loading.
         */
        public static const LOAD_CONTENT_ITEM:int = 0;

        /**
         * The content data files are being transformed into runtime data.
         */
        public static const LOAD_CONTENT_DATA:int = 1;

        /**
         * All resources have been extracted and transformed successfully.
         */
        public static const COMPLETE:int          = 2;

        /**
         * An error occurred while unpacking resources from the archive.
         */
        public static const ERROR:int             = 3;

        /**
         * The current unpack state, set to one of the enumeration constants.
         */
        public var state:int;

        /**
         * The zero-based index of the content item being unpacked.
         */
        public var itemIndex:int;

        /**
         * The total number of content items in the package.
         */
        public var itemCount:int;

        /**
         * The number of files that loaded successfully for the current content
         * item.
         */
        public var successCount:int;

        /**
         * The number of files that failed to load for the current content item.
         */
        public var failureCount:int;

        /**
         * The total number of files associated with the current content item.
         */
        public var fileCount:int;

        /**
         * Default constructor.
         */
        public function UnpackState()
        {
            this.state        = UnpackState.LOAD_CONTENT_ITEM;
            this.itemIndex    = 0;
            this.itemCount    = 0;
            this.fileCount    = 0;
            this.successCount = 0;
            this.failureCount = 0;
        }

        /**
         * The total number of files that have finished loading for the current
         * content item.
         */
        public function get filesCompleted() : int
        {
            return this.successCount + this.failureCount;
        }

        /**
         * Indicates whether all files have finished loading for the current
         * content item.
         */
        public function get allFilesLoaded() : Boolean
        {
            return this.filesCompleted === this.fileCount;
        }

        /**
         * Indicates whether all files for the current content item have been
         * loaded successfully.
         */
        public function get allFilesSucceeded() : Boolean
        {
            return this.successCount === this.fileCount;
        }

        /**
         * Indicates whether loading encountered an error.
         */
        public function get error() : Boolean
        {
            return this.state === UnpackState.ERROR;
        }

        /**
         * Indicates whether loading has completed successfully.
         */
        public function get complete() : Boolean
        {
            return this.state === UnpackState.COMPLETE;
        }

        /**
         * Indicates whether to start loading the next content item.
         */
        public function get loadNextContentItem() : Boolean
        {
            return this.state === UnpackState.LOAD_CONTENT_ITEM;
        }

        /**
         * Indicates that a file finished loading successfully.
         * @param filename The filename that finished loading.
         */
        public function fileLoadCompleted(filename:String) : void
        {
            this.successCount++;
        }

        /**
         * Indicates that a file could not be loaded for some reason.
         * @param filename The filename that failed to load.
         */
        public function fileLoadFailed(filename:String) : void
        {
            this.failureCount++;
            this.state = UnpackState.ERROR;
        }

        /**
         * Determines whether all content items have been loaded.
         * @return true if all items have loaded.
         */
        public function get hasPackageCompleted() : Boolean
        {
            return this.itemIndex === this.itemCount;
        }

        /**
         * Indicates that the loading process for the current content item is
         * complete, and that state should be reset in preparation for the next
         * content item.
         * @return true if any content items remain, or false otherwise.
         */
        public function startNextContentItem() : Boolean
        {
            this.itemIndex++;
            if (this.itemIndex < this.itemCount)
            {
                this.state = UnpackState.LOAD_CONTENT_ITEM;
                return true;
            }
            else
            {
                this.state = UnpackState.COMPLETE;
                return false;
            }

        }

        /**
         * Resets the state in preparation for unpacking a content archive.
         * @param numItems The number of items in the content package.
         */
        public function resetPackageState(numItems:int) : void
        {
            this.state     = UnpackState.LOAD_CONTENT_ITEM;
            this.itemIndex = 0;
            this.itemCount = numItems;
            if (numItems === 0)
            {
                this.state = UnpackState.COMPLETE;
            }
        }

        /**
         * Resets the state in preparation for loading the next content item.
         * @param numFiles The number of data files referenced by the content.
         */
        public function resetContentState(numFiles:int) : void
        {
            this.state        = UnpackState.LOAD_CONTENT_DATA;
            this.fileCount    = numFiles;
            this.successCount = 0;
            this.failureCount = 0;
        }
    }
}
