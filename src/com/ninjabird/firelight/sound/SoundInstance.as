package com.ninjabird.firelight.sound
{
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;

    /**
     * Represents an actively playing sound. Do not create instances of this
     * class directly. Instances of this class are created by calling the
     * SoundCategory.play() method.
     */
    public final class SoundInstance
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
         * The handle to this sound instance.
         */
        public var handle:SoundHandle;

        /**
         * The SoundChannel used to control sound playback.
         */
        public var channel:SoundChannel;

        /**
         * The SoundCategory under which this sound is currently playing.
         */
        public var category:SoundCategory;

        /**
         * The SoundTransform used to control playback volume and panning.
         */
        public var transform:SoundTransform;

        /**
         * The number of times this sound has finished playing.
         */
        public var loopCount:int;

        /**
         * The total number of times this sound should play.
         */
        public var playCount:int;

        /**
         * The current volume level at the time the sound was muted. Do not
         * modify this value directly.
         */
        public var muteVolume:Number;

        /**
         * The current playback position at the time the sound was paused. Do
         * not modify this value directly.
         */
        public var pausePosition:Number;

        /**
         * A value indicating whether this sound instance is currently paused.
         * Do not modify this value directly.
         */
        public var isPaused:Boolean;

        /**
         * A function (sender:SoundInstance, data:*) : void to invoke when
         * the sound finishes playing. This value may be null.
         */
        public var completeCallback:Function;

        /**
         * The user-defined data to be passed to the completion callback.
         * The default value is undefined.
         */
        public var callbackData:*;

        /**
         * Pointer to the next playing sound in the category. This value may
         * be null.
         */
        public var next:SoundInstance;

        /**
         * Pointer to the previous playing sound in the category. This value
         * may be null.
         */
        public var prev:SoundInstance;

        /**
         * Default Constructor (empty).
         */
        public function SoundInstance()
        {
            this.sound            = null;
            this.soundId          = null;
            this.handle           = null;
            this.channel          = null;
            this.category         = null;
            this.transform        = new SoundTransform();
            this.loopCount        = 0;
            this.playCount        = 1;
            this.muteVolume       = 1.0;
            this.pausePosition    = 0.0;
            this.completeCallback = null;
            this.callbackData     = undefined;
            this.next             = null;
            this.prev             = null;
        }
    }
}
