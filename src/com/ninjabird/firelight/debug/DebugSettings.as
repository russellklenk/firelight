package com.ninjabird.firelight.debug
{
    /**
     * Provides a single point of control for global debug settings.
     */
    public final class DebugSettings
    {
        /**
         * Set to true to enable or disable all debug features.
         */
        public static var debugEnabled:Boolean = false;

        /**
         * Set to true to enable or disable trace output from DebugTrace.
         */
        public static var traceEnabled:Boolean = false;
    }
}
