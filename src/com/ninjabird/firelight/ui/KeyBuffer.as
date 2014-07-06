package com.ninjabird.firelight.ui
{
    /**
     * Represents a dynamic buffer of key states. The key buffer is updated
     * based on key press, down and release events and is then used to
     * generate a final list of key presses.
     */
    public final class KeyBuffer
    {

        /**
         * Pointer to the start of the list of active keys.
         */
        public var listStart:KeyState;

        /**
         * Pointer to the start of the free list.
         */
        public var freeStart:KeyState;

        /**
         * Default Constructor (empty).
         */
        public function KeyBuffer()
        {
            this.listStart = null;
            this.freeStart = null;
        }

        /**
         * Performs an insert-or-update operation on the list indicating that a particular key is in the pressed state.
         * @param keyCode The key code identifier of the key.
         * @return The node representing the key.
         */
        public function pressed(keyCode:uint) : KeyState
        {
            var iter:KeyState = this.listStart;
            var node:KeyState = null;
            var prev:KeyState = null;

            // search for an existing node:
            while (iter !== null)
            {
                if (iter.keyCode === keyCode)
                {
                    // found an existing node for this key.
                    return iter;
                }

                // check the next node:
                prev = iter;
                iter = iter.next;
            }

            // no existing node found; allocate a new node:
            if (this.freeStart === null)
            {
                // empty freelist; allocate from heap:
                node = new KeyState();
            }
            else
            {
                // reuse a node from the freelist:
                node = this.freeStart;
                this.freeStart = node.next;
            }

            // initialize the node and add it to the end of the list:
            node.keyCode   = keyCode;
            node.timestamp = 0.0;
            node.delay     = 0.0;
            node.next      = null;
            if (this.listStart === null)
            {
                // the list is empty.
                this.listStart = node;
            }
            else
            {
                // the list has one or more items. prev is the end.
                prev.next = node;
            }
            return node;
        }

        /**
         * Performs a removal operation indicating that a particular key has been released.
         * @param keyCode The key code identifier of the key.
         */
        public function released(keyCode:uint) : void
        {
            var found:Boolean = false;
            var iter:KeyState = this.listStart;
            var prev:KeyState = null;

            while (iter !== null)
            {
                if (iter.keyCode === keyCode)
                {
                    // we've found the node to remove.
                    if (prev === null)
                    {
                        // the node was at the front of the list:
                        this.listStart = iter.next;
                        found = true;
                    }
                    else
                    {
                        // the node was not at the front of the list:
                        prev.next = iter.next;
                        found = true;
                    }
                    break;
                }

                // check the next node:
                prev = iter;
                iter = iter.next;
            }

            if (found)
            {
                // add the node 'iter' back to the freelist:
                iter.keyCode   = 0;
                iter.timestamp = 0.0;
                iter.delay     = 0.0;
                iter.next      = this.freeStart;
                this.freeStart = iter;
            }
        }

        /**
         * Searches for a particular key in the buffer.
         * @param keyCode The key code identifier of the key.
         * @return The associated key state, or null.
         */
        public function find(keyCode:uint) : KeyState
        {
            var iter:KeyState = this.listStart;
            while (iter !== null)
            {
                if (iter.keyCode === keyCode)
                {
                    return iter;
                }
                iter = iter.next;
            }
            return null;
        }

        /**
         * Removes all items from the key buffer.
         * @param clearFreeList true to also clear the free list.
         */
        public function clear(clearFreeList:Boolean=false) : void
        {
            var iter:KeyState = this.listStart;

            // clear the list of 'used' items:
            while (iter !== null)
            {
                // pop from the front of the list:
                this.listStart  = iter.next;

                // insert at the front of the freelist:
                iter.keyCode    = 0;
                iter.timestamp  = 0.0;
                iter.delay      = 0.0;
                iter.next       = this.freeStart;
                this.freeStart  = iter;
                iter            = this.listStart;
            }

            // also wipe the free list, if instructed:
            if (clearFreeList)
            {
                // just null the reference, no need to traverse.
                this.freeStart = null;
            }
        }

        /**
         * Gets a reference to the first key in the buffer. Returns null if the buffer is empty.
         */
        public function get front() : KeyState
        {
            return this.listStart;
        }

    }
}
