package com.ninjabird.firelight.content.events
{
    import flash.events.Event;
    import com.ninjabird.firelight.content.ContentSet;

    /**
     * Defines a custom event type raised when all content packages within a
     * content set have loaded successfully.
     */
    public final class ContentSetReadyEvent extends Event
    {
        /**
         * The ContentSet into which the group was loaded.
         */
        public var contentSet:ContentSet;

        /**
         * Constructor function for an event type raised when all of the content within a set is available for runtime use.
         * @param group The content set.
         * @param type The name of the event.
         * @param bubbles true if the event will bubble up.
         * @param cancelable true if the event is cancelable.
         */
        public function ContentSetReadyEvent(group:ContentSet, type:String=ContentEvent.SET_READY, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this.contentSet = group;
        }

        /**
         * Creates a new event instance with the same fields as this instance.
         * @return A new ContentSetReadyEvent instance.
         */
        override public function clone() : Event
        {
            return new ContentSetReadyEvent(this.contentSet, type, bubbles, cancelable);
        }
    }
}
