package com.ninjabird.firelight.content.archive
{
    import flash.utils.Endian;
    import flash.utils.ByteArray;
    import com.ninjabird.firelight.debug.DebugTrace;

    /**
     * Parses and extracts data from an in-memory TAR archive file.
     */
    public final class TarFile
    {
        /**
         * The exponent of 2^9 (=512), which corresponds to the block size. If
         * the block size is changed, this constant must also be adjusted.
         */
        public static const BLOCK_SHIFT:int = 9;

        /**
         * The block size to which all entry d
         ata is rounded up.
         */
        public static const BLOCK_SIZE:int  = 512;

        /**
         * The size of a single header entry, in bytes.
         */
        public static const HEADER_SIZE:int = 512;

        /**
         * The raw, in-memory TAR archive data.
         */
        public var data:ByteArray;

        /**
         * The list of file and directory entries contained within the archive.
         */
        public var entryList:Vector.<TarFileEntry>;

        /**
         * An associative array mapping String entry path to TarFileEntry.
         */
        public var entryTable:Object;

        /**
         * Calculates the byte offset of the next record given the offset and
         * size of the data for the previous entry.
         * @param dataOffset The byte offset of the data for the previous entry.
         * @param dataSize The size of the previous entry, in bytes.
         * @return The byte offset of the next header record.
         */
        private function nextHeaderOffset(dataOffset:uint, dataSize:uint) : uint
        {
            var bs:uint = TarFile.BLOCK_SIZE;
            var ss:uint = Math.ceil(dataSize / bs);
            return dataOffset + ss * bs;
        }

        /**
         * Reads @a length ASCII characters (each one byte) from the buffer
         * starting at @a offset and returns the result as a string.
         * @param view The ByteArray from which the data will be read.
         * @param offset The byte offset at which to begin reading data.
         * @param length The number of bytes to read.
         * @return A string initialized with the data read from the buffer.
         */
        private function readString(view:ByteArray, offset:uint, length:uint) : String
        {
            var s:String    = '';
            var e:uint      = offset  + length;
            view.position   = offset;
            for (var i:uint = offset; i < e; ++i)
            {
                var c:uint  = view.readUnsignedByte();
                if (c === 0)  break;
                s += String.fromCharCode(c);
            }
            return s;
        }

        /**
         * Reads @a length ASCII characters (each one byte) from the buffer
         * starting at @a offset, interpreting them as octal digits.
         * @param view The ByteArray from which the data will be read.
         * @param offset The byte offset at which to begin reading data.
         * @param length The number of bytes to read.
         * @return An integer representing the value.
         */
        private function readOctal(view:ByteArray, offset:uint, length:uint) : uint
        {
            var n:uint      = 0;
            var e:uint      = offset + length;
            view.position   = offset;
            for (var i:uint = 0; i < e; ++i)
            {
                var c:uint  = view.readUnsignedByte();
                if (c >= 48 && c < 56)
                {
                    n *= 8;
                    n += c - 48;
                }
                else break; // space or null terminates the value.
            }
            return n;
        }

        /**
         * Reads a single header entry from the buffer starting at the
         * specified byte offset.
         * @param view The ByteArray from which the data will be read.
         * @param offset The byte offset at which to begin reading data.
         * @return A new TarFileEntry instance initialized with the data.
         */
        private function readHeader(view:ByteArray, offset:uint) : TarFileEntry
        {
            var o:uint         = offset;
            var e:TarFileEntry = new TarFileEntry();
            e.metaOffset       = offset;
            e.dataOffset       = offset + TarFile.HEADER_SIZE;
            e.name             = this.readString(view, o, 100); o += 100;
            e.mode             = this.readOctal (view, o,   8); o +=   8;
            e.uid              = this.readOctal (view, o,   8); o +=   8;
            e.gid              = this.readOctal (view, o,   8); o +=   8;
            e.size             = this.readOctal (view, o,  12); o +=  12;
            e.mtime            = this.readOctal (view, o,  12); o +=  12;
            e.checksum         = this.readOctal (view, o,   8); o +=   8;
            e.type             = this.readOctal (view, o,   1); o +=   1;
            e.linkName         = this.readString(view, o, 100); o += 100;
            e.magic            = this.readString(view, o,   6); o +=   6;
            if (e.magic == 'ustar')
            {
                // this is a ustar archive, read the additional fields.
                e.version      = this.readOctal (view, o,   2); o +=   2;
                e.userName     = this.readString(view, o,  32); o +=  32;
                e.groupName    = this.readString(view, o,  32); o +=  32;
                e.deviceMajor  = this.readOctal (view, o,   8); o +=   8;
                e.deviceMinor  = this.readOctal (view, o,   8); o +=   8;
                e.prefix       = this.readString(view, o, 155); o += 155;
            }
            else
            {
                // this isn't a ustar archive; it may just be plain tar.
                e.version      = 0;
                e.userName     = '';
                e.groupName    = '';
                e.deviceMajor  = 0;
                e.deviceMinor  = 0;
                e.prefix       = '';
            }
            return e;
        }

        /**
         * Constructor function for a type that represents the contents of a
         * ustar tar archive file. All operations execute synchronously.
         */
        public function TarFile()
        {
            this.data       = null;
            this.entryList  = null;
            this.entryTable = null;
        }

        /**
         * Checks an entry to determine whether it is a file.
         * @param entry The archive entry to check.
         * @return true if @a entry represents a standard file.
         */
        public function isFile(entry:TarFileEntry) : Boolean
        {
            return (TarFileEntry.FILE == entry.type);
        }

        /**
         * Checks an entry to determine whether it is a directory.
         * @param entry The archive entry to check.
         * @return true if @a entry represents a directory.
         */
        public function isDirectory(entry:TarFileEntry) : Boolean
        {
            var l:int = entry.name.length - 1;
            return (TarFileEntry.DIRECTORY == entry.type || entry.name[l] == '/');
        }

        /**
         * Checks an entry to determine whether it indicates the end of the
         * archive. TAR archives are terminated with two entries of zero bytes.
         * @param entry The archive entry to check.
         * @return true if @a entry represents an end-of-file archive.
         */
        public function isEndOfArchive(entry:TarFileEntry) : Boolean
        {
            return (entry.name == null || entry.name.length == 0);
        }

        /**
         * Attempts to parse an in-memory TAR archive.
         * @param buffer The TAR archive data. The TarFile takes ownership of this buffer.
         * @return true if the TAR archive is loaded successfully.
         */
        public function load(buffer:ByteArray) : Boolean
        {
            var lst:Vector.<TarFileEntry> = new Vector.<TarFileEntry>();
            var tab:Object                = new Object();

            if (buffer == null)
            {
                DebugTrace.out('TarFile::load(1) - Invalid parameter buffer.');
                return false;
            }

            buffer.position     = 0;
            buffer.endian       = Endian.LITTLE_ENDIAN;
            var headerSize:uint = TarFile.HEADER_SIZE;
            var offset:uint     = 0;
            while (offset < buffer.length)
            {
                var e:TarFileEntry = this.readHeader(buffer, offset);
                offset = this.nextHeaderOffset(e.dataOffset, e.size);
                if (this.isEndOfArchive(e) === false)
                {
                    var k:String = e.prefix + e.name;
                    lst.push(e);
                    tab[k] = e;
                }
            }

            // we're done - set the instance fields.
            if (this.data !== null)
            {
                this.data.clear();
                this.data = null;
            }
            this.data       = buffer;
            this.entryList  = lst;
            this.entryTable = tab;
            return true;
        }

        /**
         * Extracts a file from the archive comprised of JSON text, and parses
         * the JSON into a runtime Object.
         * @param filename The filename of the entry to load.
         * @param defaultValue The value to return if @a filename is unknown.
         * @return The runtime object.
         */
        public function loadFileJSON(filename:String, defaultValue:Object=null) : Object
        {
            var e:TarFileEntry = this.entryTable[filename];
            if (e)
            {
                this.data.position = e.dataOffset;
                var s:String = this.data.readUTFBytes(e.size);
                return JSON.parse(s);
            }
            else return defaultValue;
        }

        /**
         * Extracts a text file from the archive and returns it as a String.
         * @param filename The filename of the entry to load.
         * @param defaultValue The value to return if @a filename is unknown.
         * @return The string containing the text file contents.
         */
        public function loadFileText(filename:String, defaultValue:String='') : String
        {
            var e:TarFileEntry = this.entryTable[filename];
            if (e)
            {
                this.data.position = e.dataOffset;
                return this.data.readUTFBytes(e.size);
            }
            else return defaultValue;
        }

        /**
         * Extracts a binary file from the archive.
         * @param filename The filename of the entry to load.
         * @return A ByteArray containing the file data, or null.
         */
        public function loadFileBytes(filename:String) : ByteArray
        {
            var e:TarFileEntry = this.entryTable[filename];
            if (e)
            {
                var dst:ByteArray  = new ByteArray();
                dst.position       = 0;
                dst.length         = e.size;
                this.data.position = e.dataOffset;
                this.data.readBytes(dst, 0, e.size);
                return dst;
            }
            else return null;
        }

        /**
         * Disposes of resources associated with this instance.
         */
        public function dispose() : void
        {
            this.entryList  = null;
            this.entryTable = null;
            if (this.data  != null)
            {
                this.data.clear();
                this.data = null;
            }
        }
    }
}
