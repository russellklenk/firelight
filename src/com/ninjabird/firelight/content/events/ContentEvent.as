package com.ninjabird.firelight.content.events
{
    /**
     * Defines the names of the events raised by the content runtime system.
     */
    public final class ContentEvent
    {
        /**
         * The event raised to report that the application manifest cannot be loaded.
         * See ApplicationManifestErrorEvent.
         */
        public static const MANIFEST_ERROR:String    = 'manifest:error';

        /**
         * The event raised to report that the application manifest has been loaded.
         * See ApplicationManifestLoadedEvent.
         */
        public static const MANIFEST_LOADED:String   = 'manifest:loaded';

        /**
         * The event raised to report that a content item has been successfully assembled.
         * See ContentAssemblyCompleteEvent.
         */
        public static const ASSEMBLY_COMPLETE:String = 'assembly:complete';

        /**
         * The event raised to report an error during content item assembly.
         * See ContentAssemblyErrorEvent.
         */
        public static const ASSEMBLY_ERROR:String    = 'assembly:error';

        /**
         * The event raised to report that a content item was disposed.
         * See ContentDisposedEvent.
         */
        public static const CONTENT_DISPOSED:String  = 'content:disposed';

        /**
         * The event raised to report that an error occurred while loading the content
         * in a single content package. See ContentPackageErrorEvent.
         */
        public static const PACKAGE_ERROR:String     = 'package:error';

        /**
         * The event raised to report that a single content package has been loaded.
         * See ContentPackageLoadedEvent.
         */
        public static const PACKAGE_LOADED:String    = 'package:loaded';

        /**
         * The event raised to report that an error occurred while loading a content set.
         * See ContentSetErrorEvent.
         */
        public static const SET_ERROR:String         = 'set:error';

        /**
         * The event raised to report that all content in a content set has been loaded
         * and is ready for runtime use. See ContentSetReadyEvent.
         */
        public static const SET_READY:String         = 'set:ready';

        /**
         * The event raised to report that a file cannot be loaded from a content archive.
         * See FileLoadErrorEvent.
         */
        public static const FILE_ERROR:String        = 'file:error';

        /**
         * The event raised to report that a file has been loaded from a content archive.
         * See FileLoadCompleteEvent.
         */
        public static const FILE_LOADED:String       = 'file:loaded';

        /**
         * The event raised to report that a remote resource has finished downloading.
         * See ResourceLoadCompleteEvent.
         */
        public static const RESOURCE_LOADED:String   = 'resource:loaded';

        /**
         * The event raised to report an error when downloading a remote resource.
         * See ResourceLoadErrorEvent.
         */
        public static const RESOURCE_ERROR:String    = 'resource:error';

        /**
         * The event raised to report download progress for a remote resource.
         * See ResourceLoadProgressEvent.
         */
        public static const RESOURCE_PROGRESS:String = 'resource:progress';
    }
}
