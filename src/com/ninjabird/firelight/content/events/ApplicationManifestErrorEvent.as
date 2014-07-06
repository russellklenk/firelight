package com.ninjabird.firelight.content.events
{
    import flash.events.Event;
    import com.ninjabird.firelight.content.ContentLoader;
    import com.ninjabird.firelight.content.ContentPackage;

    /**
     * Defines a custom event type raised when the application content manifest
     * transfer encounters an error.
     */
    public final class ApplicationManifestErrorEvent extends Event
    {
        /**
         * The URL representing the application manifest resource on the server.
         */
        public var requestUrl:String;

        /**
         * A string description of the error that occurred.
         */
        public var errorMessage:String;

        /**
         * Constructor function for an event type raised when the application manifest cannot be downloaded or parsed.
         * @param url The application manifest URL.
         * @param error The error message.
         * @param type The name of the event.
         * @param bubbles true if the event will bubble up.
         * @param cancelable true if the event is cancelable.
         */
        public function ApplicationManifestErrorEvent(url:String, error:String, type:String=ContentEvent.MANIFEST_ERROR, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this.requestUrl   = url;
            this.errorMessage = error;
        }

        /**
         * Creates a new event instance with the same fields as this instance.
         * @return A new ApplicationManifestErrorEvent instance.
         */
        override public function clone() : Event
        {
            return new ApplicationManifestErrorEvent(this.requestUrl, this.errorMessage, type, bubbles, cancelable);
        }
    }
}
