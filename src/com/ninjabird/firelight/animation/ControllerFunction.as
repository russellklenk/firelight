package com.ninjabird.firelight.animation
{
    import com.ninjabird.firelight.animation.ControllerFunction;
    import com.ninjabird.firelight.animation.ControllerFunction;
    import com.ninjabird.firelight.animation.ControllerFunction;

    /**
     * Defines evaluators for all of the predefined controller boundary behaviors.
     * User-defined callbacks have the form:
     * function (globalValue:Number, cp:ControllerProperties) : void
     * and should update the localValue field of the ControllerProperties class.
     */
    public final class ControllerFunction
    {
        /**
         * Transforms global time into local time for a controller without normalization or regard to boundary behavior.
         * @param globalValue The global time value.
         * @param config Controller properties.
         * @return The transformed local time value.
         */
        public static function getControllerValue(globalValue:Number, config:ControllerProperties) : Number
        {
            // this is manually-inlined in the built-in evaluators.
            return (globalValue * config.frequency + config.phase);
        }

        /**
         * Normalizes a controller's localValue so it falls in the range [0, 1].
         * @param config Controller properties.
         * @return The normalized localValue for the controller, in [0, 1].
         */
        public static function normalize(config:ControllerProperties) : Number
        {
            return (config.localValue - config.lowerBound) / (config.upperBound - config.lowerBound);
        }

        /**
         * Transforms a value in the range [minValue, maxValue] into a value in the range [0, 1].
         * @param value The value to normalize.
         * @param minValue The minimum range value.
         * @param maxValue The maximum range value.
         * @return The normalized value in [0, 1].
         */
        public static function normalizeValue(value:Number, minValue:Number, maxValue:Number) : Number
        {
            return ((value - minValue) / (maxValue - minValue));
        }

        /**
         * Transforms global time into local time for a controller with CONSTANT boundary behavior.
         * @param globalValue The global time value.
         * @param config Controller properties.
         */
        public static function evaluateConstant(globalValue:Number, config:ControllerProperties) : void
        {
            config.localValue = config.constantValue;
            if (config.localValue < config.lowerBound)
            {
                config.localValue = config.lowerBound;
            }
            if (config.localValue > config.upperBound)
            {
                config.localValue = config.upperBound;
            }
        }

        /**
         * Transforms global time into local time and applies clamping behavior.
         * @param globalValue The global time value.
         * @param config Controller properties.
         */
        public static function evaluateClamp(globalValue:Number, config:ControllerProperties) : void
        {
            var cv:Number = globalValue * config.frequency + config.phase;
            if (cv < config.lowerBound)
            {
                config.localValue = config.lowerBound;
            }
            else if (cv > config.upperBound)
            {
                config.localValue = config.upperBound;
            }
            else
            {
                config.localValue = cv;
            }
        }

        /**
         * Transforms global time into local time and applies looping behavior.
         * @param globalValue The global time value.
         * @param config Controller properties.
         */
        public static function evaluateWrap(globalValue:Number, config:ControllerProperties) : void
        {
            var cv:Number    = globalValue * config.frequency + config.phase;
            var range:Number = config.upperBound - config.lowerBound;
            if (range > 0.0)
            {
                var multiples:Number = (cv - config.lowerBound) / range;
                var wholePart:Number = Math.floor(multiples);
                var fracPart:Number  = multiples - wholePart;
                config.localValue    = config.lowerBound + fracPart * range;
            }
            else config.localValue   = config.lowerBound;
        }

        /**
         * Transforms global time into local time and applies reverse-looping behavior.
         * @param globalValue The global time value.
         * @param config Controller properties.
         */
        public static function evaluateCycle(globalValue:Number, config:ControllerProperties) : void
        {
            var cv:Number    = globalValue * config.frequency + config.phase;
            var range:Number = config.upperBound - config.lowerBound;
            if (range > 0.0)
            {
                var multiples:Number = (cv - config.lowerBound) / range;
                var wholePart:Number = Math.floor(multiples);
                var fracPart:Number  = multiples - wholePart;
                if (((int(wholePart)) & 1) !== 0)
                {
                    // the sequence is playing backwards:
                    config.localValue = config.upperBound - fracPart * range;
                }
                else
                {
                    // the sequence is playing forwards:
                    config.localValue = config.lowerBound + fracPart * range;
                }
            }
            else config.localValue = config.lowerBound;
        }

        /**
         * Transforms global time into local time and applies the appropriate interval boundary behavior.
         * @param globalValue The global time value.
         * @param config Controller properties.
         * @param customFunction A user-supplied function called when the behavior type is CUSTOM.
         * function (globalTime:Number, config:ControllerProperties) : void
         */
        public static function evaluate(globalValue:Number, config:ControllerProperties, customFunction:Function=null) : void
        {
            switch (config.boundaryBehavior)
            {
                case BoundaryBehavior.CONSTANT:
                    ControllerFunction.evaluateConstant(globalValue, config);
                    break;
                case BoundaryBehavior.CLAMP:
                    ControllerFunction.evaluateClamp(globalValue, config);
                    break;
                case BoundaryBehavior.WRAP:
                    ControllerFunction.evaluateWrap(globalValue, config);
                    break;
                case BoundaryBehavior.CYCLE:
                    ControllerFunction.evaluateCycle(globalValue, config);
                    break;
                case BoundaryBehavior.CUSTOM:
                    customFunction(globalValue, config);
                    break;
            }
        }
    }
}
