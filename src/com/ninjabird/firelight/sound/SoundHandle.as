package com.ninjabird.firelight.sound
{
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;

    /**
     * Provides a level of indirection for sound playback. A sound handle
     * may remain valid when the sound it represents has finished playing.
     */
    public final class SoundHandle
    {

        /**
         * A reference to the underlying sound instance. When the underlying
         * SoundInstance is invalidated (because it has finished playing or
         * is explicitly stopped), this value is set to null.
         */
        public var data:SoundInstance;

        /**
         * A reference to the sound data for the sound. This reference
         * remains valid even if the handle is invalidated.
         */
        public var sound:Sound;

        /**
         * The unique sound identifier associated with the sound. This field
         * remains valid even if the handle is invalidated.
         */
        public var soundId:String;

        /**
         * The category under which the sound is playing. This field remains
         * valid even if the handle is invalidated.
         */
        public var category:SoundCategory;

        /**
         * The number of times the sound will play. This field remains valid
         * even if the handle is invalidated. Values less than zero indicate
         * that the sound loops indefinitely; zero indicates that the sound
         * plays once and stops, and greater than zero indicates that the
         * sound loops a finite number of times.
         */
        public var playCount:int;

        /**
         * A value indicating whether the sound is currently playing. The
         * handle is valid only as long as the sound is playing.
         */
        public var isPlaying:Boolean;

        /**
         * Constructs a new handle instance attached to the specified sound playback data.
         * @param instance The sound instance.
         */
        public function SoundHandle(instance:SoundInstance)
        {
            this.data      = instance;
            this.sound     = instance.sound;
            this.soundId   = instance.soundId;
            this.category  = instance.category;
            this.playCount = instance.playCount;
            this.isPlaying = true;
        }

        /**
         * Marks the handle as invalid. This method is called by SoundCategory
         * when the sound has finished playing, or is explicitly stopped.
         */
        public function invalidate() : void
        {
            this.data      = null;
            this.isPlaying = false;
        }

        /**
         * Gets a reference to the SoundChannel associated with the playing
         * sound. If the sound has finished playing, the return value is null.
         */
        public function get channel() : SoundChannel
        {
            if (this.data !== null) return this.data.channel;
            else return null;
        }

        /**
         * Gets a reference to the SoundTransform used to control playback
         * volume and panning. If the sound has finished playing, the return
         * value is null.
         */
        public function get transform() : SoundTransform
        {
            if (this.data !== null) return this.data.transform;
            else return null;
        }

        /**
         * Gets the number of times the sound has played. If the sound has
         * finished playing, the return value is the playCount field.
         */
        public function get loopCount() : int
        {
            if (this.data !== null) return this.data.loopCount;
            else return this.playCount;
        }

        /**
         * Gets a value indicating whether the sound is currently paused. If
         * the sound has finished playing, the return value is false.
         */
        public function get isPaused() : Boolean
        {
            if (this.data !== null) return this.data.isPaused;
            else return false;
        }
    }
}
