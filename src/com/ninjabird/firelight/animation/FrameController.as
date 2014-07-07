package com.ninjabird.firelight.animation
{
    /**
     * Maintains the state necessary to update the current sprite frame index
     * to match a given time-based playback rate.
     */
    public final class FrameController
    {
        /**
         * The default frame rate, specified in frames-per-second.
         */
        public static const DEFAULT_FRAME_RATE:Number = 30.0;

        /**
         * The controller properties.
         */
        public var config:ControllerProperties;

        /**
         * The last global time value at which the controller was updated.
         */
        public var lastTime:Number;

        /**
         * The desired playback speed, specified in frames-per-second.
         */
        public var frameRate:Number;

        /**
         * The number of frames in the animation sequence.
         */
        public var frameCount:uint;

        /**
         * The zero-based index of the current frame in the animation sequence.
         */
        public var frameIndex:uint;

        /**
         * Default Constructor (empty).
         */
        public function FrameController()
        {
            this.config     = new ControllerProperties(BoundaryBehavior.CLAMP);
            this.lastTime   = 0.0;
            this.frameRate  = FrameController.DEFAULT_FRAME_RATE;
            this.frameCount = 0;
            this.frameIndex = 0;
        }

        /**
         * Sets the number of frames in the animation along with the default playback rate.
         * @param count The number of frames in the animation.
         * @param rate The default playback rate, in frames-per-second.
         */
        public function setAnimationProperties(count:uint, rate:Number) : void
        {
            this.lastTime   = 0.0;
            this.frameRate  = Math.abs(rate);
            this.frameCount = count;
            this.frameIndex = 0;
            this.config.localValue = this.config.lowerBound;
            this.config.upperBound = this.config.lowerBound + (count / rate);
        }

        /**
         * Computes the index of the frame that should be displayed at the a specific time.
         * @param var controllerTime The controller-local time, specified in seconds.
         * @return The zero-based index of the frame to display.
         */
        public function computeFrameIndex(controllerTime:Number) : int
        {
            if (this.frameCount === 0)
                return 0;

            // convert the controller-local time from the range:
            // [config.lowerBound, config.upperBound] to [0, 1].
            var lower:Number    =  this.config.lowerBound;
            var upper:Number    =  this.config.upperBound;
            var normTime:Number = (controllerTime - lower) / (upper - lower);

            // convert back into the range [0, frameCount).
            return int(normTime * (this.frameCount - 1));
        }

        /**
         * Sets the local controller time to a specific value.
         * @param newValue The new local controller time value.
         */
        public function setControllerValue(newValue:Number) : void
        {
            if (newValue <= this.config.lowerBound)
            {
                newValue  = this.config.lowerBound;
                this.frameIndex = 0;
            }
            else if (newValue >= this.config.upperBound)
            {
                newValue = this.config.upperBound;
                if (this.frameCount > 0)
                    this.frameIndex = this.frameCount - 1;
                else
                    this.frameIndex = 0;
            }
            else
            {
                // the value is in the valid range:
                this.frameIndex = this.computeFrameIndex(newValue);
            }
            this.lastTime = 0.0;
            this.config.localValue = newValue;
        }

        /**
         * Computes the current frame index.
         * @param globalTime The global time value, specified in seconds.
         * @return The index of the frame to display.
         */
        public function update(globalTime:Number) : uint
        {
            if (this.config.isActive && (globalTime !== this.lastTime))
            {
                ControllerFunction.evaluate(globalTime, this.config);
                this.frameIndex = this.computeFrameIndex(this.config.localValue);
                this.lastTime   = globalTime;
            }
            return this.frameIndex;
        }

        /**
         * Gets or sets the controller's boundary behavior.
         */
        public function get boundaryBehavior() : int
        {
            return this.config.boundaryBehavior;
        }
        public function set boundaryBehavior(value:int) : void
        {
            this.config.boundaryBehavior = value;
        }

        /**
         * Gets the lower bound of the controller time range. This value is typically zero.
         */
        public function get lowerBound() : Number
        {
            return this.config.lowerBound;
        }

        /**
         * Gets the upper bound of the controller time range. This value is
         * dependent on the frame count and frame rate.
         */
        public function get upperBound() : Number
        {
            return this.config.upperBound;
        }

        /**
         * Gets or sets the local controller time.
         */
        public function get localTime() : Number
        {
            return this.config.localValue;
        }
        public function set localTime(t:Number) : void
        {
            this.setControllerValue(t);
        }

        /**
         * Gets or sets the local controller time offset. The default
         * value is 0.0 (start at the beginning of the sequence).
         */
        public function get timeOffset() : Number
        {
            return this.config.phase;
        }
        public function set timeOffset(value:Number) : void
        {
            this.config.phase = value;
        }

        /**
         * Gets or sets the local controller time multiplier. The default is 1.0 (100% speed).
         */
        public function get timeMultiplier() : Number
        {
            return this.config.frequency;
        }
        public function set timeMultiplier(value:Number) : void
        {
            this.config.frequency = value;
        }

        /**
         * Gets or sets the current animation frame index.
         */
        public function get currentFrame() : uint
        {
            return this.frameIndex;
        }
        public function set currentFrame(value:uint) : void
        {
            var n:int = this.frameCount - 1;

            if (value > n)
            {
                // clamp to the upper bound.
                value = n;
            }

            var upper:Number = this.config.upperBound;
            var lower:Number = this.config.lowerBound;
            this.lastTime    = 0.0;
            this.frameIndex  = value;
            this.config.localValue = ((value * (upper - lower)) / n) + lower;
        }

        /**
         * Gets or sets a value indicating whether the controller is active.
         */
        public function get isActive() : Boolean
        {
            return this.config.isActive;
        }
        public function set isActive(value:Boolean) : void
        {
            this.config.isActive = value;
        }

    }
}
