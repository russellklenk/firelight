package com.ninjabird.firelight.content.events
{
    import flash.events.Event;

    /**
     * The event data supplied when a content package cannot be loaded.
     */
    public final class ContentPackageErrorEvent extends Event
    {
        /**
         * The friendly name of the content package.
         */
        public var packageName:String;

        /**
         * A description of the error that occurred.
         */
        public var errorMessage:String;

        /**
         * Constructor function for an event type raised when a content package cannot be loaded.
         * @param error A brief description of the error.
         * @param type The name of the event.
         * @param bubbles true if the event will bubble up.
         * @param cancelable true if the event is cancelable.
         */
        public function ContentPackageErrorEvent(error:String, type:String=ContentEvent.PACKAGE_ERROR, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this.errorMessage = error;
        }

        /**
         * Creates a new event instance with the same fields as this instance.
         * @return A new ContentPackageErrorEvent instance.
         */
        override public function clone() : Event
        {
            return new ContentPackageErrorEvent(this.errorMessage, type, bubbles, cancelable);
        }
    }
}
