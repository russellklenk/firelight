package com.ninjabird.firelight.content.assemblers
{
    import flash.events.EventDispatcher;
    import com.ninjabird.firelight.debug.DebugTrace;
    import com.ninjabird.firelight.content.Content;
    import com.ninjabird.firelight.content.events.ContentAssemblyErrorEvent;
    import com.ninjabird.firelight.content.events.ContentAssemblyCompleteEvent;

    /**
     * Defines the base class for an object that assembles all of the loaded
     * data files for a content item into their standard form.
     */
    public class ContentAssembler extends EventDispatcher
    {
        /**
         * A table of registered ContentAssembler implementations. Keys are
         * strings specifying the content type; values are function () : ContentAssembler.
         */
        public static var assemblerFactories:Object = new Object();

        /**
         * Creates a new ContentAssembler instance for a given content type.
         * @param contentType The content type.
         * @return A ContentAssembler instance, or null.
         */
        public static function create(contentType:String) : ContentAssembler
        {
            if (contentType === null || contentType.length === 0)
            {
                DebugTrace.out('ContentAssembler::create(1) - Invalid content type.');
                return null;
            }

            var key:String       = contentType.toUpperCase();
            var factory:Function = ContentAssembler.assemblerFactories[key] as Function;
            if (factory !== null)  return factory();
            else return null;
        }

        /**
         * Registers a ContentAssembler implementation to handle a content type.
         * @param contentType The content type identifier.
         * @param factory A function () : ContentAssembler that is used to
         * create instances of the ContentAssembler implementation.
         */
        public static function register(contentType:String, factory:Function) : void
        {
            if (contentType === null || contentType.length === 0)
            {
                DebugTrace.out('ContentAssembler::register(2) - No content type specified.');
                throw new ArgumentError('contentType');
            }
            if (factory === null)
            {
                DebugTrace.out('ContentAssembler::register(2) - Invalid factory function.');
                throw new ArgumentError('factory');
            }
            var key:String = contentType.toUpperCase();
            if (ContentAssembler.assemblerFactories[key])
            {
                DebugTrace.out('ContentAssembler::register(2) - Assembler already registered for type \'%s\'.', contentType);
                throw new ArgumentError('contentType');
            }
            else ContentAssembler.assemblerFactories[key] = factory;
        }

        /**
         * Raises an event indicating that the content item was assembled
         * successfully and is ready for use.
         * @param content The content item.
         */
        protected final function notifySuccess(content:Content) : void
        {
            this.dispatchEvent(new ContentAssemblyCompleteEvent(content));
        }

        /**
         * Raises an event indicating that content assembly failed.
         * @param content The content item.
         * @param reason A brief description of the reason for the error.
         */
        protected final function notifyFailure(content:Content, reason:String) : void
        {
            this.dispatchEvent(new ContentAssemblyErrorEvent(content, reason));
        }

        /**
         * Default Constructor (empty).
         */
        public function ContentAssembler()
        {
            /* empty */
        }

        /**
         * Performs content assembly after all data files have been loaded
         * successfully.
         * @param content The content item to assemble.
         * @param fileCache An object mapping filename to runtime data. Do not
         * modify the file cache table.
         */
        public function assemble(content:Content, fileCache:Object) : void
        {
            this.notifyFailure(content, 'No implementation provided for ContentAssembler::assemble(2).');
        }

        /**
         * Disposes of resources associated with the assembler instance.
         */
        public function dispose() : void
        {
            /* empty */
        }
    }
}
