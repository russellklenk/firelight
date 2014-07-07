package com.ninjabird.firelight.animation
{
    import com.ninjabird.firelight.animation.keyframes.KeyframePair;

    /**
     * Implements a controller that stores a series of keyframes, and determines the current pair of active keyframes.
     * The keyframe data is maintained externally. This controller only determines the active keys based on time.
     */
    public final class KeyframeController
    {
        /**
         * The controller properties.
         */
        public var config:ControllerProperties;

        /**
         * The last global time value at which the controller was updated.
         */
        public var lastTime:Number;

        /**
         * A list of Number specifying the keyframe times (one per-keyframe).
         */
        public var keyframes:Vector.<Number>;

        /**
         * The zero-based index of the lower-bound keyframe.
         */
        public var lowerBound:uint;

        /**
         * Constructs a new instance initialized with the specified set of keyframe time values.
         * @param times An Array of Number specifying the controller time values at each key.
         */
        public function KeyframeController(times:Vector.<Number>=null)
        {
            this.config = new ControllerProperties(BoundaryBehavior.CLAMP);
            this.setKeyTimes(times);
        }

        /**
         * Searches for the index of the lower-bound keyframe around a specific time value.
         * @param time The time value to search for.
         * @return The zero-based index of the lower-bound keyframe.
         */
        public function findLowerBoundKey(time:Number) : uint
        {
            var keys:Vector.<Number> = this.keyframes;
            if (keys === null || keys.length === 0)
            {
                // no keyframe time values set:
                return 0;
            }

            var lower:int = 0;
            var upper:int = keys.length - 1;

            // key times are in ascending order; perform a binary search.
            while (upper - lower > 1)
            {
                var midpoint:int   = (upper + lower) / 2;
                var midtime:Number = keys[midpoint];

                if (time > midtime)
                {
                    // adjust the lower bound:
                    lower = midpoint;
                }
                else if (time < midtime)
                {
                    // adjust the upper bound:
                    upper = midpoint;
                }
                else
                {
                    // time was exactly a key time:
                    lower = midpoint;
                    break;
                }
            }
            return uint(lower);
        }

        /**
         * Performs a simple test to potentially update the current lower-bound keyframe value.
         * Relies on the fact that keyframes are accessed in order, so no complex searching is required.
         * @param controllerTime The current controller time value.
         * @return The zero-based index of the lower-bound keyframe.
         */
        public function updateLowerBoundKey(controllerTime:Number) : uint
        {
            var keys:Vector.<Number> = this.keyframes;
            if (keys === null || keys.length === 0)
            {
                // no keyframe time values set:
                return 0;
            }

            var index:uint  = this.lowerBound;
            var maxIdx:uint = keys.length - 1;

            // we're looking for the first keyframe with time LESS
            // than the controllerTime value (not <=):
            if (controllerTime > keys[index])
            {
                while (index < maxIdx && controllerTime > keys[index + 1])
                {
                    ++index;
                }
            }
            else
            {
                while (index > 0 && controllerTime <= keys[index])
                {
                    --index;
                }
            }
            return index;
        }

        /**
         * Sets the current controller value to an arbitrary value.
         * @param newValue The controller's new value.
         */
        public function setControllerValue(newValue:Number) : void
        {
            if (newValue <= this.config.lowerBound)
            {
                newValue  = this.config.lowerBound;
                this.lowerBound = 0;
            }
            else if (newValue >= this.config.upperBound)
            {
                newValue  = this.config.upperBound;
                this.lowerBound = this.keyframes.length - 1;
            }
            else
            {
                // the value is in the valid range:
                this.lowerBound = this.findLowerBoundKey(newValue);
            }
            this.lastTime = 0.0;
            this.config.localValue = newValue;
        }

        /**
         * Sets the keyframe times and resets the keyframe iterators.
         * @param times An Array of Number specifying the controller time values at each key.
         */
        public function setKeyTimes(times:Vector.<Number>) : void
        {
            this.lastTime   = 0.0;
            this.lowerBound = 0;
            if (times != null && times.length > 0)
            {
                this.keyframes         = times;
                this.config.lowerBound = times[0];
                this.config.upperBound = times[times.length - 1];
                this.config.localValue = times[0];
            }
            else
            {
                this.keyframes         = new Vector.<Number>();
                this.config.lowerBound = 0.0;
                this.config.upperBound = 0.0;
                this.config.localValue = 0.0;
            }
        }

        /**
         * Updates the controller and potentially recomputes the current keyframe indices.
         * @param globalTime The global time value, specified in seconds.
         * @param keyPair On return, stores information about the current pair of keyframes.
         */
        public function update(globalTime:Number, keyPair:KeyframePair = null) : void
        {
            if (this.config.isActive && (globalTime !== this.lastTime))
            {
                ControllerFunction.evaluate(globalTime, this.config);
                this.lowerBound  = this.updateLowerBoundKey(this.config.localValue);
                this.lastTime    = globalTime;
            }
            this.getCurrentKeyframes(keyPair);
        }

        /**
         * Obtains the current pair of keyframes.
         * @param keyPair The object to update with keyframe pair information.
         */
        public function getCurrentKeyframes(keyPair:KeyframePair) : void
        {
            if (keyPair != null)
            {
                var keys:Vector.<Number> = this.keyframes;
                if (keys === null || keys.length === 0)
                {
                    keyPair.lowerIndex     = 0;
                    keyPair.upperIndex     = 1;
                    keyPair.lowerTime      = 0.0;
                    keyPair.upperTime      = 1.0;
                    keyPair.normalizedTime = 0.0;
                }
                else
                {
                    keyPair.lowerIndex     = this.lowerBound;
                    keyPair.upperIndex     = this.lowerBound + 1;
                    keyPair.lowerTime      = keys[this.lowerBound];
                    keyPair.upperTime      = keys[this.lowerBound + 1];
                    keyPair.normalizedTime =((this.config.localValue - keyPair.lowerTime) / (keyPair.upperTime - keyPair.lowerTime));
                    if (keyPair.normalizedTime < 0.0)
                    {
                        keyPair.normalizedTime = 0.0;
                    }
                    if (keyPair.normalizedTime > 1.0)
                    {
                        keyPair.normalizedTime = 1.0;
                    }
                }
            }
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
         * Gets the upper bound of the controller time range. This value is dependent on the frame count and frame rate.
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
         * Gets or sets the local controller time offset. The default value is 0.0 (start at the beginning of the sequence).
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
         * Gets or sets the local controller time multiplier. The default value is 1.0 (100% speed).
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

        /**
         * Gets an array of Number specifying the controller time values at each keyframe.
         */
        public function get keyframeTimes() : Vector.<Number>
        {
            return this.keyframes;
        }

        /**
         * Gets the number of keyframes.
         */
        public function get keyframeCount() : int
        {
            if (this.keyframes !== null) return this.keyframes.length;
            else return 0;
        }
    }
}
