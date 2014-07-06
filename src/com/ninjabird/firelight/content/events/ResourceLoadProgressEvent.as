package com.ninjabird.firelight.content.events
{
    import flash.events.Event;

    /**
     * The event data supplied when a resource download is in-progress.
     */
    public final class ResourceLoadProgressEvent extends Event
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
         * The number of bytes that have been received.
         */
        public var bytesLoaded:uint;

        /**
         * The number of bytes that represent the complete resource.
         */
        public var bytesTotal:uint;

        /**
         * A number in [0, 100] representing the percentage completion.
         */
        public var percentage:Number;

        /**
         * Constructor function for an event type raised when a remote resource is being downloaded.
         * @param id The application-defined resource request identifier.
         * @param url The full URL of the resource that was retrieved.
         * @param name The relative path of the resource that was retrieved.
         * @param format The data type returned by the request.
         * @param loaded The number of bytes loaded so far.
         * @param total The total number of bytes in the resource.
         * @param type The name of the event.
         * @param bubbles true if the event will bubble up.
         * @param cancelable true if the event is cancelable.
         */
        public function ResourceLoadProgressEvent(id:String, url:String, name:String, format:String, loaded:uint, total:uint, type:String=ContentEvent.RESOURCE_PROGRESS, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this.requestId    = id;
            this.resourceUrl  = url;
            this.resourceName = name;
            this.resourceType = format;
            this.bytesLoaded  = loaded;
            this.bytesTotal   = total;
            if (!total) this.percentage = 99.0;
            else this.percentage = (Number(loaded) / Number(total)) * 100;
        }

        /**
         * Creates a new event instance with the same fields as this instance.
         * @return A new ResourceLoadProgressEvent instance.
         */
        override public function clone() : Event
        {
            return new ResourceLoadProgressEvent(this.requestId, this.resourceUrl, this.resourceName, this.resourceType, this.bytesLoaded, this.bytesTotal, type, bubbles, cancelable);
        }
    }
}
