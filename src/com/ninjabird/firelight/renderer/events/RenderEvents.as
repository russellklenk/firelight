package com.ninjabird.firelight.renderer.events
{
    /**
     * Defines the event identifiers for events raised by the render system.
     */
    public final class RenderEvents
    {
        /**
         * Event raised when the necessary level of Stage3D functionality is not available.
         */
        public static const CONTEXT_CREATION_FAILED:String = 'context:notavailable';

        /**
         * Event raised when the rendering context was lost.
         */
        public static const CONTEXT_LOST:String = 'context:lost';

        /**
         * Event raised when the rendering context is created or restored.
         */
        public static const CONTEXT_READY:String = 'context:ready';
    }
}
