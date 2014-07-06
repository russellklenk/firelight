package com.ninjabird.firelight.ui
{
    import flash.geom.Rectangle;
    import com.ninjabird.firelight.input.KeyCode;

    /**
     * Represents the state associated with a single line edit field.
     */
    public final class TextBox
    {
        /**
         * The bounding rectangle of the control, specified in absolute
         * coordinates. This value is set by the application, but may
         * be modified by the library.
         */
        public var bounds:Rectangle;

        /**
         * The bounding rectangle of the text area, specified in absolute coordinates. This value is set by the library.
         */
        public var textBounds:Rectangle;

        /**
         * The text before any edit operations have been applied. This value is set by the application.
         */
        public var sourceText:String;

        /**
         * The text after any edit operations have been applied. This value is set by the library.
         */
        public var editedText:String;

        /**
         * The width of a single space character in the font used to render text for the control. This value is set by the library.
         */
        public var spaceWidth:int;

        /**
         * The number of characters visible in the control by default. This
         * value is initially set by the application, but is maintained by
         * the library. This value must be at least 1 at all times.
         */
        public var visibleCount:int;

        /**
         * The zero-based index of the first visible character in the text box. This value is set by the library.
         */
        public var visibleIndex:int;

        /**
         * The position of the caret within the window of visible characters. This value is set by the library.
         */
        public var caretIndex:int;

        /**
         * A value indicating whether the mouse cursor is hovering over the control. This value is set by the library.
         */
        public var isHot:Boolean;

        /**
         * A value indicating whether the control currently has focus (the mouse button is down on it.) This value is set by the library.
         */
        public var isActive:Boolean;

        /**
         * A value indicating whether the edit was accepted by the user. This value is set by the library.
         */
        public var editAccepted:Boolean;

        /**
         * Constructs a new instance with the specified dimensions.
         * @param x The x-coordinate of the upper-left corner of the control.
         * @param y The y-coordinate of the upper-left corner of the control.
         * @param width The width of the control, in pixels.
         * @param height The height of the control, in pixels.
         * @param marginX The number of pixels of space between the left and right sides of the control and the text.
         * @param marginY The number of pixels of space between the top and bottom sides of the control and the text.
         */
        public function TextBox(x:int=0, y:int=0, width:int=0, height:int=0, marginX:int=1, marginY:int=1)
        {
            this.bounds       = new Rectangle(x, y, width, height);
            this.textBounds   = new Rectangle(x + marginX, y + marginY, width - (marginX * 2), height - (marginY * 2));
            this.sourceText   = '';
            this.editedText   = '';
            this.spaceWidth   = 1;
            this.visibleCount = 1;
            this.visibleIndex = 0;
            this.caretIndex   = 0;
            this.isHot        = false;
            this.isActive     = false;
            this.editAccepted = false;
        }

        /**
         * Moves the current caret position to the end of the window
         * of visible characters.
         */
        public function advanceCaretToEndOfWindow() : void
        {
            var textLen:int  = this.editedText.length;
            var winStart:int = this.visibleIndex;
            var visCount:int = this.visibleCount - 1;
            var delta:int    = textLen - winStart;
            if (delta < visCount)
            {
                // move to the end of the string:
                this.caretIndex = delta;
            }
            else
            {
                // move to the end of the window:
                this.caretIndex = visCount;
            }
        }

        /**
         * Moves the current caret position to the start of the string.
         */
        public function advanceCaretToStartOfString() : void
        {
            this.visibleIndex = 0;
            this.caretIndex   = 0;
        }

        /**
         * Moves the current caret position to the end of the string.
         */
        public function advanceCaretToEndOfString() : void
        {
            var visCount:int = this.visibleCount - 1;
            var textLen:int  = this.editedText.length;
            if (textLen < visCount)
            {
                // the entire string will fit:
                this.visibleIndex = 0;
            }
            else
            {
                // only a portion of the string will fit:
                this.visibleIndex = textLen - visCount;
            }
            this.advanceCaretToEndOfWindow();
        }

        /**
         * Advances the caret to the next valid location in the string.
         */
        public function advanceCaretToNext() : void
        {
            var textLen:int = this.editedText.length;
            if (textLen === 0)
            {
                // the caret cannot move if the string is empty.
                return;
            }

            if (this.caretAtStringEnd)
            {
                // do nothing.
            }
            else
            {
                if (this.caretAtVisibleEnd)
                {
                    // move the window forward by one. don't adjust the caret position; it remains at the end of the visible window.
                    this.visibleIndex++;
                }
                else
                {
                    // move the caret forward by one within the window - don't adjust the window.
                    this.caretIndex++;
                }
            }
        }

        /**
         * Advances the caret to the previous valid location in the string.
         */
        public function advanceCaretToPrevious() : void
        {
            var textLen:int = this.editedText.length;
            if (textLen === 0)
            {
                // the caret cannot move if the string is empty.
                return;
            }

            if (this.caretAtStringStart)
            {
                // do nothing.
            }
            else
            {
                if (this.caretAtVisibleStart)
                {
                    // move the window back by visibleCount, clamping the window start to zero, and move the cursor to the end of the window.
                    var textIdx:int   = this.visibleIndex + this.caretIndex;
                    this.visibleIndex = Math.max(0, this.visibleIndex - 1);
                    this.caretIndex   = textIdx  -  this.visibleIndex;
                }
                else
                {
                    // move the caret back by one within the window - don't adjust the window.
                    this.caretIndex--;
                }
            }
        }

        /**
         * Inserts a single character at the current caret position.
         * @param ch The character to insert.
         */
        public function insert(ch:String) : void
        {
            var insIdx:int    = this.visibleIndex + this.caretIndex;
            var valueLen:int  = this.editedText.length;
            var newStr:String = null;
            if (insIdx === 0)
            {
                // caret is at the beginning of the string.
                newStr = ch + this.editedText;
            }
            else if (valueLen === insIdx)
            {
                // caret is at the end of the string.
                newStr = this.editedText + ch;
            }
            else
            {
                // caret is somewhere in the middle.
                newStr = this.editedText.slice(0, insIdx);
                newStr = newStr + ch;
                newStr = newStr + this.editedText.substring(insIdx);
            }
            this.editedText = newStr;
            this.advanceCaretToNext();
        }

        /**
         * Performs a backspace operation, deleting a single character immediately preceding the current caret position.
         */
        public function backspace() : void
        {
            var remIdx:int    = this.visibleIndex + this.caretIndex - 1;
            var valueLen:int  = this.editedText.length;
            var newStr:String = null;

            if (this.caretAtStringStart || valueLen === 0)
            {
                // caret is at the beginning of the string,
                // or there's no text to edit, so return.
                return;
            }

            newStr = this.editedText.substring(0, remIdx);
            if (remIdx + 1 < valueLen)
            {
                newStr = newStr + this.editedText.substring(remIdx + 1);
            }
            this.editedText = newStr;

            if (this.caretAtVisibleStart)
            {
                this.visibleIndex -= this.visibleCount;
                this.visibleIndex  = Math.max(0, this.visibleIndex);
                this.advanceCaretToEndOfWindow();
            }
            else this.caretIndex--;
        }

        /**
         * Performs a delete operation, deleting a single character immediately following the current caret position.
         */
        public function del() : void
        {
            var remIdx:int    = this.visibleIndex + this.caretIndex;
            var valueLen:int  = this.editedText.length;
            var newStr:String = null;

            if (this.caretAtStringEnd || valueLen === 0)
            {
                // caret is at the end of the string, or there's no text to edit, so return.
                return;
            }

            newStr = this.editedText.substring(0, remIdx);
            if (remIdx + 1 < valueLen)
            {
                newStr = newStr + this.editedText.substring(remIdx + 1);
            }
            this.editedText = newStr;
        }

        /**
         * Clears the edited text string and resets the appropriate internal state.
         * This function is useful after an edit is accepted.
         */
        public function clearEdit() : void
        {
            this.editedText   = this.sourceText;
            this.editAccepted = false;
            this.visibleIndex = 0;
            this.caretIndex   = 0;
        }

        /**
         * Handles any keyboard events generated while the control is active.
         * @param keys The set of key codes representing key events to process.
         * @param count The number of key events to process.
         * @param caps true of caps lock is on.
         * @param shift true if the shift key is down.
         */
        public function keyboardInput(keys:Vector.<uint>, count:int, caps:Boolean, shift:Boolean) : void
        {
            for (var i:int = 0; i < count; ++i)
            {
                var keyCode:uint = keys[i];

                switch (keyCode)
                {
                    case KeyCode.LEFT_ARROW:
                        this.advanceCaretToPrevious();
                        break;

                    case KeyCode.RIGHT_ARROW:
                        this.advanceCaretToNext();
                        break;

                    case KeyCode.HOME:
                        this.advanceCaretToStartOfString();
                        break;

                    case KeyCode.END:
                        this.advanceCaretToEndOfString();
                        break;

                    case KeyCode.DELETE:
                        this.del();
                        break;

                    case KeyCode.BACKSPACE:
                        this.backspace();
                        break;

                    case KeyCode.KEY_ENTER:
                    case KeyCode.NUMPAD_ENTER:
                        this.editAccepted = true;
                        break;

                    default:
                        {
                            var ch:String = KeyCode.toChar(keyCode, caps || shift);
                            if (ch.length > 0)
                            {
                                this.insert(ch);
                            }
                        }
                        break;
                }
            }
        }

        /**
         * Gets a value indicating whether the caret is located at the start of the edit string.
         */
        public function get caretAtStringStart() : Boolean
        {
            return (this.caretIndex === 0 && this.visibleIndex === 0);
        }

        /**
         * Gets a value indicating whether the caret is located at the end of the edit string.
         */
        public function get caretAtStringEnd() : Boolean
        {
            return (this.visibleIndex + this.caretIndex === this.editedText.length);
        }

        /**
         * Gets a value indicating whether the caret is located at the start of the range of visible characters.
         */
        public function get caretAtVisibleStart() : Boolean
        {
            return (this.caretIndex === 0);
        }

        /**
         * Gets a value indicating whether the caret is located at the end of the range of visible characters.
         */
        public function get caretAtVisibleEnd() : Boolean
        {
            return (this.caretIndex === (this.visibleCount - 1));
        }
    }
}
