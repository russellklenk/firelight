package com.ninjabird.firelight.ui
{
    import flash.geom.Rectangle;
    import com.ninjabird.firelight.input.KeyCode;

    /**
     * Represents the logical state associated with a list box control.
     */
    public final class ListBox
    {
        /**
         * The bounding rectangle of the control, specified in absolute
         * coordinates. This value is set by the application, but may
         * be modified by the library.
         */
        public var bounds:Rectangle;

        /**
         * The total number of items in the list. This value is set by the application.
         */
        public var itemCount:int;

        /**
         * The height of a single item within the list box. All items have
         * the same height. This value is set by the application.
         */
        public var itemHeight:int;

        /**
         * The zero-based index of the first visible item in the list. This
         * value is set by the application.
         */
        public var visibleStart:int;

        /**
         * The maximum number of items that the list box can display at
         * any given time. This value is set by the library.
         */
        public var visibleCount:int;

        /**
         * The zero-based index of the item within the visible window that
         * the mouse cursor is hovering over. A value of -1 indicates 'none'.
         * This value is set by the library.
         */
        public var hotIndex:int;

        /**
         * The zero-based index of the item within the visible window that
         * was clicked by the user. A value of -1 indicates 'none'.
         * This value is set by the library.
         */
        public var activeIndex:int;

        /**
         * The zero-based index of the currently selected item within the
         * list. A value of -1 indicates 'none'. This value is set by the
         * library.
         */
        public var selectedIndex:int;

        /**
         * A value indicating whether the mouse cursor is hovering over the
         * control. This value is set by the library.
         */
        public var isHot:Boolean;

        /**
         * A value indicating whether the control currently has focus (the
         * mouse button is down on it.) This value is set by the library.
         */
        public var isActive:Boolean;

        /**
         * Constructs a new instance initialized with the specified attributes.
         * @param x The x-coordinate of the upper-left corner of the control.
         * @param y The y-coordinate of the upper-left corner of the control.
         * @param width The width of the control, in pixels.
         * @param height The height of the control, in pixels.
         */
        public function ListBox(x:int=0, y:int=0, width:int=0, height:int=0)
        {
            this.bounds        = new Rectangle(x, y, width, height);
            this.itemCount     = 0;
            this.itemHeight    = 1;
            this.visibleStart  = 0;
            this.visibleCount  = 1;
            this.hotIndex      =-1;
            this.activeIndex   =-1;
            this.selectedIndex =-1;
            this.isHot         = false;
            this.isActive      = false;
        }

        /**
         * Scrolls to and selects the first item in the list.
         */
        public function selectFirstItem() : void
        {
            this.visibleStart  = 0;
            if (this.itemCount > 0)
            {
                // select the first item in the list.
                this.activeIndex   = 0;
                this.selectedIndex = 0;
            }
            else
            {
                // no items in the list, so none can be selected.
                this.activeIndex   = -1;
                this.selectedIndex = -1;
            }
        }

        /**
         * Scrolls to and selects the last item in the list.
         */
        public function selectLastItem() : void
        {
            this.visibleStart = this.itemCount - this.visibleCount;
            if (this.visibleStart < 0)
            {
                // number of items in the list <= number of visible items.
                this.visibleStart = 0;
            }
            if (this.itemCount > 0)
            {
                // select the last visible item.
                this.activeIndex   = this.visibleCount - 1;
                this.selectedIndex = this.itemCount    - 1;
            }
            else
            {
                // no items in the list, so none can be selected.
                this.activeIndex   = -1;
                this.selectedIndex = -1;
            }
        }

        /**
         * Selects the next item in the list, scrolling the list if necessary.
         */
        public function selectNextItem() : void
        {
            if (this.activeIndex >= 0)
            {
                if (this.selectedIndex + 1 < this.itemCount)
                {
                    // select the next item.
                    this.selectedIndex++;
                }
                if (this.activeIndex === this.visibleCount - 1)
                {
                    // scroll the window of visible items.
                    if (this.visibleStart + this.activeIndex + 1 < this.itemCount)
                    {
                        this.visibleStart++;
                    }
                }
                else
                {
                    // scrolling within the window of visible items.
                    this.activeIndex++;
                }
            }
        }

        /**
         * Selects the previous item in the list, scrolling the list if necessary.
         */
        public function selectPreviousItem() : void
        {
            if (this.activeIndex >= 0)
            {
                if (this.selectedIndex > 0)
                {
                    // select the previous item.
                    this.selectedIndex--;
                }
                if (this.activeIndex === 0)
                {
                    // scroll the window of visible items.
                    if (this.visibleStart > 0)
                    {
                        this.visibleStart--;
                    }
                }
                else
                {
                    // scrolling within the window of visible items.
                    this.activeIndex--;
                }
            }
        }

        /**
         * Selects a specific item within the list and scrolls the list view to the newly selected item.
         * @param index The zero-based index of the item to select. -1 deselects the current item.
         * @param scroll true to scroll to the currently selected item.
         */
        public function selectItem(index:int, scroll:Boolean=true) : void
        {
            if (index === -1)
            {
                this.deselect(scroll);
                return;
            }
            if (index < 0 || index >= this.itemCount)
            {
                // invalid index.
                return;
            }

            // select the item:
            this.selectedIndex = index;

            if (index >= this.visibleStart && index < this.visibleStart + this.visibleCount)
            {
                // the item is within view; make it active.
                this.activeIndex  = index - this.visibleStart;
            }
            else if (scroll)
            {
                // the item isn't within view; scroll to it.
                this.activeIndex  = 0;
                this.visibleStart = index;
            }
        }

        /**
         * Scrolls the list so that a particular item is within view, without changing the currently selected item.
         * @param index The zero-based index of the item to scroll to.
         */
        public function scrollToItem(index:int) : void
        {
            if (index < 0)
            {
                index = 0;
            }
            if (index >= this.itemCount)
            {
                if (this.itemCount === 0)
                {
                    // no items in the list.
                    return;
                }
                index  = this.itemCount - 1;
            }

            if (index >= this.visibleStart && index < this.visibleStart + this.visibleCount)
            {
                // the item is within view already. do nothing.
            }
            else
            {
                // the item isn't within view; scroll to it.
                this.activeIndex  = -1;
                this.visibleStart = index;
            }
        }

        /**
         * Deselects any currently selected item and scrolls back to the beginning of the list.
         * @param scroll true to also scroll to the beginning of the list.
         */
        public function deselect(scroll:Boolean=false) : void
        {
            this.activeIndex   = -1;
            this.selectedIndex = -1;
            if (scroll)
            {
                // scroll back to the beginning of the list.
                this.visibleStart = 0;
            }
        }

        /**
         * Handles any keyboard events generated while the control is active.
         * @param keys The set of key codes representing key events to process.
         * @param count The number of key events to process.
         */
        public function keyboardInput(keys:Vector.<uint>, count:int) : void
        {
            for (var i:int = 0; i < count; ++i)
            {
                var keyCode:uint = keys[i];

                switch (keyCode)
                {
                    case KeyCode.HOME:
                        this.selectFirstItem();
                        break;

                    case KeyCode.END:
                        this.selectLastItem();
                        break;

                    case KeyCode.UP_ARROW:
                        this.selectPreviousItem();
                        break;

                    case KeyCode.DOWN_ARROW:
                        this.selectNextItem();
                        break;

                    case KeyCode.BACKSPACE:
                        this.deselect();
                        break;
                }
            }
        }
    }
}
