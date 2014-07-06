package com.ninjabird.firelight.sound
{
    import flash.media.Sound;

    /**
     * Represents a loaded sound and its associated default playback
     * attributes. Do not create instances of this class directly.
     */
    public final class SoundDefinition
    {
        /**
         * The flash.media.Sound object containing the sound data.
         */
        public var sound:Sound;

        /**
         * The unique asset identifier of the sound.
         */
        public var soundId:String;

        /**
         * The default panning value for playback of this sound. A
         * value of -1 indicates that only the left channel plays;
         * a value of +1 indicates that only the right channel plays,
         * and a value of 0 (the default) indicates balanced playback.
         */
        public var defaultPan:Number;

        /**
         * The default playback volume of the sound. A value of 0 indicates
         * silent, while a value of 1 indicates full volume.
         */
        public var defaultVolume:Number;

        /**
         * The default number of times a sound will loop before stopping. A
         * value of 0 indicates the sound will play once and then stop; a
         * value of &lt; 0 indicates that the sound should play indefinitely;
         * a value of &gt; 0 indicates that the sound should loop the specified
         * number of times and then stop.
         */
        public var defaultLoopCount:int;

        /**
         * The default playback category for the sound. This value may be an
         * empty string, in which case it is part of the default sound
         * playback category.
         */
        public var defaultCategory:String;

        /**
         * Default Constructor (empty).
         */
        public function SoundDefinition()
        {
            this.sound            = null;
            this.soundId          = null;
            this.defaultPan       = 0.0;
            this.defaultVolume    = 1.0;
            this.defaultLoopCount = 0;
            this.defaultCategory  = '';
        }
    }
}
