package com.ninjabird.firelight.content.events
{
    import flash.events.Event;

    /**
     * The event data supplied when a content package is fully loaded, and the
     * content items are ready for runtime use.
     */
    public final class ContentPackageLoadedEvent extends Event
    {
        /**
         * Constructor function for an event type raised when a content package
         * has been fully loaded, and its content items are ready for use.
         * @param type The name of the event.
         * @param bubbles true if the event will bubble up.
         * @param cancelable true if the event is cancelable.
         */
        public function ContentPackageLoadedEvent(type:String=ContentEvent.PACKAGE_LOADED, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }

        /**
         * Creates a new event instance with the same fields as this instance.
         * @return A new ContentPackageLoadedEvent instance.
         */
        override public function clone() : Event
        {
            return new ContentPackageLoadedEvent(type, bubbles, cancelable);
        }
    }
}
