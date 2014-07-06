package com.ninjabird.firelight.content
{
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLRequestHeader;
    import flash.net.URLLoaderDataFormat;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import com.ninjabird.firelight.debug.DebugTrace;
    import com.ninjabird.firelight.content.events.ResourceLoadErrorEvent;
    import com.ninjabird.firelight.content.events.ResourceLoadProgressEvent;
    import com.ninjabird.firelight.content.events.ResourceLoadCompleteEvent;

    /**
     * The ContentServer manages downloading of application manifest files and content package archives.
     */
    public final class ContentServer extends EventDispatcher
    {
        /**
         * The control server URL (used during development).
         */
        public var controlUrl:String;

        /**
         * THe content server URL.
         */
        public var contentUrl:String;

        /**
         * Callback invoked when a progress event is raised by a ResourceLoader.
         * @param ev Additional information about the event.
         */
        private function handleProgress(ev:ProgressEvent) : void
        {
            var loader:ResourceLoader = ev.target as ResourceLoader;
            this.dispatchEvent(new ResourceLoadProgressEvent(
                loader.requestId,
                loader.requestUrl,
                loader.resource,
                loader.dataFormat,
                ev.bytesLoaded,
                ev.bytesTotal)
            );
        }

        /**
         * Callback invoked when a completion event is raised by a
         * ResourceLoader for an application manifest or content archive.
         * @param ev Additional information about the event.
         */
        private function handleComplete(ev:Event) : void
        {
            var loader:ResourceLoader = ev.target as ResourceLoader;
            DebugTrace.out('Finished receiving %s', loader.requestUrl);
            this.dispatchEvent(new ResourceLoadCompleteEvent(
                loader.requestId,
                loader.requestUrl,
                loader.resource,
                loader.dataFormat,
                loader.data)
            );
            this.cleanupResourceLoader(loader);
        }

        /**
         * Callback invoked when an I/O error event is raised by a
         * ResourceLoader.
         * @param ev Additional information about the event.
         */
        private function handleIOError(ev:IOErrorEvent) : void
        {
            var loader:ResourceLoader = ev.target as ResourceLoader;
            DebugTrace.out('Error loading %s: %s', loader.requestUrl, ev.text);
            this.dispatchEvent(new ResourceLoadErrorEvent(
                loader.requestId,
                loader.requestUrl,
                loader.resource,
                loader.dataFormat,
                ev.text)
            );
            this.cleanupResourceLoader(loader);
        }

        /**
         * Callback invoked when a security error is raised by a ResourceLoader.
         * @param ev Additional information about the event.
         */
        private function handleSecurityError(ev:SecurityErrorEvent) : void
        {
            var loader:ResourceLoader = ev.target as ResourceLoader;
            DebugTrace.out('Error loading %s: %s', loader.requestUrl, ev.text);
            this.dispatchEvent(new ResourceLoadErrorEvent(
                loader.requestId,
                loader.requestUrl,
                loader.resource,
                loader.dataFormat,
                ev.text)
            );
            this.cleanupResourceLoader(loader);
        }

        /**
         * Performs cleanup operations for a ResourceLoader representing a
         * download request, removing event listeners so it can be GC'd.
         * @param loader The ResourceLoader to clean up.
         */
        private function cleanupResourceLoader(loader:ResourceLoader) : void
        {
            loader.removeEventListener(Event.COMPLETE, this.handleComplete);
            loader.removeEventListener(ProgressEvent.PROGRESS, this.handleProgress);
            loader.removeEventListener(IOErrorEvent.IO_ERROR,  this.handleIOError);
            loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.handleSecurityError);
            loader.data = null;
        }

        /**
         * Constructs a new instance initialized with the specified content
         * server URL.
         * @param serverUrl The base URL used to retrieve content for the
         * application, including port number.
         */
        public function ContentServer(serverUrl:String='')
        {
            this.controlUrl = null;
            this.contentUrl = serverUrl;
        }

        /**
         * Requests a resource be loaded from the content server.
         * @param id An application-defined identifier for the request. This
         * value will be passed back to the application when the request has
         * completed, and also with progress events.
         * @param resourceName The relative path and filename of the resource
         * being requested. The path is specified relative to a previously
         * registered server base URL.
         * @param format The desired interpretation of the data returned by the
         * server. See @a flash.net.URLLoaderDataFormat. The default is binary.
         * @return The ResourceLoader representing the request.
         */
        public function requestResource(id:String, resourceName:String, format:String=URLLoaderDataFormat.BINARY) : ResourceLoader
        {
            var loader:ResourceLoader = null;
            var request:URLRequest    = null;
            var requestUrl:String     = null;

            if (this.contentUrl === null || this.contentUrl.length === 0)
            {
                DebugTrace.out('ContentServer::requestResource(4) - Ignoring request for \'%s\'; no server specified.', resourceName);
                return null;
            }

            // construct the URL of the resource.
            requestUrl = this.contentUrl;
            if (requestUrl.charAt(requestUrl.length - 1) !== '/')
            {
                requestUrl += '/';
            }
            requestUrl += resourceName;

            // build the URL request for the resource.
            // @note: Flash won't allow us to set the 'Accept-Encoding' header.
            request           = new URLRequest(requestUrl);
            request.method    = URLRequestMethod.GET;

            // now initialize the loader to execute the request.
            // set some dynamic properties on the loader so that we
            // can adjust the load factor and pass the request ID with events.
            loader            = new ResourceLoader();
            loader.requestId  = id;
            loader.dataFormat = format;
            loader.resource   = resourceName;
            loader.requestUrl = requestUrl;
            loader.addEventListener(Event.COMPLETE,                    this.handleComplete);
            loader.addEventListener(ProgressEvent.PROGRESS,            this.handleProgress);
            loader.addEventListener(IOErrorEvent.IO_ERROR,             this.handleIOError );
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.handleSecurityError);
            loader.load(request);
            return loader;
        }
    }
}
