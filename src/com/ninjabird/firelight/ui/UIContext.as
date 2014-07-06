package com.ninjabird.firelight.ui
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import com.ninjabird.firelight.input.KeyCode;

    /**
     * Represents the state information associated with an immediate-mode UI.
     * Each logical UI should maintain its own UIContext.
     */
    public final class UIContext
    {
        /**
         * A reference to the current 'hot' control - the control the
         * mouse cursor is over, or the control about to be interacted
         * with. Do not set this value directly.
         */
        public var hotItem:*;

        /**
         * A reference to the current 'active' control - the control
         * the user is currently interacting with. Do not set this
         * value directly.
         */
        public var activeItem:*;

        /**
         * The current application time, specified in seconds.
         */
        public var currentTime:Number;

        /**
         * The duration of the previous application update, specified
         * in seconds.
         */
        public var deltaTime:Number;

        /**
         * An associative table used to access the internal object state
         * for a control given the control's unique string identifier.
         */
        public var stateCache:Object;

        /**
         * Key history values (used for implementing key repeat).
         */
        public var keyHistory:KeyBuffer;

        /**
         * A buffer of key presses for the current frame.
         */
        public var keyBuffer:Vector.<uint>;

        /**
         * The number of key presses for the current frame.
         */
        public var keyCount:int;

        /**
         * The mouse cursor position at the time the mouse button was
         * pressed, specified in absolute coordinates.
         */
        public var mouseDownPos:Point;

        /**
         * A combination of MBS bitflags representing the current state of the mouse button.
         */
        public var mouseButtonState:int;

        /**
         * The current mouse cursor position, specified in absolute coordinates.
         */
        public var mouseCursor:Point;

        /**
         * The key repeat rate, specified in characters-per-second.
         */
        public var repeatRate:Number;

        /**
         * The caret blink rate, specified in cycles-per-second.
         */
        public var blinkRate:Number;

        /**
         * The current alpha value of the blinking caret.
         */
        public var caretAlpha:Number;

        /**
         * A value indicating whether caps lock is currently enabled.
         */
        public var capsLockOn:Boolean;

        /**
         * A value indicating whether the shift key is currently down.
         */
        public var shiftDown:Boolean;

        /**
         * Default Constructor (empty).
         */
        public function UIContext()
        {
            this.hotItem          = null;
            this.activeItem       = null;
            this.stateCache       = new Object();
            this.keyHistory       = new KeyBuffer();
            this.keyBuffer        = new Vector.<uint>(128, true);
            this.keyCount         = 0;
            this.mouseDownPos     = new Point();
            this.mouseButtonState = 0;
            this.mouseCursor      = new Point();
            this.repeatRate       = 10.0; // repeat at 10 characters per-second.
            this.blinkRate        = 2.0;  // blink 2 times per-second.
            this.caretAlpha       = 1.0;  // 100% opacity
            this.capsLockOn       = false;
            this.shiftDown        = false;
        }

        /**
         * Performs a point-in-rectangle hit test.
         * @param bound The bounding rectangle.
         * @param test The point to test.
         * @return true of 'test' lies within 'bound'.
         */
        public function hitTest(bound:Rectangle, test:Point) : Boolean
        {
            return (test.x >= bound.x               &&
                    test.x <  bound.x + bound.width &&
                    test.y >= bound.y               &&
                    test.y <  bound.y + bound.height);
        }

        /**
         * Sets the current hot item (the item about to be interacted with).
         * The hot item is only set if no other item is currently active.
         * @param item The unique identifier of the hot control.
         * @return true if the item was set as the hot item.
         */
        public function setHotItem(item:*) : Boolean
        {
            if (this.activeItem === null || this.activeItem === item)
            {
                // set this item as the hot item.
                hotItem = item;
                return true;
            }
            // another item (which is not this item) is currently active.
            return false;
        }

        /**
         * Sets the item that the user is currently interacting with.
         * @param item The item that the user is currently interacting with.
         */
        public function setActiveItem(item:*) : void
        {
            this.activeItem = item;
        }

        /**
         * Sets a particular item as not hot.
         * @param item The item to make not hot.
         */
        public function setItemNotHot(item:*) : void
        {
            if (this.hotItem === item)
            {
                this.hotItem = null;
            }
        }

        /**
         * Sets a particular item as not active.
         * @param item The item to make not active.
         */
        public function setItemNotActive(item:*) : void
        {
            if (this.activeItem === item)
            {
                this.activeItem = null;
            }
        }

        /**
         * Determines whether the current mouse cursor position intersects a given rectangle.
         * @param bounds The bounding rectangle of a control.
         * @return true if the mouse is currently over the specified item.
         */
        public function isMouseOver(bounds:Rectangle) : Boolean
        {
            var cursor:Point  = this.mouseCursor;
            return (cursor.x >= bounds.x                &&
                    cursor.x <  bounds.x + bounds.width &&
                    cursor.y >= bounds.y                &&
                    cursor.y <  bounds.y + bounds.height);
        }

        /**
         * Sets the current position of the mouse cursor.
         * @param x The x-coordinate of the mouse cursor.
         * @param y The y-coordinate of the mouse cursor.
         */
        public function setCursor(x:int, y:int) : void
        {
            this.mouseCursor.x = x;
            this.mouseCursor.y = y;
        }

        /**
         * Informs the user interface of the current mouse cursor position.
         * @param x The current x-coordinate of the mouse cursor.
         * @param y The current y-coordinate of the mouse cursor.
         */
        public function mouseMove(x:int, y:int) : void
        {
            this.mouseCursor.x = x;
            this.mouseCursor.y = y;
        }

        /**
         * Updates UI context state in response to a mouse button being pressed.
         * @param x The current x-coordinate of the mouse cursor.
         * @param y The current y-coordinate of the mouse cursor.
         * @param modifiers A combination of UIMouseState indicating shift/alt/ctrl key modifiers.
         */
        public function mouseButtonPress(x:int, y:int, modifiers:int) : void
        {
            this.mouseCursor.x     = x;
            this.mouseCursor.y     = y;
            modifiers             &= MouseState.ALT | MouseState.CTRL  | MouseState.SHIFT;
            this.mouseButtonState  = MouseState.ON  | MouseState.BEGIN | modifiers;
            this.mouseDownPos.x    = x;
            this.mouseDownPos.y    = y;
        }

        /**
         * Updates UI context state in response to a mouse button being released.
         * @param x The current x-coordinate of the mouse cursor.
         * @param y The current y-coordinate of the mouse cursor.
         * @param modifiers A combination of UIMouseState indicating shift/alt/ctrl key modifiers.
         */
        public function mouseButtonRelease(x:int, y:int, modifiers:int) : void
        {
            this.mouseCursor.x     = x;
            this.mouseCursor.y     = y;
            modifiers             &= MouseState.ALT | MouseState.CTRL | MouseState.SHIFT;
            this.mouseButtonState  = MouseState.ON  | MouseState.END  | modifiers;
        }

        /**
         * Updates the UI context state in response to a key being pressed.
         * @param x The current x-coordinate of the mouse cursor.
         * @param y The current y-coordinate of the mouse cursor.
         * @param keyCode The key code of the key that was pressed.
         */
        public function keyPress(x:int, y:int, keyCode:uint) : void
        {
            var state:KeyState = this.keyHistory.pressed(keyCode);
            this.mouseCursor.x = x;
            this.mouseCursor.y = y;
            state.timestamp    = this.currentTime;
            state.delay        = 1.0; // wait 1 sec before first repeat
            if (keyCode === KeyCode.CAPS_LOCK)
            {
                // toggle CAPS LOCK state.
                capsLockOn = !capsLockOn;
            }
            if (keyCode === KeyCode.SHIFT)
            {
                // set SHIFT.
                shiftDown = true;
            }
        }

        /**
         * Updates the UI context state in response to a key down. A key down
         * occurs when a key is held down, not when it is initially pressed.
         * @param x The current x-coordinate of the mouse cursor.
         * @param y The current y-coordinate of the mouse cursor.
         * @param keyCode The key code of the key that is down.
         */
        public function keyDown(x:int, y:int, keyCode:uint) : void
        {
            var repeat:Number  = 1.0 / this.repeatRate;
            var state:KeyState = this.keyHistory.find(keyCode);
            if (state !== null)
            {
                if (state.delay - this.deltaTime <= 0)
                {
                    // the key is known to be pressed. has enough time
                    // passed that we need to regenerate the press event?
                    if (this.currentTime - state.timestamp > repeat)
                    {
                        // generate a key repeat by updating the timestamp.
                        state.timestamp  = this.currentTime;
                    }
                }
                else
                {
                    // still waiting for the initial delay period to expire.
                    state.delay -= this.deltaTime;
                }
            }
            this.mouseCursor.x = x;
            this.mouseCursor.y = y;
        }

        /**
         * Updates the UI context state in response to a key being released.
         * @param x The current x-coordinate of the mouse cursor.
         * @param y The current y-coordinate of the mouse cursor.
         * @param keyCode The key code of the key that was pressed.
         */
        public function keyRelease(x:int, y:int, keyCode:uint) : void
        {
            this.keyHistory.released(keyCode);
            if (keyCode === KeyCode.SHIFT)
            {
                // unset SHIFT.
                this.shiftDown = false;
            }
        }

        /**
         * Called by the application to indicate the start of UI definition.
         * @param currTime The current global application time, in seconds.
         * @param frameTime The duration of the previous application update, in seconds.
         */
        public function begin(currTime:Number, frameTime:Number) : void
        {
            var secondsPerBlink:Number = 1.0       / this.blinkRate;
            var multiples:Number       = currTime  * this.blinkRate;
            var wholePart:Number       = Math.floor(multiples);
            var fracPart:Number        = multiples - wholePart;

            // store the current time values:
            this.currentTime = currTime;
            this.deltaTime   = frameTime;

            // update the caret alpha:
            if ((int(wholePart) & 1) !== 0)
            {
                // the sequence is playing backwards:
                this.caretAlpha = 1.0 - fracPart;
            }
            else
            {
                // the sequence is playing forwards:
                this.caretAlpha = fracPart;
            }
        }

        /**
         * Called by the application to indicate the end of input event
         * specification. This function updates the key buffer.
         */
        public function endInputs() : void
        {
            var iter:KeyState = this.keyHistory.front;

            this.keyCount = 0;
            while (iter !== null)
            {
                if (iter.timestamp === this.currentTime)
                {
                    if (this.keyCount + 1 < this.keyBuffer.length)
                    {
                        this.keyBuffer[this.keyCount++] = iter.keyCode;
                    }
                }
                iter = iter.next;
            }
        }

        /**
         * Called by the application to indicate the end of UI definition.
         */
        public function end() : void
        {
            // update the mouse button state.
            if ((this.mouseButtonState & MouseState.BEGIN) !== 0)
            {
                this.mouseButtonState ^= MouseState.BEGIN;
            }
            if ((this.mouseButtonState & MouseState.END) !== 0)
            {
                this.mouseButtonState  = MouseState.OFF;
            }

            // flush the key buffer:
            this.keyCount = 0;
        }

        /**
         * Gets a value indicating whether the mouse button was just pressed.
         */
        public function get mouseButtonPressed() : Boolean
        {
            return ((this.mouseButtonState & MouseState.ON) !== 0) && ((this.mouseButtonState & MouseState.BEGIN) !== 0);
        }

        /**
         * Gets a value indicating whether the mouse button is currently down.
         */
        public function get mouseButtonDown() : Boolean
        {
            return ((this.mouseButtonState & MouseState.ON) !== 0);
        }

        /**
         * Gets a value indicating whether the mouse button was just released.
         */
        public function get mouseButtonReleased() : Boolean
        {
            return ((this.mouseButtonState & MouseState.ON) !== 0) && ((this.mouseButtonState & MouseState.END) !== 0);
        }
    }
}
