package com.ninjabird.firelight.renderer.events
{
    import flash.events.Event;

    /**
     * Defines a custom event type raised when a Stage3D rendering context is
     * lost, and should no longer be used by the application.
     */
    public final class ContextLostEvent extends Event
    {
        /**
         * Constructor function for an event type raised when a Stage3D rendering context is lost.
         * @param stage The Stage3D that owns the lost rendering context.
         * @param type The name of the event.
         * @param bubbles true if the event will bubble up.
         * @param cancelable true if the event is cancelable.
         */
        public function ContextLostEvent(type:String=RenderEvents.CONTEXT_LOST, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }

        /**
         * Creates a new event instance with the same fields as this instance.
         * @return A new ContextLostEvent instance.
         */
        override public function clone() : Event
        {
            return new ContextLostEvent(type, bubbles, cancelable);
        }
    }
}
