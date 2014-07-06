package com.ninjabird.firelight.renderer.sprite
{
    /**
     * Provides a simple interface used to pool sprite definitions. Sprites can
     * be allocated from the pool and remain valid until the pool is flushed at
     * some application-defined interval. The sprite pool can reduce the number
     * of runtime allocations to minimize garbage collection.
     */
    public final class SpritePool
    {
        /**
         * The pool of sprite instances. Applications that allocate a range of
         * sprites will need to access this collection directly.
         */
        public var sprites:Vector.<SpriteDefinition>;

        /**
         * The current capacity of the sprite pool.
         */
        public var capacity:int;

        /**
         * The number of sprites actively allocated within the pool.
         */
        public var length:int;

        /**
         * The maximum number of sprites ever allocated from within the pool.
         */
        public var highWatermark:int;

        /**
         * Constructs a new pool with the specified initial capacity.
         * @param initialCapacity The initial capacity of the pool.
         */
        public function SpritePool(initialCapacity:int=0)
        {
            this.sprites        = new Vector.<SpriteDefinition>(initialCapacity, false);
            this.capacity       = initialCapacity;
            this.length         = 0;
            this.highWatermark  = 0;
            for (var i:int = 0; i < initialCapacity; ++i)
            {
                this.sprites[i] = new SpriteDefinition();
            }
        }

        /**
         * Changes the capacity of the pool. This operation invalidates any
         * sprite definitions previously allocated from the pool.
         * @param newCapacity The new capacity of the pool.
         */
        public function changeCapacity(newCapacity:int) : void
        {
            this.sprites        = new Vector.<SpriteDefinition>(newCapacity, false);
            this.capacity       = newCapacity;
            this.length         = 0;
            this.highWatermark  = 0;
            for (var i:int = 0; i < newCapacity; ++i)
            {
                this.sprites[i] = new SpriteDefinition();
            }
        }

        /**
         * Allocates a single sprite from the pool.
         * @return The SpriteDefinition.
         */
        public function next() : SpriteDefinition
        {
            if (this.length + 1 > this.highWatermark)
            {
                this.highWatermark = this.length + 1;
            }
            if (this.length < this.capacity)
            {
                return this.sprites[this.length++];
            }
            else
            {
                var sprite:SpriteDefinition = new SpriteDefinition();
                this.sprites[this.length++] = sprite;
                this.capacity++;
                return sprite;
            }
        }

        /**
         * Allocates a number of sprites from the pool.
         * @param count The number of sprites to allocate.
         * @return The zero-based index of the first sprite in the allocated range.
         */
        public function range(count:int) : int
        {
            var index:int       = this.length;
            var newCapacity:int = index + count;
            if (newCapacity > this.capacity)
            {
                for (var i:int = this.capacity; i < newCapacity; ++i)
                {
                    this.sprites[this.capacity++] = new SpriteDefinition();
                }
            }
            this.length += count;
            if (this.length > this.highWatermark)
            {
                this.highWatermark = this.length;
            }
            return index;
        }

        /**
         * Flushes the pool such that no sprites are considered allocated.
         * @param resetWatermark true to reset the high watermark.
         */
        public function flush(resetWatermark:Boolean=false) : void
        {
            if (resetWatermark)
            {
                this.highWatermark = 0;
            }
            this.length = 0;
        }
    }
}
