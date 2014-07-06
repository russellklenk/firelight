package com.ninjabird.firelight.state
{
    /**
     * Manages a set of events sent to a StateMachine implementation.
     */
    public final class EventBuffer
    {
        /**
         * The set of event identifiers.
         */
        public var eventIds:Vector.<int>;

        /**
         * The set of data associated with the events.
         */
        public var eventData:Vector.<*>;

        /**
         * The number of events in the buffer.
         */
        public var eventCount:int;

        /**
         * Initializes an empty event buffer.
         */
        public function EventBuffer()
        {
            this.eventIds   = new Vector.<int>();
            this.eventData  = new Vector.<*>();
            this.eventCount = 0;
        }

        /**
         * Pushes an event into the buffer.
         * @param id The event identifier.
         * @param data Optional data associated with the event.
         */
        public function push(id:int, data:*=null) : void
        {
            var index:int = this.eventCount;
            this.eventIds [index] = id;
            this.eventData[index] = data;
            this.eventCount++;
        }

        /**
         * Flushes the buffer, setting the number of events to zero.
         */
        public function flush() : void
        {
            this.eventCount = 0;
        }

        /**
         * Disposes of resources associated with the buffer. Events can no
         * longer be added to the buffer.
         */
        public function dispose() : void
        {
            this.eventIds   = null;
            this.eventData  = null;
            this.eventCount = 0;
        }
    }
}
