package com.ninjabird.firelight.renderer.atlas
{
    /**
     * Represents a single logical entry in a texture atlas. The entry may be
     * composed of one or more frames on the atlas.
     */
    public final class AtlasEntry
    {
        /**
         * The name of the entry. This is used by the application to access the item from the atlas.
         */
        public var name:String;

        /**
         * Indicates whether this atlas entry spans multiple texture pages.
         */
        public var isMultiPage:Boolean;

        /**
         * The number of frames associated with this entry. This value will be at least 1.
         */
        public var frameCount:int;

        /**
         * The largest width of any frame, in pixels.
         */
        public var frameMaxWidth:int;

        /**
         * The largest height of any frame, in pixels.
         */
        public var frameMaxHeight:int;

        /**
         * The x-coordinate of the upper-left corner of each frame.
         */
        public var frameX:Vector.<int>;

        /**
         * The y-coordinate of the upper-left corner of each frame.
         */
        public var frameY:Vector.<int>;

        /**
         * The width of each frame, in pixels.
         */
        public var frameWidth:Vector.<int>;

        /**
         * The height of each frame, in pixels.
         */
        public var frameHeight:Vector.<int>;

        /**
         * The texture page ID for each frame.
         */
        public var framePage:Vector.<int>;

        /**
         * Default constructor. Initializes all fields to their default values.
         * @param entryName The name used by the application to locate the entry within the texture atlas.
         */
        public function AtlasEntry(entryName:String)
        {
            this.name           = entryName;
            this.isMultiPage    = false;
            this.frameCount     = 0;
            this.frameMaxWidth  = 0;
            this.frameMaxHeight = 0;
            this.frameX         = new Vector.<int>();
            this.frameY         = new Vector.<int>();
            this.frameWidth     = new Vector.<int>();
            this.frameHeight    = new Vector.<int>();
            this.framePage      = new Vector.<int>();
        }

        /**
         * Appends a frame definition to the end of the entry frame list.
         * @param x The x-coordinate of the upper-left corner of the frame.
         * @param y The y-coordinate of the upper-left corner of the frame.
         * @param width The width of the frame, in pixels.
         * @param height The height of the frame, in pixels.
         * @param pageId The identifier of the texture page containing the frame image data.
         * @return The zero-based index of the frame.
         */
        public function addFrame(x:int, y:int, width:int, height:int, pageId:int) : int
        {
            if (width  > this.frameMaxWidth)  this.frameMaxWidth  = width;
            if (height > this.frameMaxHeight) this.frameMaxHeight = height;

            var index:int  = this.frameCount++;
            if (index > 0 && this.framePage[index-1] != pageId)
                this.isMultiPage = true;

            this.frameX[index]      = x;
            this.frameY[index]      = y;
            this.frameWidth[index]  = width;
            this.frameHeight[index] = height;
            this.framePage[index]   = pageId;
            return index;
        }

        /**
         * Updates the attributes for an existing frame definition.
         * @param x The x-coordinate of the upper-left corner of the frame.
         * @param y The y-coordinate of the upper-left corner of the frame.
         * @param width The width of the frame, in pixels.
         * @param height The height of the frame, in pixels.
         * @param pageId The identifier of the texture page containing the frame image data.
         * @return The zero-based index of the frame.
         */
        public function updateFrame(index:int, x:int, y:int, width:int, height:int, pageId:int) : void
        {
            if (width  > this.frameMaxWidth)  this.frameMaxWidth  = width;
            if (height > this.frameMaxHeight) this.frameMaxHeight = height;
            if (index > 0 && this.framePage[index-1] != pageId)
                this.isMultiPage = true;

            this.frameX[index]      = x;
            this.frameY[index]      = y;
            this.frameWidth[index]  = width;
            this.frameHeight[index] = height;
            this.framePage[index]   = pageId;
        }
    }
}
