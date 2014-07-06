package com.ninjabird.firelight.renderer.events
{
    import flash.events.Event;

    /**
     * Defines a custom event type raised when a Stage3D rendering context
     * meeting the application's requirements cannot be created.
     */
    public final class ContextCreationFailedEvent extends Event
    {
        /**
         * Additional information about why the context creation failed.
         */
        public var errorMessage:String;

        /**
         * Constructor function for an event type raised when a Stage3D rendering context cannot be created.
         * @param reason Additional information about why the render context could not be created.
         * @param type The name of the event.
         * @param bubbles true if the event will bubble up.
         * @param cancelable true if the event is cancelable.
         */
        public function ContextCreationFailedEvent(reason:String, type:String=RenderEvents.CONTEXT_CREATION_FAILED, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this.errorMessage  = reason;
        }

        /**
         * Creates a new event instance with the same fields as this instance.
         * @return A new ContextCreationFailedEvent instance.
         */
        override public function clone() : Event
        {
            return new ContextCreationFailedEvent(this.errorMessage, type, bubbles, cancelable);
        }
    }
}
