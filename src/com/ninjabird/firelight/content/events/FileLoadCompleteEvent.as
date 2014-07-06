package com.ninjabird.firelight.content.events
{
    import flash.events.Event;

    /**
     * The event data supplied when a content file has been successfully loaded
     * from from the data stored in an archive.
     */
    public final class FileLoadCompleteEvent extends Event
    {
        /**
         * The filename of the loaded file within the archive.
         */
        public var filename:String;

        /**
         * The object containing the runtime-ready version of the data loaded
         * from the archive, for example, a BitmapData instance.
         */
        public var resourceData:*;

        /**
         * Constructor function for an event type raised when a file has been successfully loaded from an archive.
         * @param name The filename of the loaded file within the archive.
         * @param data The runtime data generated by the loader.
         * @param type The name of the event.
         * @param bubbles true if the event will bubble up.
         * @param cancelable true if the event is cancelable.
         */
        public function FileLoadCompleteEvent(file:String, data:*, type:String=ContentEvent.FILE_LOADED, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this.filename     = file;
            this.resourceData = data;
        }

        /**
         * Creates a new event instance with the same fields as this instance.
         * @return A new FileLoadCompleteEvent instance.
         */
        override public function clone() : Event
        {
            return new FileLoadCompleteEvent(this.filename, this.resourceData, type, bubbles, cancelable);
        }
    }
}
