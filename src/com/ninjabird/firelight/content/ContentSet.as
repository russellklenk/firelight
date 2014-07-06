package com.ninjabird.firelight.content
{
    import flash.utils.Endian;
    import flash.utils.ByteArray;
    import com.ninjabird.firelight.debug.DebugTrace;

    /**
     * Represents a set of content that is related on some way. Content
     * relationships are determined by the application. Content items are
     * accessible by name or by index.
     */
    public final class ContentSet
    {
        /**
         * An empty vector returned by queries that return an empty result set.
         */
        public static const EMPTY_VECTOR:Vector.<Content> = new Vector.<Content>(0, true);

        /**
         * The total number of bytes for each content package.
         */
        private var packageSizes:Vector.<uint>;

        /**
         * The number of bytes downloaded for each content package.
         */
        private var packageLoads:Vector.<uint>;

        /**
         * The set of content package names that contribute to the set.
         */
        public  var packageList:Vector.<String>;

        /**
         * The complete set of content items, accessible by linear search.
         */
        public  var contentList:Vector.<Content>;

        /**
         * The set of content items, where items are accessible by name.
         */
        public  var byNameTable:Object;

        /**
         * The name of the content set.
         */
        public  var name:String;

        /**
         * Constructs an empty content set.
         * @param setName The optional name of the content set.
         */
        public function ContentSet(setName:String='')
        {
            this.packageSizes = new Vector.<uint>();
            this.packageLoads = new Vector.<uint>();
            this.packageList  = new Vector.<String>();
            this.contentList  = new Vector.<Content>();
            this.byNameTable  = new Object();
            this.name         = setName;
        }

        /**
         * Generates a list of the unique content item names defined in the set.
         * @return A list of the unique content item names in the set.
         */
        public function contentNames() : Vector.<String>
        {
            var nameList:Vector.<String> = new Vector.<String>()
            for (var name:String in this.byNameTable)
            {
                nameList.push(name);
            }
            return nameList;
        }

        /**
         * Adds the name of a content package contributing to the set.
         * @param packageName The name of the content package.
         */
        public function addPackage(packageName:String) : void
        {
            for (var i:int = 0; i < this.packageList.length; ++i)
            {
                if (packageName === this.packageList[i])
                    return;
            }
            this.packageList.push(packageName);
            this.packageSizes.push(0);
            this.packageLoads.push(0);
        }

        /**
         * Adds an item to the content set. This method is typically called
         * during unpacking of a content bundle, after the content item has
         * been fully loaded.
         * @param content The content item to add.
         * @return The zero-based index of the content item.
         */
        public function addContent(content:Content) : int
        {
            var index:int = this.contentList.length;

            content.handle = index;
            this.contentList.push(content);

            var nameList:Vector.<Content> = this.byNameTable[content.name];
            if (nameList === null)
            {
                nameList = Vector.<Content>([content]);
                this.byNameTable[content.name] = nameList;
            }
            else nameList.push(content);

            return index;
        }

        /**
         * Retrieves the set of all content with a given name.
         * @param name The name of the content item(s) to retrieve.
         * @return The set of all content items with the specified name. Do not
         * modify the returned list.
         */
        public function allContentByName(name:String) : Vector.<Content>
        {
            var nameList:Vector.<Content> = this.byNameTable[name];
            if (nameList === null)
            {
                nameList = ContentSet.EMPTY_VECTOR;
            }
            return nameList;
        }

        /**
         * Retrieve the first content item with a given name that also
         * optionally has the specified tag. The filter tag can be used to
         * select an item in a particular language, for example.
         * @param name The name of the content item to search for.
         * @param filterTag An optional value that can be used to narrow the
         * search to a single item. If undefined, and multiple content items
         * match the specified name, the first matching item is returned.
         * @return The Content matching the specified criteria, or null.
         */
        public function contentByName(name:String, filterTag:String=null) : Content
        {
            var nameList:Vector.<Content> = this.byNameTable[name];
            if (nameList === null)
            {
                return null;
            }

            if (filterTag)
            {
                for (var i:int = 0; i < nameList.length; ++i)
                {
                    if (nameList[i].tags.indexOf(filterTag) >= 0)
                    {
                        return nameList[i];
                    }
                }
                return null;
            }
            else return nameList[0];
        }

        /**
         * Replaces a given content item with a new item. If the specified
         * content item does not exist, the new item is added. The content
         * index is guaranteed to remain the same for existing items. Both
         * items must represent the same content and have the same name, type.
         * @param existing The current Content item reference.
         * @param newItem The Content item to replace @a existing.
         * @return The zero-based index of the content item.
         */
        public function replaceContent(existing:Content, newItem:Content) : int
        {
            var index:int = this.contentList.indexOf(existing);
            if (index < 0)
            {
                index = this.addContent(newItem);
            }
            else
            {
                index = this.replaceContentAt(index, newItem);
            }
            return index;
        }

        /**
         * Replaces a given content item with a new item, given the zero-based
         * index of the content item. The content index is guaranteed to remain
         * the same for existing items. Both items must represent the same
         * content, and have the same name and type.
         * @param index The zero-based index of the content item to replace,
         * as returned by the @a ContentSet.addContent() method.
         * @param newItem The Content item to replace the existing item.
         * @return The zero-based index of the content item.
         */
        public function replaceContentAt(index:int, newItem:Content) : int
        {
            if (index < 0 || index >= this.contentList.length)
            {
                index = this.addContent(newItem);
                return index;
            }

            var oldContent:Content = this.contentList[index];
            if (oldContent.name  !== newItem.name ||
                oldContent.type  !== newItem.type)
            {
                DebugTrace.out('ContentSet::replaceContentAt(2) - Name or type mismatch (name: %s/%s) (type: %s/%s).', oldContent.name, newItem.name, oldContent.type, newItem.type);
                throw new Error('Cannot replace content; name or type mismatch.');
            }

            this.contentList[index]       = newItem;
            var nameList:Vector.<Content> = this.byNameTable[oldContent.name];
            var nameIndex:int  = nameList.indexOf(oldContent);
            nameList[nameIndex]= newItem;
            oldContent.dispose();
            return index;
        }

        /**
         * Replace an existing content item with a new item, by comparing
         * content identities. The identity of a piece of content consists of
         * the combination of name, type and tags. The content item is added if
         * no matching content exists.
         * @param newItem The updated content item.
         * @return The zero-based index of the content item.
         */
        public function replaceContentItem(newItem:Content) : int
        {
            var nameList:Vector.<Content> = this.byNameTable[newItem.name];
            if (nameList === null)
            {
                return this.addContent(newItem);
            }

            // search for an item with the exact same type and tags.
            // together, the name, type and tags make up the content identity.
            var listId:int =-1;
            for (var i:int = 0; i < nameList.length; ++i)
            {
                var existing:Content       = nameList[i];
                if (existing.type        === newItem.type &&
                    existing.tags.length === newItem.tags.length)
                {
                    var tagMatch:Boolean   = true;
                    for (var tag:int = 0; tag < newItem.tags.length; ++tag)
                    {
                        if (existing.tags[tag] !== newItem.tags[tag])
                        {
                            tagMatch = false;
                            break;
                        }
                    }
                    if (tagMatch)
                    {
                        listId = i;
                        break;
                    }
                }
            }

            if (listId >= 0)
            {
                // if we found an identity match, replace that item.
                return this.replaceContent(nameList[listId], newItem);
            }
            else return this.addContent(newItem);
        }

        /**
         * Retrieves a handle for a given content item. The handle value is
         * guaranteed to remain the same between content reloads.
         * @param content The content item.
         * @return The content handle.
         */
        public function handleForContent(content:Content) : int
        {
            return content.handle;
        }

        /**
         * Retrieves the content definition associated with a given handle.
         * @param handle The content handle.
         * @return The content definition.
         */
        public function contentForHandle(handle:int) : Content
        {
            return this.contentList[handle];
        }

        /**
         * Calculates the total number of bytes that make up the content package
         * archive files in this content set.
         * @return The number of bytes used by the content packages in the set.
         */
        public function calculateBytesTotal() : uint
        {
            var total:uint = 0;
            for (var i:int = 0; i < this.packageSizes.length; ++i)
            {
                total += this.packageSizes[i];
            }
            return total;
        }

        /**
         * Calculates the total number of bytes downloaded so far for the
         * content packages defined in the set.
         * @return The number of bytes downloaded for the content set.
         */
        public function calculateBytesLoaded() : uint
        {
            var total:uint = 0;
            for (var i:int = 0; i < this.packageLoads.length; ++i)
            {
                total += this.packageLoads[i];
            }
            return total;
        }

        /**
         * Calculates the download progress of the content set.
         * @return A percentage value in [0, 100].
         */
        public function calculateDownloadProgress() : Number
        {
            var loadedBytes:uint = this.calculateBytesLoaded();
            var totalBytes:uint  = this.calculateBytesTotal();
            if (totalBytes > 0)
            {
                return (Number(loadedBytes) / Number(totalBytes)) * 100;
            }
            else return 100.0;
        }

        /**
         * Updates the download progress for a content package within the set.
         * @param packageName The name of the content package.
         * @param bytesLoaded The number of bytes downloaded.
         * @param bytesTotal The total number of bytes in the content package
         * archive file.
         */
        public function updatePackageProgress(packageName:String, bytesLoaded:uint, bytesTotal:uint) : void
        {
            var index:int = this.packageList.indexOf(packageName);
            if (index >= 0)
            {
                this.packageSizes[index] = bytesTotal;
                this.packageLoads[index] = bytesLoaded;
            }
        }

        /**
         * Disposes of all items in the content set and returns the set to the
         * empty state (no content items are defined.)
         * @param keepPackages true to keep the list of content packages.
         */
        public function clear(keepPackages:Boolean=true) : void
        {
            for (var i:int = 0; i < this.contentList.length; ++i)
            {
                var item:Content  = this.contentList[i];
                if (item) item.dispose();
            }
            if (keepPackages)
            {
                for (var j:int = 0; j < this.packageList.length; ++j)
                {
                    this.packageSizes[0] = 0;
                    this.packageLoads[0] = 0;
                }
            }
            else
            {
                this.packageSizes = new Vector.<uint>();
                this.packageLoads = new Vector.<uint>();
                this.packageList  = new Vector.<String>();
            }
            this.contentList = new Vector.<Content>();
            this.byNameTable = new Object();
        }

        /**
         * Disposes of all items in the content set.
         */
        public function dispose() : void
        {
            for (var i:int = 0; i < this.contentList.length; ++i)
            {
                var item:Content  = this.contentList[i];
                if (item) item.dispose();
            }
            this.packageSizes = null;
            this.packageLoads = null;
            this.packageList  = null;
            this.contentList  = null;
            this.byNameTable  = null;
        }
    }
}
