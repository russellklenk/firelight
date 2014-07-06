package com.ninjabird.firelight.renderer
{
    import flash.events.Event;
    import flash.events.ErrorEvent;
    import flash.events.EventDispatcher;
    import flash.display.Stage;
    import flash.display.Stage3D;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProfile;
    import flash.display3D.Context3DRenderMode;
    import com.ninjabird.firelight.debug.DebugTrace;
    import com.ninjabird.firelight.renderer.events.ContextLostEvent;
    import com.ninjabird.firelight.renderer.events.ContextReadyEvent;
    import com.ninjabird.firelight.renderer.events.ContextCreationFailedEvent;

    /**
     * Manages the creation and tracking of the Stage3D and Context3D display
     * context. This class can create the best available context, and is also
     * able to track and report context loss events.
     */
    public final class DisplayContext extends EventDispatcher
    {
        /**
         * Tests the runtime to determine whether Stage3D is supported. This
         * test should be performed after the main Sprite or MovieClip has been
         * added to the stage and notified via the ADDED_TO_STAGE event.
         * @param stage The main Stage display object.
         * @return true if the runtime supports Stage3D functionality.
         */
        public static function supportsStage3D(stage:Stage) : Boolean
        {
            if (stage) return stage.hasOwnProperty('stage3Ds');
            else return false;
        }

        /**
         * Tests a flash.display3D.Context3D to determine whether it is lost.
         * @param context The context to test.
         * @return true if the specified context is lost or disposed.
         */
        public static function testContextLost(context:Context3D) : Boolean
        {
            if (context) return context.driverInfo === 'Disposed' ? true : false;
            else return true;
        }

        /**
         * Tests a flash.display3D.Context3D to determine whether it is using
         * the software renderer fallback.
         * @param context The context to test.
         * @return true if the specified context is using software rendering.
         */
        public static function testSoftwareRenderer(context:Context3D) : Boolean
        {
            if (context) return context.driverInfo.indexOf('Software') === 0;
            else return false;
        }

        /**
         * Tests a flash.display3D.Context3D to determine whether it is using
         * hardware-accelerated rendering.
         * @param context The context to test.
         * @return true if the specified context is using GPU hardware.
         */
        public static function testHardwareRenderer(context:Context3D) : Boolean
        {
            if (context) return context.driverInfo.indexOf('Software') === -1;
            else return false;
        }

        /**
         * The unique display context identifier. Some platforms support more
         * than one Stage3D being active at the same time.
         */
        public var id:int;

        /**
         * The main application stage.
         */
        public var stage2d:Stage;

        /**
         * The flash.display.Stage3D used to request rendering contexts.
         */
        public var stage3d:Stage3D;

        /**
         * The active rendering context.
         */
        public var context3d:Context3D;

        /**
         * Fallback state required during fallback conditions when the best
         * available rendering context is requested.
         */
        public var fallback:FallbackState;

        /**
         * The name of the rendering context profile, or an empty string.
         */
        public var profile:String;

        /**
         * Indicates whether the rendering context has been lost.
         */
        public var isContextLost:Boolean;

        /**
         * Callback invoked when a new Context3D is created. This is used to detect a lost context event.
         * @param ev Additional information about the event.
         */
        private function handleContextCreated(ev:Event) : void
        {
            var stage:Stage3D = ev.target as Stage3D;

            if (this.context3d)
            {
                DebugTrace.out('DisplayContext::handleContextCreated(1) - Detected context loss.');
                this.notifyContextLost();
            }

            if (DisplayContext.testSoftwareRenderer(stage.context3D))
            {
                var fallback:FallbackState = this.fallback;
                if (fallback.testProfile !== FallbackState.SOFTWARE_PROFILE)
                {
                    if (fallback.next())
                    {
                        var profileName:String    = fallback.testProfile;
                        var allowSoftware:Boolean = fallback.allowSoftwareFallback;
                        this.createBestAvailableContext(profileName, allowSoftware);
                    }
                    else
                    {
                        this.notifyContextCreationFailed('No acceptable Stage3D rendering context available.');
                        return;
                    }
                }
                // else, we got the software fallback, and this is acceptable.
            }

            DebugTrace.out('DisplayContext::handleContextCreated(1) - Created with profile %s.', this.fallback.testProfile);
            this.profile   = stage.context3D.profile;
            this.context3d = stage.context3D;
            this.notifyContextReady();
        }

        /**
         * Callback invoked when a rendering context cannot be created. This
         * typically occurs when the wmode is not set to direct.
         * @param ev Additional information about the event.
         */
        private function handleContextCreationError(ev:ErrorEvent) : void
        {
            DebugTrace.out('DisplayContext::handleContextCreationError(1): %s (%d).', ev.text, ev.errorID);
            this.notifyContextCreationFailed(ev.text);
        }

        /**
         * Notifies registered listeners that the attached rendering context
         * has been created or restored.
         */
        private function notifyContextReady() : void
        {
            this.isContextLost = false;
            this.dispatchEvent(new ContextReadyEvent());
        }

        /**
         * Notifies registered listeners that a rendering context meeting the
         * application's requirements cannot be created.
         * @param reason The reason context creation failed.
         */
        private function notifyContextCreationFailed(reason:String) : void
        {
            this.isContextLost = true;
            this.dispatchEvent(new ContextCreationFailedEvent(reason));
        }

        /**
         * Constructs a new DisplayContext and optionally attaches it to the specified stage.
         * @param stage The stage to attach to, if any.
         * @param index The Stage3D index to associated with the display
         * context. This must be less than stage.stage3Ds.length.
         */
        public function DisplayContext(stage:Stage=null, index:int=0)
        {
            this.id            = -1;
            this.stage2d       = null;
            this.stage3d       = null;
            this.context3d     = null;
            this.fallback      = new FallbackState();
            this.profile       = '';
            this.isContextLost = true;
            if (stage) this.attachStage(stage, index);
        }

        /**
         * Attaches the display context to a stage.
         * @param stage The stage to attach to. The scale mode will be set to
         * StageScaleMode.NO_SCALE, and the alignment will be set to StageAlign.TOP_LEFT.
         * @param index The zero-based index of the Stage3D to associated with
         * this display context. This must be less than the number Stage3D
         * instances available on @a stage.stage3Ds.
         */
        public function attachStage(stage:Stage, index:int=0) : void
        {
            if (stage === null)
            {
                DebugTrace.out('DisplayContext::attachStage(2) - Invalid stage.');
                throw new ArgumentError('stage');
            }
            if (stage.hasOwnProperty('stage3Ds') === false)
            {
                DebugTrace.out('DisplayContext::attachStage(2) - Stage3D is not supported.');
                throw new ArgumentError('stage')
            }
            if (index < 0 || index >= stage.stage3Ds.length)
            {
                DebugTrace.out('DisplayContext::attachStage(2) - Invalid display context ID %d.', index);
                throw new ArgumentError('index');
            }

            this.id                = index;
            this.stage2d           = stage;
            this.stage3d           = stage.stage3Ds[index];
            this.context3d         = stage.stage3Ds[index].context3D;
            this.stage2d.align     = StageAlign.TOP_LEFT;
            this.stage2d.scaleMode = StageScaleMode.NO_SCALE;
            this.stage3d.addEventListener(Event.CONTEXT3D_CREATE, this.handleContextCreated);
            this.stage3d.addEventListener(ErrorEvent.ERROR, this.handleContextCreationError);

            if (this.context3d)
            {
                this.profile       = this.context3d.profile;
                this.isContextLost = false;
            }
            else
            {
                this.profile       = '';
                this.isContextLost = true;
            }
        }

        /**
         * Detaches the display context from the stage. The rendering context
         * is not disposed of, and no events are raised. The application should
         * save the rendering context prior to calling this method.
         * @return The flash.display.Stage3D previously attached.
         */
        public function detachStage() : Stage3D
        {
            var stage:Stage3D = this.stage3d;
            if (this.stage3d)
            {
                this.stage3d.removeEventListener(Event.CONTEXT3D_CREATE, this.handleContextCreated);
                this.stage3d.removeEventListener(ErrorEvent.ERROR, this.handleContextCreationError);
            }
            this.id            = -1;
            this.profile       = '';
            this.stage2d       = null;
            this.stage3d       = null;
            this.context3d     = null;
            this.isContextLost = true;
            return stage;
        }

        /**
         * Attempts to create a rendering context that uses the software
         * rendering engine. This is useful for testing worst-case performance.
         * Note that the software renderer is not available on mobile platforms.
         * @return true if the context was requested.
         */
        public function createSoftwareContext() : Boolean
        {
            if (this.stage3d === null)
            {
                DebugTrace.out('DisplayContext::createSoftwareContext(0) - Not attached to a stage.');
                this.notifyContextCreationFailed('The display context has no associated stage.');
                return false;
            }
            if (this.context3d !== null)
            {
                DebugTrace.out('DisplayContext::createSoftwareContext(0) - Display context already created.');
                return false;
            }
            this.fallback.update(FallbackState.SOFTWARE_PROFILE, true);
            this.stage3d.requestContext3D(Context3DRenderMode.SOFTWARE);
            return true;
        }

        /**
         * Attempts to create a hardware-accelerated rendering context, failing
         * if the specified hardware support level is not available instead of
         * falling back to a lesser level of support.
         * @param contextType One of the Context3DProfile enumeration values.
         * @return true if the context was requested.
         */
        public function createHardwareContext(contextType:String=Context3DProfile.BASELINE) : Boolean
        {
            if (this.stage3d === null)
            {
                DebugTrace.out('DisplayContext::createHardwareContext(0) - Not attached to a stage.');
                this.notifyContextCreationFailed('The display context has no associated stage.');
                return false;
            }
            if (this.context3d !== null)
            {
                DebugTrace.out('DisplayContext::createHardwareContext(0) - Display context already created.');
                return false;
            }
            if (contextType === FallbackState.SOFTWARE_PROFILE)
            {
                DebugTrace.out('DisplayContext::createHardwareContext(0) - Software context is not accelerated.');
                this.notifyContextCreationFailed('Software contextType passed to createHardwareContext.');
                return false;
            }
            this.fallback.update(contextType, false);
            this.stage3d.requestContext3D(Context3DRenderMode.AUTO, contextType);
            return true;
        }

        /**
         * Attempts to create the rendering context with the best-available
         * feature set, possibly falling back to software rendering if no
         * hardware-accelerated rendering context is available on the current
         * platform (and the software renderer is available and enabled.)
         * @param contextType One of the Context3DProfile enumeration values
         * indicating the context type being requested.
         * @param allowSoftware true to allow fallback to software rendering.
         * @return true if the context was requested.
         */
        public function createBestAvailableContext(contextType:String=Context3DProfile.STANDARD, allowSoftware:Boolean=true) : Boolean
        {
            if (this.stage3d === null)
            {
                DebugTrace.out('DisplayContext::createBestAvailableContext(2) - Not attached to a stage.');
                this.notifyContextCreationFailed('The display context has no associated stage.');
                return false;
            }
            if (this.context3d !== null)
            {
                DebugTrace.out('DisplayContext::createBestAvailableContext(2) - Display context already created.');
                return false;
            }
            if (contextType === FallbackState.SOFTWARE_PROFILE)
            {
                if (allowSoftware)
                {
                    return this.createSoftwareContext();
                }
                else
                {
                    DebugTrace.out('DisplayContext::createBestAvailableContext(2) - Software context requested but disallowed.');
                    this.notifyContextCreationFailed('Software context requested but disallowed.');
                    return false;
                }
            }
            this.fallback.update(contextType, allowSoftware);
            this.stage3d.requestContext3D(Context3DRenderMode.AUTO, contextType);
            return true;
        }

        /**
         * Notifies registered listeners that the attached rendering context
         * has been lost. This event notification always occurs before a
         * ContextReadyEvent indicating the rendering context has been
         * restored. This method is public because a context loss may be
         * detected by the DrawContext.
         */
        public function notifyContextLost() : void
        {
            if (this.isContextLost === false)
            {
                this.isContextLost = true;
                this.dispatchEvent(new ContextLostEvent());
            }
        }

        /**
         * Simulates a rendering context loss.
         */
        public function loseContext() : void
        {
            if (this.context3d)
            {
                try
                {
                    this.context3d.dispose(true);
                    this.isContextLost   = true;
                }
                catch (e:Error)
                {
                    /* empty */
                }
            }
        }

        /**
         * Disposes of the rendering context. The context will not be recreated
         * and no events will be raised. The stage is not detached from the
         * display context.
         */
        public function dispose() : void
        {
            if (this.context3d)
            {
                try
                {
                    this.context3d.dispose(false);
                }
                catch (e:Error)
                {
                    /* empty */
                }
            }
            this.profile       = '';
            this.context3d     = null;
            this.isContextLost = true;
        }

        /**
         * Gets or sets the flash.display3D.Context3DProfile specifying the
         * minimum level of functionality acceptable to the application. By
         * default, this is the software rendering fallback.
         */
        public function get minimumProfile() : String
        {
            return this.fallback.minimumProfile;
        }
        public function set minimumProfile(profileName:String) : void
        {
            this.fallback.minimumProfile = profileName;
        }
    }
}
