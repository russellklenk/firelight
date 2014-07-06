package com.ninjabird.firelight.content.assemblers
{
    import flash.display.DisplayObject;

    /**
     * A class that helps with reflection, and is able to access the classes,
     * functions and symbols within a SWF or SWC.
     */
    public final class ReflectionHelper
    {
        /**
         * Checks to see whether a given symbol exists.
         * @param obj The DisplayObject to query.
         * @param name The name of the symbol to query.
         * @return true of the specified symbol exists; false otherwise.
         */
        public static function isSymbol(obj:DisplayObject, name:String) : Boolean
        {
            if (obj === null) return false;
            if (name === null || name.length === 0) return false;
            return obj.loaderInfo.applicationDomain.hasDefinition(name);
        }

        /**
         * Retrieves a named symbol.
         * @param obj The DisplayObject to query.
         * @param name The name of the symbol to query.
         * @return The specified symbol, or null if no symbol with the specified name exists.
         */
        public static function getSymbol(obj:DisplayObject, name:String) : Object
        {
            var result:Object = null;
            if (obj === null) return null;
            if (name === null || name.length === 0) return false;
            try
            {
                result = obj.loaderInfo.applicationDomain.getDefinition(name);
            }
            catch (e:*)
            {
                result = null;
            }
            return result;
        }

        /**
         * Retrieves a named class definition.
         * @param obj The DisplayObject to query.
         * @param name The name of the class definition.
         * @return The specified class definition, or null if no class with the specified name exists.
         */
        public static function getClass(obj:DisplayObject, name:String) : Class
        {
            var result:Class = null;
            if (obj === null) return null;
            if (name === null || name.length === 0) return null;
            try
            {
                result = obj.loaderInfo.applicationDomain.getDefinition(name) as Class;
            }
            catch (e:*)
            {
                result = null;
            }
            return result;
        }

        /**
         * Retrieves a named function.
         * @param obj The DisplayObject to query.
         * @param name The name of the function.
         * @return The specified function, or null if no function with the specified name exists.
         */
        public static function getFunction(obj:DisplayObject, name:String) : Function
        {
            var result:Function = null;
            if (obj === null) return null;
            if (name === null || name.length === 0) return null;
            try
            {
                result = obj.loaderInfo.applicationDomain.getDefinition(name) as Function;
            }
            catch (e:*)
            {
                result = null;
            }
            return result;
        }
    }
}
