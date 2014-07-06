package com.ninjabird.firelight.renderer.events
{
    import flash.events.Event;

    /**
     * Defines a custom event type raised when a Stage3D rendering context is
     * ready for use by the application.
     */
    public final class ContextReadyEvent extends Event
    {
        /**
         * Constructor function for an event type raised when a Stage3D
         * rendering context becomes available for use by the application.
         * @param type The name of the event.
         * @param bubbles true if the event will bubble up.
         * @param cancelable true if the event is cancelable.
         */
        public function ContextReadyEvent(type:String=RenderEvents.CONTEXT_READY, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }

        /**
         * Creates a new event instance with the same fields as this instance.
         * @return A new ContextReadyEvent instance.
         */
        override public function clone() : Event
        {
            return new ContextReadyEvent(type, bubbles, cancelable);
        }
    }
}
