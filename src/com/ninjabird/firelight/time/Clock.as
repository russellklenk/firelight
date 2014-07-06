package com.ninjabird.firelight.time
{
    /**
     * Implements a clock, which is attached to a time source. The clock
     * performs clamping to maximum tick duration and tick rate computation.
     */
    public final class Clock
    {
        /**
         * The limit on the maximum tick duration reported, specified in seconds.
         */
        public static const MAXIMUM_TICK_DURATION:Number = 0.500;

        /**
         * The default duration of a tick (30 ticks-per-second).
         */
        public static const DEFAULT_TICK_DURATION:Number = 0.033;

        /**
         * The source used to read time values.
         */
        public var timeSource:TimeSource;

        /**
         * The current accumulated time value on the client, in seconds.
         */
        public var clientTime:Number;

        /**
         * The current accumulated time value on the server, in seconds.
         */
        public var serverTime:Number;

        /**
         * The duration of the previous tick, in seconds.
         */
        public var tickLength:Number;

        /**
         * The value added to the client time in order to compute the server
         * time. This value takes latency into account.
         */
        public var serverTimeOffset:Number;

        /**
         * The maximum tick duration that can be reported.
         */
        public var maximumTickLength:Number;

        /**
         * The minimum observed tick duration.
         */
        public var minimumTickDuration:Number;

        /**
         * The maximum observed tick duration.
         */
        public var maximumTickDuration:Number;

        /**
         * The previous time value returned by the time source, in seconds.
         */
        public var lastTimeValue:Number;

        /**
         * The initial time value returned by the time source, in seconds.
         */
        public var startTimeValue:Number;

        /**
         * The number of times the tick method has been called. This value
         * will wrap around to zero eventually (~414 days at 120 Hz.)
         */
        public var tickCount:uint;

        /**
         * Creates a new Clock instance that reads values from the specified time source.
         * @param source The source of time values for the clock.
         * @param expectedTickDuration The expected duration of a clock tick, in seconds.
         */
        public function Clock(source:TimeSource, expectedTickDuration:Number=Clock.DEFAULT_TICK_DURATION)
        {
            if (expectedTickDuration <= 0.0)
            {
                // use the default tick duration.
                expectedTickDuration  = Clock.DEFAULT_TICK_DURATION;
            }
            this.timeSource           = source;
            this.clientTime           = 0.0;
            this.serverTime           = 0.0;
            this.tickLength           = expectedTickDuration;
            this.serverTimeOffset     = 0.0;
            this.maximumTickLength    = Clock.MAXIMUM_TICK_DURATION;
            this.minimumTickDuration  = 1.000; // 1 sec
            this.maximumTickDuration  = 0.001; // 1 ms
            this.startTimeValue       = source.readCurrentTime();
            this.lastTimeValue        = this.startTimeValue;
            this.tickCount            = 0;
        }

        /**
         * Performs a single clock update.
         */
        public function tick() : void
        {
            var sourceTime:Number = this.timeSource.readCurrentTime();
            var duration:Number   = sourceTime - this.lastTimeValue;

            if (duration > this.maximumTickLength)
            {
                // enforce a maximum tick duration. this is desirable
                // when performing physical simualtions (for example)
                // where too large a time step will cause the physics
                // simulation to explode.
                duration = this.maximumTickLength;
            }

            this.lastTimeValue = sourceTime;
            this.tickLength    = duration;
            this.clientTime   += duration;
            this.serverTime    = this.clientTime + this.serverTimeOffset;
            this.tickCount    += 1;

            // update the minimum/maximum observed tick duration:
            if (this.clientTime > 1.0)
            {
                if (duration < this.minimumTickDuration)
                {
                    this.minimumTickDuration = duration;
                }
                if (duration > this.maximumTickDuration)
                {
                    this.maximumTickDuration = duration;
                }
            }
        }

        /**
         * Resets the minimum and maximum tick durations.
         */
        public function resetMinAndMaxFrameRates() : void
        {
            this.minimumTickDuration = 1.000; // 1 sec
            this.maximumTickDuration = 0.001; // 1 ms
        }

        /**
         * Computes the instantaneous tick rate of the clock (the number of
         * ticks-per-second).
         */
        public function get tickRate() : Number
        {
            return 1.0 / this.tickLength;
        }

        /**
         * Gets the lowest tick rate observed since the clock was started.
         */
        public function get minimumTickRate() : Number
        {
            return 1.0 / this.maximumTickDuration;
        }

        /**
         * Gets the highest tick rate observed since the clock was started.
         */
        public function get maximumFrameRate() : Number
        {
            return 1.0 / this.minimumTickDuration;
        }
    }
}
