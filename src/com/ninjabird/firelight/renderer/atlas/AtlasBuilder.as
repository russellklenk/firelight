package com.ninjabird.firelight.renderer.atlas
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.StageQuality;
    import flash.geom.Matrix;
    import flash.geom.Point;

    /**
     * Supports dynamically generating texture atlases from bitmaps or vector
     * shapes by rendering them into a larger bitmap, which can then be loaded
     * into a texture object. The bitmap data is always 32bpp BGRA format.
     */
    public final class AtlasBuilder
    {
        /**
         * The point value (0, 0).
         */
        public static const ZERO:Point = new Point();

        /**
         * The root node of the tree, or null if the tree is empty.
         */
        public var root:PackerNode;

        /**
         * The first node in the free list.
         */
        public var freeList:PackerNode;

        /**
         * The number of pixels of unused area.
         */
        public var areaFree:int;

        /**
         * The number of pixels of used area.
         */
        public var areaUsed:int;

        /**
         * The width of the atlas image, in pixels.
         */
        public var imageWidth:int;

        /**
         * The height of the atlas image, in pixels.
         */
        public var imageHeight:int;

        /**
         * The number of sub-images defined on the atlas.
         */
        public var imageCount:int;

        /**
         * The amount of vertical padding, in pixels.
         */
        public var verticalPad:int;

        /**
         * The amount of horizontal padding, in pixels.
         */
        public var horizontalPad:int;

        /**
         * The atlas image bitmap data.
         */
        public var bitmap:BitmapData;

        /**
         * Allocates a node. If a node is available in the free list, it is
         * returned; otherwise, a new node is allocated from the heap.
         * @return The node.
         */
        private function allocateNode() : PackerNode
        {
            if (this.freeList)
            {
                var node:PackerNode = this.freeList;
                this.freeList       = node.leftChild;
                node.left           = 0;
                node.top            = 0;
                node.right          = 0;
                node.bottom         = 0;
                node.contentX       = 0;
                node.contentY       = 0;
                node.contentWidth   = 0;
                node.contentHeight  = 0;
                node.leftChild      = null;
                node.rightChild     = null;
                node.frameIndex     = -1;
                node.data           = undefined;
                return node;
            }
            else return new PackerNode();
        }

        /**
         * Frees a node by returning it to the free list.
         * @param node The node being freed.
         */
        private function freeNode(node:PackerNode) : void
        {
            node.data      = undefined;
            node.leftChild = this.freeList;
            this.freeList  = node;
        }

        /**
         * Recursively adds all nodes under a given node to the free list.
         * @param node The node to return to the free list.
         */
        private function clearTree(node:PackerNode) : void
        {
            if (node)
            {
                this.clearTree(node.rightChild);
                this.clearTree(node.leftChild);
                this.freeNode(node);
            }
        }

        /**
         * Attempts to insert a node into the tree, dividing space as necessary.
         * @param node The node to insert at.
         * @param width The width of the rectangle stored at the node.
         * @param height The height of the rectangle stored at the node.
         */
        private function insertNode(node:PackerNode, width:int, height:int) : PackerNode
        {
            if (node.leftChild && node.rightChild)
            {
                // this isn't a leaf node, so attempt to insert in the subtree.
                var target:PackerNode = this.insertNode(node.leftChild, width, height);
                if (target) return target;
                else return this.insertNode(node.rightChild, width, height);
            }
            else if (node.data)
            {
                // this node is an occupied leaf node; can't insert here.
                return null;
            }
            else
            {
                // this node is an unoccupied leaf node, try to insert.
                var rectWidth:int  = node.right  - node.left;
                var rectHeight:int = node.bottom - node.top;
                if (width > rectWidth || height > rectHeight)
                    return null; // won't fit in this node...

                // if the rect will fit exactly at this node, put it here.
                if (width === rectWidth && height === rectHeight)
                    return node;

                // otherwise, the rect will fit, but not exactly, so subdivide
                // the space at this node into a used portion (left child) and
                // an unused portion (the right child.)
                var a:PackerNode = this.allocateNode(); // left child
                var b:PackerNode = this.allocateNode(); // right child
                var dw:int       = rectWidth  - width;
                var dh:int       = rectHeight - height;
                if (dw > dh)
                {
                    a.left   = node.left;
                    a.top    = node.top;
                    a.right  = node.left + width;
                    a.bottom = node.bottom;
                    b.left   = node.left + width;
                    b.top    = node.top;
                    b.right  = node.right;
                    b.bottom = node.bottom;
                }
                else
                {
                    a.left   = node.left;
                    a.top    = node.top;
                    a.right  = node.right;
                    a.bottom = node.top + height;
                    b.left   = node.left;
                    b.top    = node.top + height;
                    b.right  = node.right;
                    b.bottom = node.bottom;
                }
                node.leftChild  = a;
                node.rightChild = b;
                return this.insertNode(node.leftChild, width, height);
            }
        }

        /**
         * Constructs a new instance. Use AtlasBuilder.clearAtlas() to specify
         * the image attributes and allocate or clear the underlying bitmap.
         */
        public function AtlasBuilder()
        {
            this.root          = null;
            this.freeList      = null;
            this.areaFree      = 0;
            this.areaUsed      = 0;
            this.imageCount    = 0;
            this.imageWidth    = 0;
            this.imageHeight   = 0;
            this.verticalPad   = 0;
            this.horizontalPad = 0;
            this.bitmap        = null;
        }

        /**
         * Clears the atlas and resets it to empty. The underlying bitmap data is reallocated, if necessary.
         * @param width The width of the atlas image, in pixels.
         * @param height The height of the atlas image, in pixels.
         * @param color The background color of the atlas image.
         * @param hpad The horizontal padding, in pixels.
         * @param vpad The vertical padding, in pixels.
         */
        public function clearAtlas(width:int, height:int, color:uint, hpad:int=0, vpad:int=0) : void
        {
            if (this.bitmap)
            {
                if (this.bitmap.width === width && this.bitmap.height === height)
                {
                    // reuse the bitmap, but clear it out.
                    this.bitmap.fillRect(this.bitmap.rect, color);
                }
                else
                {
                    // dispose the existing bitmap and allocate a new one.
                    this.bitmap.dispose();
                    this.bitmap = new BitmapData(width, height, true, color);
                }
            }
            else this.bitmap = new BitmapData(width, height, true, color);

            // return all nodes to the free list.
            this.clearTree(this.root);

            // initialize the root node to the entire area:
            this.root        = this.allocateNode();
            this.root.right  = width;
            this.root.bottom = height;

            // reset areas and image dimensions.
            this.areaFree      = width * height;
            this.areaUsed      = 0;
            this.imageCount    = 0;
            this.imageWidth    = width;
            this.imageHeight   = height;
            this.verticalPad   = vpad;
            this.horizontalPad = hpad;
        }

        /**
         * Renders a bitmap into the atlas image, using either the vector
         * rendering engine or performing a fast blit.
         * @param bitmap The bitmap to render into the atlas.
         * @param useVector true to use the vector rendering engine, in which
         * case the bitmap is rendered using the transform set on the Bitmap.
         * Specifying false (the default) performs a fast blit without any
         * rotation or scaling.
         * @return The PackerNode representing the bitmap, or null.
         */
        public function addBitmap(bitmap:Bitmap, useVector:Boolean=false) : PackerNode
        {
            if (useVector)
            {
                var w:int      = int(bitmap.width);
                var h:int      = int(bitmap.height);
                var width:int  = w + (this.horizontalPad * 2);
                var height:int = h + (this.verticalPad   * 2);
                var area:int   = width * height;
                if (area > this.areaFree)
                {
                    return null;
                }

                var node:PackerNode = this.insertNode(this.root, width, height);
                if (node)
                {
                    node.contentX      = node.left + this.horizontalPad;
                    node.contentY      = node.top  + this.verticalPad;
                    node.contentWidth  = w;
                    node.contentHeight = h;
                    node.frameIndex    = 0;
                    node.data          = bitmap;
                    this.areaFree     -= area;
                    this.areaUsed     += area;
                    this.imageCount++;
                    this.bitmap.drawWithQuality(
                        bitmap,
                        new Matrix(1, 0, 0, 1, node.contentX, node.contentY),
                        bitmap.transform.colorTransform,
                        bitmap.blendMode, null, false, StageQuality.BEST);
                }
                return node;
            }
            else return this.addBitmapData(bitmap.bitmapData);
        }

        /**
         * Performs a fast blit of a bitmap into the atlas image.
         * @param data The BitmapData to render into the atlas.
         * @return The PackerNode representing the bitmap, or null.
         */
        public function addBitmapData(data:BitmapData) : PackerNode
        {
            var width:int  = data.width  + (this.horizontalPad * 2);
            var height:int = data.height + (this.verticalPad   * 2);
            var area:int   = width * height;
            if (area > this.areaFree)
            {
                return null;
            }

            var node:PackerNode = this.insertNode(this.root, width, height);
            if (node)
            {
                node.contentX      = node.left + this.horizontalPad;
                node.contentY      = node.top  + this.verticalPad;
                node.contentWidth  = data.width;
                node.contentHeight = data.height;
                node.frameIndex    = 0;
                node.data          = data;
                this.areaFree     -= area;
                this.areaUsed     += area;
                this.imageCount++;
                this.bitmap.copyPixels(data, data.rect, new Point(node.contentX, node.contentY), null, null, true);
            }
            return node;
        }

        /**
         * Renders a single frame of a MovieClip into the atlas image using
         * the vector renderer. The frame is rendered with any transform,
         * color transform and blend mode set on the MovieClip.
         * @param movie The MovieClip to render into the atlas.
         * @param frame The zero-based index of the frame to render.
         * @return The PackerNode representing the frame, or null.
         */
        public function addMovieFrame(movie:MovieClip, frame:int) : PackerNode
        {
            movie.gotoAndStop(frame);
            var w:int      = int(movie.width);
            var h:int      = int(movie.height);
            var width:int  = w + (this.horizontalPad * 2);
            var height:int = h + (this.verticalPad   * 2);
            var area:int   = width * height;
            if (area > this.areaFree)
            {
                return null;
            }

            var node:PackerNode = this.insertNode(this.root, width, height);
            if (node)
            {
                node.contentX      = node.left + this.horizontalPad;
                node.contentY      = node.top  + this.verticalPad;
                node.contentWidth  = w;
                node.contentHeight = h;
                node.frameIndex    = frame;
                node.data          = movie;
                this.areaFree     -= area;
                this.areaUsed     += area;
                this.imageCount++;
                this.bitmap.drawWithQuality(
                    movie,
                    new Matrix(1, 0, 0, 1, node.contentX, node.contentY),
                    movie.transform.colorTransform,
                    movie.blendMode, null, false, StageQuality.BEST);
            }
            return node;
        }

        /**
         * Renders a MovieClip into the atlas image using the vector renderer.
         * Animations should always be added to the atlas first to maximize the
         * chances that all frames will be present on the same atlas image.
         * @param movie The MovieClip to render into the atlas.
         * @return A list of PackerNode instances representing the frames of
         * the movie rendered into the atlas, or null.
         */
        public function addMovieClip(movie:MovieClip) : Vector.<PackerNode>
        {
            var nodeList:Vector.<PackerNode> = new Vector.<PackerNode>();
            for (var i:int = 0; i < movie.totalFrames; ++i)
            {
                var node:PackerNode = this.addMovieFrame(movie, i);
                if (node) nodeList.push(node);
                else break;
            }
            return nodeList;
        }

        /**
         * Renders a vector shape into the atlas image. The shape is rendered
         * with any transform, color transform and blend mode set on the Shape.
         * @param shape The shape to render.
         * @return The PackerNode representing the shape, or null.
         */
        public function addShape(shape:Shape) : PackerNode
        {
            var w:int      = int(shape.width);
            var h:int      = int(shape.height);
            var width:int  = w + (this.horizontalPad * 2);
            var height:int = h + (this.verticalPad   * 2);
            var area:int   = width * height;
            if (area > this.areaFree)
            {
                return null;
            }

            var node:PackerNode = this.insertNode(this.root, width, height);
            if (node)
            {
                node.contentX      = node.left + this.horizontalPad;
                node.contentY      = node.top  + this.verticalPad;
                node.contentWidth  = w;
                node.contentHeight = h;
                node.frameIndex    = 0;
                node.data          = shape;
                this.areaFree     -= area;
                this.areaUsed     += area;
                this.imageCount++;
                this.bitmap.drawWithQuality(
                    shape,
                    new Matrix(1, 0, 0, 1, node.contentX, node.contentY),
                    shape.transform.colorTransform,
                    shape.blendMode, null, false, StageQuality.BEST);
            }
            return node;
        }

        /**
         * Renders a sprite into the atlas image. The sprite is rendered with
         * any transform, color transform and blend mode set on the Sprite.
         * @param sprite The sprite to render.
         * @return The PackerNode representing the sprite, or null.
         */
        public function addSprite(sprite:Sprite) : PackerNode
        {
            var w:int      = int(sprite.width);
            var h:int      = int(sprite.height);
            var width:int  = w + (this.horizontalPad * 2);
            var height:int = h + (this.verticalPad   * 2);
            var area:int   = width * height;
            if (area > this.areaFree)
            {
                return null;
            }

            var node:PackerNode = this.insertNode(this.root, width, height);
            if (node)
            {
                node.contentX      = node.left + this.horizontalPad;
                node.contentY      = node.top  + this.verticalPad;
                node.contentWidth  = w;
                node.contentHeight = h;
                node.frameIndex    = 0;
                node.data          = sprite;
                this.areaFree     -= area;
                this.areaUsed     += area;
                this.imageCount++;
                this.bitmap.drawWithQuality(
                    sprite,
                    new Matrix(1, 0, 0, 1, node.contentX, node.contentY),
                    sprite.transform.colorTransform,
                    sprite.blendMode, null, false, StageQuality.BEST);
            }
            return node;
        }

        /**
         * Disposes of resources associated with this instance.
         */
        public function dispose() : void
        {
            if (this.bitmap)
            {
                this.bitmap.dispose();
                this.bitmap = null
            }
            this.root        = null;
            this.freeList    = null;
            this.areaFree    = 0;
            this.areaUsed    = 0;
            this.imageCount  = 0;
        }
    }
}
