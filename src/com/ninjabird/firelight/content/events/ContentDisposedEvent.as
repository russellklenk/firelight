package com.ninjabird.firelight.content.events
{
    import flash.events.Event;
    import com.ninjabird.firelight.content.Content;

    /**
     * Defines a custom event type raised when a content item is disposed.
     */
    public final class ContentDisposedEvent extends Event
    {
        /**
         * A reference to the content item being disposed.
         */
        public var content:Content;

        /**
         * Constructor function for an event type raised when a content item is being unloaded or disposed of.
         * @param item The Content item being unloaded.
         * @param type The name of the event.
         * @param bubbles true if the event will bubble up.
         * @param cancelable true if the event is cancelable.
         */
        public function ContentDisposedEvent(item:Content, type:String=ContentEvent.CONTENT_DISPOSED, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this.content = item;
        }

        /**
         * Creates a new event instance with the same fields as this instance.
         * @return A new ContentDisposedEvent instance.
         */
        override public function clone() : Event
        {
            return new ContentDisposedEvent(this.content, type, bubbles, cancelable);
        }
    }
}
