package com.ninjabird.firelight.content.events
{
    import flash.events.Event;

    /**
     * The event data supplied when a resource has failed to load from a remote server.
     */
    public final class ResourceLoadErrorEvent extends Event
    {
        /**
         * An application-defined identifier for the resource request.
         */
        public var requestId:String;

        /**
         * The absolute URL of the resource that was retrieved.
         */
        public var resourceUrl:String;

        /**
         * The relative path of the resource that was retrieved.
         */
        public var resourceName:String;

        /**
         * The resource type returned by the request, one of the constants
         * defined by the flash.net.URLLoaderDataFormat type.
         */
        public var resourceType:String;

        /**
         * A string description of the error that occurred.
         */
        public var errorMessage:String;

        /**
         * Constructor function for an event type raised when a remote resource has failed to download.
         * @param id The application-defined resource request identifier.
         * @param url The full URL of the resource that was retrieved.
         * @param name The relative path of the resource that was retrieved.
         * @param format The data type returned by the request.
         * @param text The error message text.
         * @param type The name of the event.
         * @param bubbles true if the event will bubble up.
         * @param cancelable true if the event is cancelable.
         */
        public function ResourceLoadErrorEvent(id:String, url:String, name:String, format:String, text:String, type:String=ContentEvent.RESOURCE_ERROR, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this.requestId    = id;
            this.resourceUrl  = url;
            this.resourceName = name;
            this.resourceType = format;
            this.errorMessage = text;
        }

        /**
         * Creates a new event instance with the same fields as this instance.
         * @return A new ResourceLoadErrorEvent instance.
         */
        override public function clone() : Event
        {
            return new ResourceLoadErrorEvent(this.requestId, this.resourceUrl, this.resourceName, this.resourceType, this.errorMessage, type, bubbles, cancelable);
        }
    }
}
