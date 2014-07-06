package com.ninjabird.firelight.renderer
{
    import flash.display3D.Context3DProfile;
    import com.ninjabird.firelight.debug.DebugTrace;

    /**
     * Maintains the state data used to manage fallback to a less-capable display context profile.
     */
    public final class FallbackState
    {
        /**
         * The name of the software rendering profile.
         */
        public static const SOFTWARE_PROFILE:String      = 'software';

        /**
         * The list of supported display context profiles, in ascending order by capability level.
         */
        public static const PROFILE_LIST:Vector.<String> = Vector.<String>([
            FallbackState.SOFTWARE_PROFILE,
            Context3DProfile.BASELINE_CONSTRAINED,
            Context3DProfile.BASELINE,
            Context3DProfile.BASELINE_EXTENDED,
            Context3DProfile.STANDARD
        ]);

        /**
         * Indicates whether the software renderer can be used as a fallback if
         * no hardware-accelerated profiles are available.
         */
        public var allowSoftwareFallback:Boolean;

        /**
         * Indicates whether the next fallback profile will be tried.
         */
        public var tryNextProfile:Boolean;

        /**
         * The flash.display3D.Context3DProfile currently under test.
         */
        public var testProfile:String;

        /**
         * The flash.display3D.Context3DProfile used as the fallback in case
         * the profile under test is not available.
         */
        public var nextProfile:String;

        /**
         * The flash.display3D.Context3DProfile specifying the minimum level of
         * functionality acceptable to the application.
         */
        public var minimumProfile:String;

        /**
         * Constructs a new instance initialized to the default state.
         */
        public function FallbackState()
        {
            this.allowSoftwareFallback = true;
            this.tryNextProfile        = true;
            this.testProfile           = Context3DProfile.STANDARD;
            this.nextProfile           = Context3DProfile.BASELINE_EXTENDED;
            this.minimumProfile        = FallbackState.SOFTWARE_PROFILE;
        }

        /**
         * Updates the fallback state to start testing the next step-down in
         * the capability fallback chain.
         * @return true if the next fallback profile can be tested, or false if
         * the profile is not known or would violate the minimum application
         * requirements for display capabilities.
         */
        public function next() : Boolean
        {
            return this.update(this.nextProfile, this.allowSoftwareFallback);
        }

        /**
         * Updates the fallback state to start testing a display profile.
         * @param contextType The display context profile being tested.
         * @param allowSoftware true to allow the software renderer fallback.
         * @return true if the profile @a contextType can be tested, or false
         * if the profile is not known or would violate the minimum application
         * requirements for display capabilities.
         */
        public function update(contextType:String=Context3DProfile.STANDARD, allowSoftware:Boolean=true) : Boolean
        {
            var baseIndex:int = FallbackState.PROFILE_LIST.indexOf(this.minimumProfile);
            var testIndex:int = FallbackState.PROFILE_LIST.indexOf(contextType);
            if (testIndex < 0)
            {
                DebugTrace.out('FallbackState::update(2) - No profile to fall back to. Stage3D is not available.');
                return false;
            }
            if (testIndex < baseIndex)
            {
                DebugTrace.out('FallbackState::update(2) - Profile \'%s\' is less capable than minimum requirement \'%s\'.', contextType, this.minimumProfile);
                return false;
            }

            switch (contextType)
            {
                case Context3DProfile.STANDARD:
                    this.allowSoftwareFallback = allowSoftware;
                    this.tryNextProfile        = true;
                    this.nextProfile           = Context3DProfile.BASELINE_EXTENDED;
                    this.testProfile           = Context3DProfile.STANDARD;
                    break;

                case Context3DProfile.BASELINE_EXTENDED:
                    this.allowSoftwareFallback = allowSoftware;
                    this.tryNextProfile        = true;
                    this.nextProfile           = Context3DProfile.BASELINE;
                    this.testProfile           = Context3DProfile.BASELINE_EXTENDED;
                    break;

                case Context3DProfile.BASELINE:
                    this.allowSoftwareFallback = allowSoftware;
                    this.tryNextProfile        = true;
                    this.nextProfile           = Context3DProfile.BASELINE_CONSTRAINED;
                    this.testProfile           = Context3DProfile.BASELINE;
                    break;

                case Context3DProfile.BASELINE_CONSTRAINED:
                    this.allowSoftwareFallback = allowSoftware;
                    this.tryNextProfile        = true;
                    this.nextProfile           = FallbackState.SOFTWARE_PROFILE;
                    this.testProfile           = Context3DProfile.BASELINE_CONSTRAINED;
                    break;

                case FallbackState.SOFTWARE_PROFILE:
                    this.allowSoftwareFallback = true;
                    this.tryNextProfile        = false;
                    this.nextProfile           = '';
                    this.testProfile           = FallbackState.SOFTWARE_PROFILE;
                    break;

                default:
                    DebugTrace.out('FallbackState::update(2) - Invalid contextType \'%s\'.', contextType);
                    return false;
            }
            return true;
        }
    }
}
