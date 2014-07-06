package com.ninjabird.firelight.time
{
    import flash.utils.getTimer;

    /**
     * Implements the TimeSource interface to provide time values based on the
     * flash.utils.getTimer API.
     */
    public final class FlashTimeSource implements TimeSource
    {
        /**
         * The previous tick count, used to detect timer wrap-around.
         */
        private var previousTicks:int;

        /**
         * The current tick count, as returned by the most recent call to the
         * flash.utils.getTimer API.
         */
        private var currentTicks:int;

        /**
         * The current time value, in seconds.
         */
        public  var currentTime:Number;

        /**
         * Default constructor. Initializes all fields to zero.
         */
        public function FlashTimeSource()
        {
            this.previousTicks = 0;
            this.currentTicks  = 0;
            this.currentTime   = 0.0;
        }

        /**
         * Reads the current time value.
         * @return The current timestamp, specified in seconds.
         */
        public function readCurrentTime() : Number
        {
            // the getTimer API returns values in milliseconds as a signed
            // 32-bit integer value, which means that it will wrap around
            // after approximately 25 days. detect and handle this case.
            this.previousTicks = this.currentTicks;
            this.currentTicks  = getTimer();

            if (this.previousTicks > this.currentTicks)
            {
                // the counter has wrapped around. add the bit of time between
                // the previous tick count and the max unsigned integer value.
                this.currentTicks += (4294967295 - this.previousTicks);
                this.previousTicks =  0;
            }

            var elapsed:uint  = this.currentTicks - this.previousTicks;
            this.currentTime += elapsed * 0.001;
            return this.currentTime;
        }
    }
}
