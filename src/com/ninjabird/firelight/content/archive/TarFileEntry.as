package com.ninjabird.firelight.content.archive
{
    /**
     * Represents the uncompressed metadata associated with a single entry in
     * a TAR archive.
     */
    public final class TarFileEntry
    {
        /**
         * The record represents a standard file.
         */
        public static const FILE:int      = 0;

        /**
         * The record represents a hard link.
         */
        public static const HARDLINK:int  = 1;

        /**
         * The record represents a symbolic link.
         */
        public static const SYMLINK:int   = 2;

        /**
         *  The record represents a character device.
         */
        public static const CHARACTER:int = 3;

        /**
         * The record represents a block device.
         */
        public static const BLOCK:int     = 4;

        /**
         * The record represents a directory.
         */
        public static const DIRECTORY:int = 5;

        /**
         * The record represents a named pipe.
         */
        public static const FIFO:int      = 6;

        /**
         * The byte offset of the start of the entry metadata.
         */
        public var metaOffset:uint;

        /**
         * The byte offset of the start of the record data.
         */
        public var dataOffset:uint;

        /**
         * The name of the entry (the filename, for example.)
         */
        public var name:String;

        /**
         * Mode flags associated with this entry.
         */
        public var mode:uint;

        /**
         * The owner user ID.
         */
        public var uid:uint;

        /**
         * The owner group ID.
         */
        public var gid:uint;

        /**
         * The size of the entry data, in bytes.
         */
        public var size:uint;

        /**
         * The file modification time.
         */
        public var mtime:uint;

        /**
         * The checksum of the header data.
         */
        public var checksum:uint;

        /**
         * The entry type, for example TarFileEntry.FILE.
         */
        public var type:int;

        /**
         * The name of the linked file.
         */
        public var linkName:String;

        /**
         * The archive signature bytes; should always be 'ustar'.
         */
        public var magic:String;

        /**
         * The ustar version, typically zero.
         */
        public var version:uint;

        /**
         * The username of the owner.
         */
        public var userName:String;

        /**
         * The group name of the owner.
         */
        public var groupName:String;

        /**
         * The device major version.
         */
        public var deviceMajor:uint;

        /**
         * The device minor version.
         */
        public var deviceMinor:uint;

        /**
         * The filename prefix.
         */
        public var prefix:String;

        /**
         * Constructor function for an object defining the various types of
         * records that may be found within a tar archive file in the ustar
         * format.
         */
        public function TarFileEntry()
        {
            this.metaOffset  = 0;
            this.dataOffset  = 0;
            this.name        = null;
            this.mode        = 0;
            this.uid         = 0;
            this.gid         = 0;
            this.size        = 0;
            this.mtime       = 0;
            this.checksum    = 0;
            this.type        = TarFileEntry.FILE;
            this.linkName    = null;
            this.magic       = null;
            this.version     = 0;
            this.userName    = null;
            this.groupName   = null;
            this.deviceMajor = 0;
            this.deviceMinor = 0;
            this.prefix      = '';
        }
    }
}
