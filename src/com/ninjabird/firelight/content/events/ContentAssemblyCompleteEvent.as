package com.ninjabird.firelight.content.events
{
    import flash.events.Event;
    import com.ninjabird.firelight.content.Content;

    /**
     * The event data supplied when a content item is fully assembled and ready for use.
     */
    public final class ContentAssemblyCompleteEvent extends Event
    {
        /**
         * The content item being assembled.
         */
        public var content:Content;

        /**
         * Constructor function for an event type raised when a content item is fully assembled and ready for use.
         * @param contentItem The content item being assembled.
         * @param type The name of the event.
         * @param bubbles true if the event will bubble up.
         * @param cancelable true if the event is cancelable.
         */
        public function ContentAssemblyCompleteEvent(contentItem:Content, type:String=ContentEvent.ASSEMBLY_COMPLETE, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this.content = contentItem;
        }

        /**
         * Creates a new event instance with the same fields as this instance.
         * @return A new ContentAssemblyCompleteEvent instance.
         */
        override public function clone() : Event
        {
            return new ContentAssemblyCompleteEvent(this.content, type, bubbles, cancelable);
        }
    }
}
