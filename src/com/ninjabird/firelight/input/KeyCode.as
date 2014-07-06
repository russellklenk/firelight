package com.ninjabird.firelight.input
{
    /**
     * Defines constants for all keyboard key values.
     */
    public final class KeyCode
    {
        public static const BACKSPACE:uint     = 8;
        public static const TAB:uint           = 9;
        public static const KEY_ENTER:uint     = 13;
        public static const SHIFT:uint         = 16;
        public static const CONTROL:uint       = 17;
        public static const PAUSE:uint         = 19;
        public static const BREAK:uint         = 19;
        public static const CAPS_LOCK:uint     = 20;
        public static const ESCAPE:uint        = 27;
        public static const SPACE:uint         = 32;
        public static const PAGE_UP:uint       = 33;
        public static const PAGE_DOWN:uint     = 34;
        public static const END:uint           = 35;
        public static const HOME:uint          = 36;
        public static const LEFT_ARROW:uint    = 37;
        public static const UP_ARROW:uint      = 38;
        public static const RIGHT_ARROW:uint   = 39;
        public static const DOWN_ARROW:uint    = 40;
        public static const INSERT:uint        = 45;
        public static const DELETE:uint        = 46;
        public static const KEY_0:uint         = 48;
        public static const KEY_1:uint         = 49;
        public static const KEY_2:uint         = 50;
        public static const KEY_3:uint         = 51;
        public static const KEY_4:uint         = 52;
        public static const KEY_5:uint         = 53;
        public static const KEY_6:uint         = 54;
        public static const KEY_7:uint         = 55;
        public static const KEY_8:uint         = 56;
        public static const KEY_9:uint         = 57;
        public static const A:uint             = 65;
        public static const B:uint             = 66;
        public static const C:uint             = 67;
        public static const D:uint             = 68;
        public static const E:uint             = 69;
        public static const F:uint             = 70;
        public static const G:uint             = 71;
        public static const H:uint             = 72;
        public static const I:uint             = 73;
        public static const J:uint             = 74;
        public static const K:uint             = 75;
        public static const L:uint             = 76;
        public static const M:uint             = 77;
        public static const N:uint             = 78;
        public static const O:uint             = 79;
        public static const P:uint             = 80;
        public static const Q:uint             = 81;
        public static const R:uint             = 82;
        public static const S:uint             = 83;
        public static const T:uint             = 84;
        public static const U:uint             = 85;
        public static const V:uint             = 86;
        public static const W:uint             = 87;
        public static const X:uint             = 88;
        public static const Y:uint             = 89;
        public static const Z:uint             = 90;
        public static const NUMPAD_0:uint      = 96;
        public static const NUMPAD_1:uint      = 97;
        public static const NUMPAD_2:uint      = 98;
        public static const NUMPAD_3:uint      = 99;
        public static const NUMPAD_4:uint      = 100;
        public static const NUMPAD_5:uint      = 101;
        public static const NUMPAD_6:uint      = 102;
        public static const NUMPAD_7:uint      = 103;
        public static const NUMPAD_8:uint      = 104;
        public static const NUMPAD_9:uint      = 105;
        public static const NUMPAD_STAR:uint   = 106;
        public static const NUMPAD_PLUS:uint   = 107;
        public static const NUMPAD_ENTER:uint  = 13;
        public static const NUMPAD_MINUS:uint  = 109;
        public static const NUMPAD_PERIOD:uint = 110;
        public static const NUMPAD_SLASH:uint  = 111;
        public static const F1:uint            = 112;
        public static const F2:uint            = 113;
        public static const F3:uint            = 114;
        public static const F4:uint            = 115;
        public static const F5:uint            = 116;
        public static const F6:uint            = 117;
        public static const F7:uint            = 118;
        public static const F8:uint            = 119;
        public static const F9:uint            = 120;
        public static const F10:uint           = 121;
        public static const F11:uint           = 122;
        public static const F12:uint           = 123;
        public static const F13:uint           = 124;
        public static const F14:uint           = 125;
        public static const F15:uint           = 126;
        public static const NUM_LOCK:uint      = 144;
        public static const SCROLL_LOCK:uint   = 145;
        public static const SEMICOLON:uint     = 186; // ;, :
        public static const EQUAL:uint         = 187; // =, +
        public static const COMMA:uint         = 188; // ,, <
        public static const MINUS:uint         = 189; // -, _
        public static const PERIOD:uint        = 190; // ., >
        public static const SLASH:uint         = 191; // /, ?
        public static const ACCENT:uint        = 192; // `, ~
        public static const LEFT_BRACKET:uint  = 219; // [, {
        public static const FORWARD_SLASH:uint = 220; // \, |
        public static const RIGHT_BRACKET:uint = 221; // ], }
        public static const QUOTE:uint         = 222; // ', '

        /**
         * Converts a alphanumeric key code identifier into its corresponding
         * character value. NOTE: this currently only works for an English
         * keyboard layout - Flash seems to have no way to convert from a key
         * code to a unicode character automatically - String.fromCharCode
         * won't work since it uses character codes, and not key codes.
         * @param keyCode The key code to look up.
         * @param shift true if the shift key modifier is active.
         * @return The corresponding string, or an empty string if the key code has no alphanumeric equivalent.
         */
        public static function toChar(keyCode:uint, shift:Boolean = false) : String
        {
            switch (keyCode)
            {
                case KeyCode.SPACE:         return ' ';
                case KeyCode.KEY_0:         return (shift) ? ')' : '0';
                case KeyCode.KEY_1:         return (shift) ? '!' : '1';
                case KeyCode.KEY_2:         return (shift) ? '@' : '2';
                case KeyCode.KEY_3:         return (shift) ? '#' : '3';
                case KeyCode.KEY_4:         return (shift) ? '$' : '4';
                case KeyCode.KEY_5:         return (shift) ? '%' : '5';
                case KeyCode.KEY_6:         return (shift) ? '^' : '6';
                case KeyCode.KEY_7:         return (shift) ? '&' : '7';
                case KeyCode.KEY_8:         return (shift) ? '*' : '8';
                case KeyCode.KEY_9:         return (shift) ? '(' : '9';
                case KeyCode.A:             return (shift) ? 'A' : 'a';
                case KeyCode.B:             return (shift) ? 'B' : 'b';
                case KeyCode.C:             return (shift) ? 'C' : 'c';
                case KeyCode.D:             return (shift) ? 'D' : 'd';
                case KeyCode.E:             return (shift) ? 'E' : 'e';
                case KeyCode.F:             return (shift) ? 'F' : 'f';
                case KeyCode.G:             return (shift) ? 'G' : 'g';
                case KeyCode.H:             return (shift) ? 'H' : 'h';
                case KeyCode.I:             return (shift) ? 'I' : 'i';
                case KeyCode.J:             return (shift) ? 'J' : 'j';
                case KeyCode.K:             return (shift) ? 'K' : 'k';
                case KeyCode.L:             return (shift) ? 'L' : 'l';
                case KeyCode.M:             return (shift) ? 'M' : 'm';
                case KeyCode.N:             return (shift) ? 'N' : 'n';
                case KeyCode.O:             return (shift) ? 'O' : 'o';
                case KeyCode.P:             return (shift) ? 'P' : 'p';
                case KeyCode.Q:             return (shift) ? 'Q' : 'q';
                case KeyCode.R:             return (shift) ? 'R' : 'r';
                case KeyCode.S:             return (shift) ? 'S' : 's';
                case KeyCode.T:             return (shift) ? 'T' : 't';
                case KeyCode.U:             return (shift) ? 'U' : 'u';
                case KeyCode.V:             return (shift) ? 'V' : 'v';
                case KeyCode.W:             return (shift) ? 'W' : 'w';
                case KeyCode.X:             return (shift) ? 'X' : 'x';
                case KeyCode.Y:             return (shift) ? 'Y' : 'y';
                case KeyCode.Z:             return (shift) ? 'Z' : 'z';
                case KeyCode.NUMPAD_0:      return '0';
                case KeyCode.NUMPAD_1:      return '1';
                case KeyCode.NUMPAD_2:      return '2';
                case KeyCode.NUMPAD_3:      return '3';
                case KeyCode.NUMPAD_4:      return '4';
                case KeyCode.NUMPAD_5:      return '5';
                case KeyCode.NUMPAD_6:      return '6';
                case KeyCode.NUMPAD_7:      return '7';
                case KeyCode.NUMPAD_8:      return '8';
                case KeyCode.NUMPAD_9:      return '9';
                case KeyCode.NUMPAD_STAR:   return '*';
                case KeyCode.NUMPAD_PLUS:   return '+';
                case KeyCode.NUMPAD_MINUS:  return '-';
                case KeyCode.NUMPAD_PERIOD: return '.';
                case KeyCode.NUMPAD_SLASH:  return '/';
                case KeyCode.SEMICOLON:     return (shift) ? ':' : ';';
                case KeyCode.EQUAL:         return (shift) ? '+' : '=';
                case KeyCode.COMMA:         return (shift) ? '<' : ',';
                case KeyCode.MINUS:         return (shift) ? '_' : '-';
                case KeyCode.PERIOD:        return (shift) ? '>' : '.';
                case KeyCode.SLASH:         return (shift) ? '?' : '/';
                case KeyCode.ACCENT:        return (shift) ? '~' : '`';
                case KeyCode.LEFT_BRACKET:  return (shift) ? '{' : '[';
                case KeyCode.FORWARD_SLASH: return (shift) ? '|' : '\\';
                case KeyCode.RIGHT_BRACKET: return (shift) ? '}' : ']';
                case KeyCode.QUOTE:         return (shift) ? '\"': '\'';
                default:                    break;
            }
            return '';
        }

        /**
         * Converts a alphanumeric key code identifier into its corresponding
         * character value using an application-defined keyboard mapping table.
         * @param keyCode The key code to look up.
         * @param keyMap The keyboard mapping table, mapping key code to String.
         * @param shift true if the shift key modifier is active.
         * @return The corresponding string, or an empty string if the key code has no alphanumeric equivalent.
         */
        public static function toCharWithMap(keyCode:uint, keyMap:Array, shift:Boolean = false) : String
        {
            var str:String  = keyMap[keyCode] as String;
            if (str === null) str = '';
            return str;
        }
    }
}
