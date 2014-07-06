package com.ninjabird.firelight.ui
{
    import flash.geom.Rectangle;

    /**
     * Represents the logical state associated with a scroll bar control.
     */
    public final class ScrollBar
    {
        /**
         * The bounding rectangle of the control, specified in absolute
         * coordinates. This value is set by the application, but may
         * be modified by the library.
         */
        public var bounds:Rectangle;

        /**
         * The bounding rectangle of the thumb, specified in absolute
         * coordinates. This value is set by the library.
         */
        public var thumbBounds:Rectangle;

        /**
         * The maximum value that can be reported by the control. This
         * value is set by the application.
         */
        public var maxValue:int;

        /**
         * The current value of the thumb, in [0, maxValue]. This value
         * is set by the application, but may be modified by the library.
         */
        public var currentValue:int;

        /**
         * A value indicating whether the mouse cursor is hovering over the
         * thumb. This value is set by the library.
         */
        public var isHot:Boolean;

        /**
         * A value indicating whether the thumb currently has focus (the
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
        public function ScrollBar(x:int, y:int, width:int, height:int)
        {
            this.bounds       = new Rectangle(x, y, width, height);
            this.thumbBounds  = new Rectangle(x, y, 0, 0);
            this.maxValue     = 0;
            this.currentValue = 0;
            this.isHot        = false;
            this.isActive     = false;
        }
    }
}
