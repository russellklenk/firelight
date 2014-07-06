package com.ninjabird.firelight.renderer.atlas
{
    /**
     * Represents a single rectangle on the atlas image when building a dynamic texture atlas.
     */
    public final class PackerNode
    {
        /**
         * The x-coordinate of the upper-left corner of the bounding rectangle.
         */
        public var left:int;

        /**
         * The y-coordinate of the upper-left corner of the bounding rectangle.
         */
        public var top:int;

        /**
         * The x-coordinate of the lower-right corner of the bounding rectangle.
         */
        public var right:int;

        /**
         * The y-coordinate of the lower-right corner of the bounding rectangle.
         */
        public var bottom:int;

        /**
         * The x-coordinate of the upper-left corner of the bounding rectangle of the content.
         */
        public var contentX:int;

        /**
         * The y-coordinate of the upper-left corner of the bounding rectangle of the content.
         */
        public var contentY:int;

        /**
         * The width of the content, in pixels.
         */
        public var contentWidth:int;

        /**
         * The height of the content, in pixels.
         */
        public var contentHeight:int;

        /**
         * A reference to the left child node, or null.
         */
        public var leftChild:PackerNode;

        /**
         * A reference to the right child node, or null.
         */
        public var rightChild:PackerNode;

        /**
         * The zero-based index of the frame present at the node, or -1.
         */
        public var frameIndex:int;

        /**
         * Data associated with the node, or undefined if the node is empty.
         */
        public var data:*;

        /**
         * Default constructor. Since many node instances will be created, no
         * additional initialization is performed here.
         */
        public function PackerNode()
        {
            /* empty */
        }
    }
}
