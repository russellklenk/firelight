package com.ninjabird.firelight.input
{
    import flash.display.Stage;
    import flash.events.MouseEvent;
    import flash.events.KeyboardEvent;

    /**
     * Tracks the raw states of the keyboard and mouse, which can be used
     * to generate game actions.
     */
    public final class InputManager
    {
        /**
         * The set of previously captured input device states.
         */
        public var previousState:InputState;

        /**
         * The current set of input device states.
         */
        public var currentState:InputState;

        /**
         * The change in horizontal mouse position from the last update.
         */
        public var mouseDeltaX:Number;

        /**
         * The change in vertical mouse position from the last update.
         */
        public var mouseDeltaY:Number;

        /**
         * The x-coordinate of the mouse cursor on the stage.
         */
        public var mouseX:Number;

        /**
         * The y-coordinate of the mouse cursor on the stage.
         */
        public var mouseY:Number;

        /**
         * An array of zero or more key codes representing the set of keys
         * currently in the down position. Use the keysDownCount field to
         * determine the number of valid entries.
         */
        public var keysDown:Vector.<uint>;

        /**
         * The number of valid key codes stored in keysDown.
         */
        public var keysDownCount:int;

        /**
         * An array of zero or more key codes representing the newly pressed
         * keys since the last update. Use the keysPressedCount field to
         * determine the number of valid entries.
         */
        public var keysPressed:Vector.<uint>;

        /**
         * The number of valid key codes stored in keysPressed.
         */
        public var keysPressedCount:int;

        /**
         * An array of zero or more key codes representing the newly released
         * keys since the last update. Use the keysReleasedCount field to
         * determine the number of valid entries.
         */
        public var keysReleased:Vector.<uint>;

        /**
         * The number of valid key codes stored in keysReleased.
         */
        public var keysReleasedCount:int;

        /**
         * An array of zero or more button codes representing the set of
         * buttons currently in the down position. Use the buttonsDownCount
         * field to determine the number of valid entries.
         */
        public var buttonsDown:Vector.<uint>;

        /**
         * The number of valid button codes stored in buttonsDown.
         */
        public var buttonsDownCount:int;

        /**
         * An array of zero or more button codes representing the newly
         * pressed buttons since the last update. Use the buttonsPressedCount
         * field to determine the number of valid entries.
         */
        public var buttonsPressed:Vector.<uint>;

        /**
         * The number of valid button codes stored in buttonsPressed.
         */
        public var buttonsPressedCount:int;

        /**
         * An array of zero or more button codes representing the newly
         * released buttons since the last update. Use the buttonsReleasedCount
         * field to determine the number of valid entries.
         */
        public var buttonsReleased:Vector.<uint>;

        /**
         * The number of valid button codes stored in buttonsReleased.
         */
        public var buttonsReleasedCount:int;

        /**
         * Handles the KeyboardEvent.KEY_UP event.
         * @param e Additional information associated with the event.
         */
        private function handleKeyUp(e:KeyboardEvent) : void
        {
            // clear the bit representing the key:
            this.currentState.keyboard.states[e.keyCode >>> 5] &= ~(1 << (e.keyCode & 0x1F));
        }

        /**
         * Handles the KeyboardEvent.KEY_DOWN event.
         * @param e Additional information associated with the event.
         */
        private function handleKeyDown(e:KeyboardEvent) : void
        {
            // set the bit representing the key:
            this.currentState.keyboard.states[e.keyCode >>> 5] |=  (1 << (e.keyCode & 0x1F));
        }

        /**
         * Handles the MouseEvent.MOUSE_MOVE event.
         * @param e Additional information associated with the event.
         */
        private function handleMouseMove(e:MouseEvent) : void
        {
            this.mouseX = e.stageX;
            this.mouseY = e.stageY;
        }

        /**
         * Handles the MouseEvent.MOUSE_WHEEL event.
         * @param e Additional information associated with the event.
         */
        private function handleMouseWheel(e:MouseEvent) : void
        {
            this.currentState.mouse.z += e.delta;
        }

        /**
         * Handles the MouseEvent.MOUSE_UP event.
         * @param e Additional information associated with the event.
         */
        private function handleMouseButtonUp(e:MouseEvent) : void
        {
            // Flash only reports one button press - AIR reports more, though.
            // clear the bit representing the mouse button.
            this.currentState.mouse.buttons &= ~(1 << ButtonCode.LEFT_BUTTON);
        }

        /**
         * Handles the MouseEvent.MOUSE_DOWN event.
         * @param e Additional information associated with the event.
         */
        private function handleMouseButtonDown(e:MouseEvent) : void
        {
            // Flash only reports one button press - AIR reports more, though.
            // set the bit representing the mouse button.
            this.currentState.mouse.buttons |=  (1 << ButtonCode.LEFT_BUTTON);
        }

        /**
         * Constructs a new instance that listens for input events on the specified stage.
         * @param stage The Stage on which input events are reported.
         */
        public function InputManager(stage:Stage)
        {
            this.previousState        = new InputState();
            this.currentState         = new InputState();
            this.mouseDeltaX          = 0;
            this.mouseDeltaY          = 0;
            this.mouseX               = 0;
            this.mouseY               = 0;
            this.keysDown             = new Vector.<uint>();
            this.keysPressed          = new Vector.<uint>();
            this.keysReleased         = new Vector.<uint>();
            this.buttonsDown          = new Vector.<uint>();
            this.buttonsPressed       = new Vector.<uint>();
            this.buttonsReleased      = new Vector.<uint>();
            this.keysDownCount        = 0;
            this.keysPressedCount     = 0;
            this.keysReleasedCount    = 0;
            this.buttonsDownCount     = 0;
            this.buttonsPressedCount  = 0;
            this.buttonsReleasedCount = 0;

            // @NOTE: intentionally not using weak references here.
            stage.addEventListener(MouseEvent.MOUSE_UP,    this.handleMouseButtonUp);
            stage.addEventListener(MouseEvent.MOUSE_DOWN,  this.handleMouseButtonDown);
            stage.addEventListener(MouseEvent.MOUSE_MOVE,  this.handleMouseMove);
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, this.handleMouseWheel);
            stage.addEventListener(KeyboardEvent.KEY_UP,   this.handleKeyUp);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, this.handleKeyDown);
        }

        /**
         * Updates the current input device state.
         */
        public function update() : void
        {
            var curr:uint    = 0;
            var prev:uint    = 0;
            var changes:uint = 0;
            var downs:uint   = 0;
            var ups:uint     = 0;
            var mask:uint    = 0;
            var i:uint       = 0;
            var j:uint       = 0;

            // update the current mouse state:
            this.currentState.mouse.x = this.mouseX;
            this.currentState.mouse.y = this.mouseY;
            this.mouseDeltaX = this.currentState.mouse.x - this.previousState.mouse.x;
            this.mouseDeltaY = this.currentState.mouse.y - this.previousState.mouse.y;

            // generate events for the keyboard:
            this.keysDownCount      = 0;
            this.keysPressedCount   = 0;
            this.keysReleasedCount  = 0;
            for (i = 0; i < 8; ++i)
            {
                curr    = this.currentState.keyboard.states[i];
                prev    = this.previousState.keyboard.states[i];
                changes = (curr    ^   prev);
                downs   = (changes &   curr);
                ups     = (changes & ~(curr));

                for (j = 0; j < 32; ++j)
                {
                    var kc:uint = (i << 5) + j;

                    mask = (1 << j);
                    if ((curr & mask) !== 0)
                    {
                        this.keysDown[this.keysDownCount++] = kc;
                    }
                    if ((downs & mask) !== 0)
                    {
                        this.keysPressed[this.keysPressedCount++] = kc;
                    }
                    if ((ups & mask) !== 0)
                    {
                        this.keysReleased[this.keysReleasedCount++] = kc;
                    }
                }
            }

            // generate events for the buttons:
            this.buttonsDownCount     = 0;
            this.buttonsPressedCount  = 0;
            this.buttonsReleasedCount = 0;
            curr    = this.currentState.mouse.buttons;
            prev    = this.previousState.mouse.buttons;
            changes = (curr    ^   prev);
            downs   = (changes &   curr);
            ups     = (changes & ~(curr));
            for (j = 0; j < 32; ++j)
            {
                mask = (1 << j);
                if ((curr & mask) !== 0)
                {
                    this.buttonsDown[this.buttonsDownCount++] = j;
                }
                if ((downs & mask) !== 0)
                {
                    this.buttonsPressed[this.buttonsPressedCount++] = j;
                }
                if ((ups & mask) !== 0)
                {
                    this.buttonsReleased[this.buttonsReleasedCount++] = j;
                }
            }
            InputState.assign(this.previousState, this.currentState);
        }

        /**
         * Completely resets the input state.
         */
        public function resetInputState() : void
        {
            this.keysDown.length           = 0;
            this.keysDownCount             = 0;
            this.keysPressed.length        = 0;
            this.keysPressedCount          = 0;
            this.keysReleased.length       = 0;
            this.keysReleasedCount         = 0;
            this.buttonsDown.length        = 0;
            this.buttonsDownCount          = 0;
            this.buttonsPressed.length     = 0;
            this.buttonsPressedCount       = 0;
            this.buttonsReleased.length    = 0;
            this.buttonsReleasedCount      = 0;
            this.mouseDeltaX               = 0;
            this.mouseDeltaY               = 0;
            this.mouseX                    = 0;
            this.mouseY                    = 0;
            this.previousState.mouse.x     = 0;
            this.previousState.mouse.y     = 0;
            this.previousState.mouse.z     = 0;
            this.currentState.mouse.x      = 0;
            this.currentState.mouse.y      = 0;
            this.currentState.mouse.z      = 0;
            this.previousState.mouse.reset();
            this.currentState.mouse.reset();
            this.previousState.keyboard.reset();
            this.currentState.keyboard.reset();
        }

        /**
         * Determines whether a specific key is currently in the up state.
         * @param keyCode The key code of the key to check.
         * @return Returns true if the specified key is currently up.
         */
        public function isKeyUp(keyCode:uint) : Boolean
        {
            return ((this.currentState.keyboard.states[keyCode >>> 5] & (1 << (keyCode & 0x1F))) === 0);
        }

        /**
         * Determines whether a specific key is currently in the down state.
         * @param keyCode The key code of the key to check.
         * @return Returns true if the specified key is currently down.
         */
        public function isKeyDown(keyCode:uint) : Boolean
        {
            return ((this.currentState.keyboard.states[keyCode >>> 5] & (1 << (keyCode & 0x1F))) !== 0);
        }

        /**
         * Determines whether a specific mouse button is currently in the up state.
         * @param buttonCode The button code of the button to check.
         * @return Returns true if the specified mouse button is currently up.
         */
        public function isButtonUp(buttonCode:uint) : Boolean
        {
            return ((this.currentState.mouse.buttons & (1 << buttonCode)) === 0);
        }

        /**
         * Determines whether a specific mouse button is currently in the down state.
         * @param buttonCode The button code of the button to check.
         * @return Returns true if the specified mouse button is currently down.
         */
        public function isButtonDown(buttonCode:uint) : Boolean
        {
            return ((this.currentState.mouse.buttons & (1 << buttonCode)) !== 0);
        }

        /**
         * Determines whether a specific key was just pressed on the most recent update.
         * @param keyCode The key code of the key to check.
         * @return Returns true if the specified key is newly pressed.
         */
        public function wasKeyPressed(keyCode:uint) : Boolean
        {
            var result:Boolean = false;
            for (var i:int = 0, n:int = this.keysPressedCount; i < n; ++i)
            {
                if (this.keysPressed[i] === keyCode)
                {
                    result = true;
                    break;
                }
            }
            return result;
        }

        /**
         * Determines whether a specific key was just released on the most recent update.
         * @param keyCode The key code of the key to check.
         * @return Returns true if the specified key is newly released.
         */
        public function wasKeyReleased(keyCode:uint) : Boolean
        {
            var result:Boolean = false;
            for (var i:int = 0, n:int = this.keysReleasedCount; i < n; ++i)
            {
                if (this.keysReleased[i] === keyCode)
                {
                    result = true;
                    break;
                }
            }
            return result;
        }

        /**
         * Determines whether a specific button was just pressed on the most recent update.
         * @param buttonCode The buttonCode of the button to check.
         * @return Returns true if the specified button is newly pressed.
         */
        public function wasButtonPressed(buttonCode:uint) : Boolean
        {
            var result:Boolean = false;
            for (var i:int = 0, n:int = this.buttonsPressedCount; i < n; ++i)
            {
                if (this.buttonsPressed[i] === buttonCode)
                {
                    result = true;
                    break;
                }
            }
            return result;
        }

        /**
         * Determines whether a specific button was just released on the most recent update.
         * @param buttonCode The button code of the button to check.
         * @return Returns true if the specified button is newly released.
         */
        public function wasButtonReleased(buttonCode:uint) : Boolean
        {
            var result:Boolean = false;
            for (var i:int = 0, n:int = this.buttonsReleasedCount; i < n; ++i)
            {
                if (this.buttonsReleased[i] === buttonCode)
                {
                    result = true;
                    break;
                }
            }
            return result;
        }

        /**
         * Gets the change in mouse wheel position from the previous update.
         */
        public function get mouseDeltaZ() : Number
        {
            return (this.currentState.mouse.z - this.previousState.mouse.z);
        }
    }
}
