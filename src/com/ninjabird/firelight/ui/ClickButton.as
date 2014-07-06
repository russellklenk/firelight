package com.ninjabird.firelight.ui
{
    import flash.geom.Rectangle;

    /**
     * Represents the state associated with a single click button instance.
     */
    public final class ClickButton
    {
        /**
         * The bounding rectangle of the control, specified in absolute
         * coordinates. This value is set by the application, but may
         * be modified by the library.
         */
        public var bounds:Rectangle;

        /**
         * A value indicating whether the mouse cursor is hovering over the
         * button. This value is set by the library.
         */
        public var isHot:Boolean;

        /**
         * A value indicating whether the button currently has focus (the
         * mouse button is down on it.) This value is set by the library.
         */
        public var isActive:Boolean;

        /**
         * A value indicating whether the button has been clicked.
         * This value is set by the library.
         */
        public var wasClicked:Boolean;

        /**
         * Constructs a new instance initialized with the specified attributes.
         * @param x The x-coordinate of the upper-left corner of the control.
         * @param y The y-coordinate of the upper-left corner of the control.
         * @param width The width of the control, in pixels.
         * @param height The height of the control, in pixels.
         */
        public function ClickButton(x:int=0, y:int=0, width:int=0, height:int=0)
        {
            this.bounds     = new Rectangle(x, y, width, height);
            this.isHot      = false;
            this.isActive   = false;
            this.wasClicked = false;
        }
    }
}
