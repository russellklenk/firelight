package com.ninjabird.firelight.debug
{
    /**
     * Wraps the built-in Flash Player trace() function and extends it to allow
     * for printf-style string formatting.
     */
    public final class DebugTrace
    {
        /**
         * Internal helper function used by sprintf to handle formatting.
         * @param match The match object to process.
         * @param nosign A value indicating whether sign should be suppressed.
         * @return The formatted value.
         */
        private static function sprintfCvt(match:*, nosign:Boolean) : String
        {
            if (nosign)
            {
                match.sign = '';
            }
            else
            {
                match.sign = match.negative ? '-' : match.sign;
            }

            var len:int    = match.min - match.argument.length + 1 - match.sign.length;
            var pad:String = new Array(len < 0 ? 0 : len).join(match.pad);
            var res:String = '';

            if (!match.left)
            {
                if (match.pad == '0' || nosign)
                {
                    res = match.sign + pad + match.argument;
                }
                else
                {
                    res = pad + match.sign + match.argument;
                }
            }
            else
            {
                if (match.pad == '0' || nosign)
                {
                    res = match.sign + match.argument + pad.replace(/0/g, ' ');
                }
                else
                {
                    res = match.sign + match.argument + pad;
                }
            }
            return res;
        }

        /**
         * Performs string formatting equivalent to the sprintf function from the CRT.
         * @param fmt The format string (required).
         * @param ...varargs Optional substitution arguments (variable-length).
         * @return The formatted string.
         */
        public static function sprintf(fmt:String, ...varargs) : String
        {
            return DebugTrace.sprintfArray(fmt, varargs);
        }

        /**
         * Performs string formatting equivalent to the sprintf function from the CRT.
         * @param fmt The format string (required).
         * @param varargs Substitution arguments (variable-length).
         * @return The formatted string.
         */
        public static function sprintfArray(fmt:String, varargs:Array) : String
        {
            if (null == fmt)
            {
                // return an empty string:
                return '';
            }
            if (0 == fmt.length || fmt.indexOf('%') < 0)
            {
                // early out - no formatting needed:
                return fmt;
            }

            var exp:RegExp              = /(%([%]|(\-)?(\+|\x20)?(0)?(\d+)?(\.(\d)?)?([bcdfosxX])))/g;
            var matches:Vector.<Object> = new Vector.<Object>();
            var strings:Vector.<Object> = new Vector.<Object>();
            var convCount:int           = 0;
            var strPosStart:int         = 0;
            var strPosEnd:int           = 0;
            var matchPosEnd:int         = 0;
            var formatted:String        = '';
            var code:String             = null;
            var subst:String            = '';
            var match:*                 = null;

            while ((match = exp.exec(fmt)) !== null)
            {
                if (match[9])
                {
                    convCount += 1;
                }
                strPosStart             = matchPosEnd;
                strPosEnd               = exp.lastIndex - match[0].length;
                strings[strings.length] = fmt.substring(strPosStart, strPosEnd);
                matchPosEnd             = exp.lastIndex;
                matches.push(
                {
                    match:     match[0],
                    left:      match[3] ? true : false,
                    sign:      match[4] || '',
                    pad:       match[5] || ' ',
                    min:       match[6] || 0,
                    precision: match[8],
                    code:      match[9] || '%',
                    negative:  parseInt(varargs[convCount - 1]) < 0 ? true : false,
                    argument:  String(varargs[convCount - 1])
                });
            }
            strings.push(fmt.substring(matchPosEnd));

            if (0 == matches.length)
            {
                // no formatting needed:
                return fmt;
            }
            if (convCount > varargs.length)
            {
                // argument count mismatch:
                return fmt;
            }

            for (var i:int = 0; i < matches.length; ++i)
            {
                code = matches[i].code;

                if ('%' == code)
                {
                    // %% - escaped percent sign.
                    subst = '%';
                }
                else if ('b' == code)
                {
                    // binary-formatted value.
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(2));
                    subst               = DebugTrace.sprintfCvt(matches[i], true);
                }
                else if ('c' == code)
                {
                    // character code value.
                    matches[i].argument = String(String.fromCharCode(Math.abs(parseInt(matches[i].argument))));
                    subst               = DebugTrace.sprintfCvt(matches[i], true);
                }
                else if ('d' == code)
                {
                    // signed decimal value.
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)));
                    subst               = DebugTrace.sprintfCvt(matches[i], false);
                }
                else if ('u' == code)
                {
                    // unsigned decimal value.
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)));
                    subst               = DebugTrace.sprintfCvt(matches[i], true);
                }
                else if ('f' == code)
                {
                    // floating-point value.
                    matches[i].argument = String(Math.abs(parseFloat(matches[i].argument)).toFixed(matches[i].precision ? matches[i].precision : 6));
                    subst               = DebugTrace.sprintfCvt(matches[i], false);
                }
                else if ('o' == code)
                {
                    // octal value.
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(8));
                    subst               = DebugTrace.sprintfCvt(matches[i], false);
                }
                else if ('s' == code)
                {
                    // string value.
                    matches[i].argument = matches[i].argument.substring(0, matches[i].precision ? matches[i].precision : matches[i].argument.length);
                    subst               = DebugTrace.sprintfCvt(matches[i], true);
                }
                else if ('x' == code)
                {
                    // hexadecimal value (lower-case digits).
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(16));
                    subst               = DebugTrace.sprintfCvt(matches[i], false);
                }
                else if ('X' == code)
                {
                    // hexadecimal value (upper-case digits).
                    matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(16));
                    subst               = DebugTrace.sprintfCvt(matches[i], false).toUpperCase();
                }
                else
                {
                    // unknown format specifier - do nothing.
                    subst = matches[i].match;
                }

                formatted += strings[i];
                formatted += subst;
            }
            formatted += strings[i];
            return formatted;
        }

        /**
         * Sends a trace message any enabled trace endpoints.
         * @param format The printf/sprintf-style format string.
         * @param ... args Variable length argument list.
         */
        public static function out(format:String, ... args) : void
        {
            if (DebugSettings.debugEnabled && DebugSettings.traceEnabled)
            {
                try
                {
                    trace(DebugTrace.sprintfArray(format, args));
                }
                catch (e:*)
                {
                    /* empty */
                }
            }
        }
    }
}
