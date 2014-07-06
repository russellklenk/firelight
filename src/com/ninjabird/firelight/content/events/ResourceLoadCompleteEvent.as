package com.ninjabird.firelight.content.events
{
    import flash.events.Event;

    /**
     * The event data supplied when a resource has been successfully loaded from a remote server.
     */
    public final class ResourceLoadCompleteEvent extends Event
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
         * The data retrieved by the request. This will be one of:
         *  - String, if resourceType is URLLoaderDataFormat.TEXT
         *  - ByteArray, if resourceType is URLLoaderDataFormat.BINARY
         *  - URLVariables, if resourceType is URLLoaderDataFormat.VARIABLES
         */
        public var resourceData:*;

        /**
         * Constructor function for an event type raised when a remote resource has been downloaded successfully.
         * @param id The application-defined resource request identifier.
         * @param url The full URL of the resource that was retrieved.
         * @param name The relative path of the resource that was retrieved.
         * @param format The data type returned by the request.
         * @param data The data returned by the request.
         * @param type The name of the event.
         * @param bubbles true if the event will bubble up.
         * @param cancelable true if the event is cancelable.
         */
        public function ResourceLoadCompleteEvent(id:String, url:String, name:String, format:String, data:*, type:String=ContentEvent.RESOURCE_LOADED, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this.requestId    = id;
            this.resourceUrl  = url;
            this.resourceName = name;
            this.resourceType = format;
            this.resourceData = data;
        }

        /**
         * Creates a new event instance with the same fields as this instance.
         * @return A new ResourceLoadCompleteEvent instance.
         */
        override public function clone() : Event
        {
            return new ResourceLoadCompleteEvent(this.requestId, this.resourceUrl, this.resourceName, this.resourceType, this.resourceData, type, bubbles, cancelable);
        }
    }
}
