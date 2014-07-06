package com.ninjabird.firelight.ui
{
    import flash.geom.Rectangle;

    /**
     * Represents the state associated with a single toggle button instance.
     */
    public final class ToggleButton
    {
        /**
         * The bounding rectangle of the control, specified in absolute
         * coordinates. This value is set by the application, but may
         * be modified by the library.
         */
        public var bounds:Rectangle;

        /**
         * The current toggle state of the button, where a value of 0 = off
         * and a value of 1 = on. This value is set by the application, but
         * may be modified by the library.
         */
        public var state:int;

        /**
         * A value indicating whether the mouse cursor is hovering over the button. This value is set by the library.
         */
        public var isHot:Boolean;

        /**
         * A value indicating whether the button currently has focus (the
         * mouse button is down on it.) This value is set by the library.
         */
        public var isActive:Boolean;

        /**
         * A value indicating whether the button has been clicked. This value is set by the library.
         */
        public var wasClicked:Boolean;

        /**
         * Constructs a new instance initialized with the specified attributes.
         * @param x The x-coordinate of the upper-left corner of the control.
         * @param y The y-coordinate of the upper-left corner of the control.
         * @param width The width of the control, in pixels.
         * @param height The height of the control, in pixels.
         * @param onOrOff The initial toggle state of the button (1 = ON).
         */
        public function ToggleButton(x:int=0, y:int=0, width:int=0, height:int=0, onOrOff:int=0)
        {
            this.bounds     = new Rectangle(x, y, width, height);
            this.state      = onOrOff;
            this.isHot      = false;
            this.isActive   = false;
            this.wasClicked = false;
        }
    }
}
