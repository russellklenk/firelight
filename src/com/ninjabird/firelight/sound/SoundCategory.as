package com.ninjabird.firelight.sound
{
    import flash.media.Sound;
    import flash.events.Event;
    import flash.utils.Dictionary;

    /**
     * Represents a category of associated sounds that are currently playing.
     * Do not create instances of this class directly; use the SoundManager
     * instead (see SoundManager.getCategory and SoundManager.play.)
     */
    public final class SoundCategory
    {
        /**
         * The name of the sound category.
         */
        public  var name:String;

        /**
         * The number of sounds currently being played back in this category.
         */
        private var count:int;

        /**
         * The first node in the list of free sound instance nodes. The free
         * list is used to reduce the number of object allocations.
         */
        private var free:SoundInstance;

        /**
         * The first node in the list of currently playing sounds in this
         * category. If there are no playing sounds in this category, this
         * value is null.
         */
        private var head:SoundInstance;

        /**
         * The last node in the list of currently playing sounds in this
         * category. If there are no playing sounds in this category, this
         * value is null.
         */
        private var tail:SoundInstance;

        /**
         * A table mapping Sound to SoundInstance. This table is used to
         * fire events when a sound finishes playing.
         */
        private var soundObjectTable:Dictionary;

        /**
         * The global volume level applied to all sounds in the category.
         */
        private var volume:Number;

        /**
         * The global panning applied to all sounds in the category.
         */
        private var panning:Number;

        /**
         * A value indicating whether playback for the entire sound category
         * is muted.
         */
        private var isMuted:Boolean;

        /**
         * Allocates a list node. This function first attempts to allocate
         * from the free list, and if no nodes are available, falls back to
         * allocate a new node from the heap.
         * @return The allocated node instance.
         */
        private function allocNode() : SoundInstance
        {
            var node:SoundInstance = null;
            if (this.free !== null)
            {
                // allocate from the free list:
                node       = this.free;
                this.free  = node.next;
            }
            else
            {
                // allocate from the system heap:
                node = new SoundInstance();
            }
            return node;
        }

        /**
         * Removes a specific item from the list and lookup tables.
         * @param pos The node representing the item to be removed.
         */
        public function remove(pos:SoundInstance) : void
        {
            var node:SoundInstance = pos;

            if (this.count > 1)
            {
                // the list will be non-empty after removal.
                if (pos !== this.head && pos !== this.tail)
                {
                    node.prev.next = pos.next;
                    node.next.prev = pos.prev;
                    node.next      = this.free;
                    this.free      = node;
                    this.count    -= 1;
                }
                else if (pos === this.head)
                {
                    node.next.prev = null;
                    this.head      = node.next;
                    node.next      = this.free;
                    this.free      = node;
                    this.count    -= 1;
                }
                else if (pos === this.tail)
                {
                    node.prev.next = null;
                    this.tail      = node.prev;
                    node.next      = this.free;
                    this.free      = node;
                    this.count    -= 1;
                }

                // remove from the lookup table.
                this.soundObjectTable[node.sound] = null;
            }
            else if (this.count === 1)
            {
                // the list will be empty after removal.
                this.head       = null;
                this.tail       = null;
                node.next       = this.free;
                this.free       = node;
                this.count      = 0;

                // remove from the lookup table.
                this.soundObjectTable[node.sound] = null;
            }
        }

        /**
         * Callback invoked when a sound instance has finished a single play iteration.
         * @param ev Additional data associated with the event.
         */
        private function handleSoundComplete(ev:Event) : void
        {
            var obj:Sound           = ev.target as Sound;
            var node:SoundInstance  = this.soundObjectTable[obj] as SoundInstance;
            if (node !== null)
            {
                node.loopCount     += 1;
                if (node.loopCount >= node.playCount && node.playCount >= 0)
                {
                    // this sound has truly finished playing.
                    if (node.completeCallback !== null)
                    {
                        // invoke the user-supplied callback (if any).
                        node.completeCallback(node, node.callbackData);
                    }

                    // invalidate the handle:
                    node.handle.invalidate();

                    // remove it from the sound list and tables.
                    this.remove(node);

                    // remove this event handler so we don't leak.
                    node.channel.removeEventListener(Event.SOUND_COMPLETE, this.handleSoundComplete);
                }
                else (node.playCount < 0)
                {
                    // re-start the sound for the next loop.
                    node.channel = node.sound.play(0, 0, node.transform);
                }
            }
        }

        /**
         * Constructs a new named category instance.
         * @param categoryName The name of the sound category.
         */
        public function SoundCategory(categoryName:String)
        {
            if (categoryName === null)
            {
                // use the default category name (an empty string).
                categoryName = SoundManager.DEFAULT_CATEGORY_NAME;
            }
            this.name             = categoryName;
            this.free             = null;
            this.head             = null;
            this.tail             = null;
            this.count            = 0;
            this.soundObjectTable = new Dictionary();
            this.volume           = 1.0;
            this.panning          = 0.0;
            this.isMuted          = false;
        }

        /**
         * Starts playing a new instance of an existing sound.
         * @param id The unique identifier of the sound.
         * @param sound The sound data.
         * @param loopCount The number of times the sound should loop. Less
         * than zero indicates an infinite loop, zero indicates play once.
         * @param soundVolume The playback volume of the sound, in [0, 1].
         * @param soundPanning The panning of the sound, in [-1, +1].
         * @param callback A function (s:SoundInstance, d:*) : void to invoke
         * when sound playback has completed.
         * @param callbackData Optional data to be passed to the callback.
         * @return A SoundHandle that can be used to reference the sound, or null.
         */
        public function play(id:String, sound:Sound, loopCount:int=0, soundVolume:Number=1.0, soundPanning:Number=0.0, callback:Function=null, callbackData:*=undefined) : SoundHandle
        {
            // clamp the volume into [0, 1] and panning into [-1, +1]:
            if (soundVolume  < 0.0) soundVolume  =  0.0;
            if (soundVolume  > 1.0) soundVolume  =  1.0;
            if (soundPanning <-1.0) soundPanning = -1.0;
            if (soundPanning >+1.0) soundPanning = +1.0;

            // allocate and initialize a new node:
            var node:SoundInstance = this.allocNode();
            node.sound             = sound;
            node.soundId           = id;
            node.category          = this;
            node.transform.pan     = soundPanning;
            node.transform.volume  = this.isMuted ? 0.0 : soundVolume * volume;
            node.loopCount         = 0;
            node.playCount         = loopCount >= 0 ? loopCount + 1 : loopCount;
            node.muteVolume        = soundVolume; // unscaled by category
            node.pausePosition     = 0;
            node.isPaused          = false;
            node.completeCallback  = callback;
            node.callbackData      = callbackData;

            // insert the node at the end of the playing sound list:
            if (this.count > 0)
            {
                // inserting at the back of a non-empty list.
                node.next = null;
                node.prev = this.tail;
                this.tail.next = node;
                this.tail      = node;
            }
            else
            {
                // inserting at the back of an empty list.
                node.next = null;
                node.prev = null;
                this.head = node;
                this.tail = node;
            }
            this.count++;

            // insert the node into the lookup table.
            this.soundObjectTable[sound] = node;

            // start the sound playing, and register for
            // notification when it has finished a loop.
            node.channel = sound.play(0, 0, node.transform);
            node.channel.addEventListener(Event.SOUND_COMPLETE, this.handleSoundComplete);

            // create and return a handle to the caller.
            var hand:SoundHandle = new SoundHandle(node);
            node.handle = hand;
            return hand;
        }

        /**
         * Stops playback of a specific sound.
         * @param handle The sound to stop.
         */
        public function stop(handle:SoundHandle) : void
        {
            if (handle !== null && handle.isPlaying)
            {
                // stop playback of the sound and invoke the callback.
                handle.data.channel.stop();
                if (handle.data.completeCallback !== null)
                {
                    // invoke the user-supplied callback (if any).
                    handle.data.completeCallback(handle.data, handle.data.callbackData);
                }

                // remove the sound from the sound list and tables.
                this.remove(handle.data);

                // remove the event handler so we don't leak.
                handle.data.channel.removeEventListener(Event.SOUND_COMPLETE, this.handleSoundComplete);
                handle.invalidate();
            }
        }

        /**
         * Stops playback of all active sounds in the category.
         */
        public function stopAll() : void
        {
            var iter:SoundInstance = this.head;
            while (iter !== null)
            {
                this.stop(iter.handle);
                iter = this.head;
            }
        }

        /**
         * Mutes a single sound.
         * @param handle The sound to mute.
         */
        public function mute(handle:SoundHandle) : void
        {
            if (handle !== null && handle.isPlaying && this.isMuted === false)
            {
                // the value stored in muteVolume does not have the
                // global category volume applied to it, because we'll
                // re-apply the category volume when we un-mute. we
                // do this because the category volume could change in
                // between the muting and unmuting of the sound.
                handle.data.muteVolume = handle.data.transform.volume / this.volume;
                handle.data.transform.volume = 0.0;
            }
        }

        /**
         * Mutes (but continues playing) all sounds in the category.
         */
        public function muteAll() : void
        {
            if (this.isMuted === false)
            {
                var iter:SoundInstance = this.head;
                while (iter !== null)
                {
                    // the value stored in muteVolume does not have the
                    // global category volume applied to it, because we'll
                    // re-apply the category volume when we un-mute. we
                    // do this because the category volume could change in
                    // between the muting and unmuting of the sound.
                    iter.muteVolume = iter.transform.volume / this.volume;
                    iter.transform.volume = 0.0;
                    iter = iter.next;
                }
                this.isMuted = true;
            }
        }

        /**
         * Unmutes a single sound.
         * @param handle The sound to unmute.
         */
        public function unmute(handle:SoundHandle) : void
        {
            if (handle !== null)
            {
                // restore the volume for the sound.
                handle.data.transform.volume = handle.data.muteVolume * this.volume;
            }
        }

        /**
         * Unmutes all sounds, returning them to their previous playback volume.
         */
        public function unmuteAll() : void
        {
            if (this.isMuted === true)
            {
                var    iter:SoundInstance = this.head;
                while (iter !== null)
                {
                    iter.transform.volume = iter.muteVolume * this.volume;
                    iter                  = iter.next;
                }
                this.isMuted = false;
            }
        }

        /**
         * Pauses playback of a specific sound.
         * @param handle The sound to pause.
         */
        public function pause(handle:SoundHandle) : void
        {
            if (handle !== null && handle.isPlaying && handle.data.isPaused === false)
            {
                handle.data.pausePosition = handle.data.channel.position;
                handle.data.isPaused = true;
                handle.data.channel.stop();
            }
        }

        /**
         * Pauses playback of all sounds.
         */
        public function pauseAll() : void
        {
            var iter:SoundInstance = head;
            while (iter !== null)
            {
                if (iter.isPaused === false)
                {
                    iter.pausePosition = iter.channel.position;
                    iter.isPaused = true;
                    iter.channel.stop();
                }
                iter = iter.next;
            }
        }

        /**
         * Resumes playback of a specific sound.
         * @param handle The sound to resume.
         */
        public function resume(handle:SoundHandle) : void
        {
            if (handle !== null && handle.isPlaying && handle.data.isPaused === true)
            {
                var pos:Number            = handle.data.pausePosition;
                handle.data.channel       = handle.data.sound.play(pos, 0, handle.data.transform);
                handle.data.isPaused      = false;
                handle.data.pausePosition = 0.0;
            }
        }

        /**
         * Resumes playback of all paused sounds.
         */
        public function resumeAll() : void
        {
            var iter:SoundInstance = this.head;
            while (iter !== null)
            {
                if (iter.isPaused === true)
                {
                    var pos:Number     = iter.pausePosition;
                    iter.channel       = iter.sound.play(pos, 0, iter.transform);
                    iter.isPaused      = false;
                    iter.pausePosition = 0.0;
                }
                iter = iter.next;
            }
        }

        /**
         * Sets the current pan value for a specific sound.
         * @param handle The sound to modify.
         * @param pan The new pan value in [-1, +1].
         */
        public function setPan(handle:SoundHandle, pan:Number) : void
        {
            if (handle !== null && handle.isPlaying)
            {
                if (pan < -1.0) pan = -1.0;
                if (pan > +1.0) pan = +1.0;
                handle.data.transform.pan = pan;
            }
        }

        /**
         * Sets the pan value for all sounds in the category.
         * @param pan The new pan value in [-1, +1].
         */
        public function setGlobalPan(pan:Number) : void
        {
            if (pan < -1.0) pan = -1.0;
            if (pan > +1.0) pan = +1.0;

            var iter:SoundInstance = this.head;
            while (iter !== null)
            {
                iter.transform.pan = pan;
                iter = iter.next;
            }
            this.panning = pan;
        }

        /**
         * Sets the current volume for a specific sound.
         * @param handle The sound to modify.
         * @param vol The new volume in [0, 1].
         */
        public function setVolume(handle:SoundHandle, vol:Number) : void
        {
            if (handle != null && handle.isPlaying)
            {
                // enforce a minimum volume - use mute if you want to mute.
                if (vol < 0.01) vol = 0.01;
                if (vol > 1.00) vol = 1.00;
                if (this.isMuted === false)
                {
                    handle.data.transform.volume = vol * this.volume;
                    handle.data.muteVolume = vol;
                }
                else
                {
                    handle.data.transform.volume = 0.0;
                    handle.data.muteVolume = vol;
                }
            }
        }

        /**
         * Sets the global volume modifier for all sounds in the category.
         * Individual sounds retain their current volume level, but all
         * sounds are scaled by a category-wide volume.
         * @param vol The new volume in [0, 1].
         */
        public function setGlobalVolume(vol:Number) : void
        {
            // enforce a minimum global volume - use mute if you want to mute.
            if (vol < 0.01) vol = 0.01;
            if (vol > 1.00) vol = 1.00;

            var scale:Number = 1.0 / this.volume;
            var iter:SoundInstance = this.head;
            if (this.isMuted === false)
            {
                while (iter  !== null)
                {
                    // reverse the previous scale, and apply the new scale.
                    var currVolume:Number = iter.transform.volume * scale;
                    iter.transform.volume = currVolume * vol;
                    iter.muteVolume = currVolume;
                    iter = iter.next;
                }
            }
            this.volume = volume;
        }
    }
}
