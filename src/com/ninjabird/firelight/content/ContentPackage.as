package com.ninjabird.firelight.content
{
    import com.ninjabird.firelight.content.events.ContentEvent;
    import com.ninjabird.firelight.content.events.ContentEvent;
    import com.ninjabird.firelight.content.events.ContentEvent;
    import com.ninjabird.firelight.content.events.ContentEvent;
    import com.ninjabird.firelight.content.events.ContentEvent;

    import flash.utils.ByteArray;
    import flash.events.EventDispatcher;
    import com.ninjabird.firelight.debug.DebugTrace;
    import com.ninjabird.firelight.content.archive.TarFile;
    import com.ninjabird.firelight.content.loaders.FileLoader;
    import com.ninjabird.firelight.content.assemblers.ContentAssembler;
    import com.ninjabird.firelight.content.events.FileLoadErrorEvent;
    import com.ninjabird.firelight.content.events.FileLoadCompleteEvent;
    import com.ninjabird.firelight.content.events.ContentPackageErrorEvent;
    import com.ninjabird.firelight.content.events.ContentPackageLoadedEvent;
    import com.ninjabird.firelight.content.events.ContentAssemblyErrorEvent;
    import com.ninjabird.firelight.content.events.ContentAssemblyCompleteEvent;

    /**
     * State data associated with a single logical content package. All items
     * in a content package are contained within the same physical archive.
     */
    public final class ContentPackage extends EventDispatcher
    {
        /**
         * One of the values of the UnpackState enumeration, indicating the
         * current unpack state of the content package.
         */
        public var unpackState:UnpackState;

        /**
         * The ContentSet into which the content items will be loaded.
         */
        public var contentSet:ContentSet;

        /**
         * The object used to access data within the archive file.
         */
        public var archive:TarFile;

        /**
         * The user-friendly display name of the package.
         */
        public var friendlyName:String;

        /**
         * The filename of the archive file. This is generated from the file
         * contents and is generally not suitable for display.
         */
        public var filename:String;

        /**
         * The archive manifest describing the content contained within the
         * archive file. The manifest is available after the archive has been
         * loaded successfully by calling ContentPackage.loadArchive().
         */
        public var manifest:Object;

        /**
         * A table mapping filename to the runtime data generated from the
         * file. This acts as a cache to prevent the same file from being
         * processed multiple times.
         */
        public var fileCache:Object;

        /**
         * Extracts the file extension for a given path string. The extension
         * is anything after the last period character.
         * @param path The path string.
         * @return The extension, without leading period, or an empty string.
         */
        private function fileExtension(path:String) : String
        {
            var periodIndex:int = path.lastIndexOf('.');
            if (periodIndex >= 0) return path.substr(periodIndex + 1);
            else return '';
        }

        /**
         * Begins loading a data file for a content item. This function never
         * accesses the file cache.
         * @param path The path of the file to load within the archive.
         * @return true if loading was started, or false if an error occurred.
         */
        private function beginLoadFile(path:String) : Boolean
        {
            var ext:String        = this.fileExtension(path);
            var loader:FileLoader = FileLoader.create(ext);
            if (loader)
            {
                loader.addEventListener(ContentEvent.FILE_ERROR,  this.handleFileLoadError);
                loader.addEventListener(ContentEvent.FILE_LOADED, this.handleFileLoadComplete);
                loader.loadFile(this.archive, path);
                return true;
            }
            else return this.notifyError('No file loader found for \''+path+'\'.');
        }

        /**
         * Begins assembling a content item once all of its runtime data is
         * loaded and available.
         * @param content The content item to assemble.
         * @return true if assembly was started, or false if an error occurred.
         */
        private function beginAssembleContent(content:Content) : Boolean
        {
            var type:String = content.type;
            var assembler:ContentAssembler = ContentAssembler.create(type);
            if (assembler)
            {
                assembler.addEventListener(ContentEvent.ASSEMBLY_ERROR,    this.handleContentAssemblyError);
                assembler.addEventListener(ContentEvent.ASSEMBLY_COMPLETE, this.handleContentAssemblyComplete);
                assembler.assemble(content, this.fileCache);
                return true;
            }
            else return this.notifyError('No assembler found for \''+content.name+'\' ('+type+').');
        }

        /**
         * Notifies any listeners that an error has occurred while loading the
         * content package.
         * @param reason A description of the error.
         * @return This function always returns false.
         */
        private function notifyError(reason:String) : Boolean
        {
            this.dispatchEvent(new ContentPackageErrorEvent(reason));
            this.unpackState.state = UnpackState.ERROR;
            return false;
        }

        /**
         * Notifies any listeners that the content package has been loaded
         * successfully and that content items are ready for runtime use.
         */
        private function notifyLoaded() : void
        {
            this.dispatchEvent(new ContentPackageLoadedEvent());
            this.unpackState.state = UnpackState.COMPLETE;
        }

        /**
         * Callback invoked when an error occurs while loading a data file from
         * the archive or transforming the raw data into runtime-ready data.
         * @param ev Additional information about the event.
         */
        private function handleFileLoadError(ev:FileLoadErrorEvent) : void
        {
            var reason:String = ev.filename + ': ' + ev.errorMessage;
            this.unpackState.fileLoadFailed(ev.filename);
            this.cleanupLoader(ev.target as FileLoader);
            this.notifyError(reason);
        }

        /**
         * Callback invoked when the data for a file has been loaded, parsed
         * transformed into runtime-ready data, such as a BitmapData instance.
         * @param ev Additional information about the event.
         */
        private function handleFileLoadComplete(ev:FileLoadCompleteEvent) : void
        {
            this.updateFileCache(ev.filename, ev.resourceData);
            this.unpackState.fileLoadCompleted(ev.filename);
            this.cleanupLoader(ev.target as FileLoader);

            // check if the content item is complete, if so, begin assembly.
            if (this.unpackState.allFilesSucceeded)
            {
                var itemIndex:int     = this.unpackState.itemIndex;
                var resources:Array   = this.manifest.resources;
                var metadata:Object   = resources[itemIndex];
                var content:Content   = new Content();
                content.sourcePackage = this.friendlyName;
                content.name          = metadata.name;
                content.type          = metadata.type;
                content.tags          = Vector.<String>(metadata.tags);
                content.dataFiles     = Vector.<String>(metadata.data);
                content.attributes    = new Object();
                content.runtimeData   = new Object();
                this.beginAssembleContent(content);
            }
        }

        /**
         * Callback invoked when an error occurs while assembling a content
         * item from its component data.
         * @param ev Additional information about the event.
         */
        private function handleContentAssemblyError(ev:ContentAssemblyErrorEvent) : void
        {
            var reason:String = ev.content.name + ' (' + ev.content.type + '): ' + ev.errorMessage;
            this.cleanupAssembler(ev.target as ContentAssembler);
            this.notifyError(reason);
        }

        /**
         * Callback invoked when a content item has been fully assembled from
         * its component parts and is ready for use.
         * @param ev Additional information about the event.
         */
        private function handleContentAssemblyComplete(ev:ContentAssemblyCompleteEvent) : void
        {
            this.cleanupAssembler(ev.target as ContentAssembler);
            this.contentSet.replaceContentItem(ev.content);

            if (this.unpackState.startNextContentItem() === false)
            {
                // no content items remain; this package is loaded.
                // unload the archive data; we don't need it anymore.
                this.notifyLoaded();
                this.archive.dispose();
                this.archive = null;
            }
        }

        /**
         * Detaches event listeners and disposes of a FileLoader.
         * @param loader The loader.
         */
        private function cleanupLoader(loader:FileLoader) : void
        {
            if (loader)
            {
                loader.removeEventListener(ContentEvent.FILE_ERROR,  this.handleFileLoadError);
                loader.removeEventListener(ContentEvent.FILE_LOADED, this.handleFileLoadComplete);
                loader.dispose();
            }
        }

        /**
         * Detaches event listeners and disposes of a ContentAssembler.
         * @param assembler The assembler.
         */
        private function cleanupAssembler(assembler:ContentAssembler) : void
        {
            if (assembler)
            {
                assembler.removeEventListener(ContentEvent.ASSEMBLY_ERROR,    this.handleContentAssemblyError);
                assembler.removeEventListener(ContentEvent.ASSEMBLY_COMPLETE, this.handleContentAssemblyComplete);
                assembler.dispose();
            }
        }

        /**
         * Default constructor. Initializes all fields to null or zero.
         * @param name The friendly name of the content package.
         * @param file The path and filename of the content package on the
         * content server.
         */
        public function ContentPackage(name:String, file:String)
        {
            this.unpackState  = new UnpackState();
            this.contentSet   = null;
            this.fileCache    = null;
            this.archive      = null;
            this.friendlyName = name;
            this.filename     = file;
            this.manifest     = null;
        }

        /**
         * Indicates whether all content in the package has been successfully
         * loaded and is ready for use.
         */
        public function get isLoaded() : Boolean
        {
            return this.unpackState.complete;
        }

        /**
         * Resets the file cache to an empty state.
         */
        public function clearFileCache() : void
        {
            this.fileCache = new Object();
        }

        /**
         * Updates an entry in the file cache.
         * @param filename The filename representing the key of the entry.
         * @param data The data value to be associated with the filename.
         */
        public function updateFileCache(filename:String, data:*) : void
        {
            this.fileCache[filename] = data;
        }

        /**
         * Starts loading the content package given the raw data that makes up the archive file.
         * @param data The raw data representing the archive file contents. The
         * content package takes ownership of this data. The data is not copied.
         * @return true if the archive data was parsed successfully.
         */
        public function loadArchive(data:ByteArray) : Boolean
        {
            var archive:TarFile = new TarFile();
            if (archive.load(data))
            {
                this.archive        = archive;
                this.manifest       = archive.loadFileJSON('package.manifest');
                var resources:Array = this.manifest.resources as Array;
                this.unpackState    = new UnpackState();
                this.unpackState.resetPackageState(resources.length);
                this.clearFileCache();

                if (resources.length === 0)
                {
                    // this is an empty archive, so we're done.
                    this.notifyLoaded();
                    this.archive.dispose();
                    this.archive = null;
                }
                return true;
            }
            else return this.notifyError('The archive data could not be parsed.');
        }

        /**
         * Executes a single step in the content unpacking process.
         * @return true if the process is in a wait state and the update tick
         * should be considered complete, or false if the content loader update
         * tick should continue.
         */
        public function unpack() : Boolean
        {
            if (this.unpackState.loadNextContentItem)
            {
                // queue all of the files for loading from the archive. file
                // loading could be either synchronous or asynchronous.
                var itemIndex:int   = this.unpackState.itemIndex;
                var resources:Array = this.manifest.resources as Array;
                var metadata:Object = resources[itemIndex];
                var dataFiles:Array = metadata.data as Array;
                this.unpackState.resetContentState(dataFiles.length);
                for (var i:int = 0; i < dataFiles.length; ++i)
                {
                    var filename:String = dataFiles[i] as String;
                    var cacheData:*     = this.fileCache[filename];
                    if (cacheData) this.unpackState.fileLoadCompleted(filename);
                    else this.beginLoadFile(filename);
                }
                return false;
            }
            else return true;
        }

        /**
         * Disposes the archive, manifest and file cache associated with the
         * content package, and resets the unpack state.
         * @param archiveOnly true to unload the archive data only.
         */
        public function unload(archiveOnly:Boolean=true) : void
        {
            if (this.archive !== null)
            {
                this.archive.dispose();
                this.archive = null;
            }
            if (archiveOnly  === false)
            {
                this.fileCache = null;
                this.manifest  = null;
            }
            this.unpackState = new UnpackState();
        }

        /**
         * Disposes of resources associated with the content package. Note that
         * this does not dispose of the content items loaded from the package,
         * as those are owned by the ContentSet.
         */
        public function dispose() : void
        {
            if (this.archive !== null)
            {
                this.archive.dispose();
                this.archive = null;
            }
            this.fileCache   = null;
            this.manifest    = null;
            this.contentSet  = null;
            this.unpackState = null;
        }
    }
}
