package com.ninjabird.firelight.content.events
{
    import flash.events.Event;
    import com.ninjabird.firelight.content.ContentSet;

    /**
     * Defines a custom event type raised when an error occurs while loading,
     * parsing or loading data from a content package.
     */
    public final class ContentSetErrorEvent extends Event
    {
        /**
         * The content set being loaded.
         */
        public var contentSet:ContentSet;

        /**
         * The name of the package that was being loaded.
         */
        public var packageName:String;

        /**
         * A text description of the error.
         */
        public var errorMessage:String;

        /**
         * Constructor function for an event type raised when an error occurs while loading a content package.
         * @param group The content set that owns the failed package.
         * @param friendlyName The name of the content package being loaded.
         * @param error A description of the error.
         * @param type The name of the event.
         * @param bubbles true if the event will bubble up.
         * @param cancelable true if the event is cancelable.
         */
        public function ContentSetErrorEvent(group:ContentSet, friendlyName:String, error:String, type:String=ContentEvent.SET_ERROR, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this.contentSet   = group;
            this.packageName  = friendlyName;
            this.errorMessage = error;
        }

        /**
         * Creates a new event instance with the same fields as this instance.
         * @return A new ContentSetErrorEvent instance.
         */
        override public function clone() : Event
        {
            return new ContentSetErrorEvent(this.contentSet, this.packageName, this.errorMessage, type, bubbles, cancelable);
        }
    }
}
