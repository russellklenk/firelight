package com.ninjabird.firelight.ui
{
    import flash.geom.Rectangle;
    import com.ninjabird.firelight.font.FontDefinition;

    /**
     * Defines static methods implementing widget/control logic for the set of controls implemented by the library.
     */
    public final class UIControls
    {
        /**
         * A global rectangle instance used during intermediate computations.
         */
        private static var TempRect:Rectangle = new Rectangle();

        /**
         * Implements the logic for a click button.
         * @param context The user interface context object.
         * @param id A context-unique identifier for the control.
         * @param x The x-coordinate of the upper-left corner of the clickable region.
         * @param y The y-coordinate of the upper-left corner of the clickable region.
         * @param width The width of the clickable region, in pixels.
         * @param height The height of the clickable region, in pixels.
         * @param appClicked An application-specified value used to simulate a button click.
         * @param active true if the control can be interacted with.
         * @return Button state information necessary for rendering.
         */
        public static function doClickButton(context:UIContext, id:String, x:int, y:int, width:int, height:int, appClicked:Boolean=false, active:Boolean=true) : ClickButton
        {
            var button:ClickButton = context.stateCache[id] as ClickButton;
            var isHot:Boolean      = false;
            var wasClicked:Boolean = false;

            if (button === null)
            {
                // generate a new state object for this button.
                button = new ClickButton(x, y, width, height);
                context.stateCache[id] = button;
            }

            // update the button bounding region:
            button.bounds.x       = x;
            button.bounds.y       = y;
            button.bounds.width   = width;
            button.bounds.height  = height;
            isHot                 = context.isMouseOver(button.bounds);

            if (appClicked)
            {
                // the application sent an explicit button click:
                button.isHot      = isHot;
                button.wasClicked = true;
                return button;
            }

            // update the button hotness:
            if (isHot && active)
            {
                context.setHotItem(button);
            }
            else
            {
                context.setItemNotHot(button);
                context.setItemNotActive(button);
            }

            if (button === context.activeItem)
            {
                // this button is currently active.
                if (context.mouseButtonReleased)
                {
                    if (button === context.hotItem)
                    {
                        // the mouse button was released over the button.
                        wasClicked = true;
                    }
                    context.setItemNotActive(button);
                }
            }
            else if (isHot && active)
            {
                if (context.mouseButtonPressed)
                {
                    // the mouse button was pressed over the button.
                    context.setActiveItem(button);
                    context.setHotItem(button);
                }
            }

            button.isHot      = (button === context.hotItem);
            button.isActive   = (button === context.activeItem);
            button.wasClicked = wasClicked;
            return button;
        }

        /**
         * Implements the logic for a toggle button or checkbox.
         * @param context The user interface context object.
         * @param id A context-unique identifier for the control.
         * @param x The x-coordinate of the upper-left corner of the clickable region.
         * @param y The y-coordinate of the upper-left corner of the clickable region.
         * @param width The width of the clickable region, in pixels.
         * @param height The height of the clickable region, in pixels.
         * @param onOrOff The initial state of the toggle button (1 = ON, 0 = OFF).
         * @param appClicked An application-specified value used to simulate a button click.
         * @param active true if the control can be interacted with.
         * @return Button state information necessary for rendering.
         */
        public static function doToggleButton(context:UIContext, id:String, x:int, y:int, width:int, height:int, onOrOff:int=0, appClicked:Boolean=false, active:Boolean=true) : ToggleButton
        {
            var button:ToggleButton = context.stateCache[id] as ToggleButton;
            var isHot:Boolean       = false;
            var wasClicked:Boolean  = false;

            if (button === null)
            {
                // generate a new state object for this button.
                button = new ToggleButton(x, y, width, height, onOrOff);
                context.stateCache[id] = button;
            }

            // update the button bounding region:
            button.bounds.x       = x;
            button.bounds.y       = y;
            button.bounds.width   = width;
            button.bounds.height  = height;
            isHot                 = context.isMouseOver(button.bounds);

            if (appClicked)
            {
                button.isHot      = isHot;
                button.state      = button.state != 0 ? 0 : 1;
                button.wasClicked = true;
                return button;
            }

            // update the button hotness:
            if (isHot && active)
            {
                context.setHotItem(button);
            }
            else
            {
                context.setItemNotHot(button);
                context.setItemNotActive(button);
            }

            if (button === context.activeItem)
            {
                // this button is currently active.
                if (context.mouseButtonReleased)
                {
                    if (button === context.hotItem)
                    {
                        // the mouse button was released over the button.
                        button.state = button.state != 0 ? 0 : 1;
                        wasClicked   = true;
                    }
                    context.setItemNotActive(button);
                }
            }
            else if (isHot && active)
            {
                if (context.mouseButtonPressed)
                {
                    // the mouse button was pressed over the button.
                    context.setActiveItem(button);
                    context.setHotItem(button);
                }
            }

            button.isHot       = (button === context.hotItem);
            button.isActive    = (button === context.activeItem);
            button.wasClicked  = wasClicked;
            return button;
        }

        /**
         * Implements the logic for a single-line editable text box.
         * @param id The unique identifier of the control.
         * @param x The x-coordinate of the upper-left corner of the clickable region.
         * @param y The y-coordinate of the upper-left corner of the clickable region.
         * @param width The width of the clickable region, in pixels.
         * @param height The height of the clickable region, in pixels.
         * @param marginX The number of pixels of space between the left and right sides of the control and the text.
         * @param marginY The number of pixels of space between the top and bottom sides of the control and the text.
         * @param font The font used to render the button text.
         * @param active true if the control can be interacted with.
         * @return Control state information necessary for rendering.
         */
        public static function doTextBox(context:UIContext, id:String, x:int, y:int, width:int, height:int, marginX:int, marginY:int, font:FontDefinition, active:Boolean=true) : TextBox
        {
            var edit:TextBox  = context.stateCache[id] as TextBox;
            var isHot:Boolean = false;

            if (edit === null)
            {
                // generate a new state object for this button.
                edit                   = new TextBox(x, y, width, height, marginX, marginY);
                edit.spaceWidth        = font.averageWidth;
                context.stateCache[id] = edit;
            }

            // update the edit field bounding region:
            edit.bounds.x          = x;
            edit.bounds.y          = y;
            edit.bounds.width      = width;
            edit.bounds.height     = height;
            edit.textBounds.x      = x + marginX;
            edit.textBounds.y      = y + marginY;
            edit.textBounds.width  = width  - (marginX * 2);
            edit.textBounds.height = height - (marginY * 2);
            edit.visibleCount      = edit.textBounds.width / edit.spaceWidth;
            isHot                  = context.isMouseOver(edit.bounds);

            // update control hotness:
            if (isHot && active)
            {
                context.setHotItem(edit);
            }
            else
            {
                context.setItemNotHot(edit);
            }

            if (edit === context.activeItem)
            {
                if (context.mouseButtonReleased)
                {
                    if (edit !== context.hotItem)
                    {
                        // the mouse button was released, but not over the edit box - become inactive.
                        context.setItemNotActive(edit);
                    }
                }
                if (edit === context.activeItem)
                {
                    // the edit control is still active - process any buffered keyboard input.
                    edit.keyboardInput(context.keyBuffer, context.keyCount, context.capsLockOn, context.shiftDown);
                }
            }
            else if (isHot && active)
            {
                if (context.mouseButtonReleased)
                {
                    // the mouse button was released over the edit box.
                    context.setActiveItem(edit);
                    context.setHotItem(edit);
                }
            }

            edit.isHot    = (edit === context.hotItem);
            edit.isActive = (edit === context.activeItem);
            return edit;
        }

        /**
         * Implements the logic for a list box control.
         * @param id The unique identifier of the control.
         * @param x The x-coordinate of the upper-left corner of the clickable region.
         * @param y The y-coordinate of the upper-left corner of the clickable region.
         * @param width The width of the clickable region, in pixels.
         * @param height The height of the clickable region, in pixels.
         * @param itemCount The total number of items in the list.
         * @param itemHeight The height of a single list item, in pixels.
         * @param active true if the control can be interacted with.
         * @return Control state information necessary for rendering.
         */
        public static function doListBox(context:UIContext, id:String, x:int, y:int, width:int, height:int, itemCount:int, itemHeight:int, active:Boolean=true) : ListBox
        {
            var list:ListBox = context.stateCache[id] as ListBox;
            var mouseOverItem:int = 0;

            if (list === null)
            {
                // generate a new state object for this list.
                list = new ListBox(x, y, width, height);
                context.stateCache[id] = list;
            }

            // update the list box bounding region and properties:
            list.bounds.x      = x;
            list.bounds.y      = y;
            list.bounds.width  = width;
            list.bounds.height = height;
            list.itemCount     = itemCount;
            list.itemHeight    = itemHeight;
            list.visibleCount  = int(Math.floor(height / itemHeight));
            list.hotIndex      = -1;

            // determine the potential hit item:
            if (context.isMouseOver(list.bounds))
            {
                // the mouse is hovering over the control.
                var localY:int = context.mouseCursor.y - list.bounds.y;
                mouseOverItem  = int(Math.floor(localY / list.itemHeight));
            }
            else
            {
                // the mouse isn't hovering over the control.
                mouseOverItem  = -1;
            }

            // update the state of the list box:
            if (list === context.activeItem)
            {
                // select any hot list item within view:
                list.hotIndex = mouseOverItem;

                // select a new active item within view if the mouse is released within control bounds.
                if (context.mouseButtonReleased)
                {
                    if (list === context.hotItem)
                    {
                        list.activeIndex = mouseOverItem;
                    }
                    context.setItemNotActive(list);
                }
                list.keyboardInput(context.keyBuffer, context.keyCount);
            }
            else if (list === context.hotItem)
            {
                list.hotIndex = mouseOverItem;
                if (context.mouseButtonReleased)
                {
                    list.activeIndex = mouseOverItem;
                    context.setActiveItem(list);
                }
            }

            if (context.isMouseOver(list.bounds) && active)
            {
                context.setHotItem(list);
            }
            else
            {
                context.setItemNotHot(list);
            }

            list.isHot    = (list === context.hotItem);
            list.isActive = (list === context.activeItem);
            return list;
        }

        /**
         * Implements the logic for a scroll bar control.
         * @param id The unique identifier of the control.
         * @param x The x-coordinate of the upper-left corner of the scroll region.
         * @param y The y-coordinate of the upper-left corner of the scroll region.
         * @param width The width of the scroll region, in pixels.
         * @param height The height of the scroll region, in pixels.
         * @param maxValue The maximum value that can be reported by the control.
         * @param currentValue The current value of the control, in [0, maxValue].
         * @return Control state information necessary for rendering.
         */
        public static function doScrollBar(context:UIContext, id:String, x:int, y:int, width:int, height:int, maxValue:int, currentValue:int) : ScrollBar
        {
            var scroll:ScrollBar = context.stateCache[id] as ScrollBar;
            var isHot:Boolean    = false;
            var t:Number         = 0.0;
            var pos:int          = 0;
            var dim:int          = 0;
            var thumbX:int       = 0;
            var thumbY:int       = 0;
            var thumbWidth:int   = 0;
            var thumbHeight:int  = 0;

            if (scroll === null)
            {
                // generate a new state object for this control.
                scroll = new ScrollBar(x, y, width, height);
                context.stateCache[id] = scroll;
            }

            // ensure that both the current value and max value are >= 0
            // and clamp the current value to the maximum value.
            if (maxValue     < 0)        maxValue     = 0;
            if (currentValue < 0)        currentValue = 0;
            if (currentValue > maxValue) currentValue = maxValue;

            // update the control bounding region:
            scroll.bounds.x       = x;
            scroll.bounds.y       = y;
            scroll.bounds.width   = width;
            scroll.bounds.height  = height;
            isHot                 = context.isMouseOver(scroll.bounds);

            if (isHot)
            {
                context.setHotItem(scroll);
                if (context.mouseButtonDown)
                {
                    // the mouse is down over us, so we're also active.
                    context.setActiveItem(scroll);
                }
            }
            else
            {
                context.setItemNotHot(scroll);
                context.setItemNotActive(scroll);
            }

            // compute the normalized parameter t between start and end.
            if (maxValue != 0)
            {
                t = Number(currentValue) / Number(maxValue);
            }
            else
            {
                t = 0.0;
            }

            // compute the bounding rectangle for the thumb.
            if (width > height)
            {
                // horizontal scroll bar.
                dim         = width   - height;
                thumbX      = x       + int(dim * t);
                thumbY      = y;
                thumbWidth  = height;
                thumbHeight = height;
            }
            else
            {
                // vertical scroll bar.
                dim         = height  - width;
                thumbX      = x;
                thumbY      = y       + int(dim * t);
                thumbWidth  = width;
                thumbHeight = width;
            }
            scroll.thumbBounds.x      = thumbX;
            scroll.thumbBounds.y      = thumbY;
            scroll.thumbBounds.width  = thumbWidth;
            scroll.thumbBounds.height = thumbHeight;

            if (scroll === context.activeItem)
            {
                if (width > height)
                {
                    // horizontal scroll bar. translate the mouse position
                    // into the local coordinate space of the control. since
                    // this is a horizontal scroll, the thumb moves along the
                    // x-axis and we consider only the mouse x-coordinate.
                    // clamp into the scrollable range.
                    pos = context.mouseCursor.x - (x + (thumbWidth  >> 1));
                    dim = width - thumbWidth;
                }
                else
                {
                    // vertical scroll bar. translate the mouse position
                    // into the local coordinate space of the control. since
                    // this is a vertical scroll, the thumb moves along the
                    // y-axis and we consider only the mouse y-coordinate.
                    pos = context.mouseCursor.y - (y + (thumbHeight >> 1));
                    dim = height - thumbHeight;
                }

                // clamp into the scrollable range.
                if (pos > dim) pos = dim;
                if (pos < 0)   pos = 0;

                // translate the local mouse position back into a value.
                t            = Number(pos) / Number(dim);
                currentValue = int(t * maxValue);
            }

            scroll.isHot        = (scroll === context.hotItem);
            scroll.isActive     = (scroll === context.activeItem);
            scroll.maxValue     = maxValue;
            scroll.currentValue = currentValue;
            return scroll;
        }
    }
}
