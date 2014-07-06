package com.ninjabird.firelight.sound
{
    import flash.media.Sound;
    import flash.media.SoundMixer;
    import flash.media.SoundTransform;
    import com.ninjabird.firelight.debug.DebugTrace;

    /**
     * Manages a set of sounds, accessible by name and allows them to play
     * on different sound channels. This class also manages the global
     * volume settings for the application.
     */
    public final class SoundManager
    {
        /**
         * The name of the default sound category.
         */
        public static const DEFAULT_CATEGORY_NAME:String = '';

        /**
         * A table mapping category name to SoundCategory.
         */
        public var categoryTable:Object;

        /**
         * A table mapping sound ID to SoundDefinition.
         */
        public var definitionTable:Object;

        /**
         * The sound transform applied to the global mixer.
         */
        public var globalTransform:SoundTransform;

        /**
         * Default Constructor (empty).
         */
        public function SoundManager()
        {
            this.categoryTable   = new Object();
            this.definitionTable = new Object();
            this.globalTransform = new SoundTransform();
            SoundMixer.soundTransform = globalTransform;
        }

        /**
         * Adds an externally-created sound definition.
         * @param def The sound definition. All fields are validated.
         * @return true if the sound was registered, or false if an error
         * occurred or there is another sound with the same ID.
         */
        public function addSound(def:SoundDefinition) : Boolean
        {
            if (def === null)
            {
                DebugTrace.out('SoundManager::addSound(1) - Invalid definition (null).');
                return false;
            }
            if (def.sound === null)
            {
                DebugTrace.out('SoundManager::addSound(1) - Invalid sound (null).');
                return false;
            }
            if (def.soundId === null || def.soundId.length === 0)
            {
                DebugTrace.out('SoundManager::addSound(1) - Invalid sound ID.');
                return false;
            }

            // clamp volume and panning into a valid range:
            if (def.defaultVolume < 0.0) def.defaultVolume = 0.0;
            if (def.defaultVolume > 1.0) def.defaultVolume = 1.0;
            if (def.defaultPan    <-1.0) def.defaultPan    =-1.0;
            if (def.defaultPan    >+1.0) def.defaultPan    =+1.0;

            // make sure that the default playback category is non-null.
            if (def.defaultCategory === null)
            {
                def.defaultCategory = SoundManager.DEFAULT_CATEGORY_NAME;
            }

            // is there an existing sound with this ID?
            def.soundId  = def.soundId.toUpperCase();
            var existing:SoundDefinition = this.definitionTable[def.soundId] as SoundDefinition;
            if (existing !== null)
            {
                // there's an existing sound with this same ID.
                if (existing.sound === def.sound)
                {
                    // they are the same sound, so return success.
                    return true;
                }
                else
                {
                    // they are not the same sound - fail.
                    DebugTrace.out('SoundManager::addSound(1) - ID collision for \'%s\'.', def.soundId);
                    return false;
                }
            }

            // no existing sound, so register a new one:
            this.definitionTable[def.soundId] = def;
            return true;
        }

        /**
         * Creates a new sound definition.
         * @param id The unique sound ID. This value cannot be null or empty.
         * @param sound The sound data. This value cannot be null.
         * @param loopCount The loop count. Less than zero means loop
         * indefinitely, zero means play once and stop, and greater than zero
         * means loop a specific number of times.
         * @param volume The default playback volume, in [0, 1].
         * @param pan The default panning value, in [-1, +1].
         * @param category The name of the sound category in which the sound is defined.
         * @return The sound definition representing the sound, or null.
         */
        public function createSound(id:String, sound:Sound, loopCount:int=0, volume:Number=1.0, pan:Number=0.0, category:String=null) : SoundDefinition
        {
            if (sound === null)
            {
                DebugTrace.out('SoundManager::createSound(6) - Invalid sound (null).');
                return null;
            }
            if (id === null || sound.length === 0)
            {
                DebugTrace.out('SoundManager::createSound(6) - Invalid sound ID (null).');
                return null;
            }
            if (category === null)
            {
                // use the default category name.
                category = SoundManager.DEFAULT_CATEGORY_NAME;
            }

            var def:SoundDefinition = new SoundDefinition();
            def.sound               = sound;
            def.soundId             = id;
            def.defaultPan          = pan;
            def.defaultVolume       = volume;
            def.defaultLoopCount    = loopCount;
            def.defaultCategory     = category;
            if (this.addSound(def)) return def;
            else return null;
        }

        /**
         * Retrieves a sound definition by sound ID.
         * @param id The sound ID.
         * @return The corresponding SoundDefinition, or null.
         */
        public function sound(id:String) : SoundDefinition
        {
            if (id === null || id.length === 0)
            {
                DebugTrace.out('SoundManager::getSound(1) - Invalid sound ID.');
                return null;
            }
            return this.definitionTable[id.toUpperCase()] as SoundDefinition;
        }

        /**
         * Retrieves a sound category by name, creating a new category if
         * none exists with the specified name.
         * @param name The sound category name.
         * @return The corresponding SoundCategory.
         */
        public function category(name:String) : SoundCategory
        {
            if (name === null)
            {
                // select the default category (an empty string).
                name = SoundManager.DEFAULT_CATEGORY_NAME;
            }
            if (name.length > 0)
            {
                // category names are canonicalized to uppercase.
                name = name.toUpperCase();
            }

            var cat:SoundCategory = this.categoryTable[name] as SoundCategory;
            if (cat === null)
            {
                // create a new category:
                cat = new SoundCategory(name);
                this.categoryTable[name] = cat;
            }
            return cat;
        }

        /**
         * Starts playback of a sound in a specific sound category using the
         * default volume, panning and loop count specified in the sound template.
         * @param id The unique ID of the sound template.
         * @param categoryName The name of the sound category.
         * @param callback A function (s:SoundInstance, d:*) : void invoked
         * when the sound has finished playing.
         * @param callbackData Application-defined data to be passed to the
         * sound completion callback.
         * @return A handle to the sound instance, or null.
         */
        public function play(id:String, categoryName:String=null, callback:Function=null, callbackData:*=undefined) : SoundHandle
        {
            var def:SoundDefinition = this.sound(id);
            var cat:SoundCategory   = null;
            if (def === null)
            {
                DebugTrace.out('SoundManager::play(4) - Unknown sound \'%s\'.', id);
                return null;
            }
            if (categoryName === null)
            {
                // use the default category for the sound.
                categoryName   = def.defaultCategory;
            }
            cat = this.category(categoryName);
            return cat.play(def.soundId, def.sound, def.defaultLoopCount, def.defaultVolume, def.defaultPan, callback, callbackData);
        }

        /**
         * Starts playback of a sound in a specific sound category using a
         * custom volume, panning and loop count.
         * @param id The unique ID of the sound template.
         * @param categoryName The name of the sound category.
         * @param loopCount The number of times the sound should loop. Less
         * than zero indicates an infinite loop, zero indicates play once.
         * @param volume The playback volume of the sound, in [0, 1].
         * @param pan The panning of the sound, in [-1, +1].
         * @param callback A function (s:SoundInstance, d:*) : void invoked
         * when the sound has finished playing.
         * @param callbackData Application-defined data to be passed to the
         * sound completion callback.
         * @return A handle to the sound instance, or null.
         */
        public function playCustom(id:String, categoryName:String=null, loopCount:int=0, volume:Number=1.0, pan:Number=0.0, callback:Function=null, callbackData:*=undefined) : SoundHandle
        {
            var def:SoundDefinition = this.sound(id);
            var cat:SoundCategory   = null;
            if (def === null)
            {
                DebugTrace.out('SoundManager::playCustom(7) - Unknown sound \'%s\'.', id);
                return null;
            }
            if (categoryName === null)
            {
                // use the default category for the sound.
                categoryName   = def.defaultCategory;
            }
            cat = this.category(categoryName);
            return cat.play(def.soundId, def.sound, loopCount, volume, pan, callback, callbackData);
        }

        /**
         * Stops playback of a specific sound.
         * @param handle The sound to stop.
         */
        public function stop(handle:SoundHandle) : void
        {
            if (handle !== null && handle.isPlaying)
            {
                handle.category.stop(handle);
            }
        }

        /**
         * Stops playback of all currently playing sounds.
         */
        public function stopAll() : void
        {
            for each (var category:SoundCategory in this.categoryTable)
            {
                category.stopAll();
            }
        }

        /**
         * Stops playback of all sounds currently playing in a specific
         * sound category.
         * @param categoryName The name of the sound category.
         */
        public function stopCategory(categoryName:String) : void
        {
            var category:SoundCategory = this.category(categoryName);
            category.stopAll();
        }

        /**
         * Mutes a specific sound.
         * @param   handle The sound to mute.
         */
        public function mute(handle:SoundHandle) : void
        {
            if (handle !== null && handle.isPlaying)
            {
                handle.category.mute(handle);
            }
        }

        /**
         * Mutes all currently playing sounds without stopping their playback.
         */
        public function muteAll() : void
        {
            for each (var category:SoundCategory in this.categoryTable)
            {
                category.muteAll();
            }
        }

        /**
         * Mutes all currently playing sounds in a specific category.
         * @param categoryName The name of the sound category.
         */
        public function muteCategory(categoryName:String) : void
        {
            var category:SoundCategory = this.category(categoryName);
            category.muteAll();
        }

        /**
         * Un-mutes a specific sound.
         * @param handle The sound to un-mute.
         */
        public function unmute(handle:SoundHandle) : void
        {
            if (handle !== null && handle.isPlaying)
            {
                handle.category.unmute(handle);
            }
        }

        /**
         * Un-mutes all currently playing sounds without stopping their playback.
         */
        public function unmuteAll() : void
        {
            for each (var category:SoundCategory in this.categoryTable)
            {
                category.unmuteAll();
            }
        }

        /**
         * Un-mutes all currently playing sounds in a specific category.
         * @param categoryName The name of the sound category.
         */
        public function unmuteCategory(categoryName:String) : void
        {
            var category:SoundCategory = this.category(categoryName);
            category.unmuteAll();
        }

        /**
         * Pauses a specific sound.
         * @param handle The sound to pause.
         */
        public function pause(handle:SoundHandle) : void
        {
            if (handle !== null && handle.isPlaying)
            {
                handle.category.pause(handle);
            }
        }

        /**
         * Pauses all currently playing sounds.
         */
        public function pauseAll() : void
        {
            for each (var category:SoundCategory in this.categoryTable)
            {
                category.pauseAll();
            }
        }

        /**
         * Pauses all currently playing sounds in a specific category.
         * @param categoryName The name of the sound category.
         */
        public function pauseCategory(categoryName:String) : void
        {
            var category:SoundCategory = this.category(categoryName);
            category.pauseAll();
        }

        /**
         * Resumes playing a specific paused sound.
         * @param handle The sound to resume.
         */
        public function resume(handle:SoundHandle) : void
        {
            if (handle !== null && handle.isPlaying)
            {
                handle.category.resume(handle);
            }
        }

        /**
         * Resumes all currently paused sounds.
         */
        public function resumeAll() : void
        {
            for each (var category:SoundCategory in this.categoryTable)
            {
                category.resumeAll();
            }
        }

        /**
         * Resume all currently paused sounds in a specific category.
         * @param categoryName The name of the sound category.
         */
        public function resumeCategory(categoryName:String) : void
        {
            var category:SoundCategory = this.category(categoryName);
            category.resumeAll();
        }

        /**
         * Sets the pan value for a specific sound.
         * @param handle The sound to modify.
         * @param pan The new pan value in [-1, +1].
         */
        public function setPan(handle:SoundHandle, pan:Number) : void
        {
            if (handle !== null && handle.isPlaying)
            {
                handle.category.setPan(handle, pan);
            }
        }

        /**
         * Sets the pan value for all sounds in a specific category.
         * @param categoryName The category name.
         * @param pan The new pan value in [-1, +1].
         */
        public function setPanForCategory(categoryName:String, pan:Number) : void
        {
            var category:SoundCategory = this.category(categoryName);
            category.setGlobalPan(pan);
        }

        /**
         * Sets the volume for a specific sound.
         * @param handle The sound to modify.
         * @param volume The new volume in [0, 1].
         */
        public function setVolume(handle:SoundHandle, volume:Number) : void
        {
            if (handle !== null && handle.isPlaying)
            {
                handle.category.setVolume(handle, volume);
            }
        }

        /**
         * Sets the volume for an entire category of sounds. Individual sounds
         * retain their current relative volumes.
         * @param categoryName The category name.
         * @param volume The new volume in [0, 1].
         */
        public function setVolumeForCategory(categoryName:String, volume:Number) : void
        {
            var category:SoundCategory = this.category(categoryName);
            category.setGlobalVolume(volume);
        }

        /**
         * Sets the global pan for all sounds in all categories. Individual
         * sounds and categories retain their current relative pan.
         * @param pan The new global pan value in [-1, +1].
         */
        public function setGlobalPan(pan:Number) : void
        {
            if (pan < -1.0) pan = -1.0;
            if (pan > +1.0) pan = +1.0;
            this.globalTransform.pan      = pan;
            SoundMixer.soundTransform.pan = pan;
        }

        /**
         * Sets the global volume for all sounds in all categories. Individual
         * sounds and categories retain their current relative volume.
         * @param volume The new global volume in [0, 1].
         */
        public function setGlobalVolume(volume:Number) : void
        {
            if (volume < 0.0) volume = 0.0;
            if (volume > 1.0) volume = 1.0;
            this.globalTransform.volume      = volume;
            SoundMixer.soundTransform.volume = volume;
        }

        /**
         * Gets or sets the global pan value. Individual sounds and categories
         * retain their current relative pan.
         */
        public function get globalPan() : Number
        {
            return SoundMixer.soundTransform.pan;
        }
        public function set globalPan(value:Number) : void
        {
            if (value < -1.0) value = -1.0;
            if (value > +1.0) value = +1.0;
            this.globalTransform.pan      = value;
            SoundMixer.soundTransform.pan = value;
        }

        /**
         * Gets or sets the global volume value. Individual sounds and
         * categories retain their current relative volume.
         */
        public function get globalVolume() : Number
        {
            return SoundMixer.soundTransform.volume;
        }
        public function set globalVolume(value:Number) : void
        {
            if (value < 0.0) value = 0.0;
            if (value > 1.0) value = 1.0;
            this.globalTransform.volume      = value;
            SoundMixer.soundTransform.volume = value;
        }
    }
}
