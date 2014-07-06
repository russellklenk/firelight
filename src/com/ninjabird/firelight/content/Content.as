package com.ninjabird.firelight.content
{
    import flash.events.EventDispatcher;
    import com.ninjabird.firelight.content.events.ContentDisposedEvent;

    /**
     * Defines the parsed runtime data associated with a single content item.
     */
    public final class Content extends EventDispatcher
    {
        /**
         * The name of the content package this content item was loaded from.
         */
        public var sourcePackage:String;

        /**
         * The name of the content item. This will be unique within the
         * content package.
         */
        public var name:String;

        /**
         * The content type. This is used to look up the associated content
         * loader, used to transform the raw content data into runtime data.
         */
        public var type:String;

        /**
         * An array of strings specifying application-defined data attributes,
         * which can be used for filtering or selecting content. The tag values
         * are extracted from extension fragments on the source filename.
         */
        public var tags:Vector.<String>;

        /**
         * The set of data file paths identifying the files comprising the raw
         * content data within the source content package.
         */
        public var dataFiles:Vector.<String>;

        /**
         * The set of runtime attributes associated with the content item; for
         * example, the width and height of a BitmapData could also be stored
         * here. The set of attributes varies depending on the content type.
         * Runtime attributes are available only after the content data is
         * transformed into runtime data.
         */
        public var attributes:Object;

        /**
         * The runtime data that results from loading the content item. This
         * field is set after the loading phase has completed.
         */
        public var runtimeData:Object;

        /**
         * The handle to this Content item within the content set.
         */
        public var handle:int;

        /**
         * Default constructor. Initializes all fields to null.
         */
        public function Content()
        {
            this.sourcePackage = null;
            this.name          = null;
            this.type          = null;
            this.tags          = null;
            this.dataFiles     = null;
            this.attributes    = null;
            this.runtimeData   = null;
            this.handle        = -1;
        }

        /**
         * Searches the content metadata to locate the first filename with a
         * given extension. The file extension is considered to be anything
         * after the last occurrence of the period character.
         * @param extension The extension string, without leading period.
         * @param startIndex The zero-based starting index. Defaults to zero.
         * @return The zero-based index of the first file at index greater than
         * or equal to @a startIndex with the specified extension, or -1.
         */
        public function fileWithExtension(extension:String, startIndex:int = 0) : int
        {
            var separator:String = '.';
            var fileCount:int    = dataFiles.length;
            for (var i:int = startIndex; i < fileCount; ++i)
            {
                var filename:String = this.dataFiles[i];
                var lastPeriod:int  = filename.lastIndexOf(separator);
                if (lastPeriod >= 0)
                {
                    // this filename has an extension component.
                    var ext:String  = filename.substr(lastPeriod + 1);
                    if (ext === extension)
                    {
                        return i;
                    }
                }
                else
                {
                    // this filename does not have an extension.
                    if (extension == null || extension.length == 0)
                    {
                        return i;
                    }
                }
            }
            return -1;
        }

        /**
         * Searches the content metadata to locate the first filename with a
         * given extension. The file extension is considered to be anything
         * after the last occurrence of the period character.
         * @param extensions The list of extension strings, without leading period.
         * @param startIndex The zero-based starting index. Defaults to zero.
         * @return The zero-based index of the first file at index greater than
         * or equal to @a startIndex with the specified extension, or -1.
         */
        public function fileWithAnyExtension(extensions:Array, startIndex:int = 0) : int
        {
            var separator:String = '.';
            var fileCount:int    = dataFiles.length;
            var extCount:int     = extensions.length;
            for (var i:int = startIndex; i < fileCount; ++i)
            {
                var filename:String = this.dataFiles[i];
                var lastPeriod:int  = filename.lastIndexOf(separator);
                if (lastPeriod >= 0)
                {
                    // this filename has an extension component.
                    var ext:String  = filename.substr(lastPeriod + 1);
                    for (var j:int  = 0; j < extCount; ++j)
                    {
                        if (ext === extensions[j])
                        {
                            return i;
                        }
                    }
                }
                else
                {
                    // this filename does not have an extension.
                    for (var k:int  = 0; k < extCount; ++k)
                    {
                        if (extensions[k] === null || extensions[k].length === 0)
                        {
                            return i;
                        }
                    }
                }
            }
            return -1;
        }

        /**
         * Unloads the content item, invalidating the attributes and runtimeData
         * fields, but leaving the other fields intact.
         */
        public function unload() : void
        {
            this.dispatchEvent(new ContentDisposedEvent(this));
            this.attributes  = null;
            this.runtimeData = null;
        }

        /**
         * Disposes of the content item, invalidating all fields.
         */
        public function dispose() : void
        {
            this.dispatchEvent(new ContentDisposedEvent(this));
            this.sourcePackage = null;
            this.name          = null;
            this.type          = null;
            this.tags          = null;
            this.dataFiles     = null;
            this.attributes    = null;
            this.runtimeData   = null;
            this.handle        = -1;
        }
    }
}
