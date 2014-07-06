package com.ninjabird.firelight.content
{
    /**
     * Defines various utility functions for working with path strings.
     */
    public class PathHelper
    {
        /**
         * Remove any path separator characters from the start of a path.
         * @param str The path string.
         * @return The input string with any leading path separators removed.
         */
        public static function removeLeadingSlash(str:String) : String
        {
            if (str)
            {
                var  num:int   = 0;
                for (var i:int = 0, n:int = str.length; i < n; ++i)
                {
                    var chi:int = str.charCodeAt(i);
                    if (chi !== 47 && chi !== 92)
                        break;
                    ++num;
                }
                if (num === 0) return str;
                else return str.slice(num);
            }
            else return '';
        }

        /**
         * Remove any path separator characters from the end of a path.
         * @param str The path string.
         * @return The input string with any trailing path separators removed.
         */
        public static function removeTrailingSlash(str:String) : String
        {
            if (str)
            {
                var  len:int   = str.length;
                var  num:int   = 0;
                for (var i:int = len - 1; i >= 0; --i)
                {
                    var chi:int = str.charCodeAt(i);
                    if (chi !== 47 && chi !== 92)
                        break;
                    ++num;
                }
                if (num === 0) return str;
                if (num === len) return '';
                else return str.slice(0, len - num);
            }
            else return '';
        }

        /**
         * Joins one or more path components into a single path.
         * @param ...varargs The set of path components.
         * @return The combined path.
         */
        public static function join(...varargs) : String
        {
            return PathHelper.join_array(varargs);
        }

        /**
         * Joins one or more path components into a single path.
         * @param paths The set of path components.
         * @return The combined path.
         */
        public static function join_array(paths:Array) : String
        {
            for (var i:int = 0, n:int = paths.length; i < n; ++i)
            {
                paths[i] = PathHelper.removeTrailingSlash(paths[i] as String);
            }
            return paths.join('/');
        }

        /**
         * Standardizes the directory separator characters in a path string.
         * @param path The path string.
         * @return The path string, with '/' as the directory separator.
         */
        public static function normalize(path:String) : String
        {
            if (path && path.indexOf('\\') >= 0)
            {
                var parts:Array = path.split('\\');
                return parts.join('/');
            }
            return path;
        }

        /**
         * Extracts the directory portion of a path (anything up to, but not
         * including, the last path separator character.)
         * @param path The input path.
         * @return The directory portion of the specified path.
         */
        public static function dirname(path:String) : String
        {
            if (path)
            {
                var normPath:String = PathHelper.normalize(path);
                var lastForward:int = normPath.lastIndexOf('/');
                if (lastForward > 0)  return normPath.slice(0, lastForward);
                else return '';
            }
            else return '';
        }

        /**
         * Extracts the filename (or last directory name) portion of a path,
         * that is, anything after the last path separator character.
         * @param path The input path.
         * @return The base portion of the specified path.
         */
        public static function basename(path:String) : String
        {
            if (path)
            {
                var normPath:String = PathHelper.normalize(path);
                var lastForward:int = normPath.lastIndexOf('/');
                if (lastForward > 0)  return normPath.slice(lastForward+1);
                else return normPath;
            }
            else return '';
        }

        /**
         * Returns the file extension portion of a path, that is, anything
         * after (and including) the last period character.
         * @param path The input path.
         * @return The extension portion of the specified path.
         */
        public static function extname(path:String) : String
        {
            if (path)
            {
                // @note if lastPeriod is 0, this is most likely a hidden file
                // and not a file extension, so in this case, return empty.
                var lastPeriod:int = path.lastIndexOf('.');
                if (lastPeriod > 0) return path.slice(lastPeriod);
                else return '';
            }
            else return '';
        }
    }
}
