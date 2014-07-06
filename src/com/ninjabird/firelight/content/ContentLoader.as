package com.ninjabird.firelight.content
{
    import com.ninjabird.firelight.content.events.ContentEvent;

    import flash.net.URLLoaderDataFormat;
    import flash.utils.getTimer;
    import flash.utils.ByteArray;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import com.ninjabird.firelight.debug.DebugTrace;
    import com.ninjabird.firelight.content.events.FileLoadErrorEvent;
    import com.ninjabird.firelight.content.events.FileLoadCompleteEvent;
    import com.ninjabird.firelight.content.events.ContentSetErrorEvent;
    import com.ninjabird.firelight.content.events.ContentSetReadyEvent;
    import com.ninjabird.firelight.content.events.ResourceLoadErrorEvent;
    import com.ninjabird.firelight.content.events.ResourceLoadProgressEvent;
    import com.ninjabird.firelight.content.events.ResourceLoadCompleteEvent;
    import com.ninjabird.firelight.content.events.ContentPackageErrorEvent;
    import com.ninjabird.firelight.content.events.ContentPackageLoadedEvent;
    import com.ninjabird.firelight.content.events.ContentAssemblyErrorEvent;
    import com.ninjabird.firelight.content.events.ContentAssemblyCompleteEvent;
    import com.ninjabird.firelight.content.events.ApplicationManifestErrorEvent;
    import com.ninjabird.firelight.content.events.ApplicationManifestLoadedEvent;

    /**
     * Maintains global state for outstanding content requests and manages
     * background downloading and foreground parsing of resource packages.
     */
    public final class ContentLoader extends EventDispatcher
    {
        /**
         * The string used to indicate the latest version of content data.
         */
        public static const LATEST_VERSION:String = 'latest';

        /**
         * The name of the current application. This is used to identify the
         * application manifest to download.
         */
        public var applicationName:String;

        /**
         * The name of the runtime platform.
         */
        public var platformName:String;

        /**
         * The version of the content to load from the application manifest.
         */
        public var version:String;

        /**
         * An object defining metadata for the content packages for the active
         * content version. Keys are content package names.
         */
        public var versionData:Object;

        /**
         * The application manifest.
         */
        public var manifest:Object;

        /**
         * A table mapping a string name to the associated ContentSet.
         */
        public var setsByName:Object;

        /**
         * A table mapping a string name to the associated ContentPackage.
         */
        public var packagesByName:Object;

        /**
         * The ContentServer used to manage downloading of resources from the
         * remote file servers.
         */
        public var server:ContentServer;

        /**
         * The set of content sets defined by the application.
         */
        public var contentSets:Vector.<ContentSet>;

        /**
         * The set of content packages defined in the application manifest.
         */
        public var packages:Vector.<ContentPackage>;

        /**
         * The set of content packages that have not yet finished loading.
         */
        public var unpackQueue:Vector.<ContentPackage>;

        /**
         * Callback invoked when the content server reports an error downloading a content package.
         * @param ev Additional information about the event.
         */
        private function handleServerError(ev:ResourceLoadErrorEvent) : void
        {
            if (ev.requestId !== 'manifest')
            {
                var pack:ContentPackage = this.packagesByName[ev.requestId];
                if (pack)
                {
                    this.dispatchEvent(new ContentSetErrorEvent(
                        pack.contentSet, pack.friendlyName, ev.errorMessage));
                }
            }
            else this.dispatchEvent(new ApplicationManifestErrorEvent(
                ev.resourceUrl, ev.errorMessage));
        }

        /**
         * Callback invoked when the content server reports progress while downloading a content package.
         * @param ev Additional information about the event.
         */
        private function handleServerProgress(ev:ResourceLoadProgressEvent) : void
        {
            if (ev.requestId !== 'manifest')
            {
                var pack:ContentPackage = this.packagesByName[ev.requestId];
                if (pack)
                {
                    pack.contentSet.updatePackageProgress(
                        pack.friendlyName,
                        ev.bytesLoaded,
                        ev.bytesTotal);
                }
            }
        }

        /**
         * Callback invoked when the content server has finished downloading a content package.
         * @param ev Additional information about the event.
         */
        private function handleServerComplete(ev:ResourceLoadCompleteEvent) : void
        {
            if (ev.requestId !== 'manifest')
            {
                var pack:ContentPackage = this.packagesByName[ev.requestId];
                if (pack)
                {
                    pack.loadArchive(ev.resourceData as ByteArray);
                    this.unpackQueue.push(pack);
                }
            }
            else this.processApplicationManifest(ev.resourceData as String);
        }

        /**
         * Callback invoked when an error occurs while downloading, unpacking or preparing a content package.
         * @param ev Additional information about the event.
         */
        private function handlePackageError(ev:ContentPackageErrorEvent) : void
        {
            var pack:ContentPackage = ev.target as ContentPackage;
            this.unpackQueue.shift();
            pack.removeEventListener(ContentEvent.PACKAGE_ERROR,  this.handlePackageError);
            this.removeEventListener(ContentEvent.PACKAGE_LOADED, this.handlePackageLoaded);
            this.dispatchEvent(new ContentSetErrorEvent(pack.contentSet, pack.friendlyName, ev.errorMessage));
        }

        /**
         * Callback invoked when a content package has been fully downloaded,
         * unpacked and loaded into its content set.
         * @param ev Additional information about the event.
         */
        private function handlePackageLoaded(ev:ContentPackageLoadedEvent) : void
        {
            var pack:ContentPackage = ev.target as ContentPackage;
            this.unpackQueue.shift();
            this.removeEventListener(ContentEvent.PACKAGE_ERROR,  this.handlePackageError);
            this.removeEventListener(ContentEvent.PACKAGE_LOADED, this.handlePackageLoaded);
            if (this.checkContentSet(pack.contentSet.name))
            {
                this.dispatchEvent(new ContentSetReadyEvent(pack.contentSet));
            }
        }

        /**
         * Parses the data representing the application manifest.
         * @param manifestData The JSON-encoded application manifest data.
         */
        private function processApplicationManifest(manifestData:String) : void
        {
            this.manifest      = JSON.parse(manifestData);
            this.versionData   = this.manifest[this.version];
            var bundles:Object = this.versionData.packages[this.platformName];
            for (var i:int = 0;  i < bundles.length; ++i)
            {
                var packageName:String      = bundles[i].name;
                var filename:String         = bundles[i].file;
                var existing:ContentPackage = this.packagesByName[packageName];
                if (existing)
                {
                    existing.unload(false);
                    existing.filename   = filename;
                    var unpackIndex:int = this.unpackQueue.indexOf(existing);
                    if (unpackIndex >= 0) this.unpackQueue.splice (unpackIndex, 1);
                }
                else
                {
                    existing = new ContentPackage(packageName, filename);
                    this.packagesByName[packageName] = existing;
                    this.packages.push(existing);
                }
            }
            this.dispatchEvent(new ApplicationManifestLoadedEvent(this.manifest, this.versionData, this.packages));
        }

        /**
         * Constructs a new instance initialized with default values.
         */
        public function ContentLoader()
        {
            this.applicationName = '';
            this.platformName    = '';
            this.version         = '';
            this.server          = null;
            this.versionData     = new Object();
            this.manifest        = new Object();
            this.setsByName      = new Object();
            this.packagesByName  = new Object();
            this.contentSets     = new Vector.<ContentSet>();
            this.packages        = new Vector.<ContentPackage>();
            this.unpackQueue     = new Vector.<ContentPackage>();
        }

        /**
         * Connects the loader to a content server, and specifies basic
         * application and platform attributes.
         * @param contentServer The ContentServer used to manage downloading of
         * application content packages.
         * @param appName The application name, used to locate the application
         * manifest on the server.
         * @param platform The name of the current runtime platform.
         * @return true if content loading can proceed,
         */
        public function connect(contentServer:ContentServer, appName:String, platform:String, versionId:String=ContentLoader.LATEST_VERSION) : Boolean
        {
            if (appName == null || appName.length == 0)
            {
                DebugTrace.out('ContentLoader::connect(3) - Invalid application name.');
                return false;
            }
            if (platform == null || platform.length == 0)
            {
                DebugTrace.out('ContentLoader::connect(3) - Invalid runtime platform.');
                return false;
            }
            if (contentServer == null)
            {
                DebugTrace.out('ContentLoader::connect(3) - Invalid content server.');
                return false;
            }
            this.applicationName = appName;
            this.platformName    = platform;
            this.version         = versionId;
            this.server          = contentServer;
            this.server.addEventListener(ContentEvent.RESOURCE_ERROR,    this.handleServerError);
            this.server.addEventListener(ContentEvent.RESOURCE_LOADED,   this.handleServerComplete);
            this.server.addEventListener(ContentEvent.RESOURCE_PROGRESS, this.handleServerProgress);
            this.loadApplicationManifest();
            return true;
        }

        /**
         * Disconnects the loader from the content server.
         */
        public function disconnect() : void
        {
            if (this.server)
            {
                this.server.removeEventListener(ContentEvent.RESOURCE_ERROR,    this.handleServerError);
                this.server.removeEventListener(ContentEvent.RESOURCE_LOADED,   this.handleServerComplete);
                this.server.removeEventListener(ContentEvent.RESOURCE_PROGRESS, this.handleServerProgress);
                this.server = null;
            }
        }

        /**
         * Creates or retrieves a content set with a given name.
         * @param setName The name of the content set.
         * @return The interface to the content set.
         */
        public function contentSet(setName:String) : ContentSet
        {
            var existing:ContentSet = this.setsByName[setName];
            if (existing) return existing;
            else
            {
                existing  = new ContentSet(setName);
                this.setsByName[setName] = existing;
                this.contentSets.push(existing);
                return existing;
            }
        }

        /**
         * Requests the application manifest from the content server. This is
         * the first step in the content loading process after the content
         * server is connected to the loader. An ApplicationManifestLoadedEvent
         * is emitted when the application manifest has been downloaded and
         * parsed.
         */
        public function loadApplicationManifest() : void
        {
            if (this.server)
            {
                var requestId:String    = 'manifest';
                var resourceName:String = this.applicationName + '.manifest';
                var responseType:String = URLLoaderDataFormat.TEXT;
                this.server.requestResource(requestId, resourceName, responseType);
            }
        }

        /**
         * Loads the group of content packages that make up a content set. A
         * ContentSetReadyEvent is emitted when all content has been loaded and
         * is available for use.
         * @param setName The name of the content set to load.
         * @param true if loading was started successfully.
         */
        public function loadContentSet(setName:String) : Boolean
        {
            var group:ContentSet = this.setsByName[setName];
            if (group === null)
            {
                DebugTrace.out('Request to load unknown content set \'%s\'; ignoring.', setName);
                return false;
            }
            if (group.packageList.length === 0)
            {
                DebugTrace.out('Request to load empty content set \'%s\'; ignoring.', setName);
                return false;
            }

            var packageNames:Vector.<String> = group.packageList;
            for (var i:int = 0; i < packageNames.length; ++i)
            {
                var pack:ContentPackage = this.packagesByName[packageNames[i]];
                if (pack === null)
                {
                    DebugTrace.out('Request to load unknown package \'%s\'.', packageNames[i]);
                    return false;
                }
                if (pack.contentSet !== null)
                {
                    DebugTrace.out('Content package \'%s\' already bound to target \'%s\'.', packageNames[i], pack.contentSet.name);
                    return false;
                }

                // bind the content set to the package.
                pack.contentSet = group;
                pack.contentSet.updatePackageProgress(packageNames[i], 0, 0);
                pack.addEventListener(ContentEvent.PACKAGE_ERROR,  this.handlePackageError);
                pack.addEventListener(ContentEvent.PACKAGE_LOADED, this.handlePackageLoaded);

                // request the archive from the content server.
                var resourceId:String   = packageNames[i];
                var resourceName:String = pack.filename;
                var responseType:String = URLLoaderDataFormat.BINARY;
                this.server.requestResource(resourceId, resourceName, responseType);
            }
            return true;
        }

        /**
         * Unloads and deletes an existing content set. All content defined in
         * the set is disposed of, and becomes invalid.
         * @param setName The name of the content set to delete.
         */
        public function unloadContentSet(setName:String) : void
        {
            var group:ContentSet = this.setsByName[setName];
            if (group)
            {
                // dispose of all associated content packages.
                for (var packageName:String in group.packageList)
                {
                    var pack:ContentPackage  = this.packagesByName[packageName];
                    if (pack)
                    {
                        delete this.packagesByName[packageName];
                        var packIndex:int   = this.packages.indexOf(pack);
                        if (packIndex >= 0)   this.packages.splice (packIndex, 1);
                        var unpackIndex:int = this.unpackQueue.indexOf(pack);
                        if (unpackIndex >= 0) this.unpackQueue.splice (unpackIndex, 1);
                        pack.removeEventListener(ContentEvent.PACKAGE_ERROR,  this.handlePackageError);
                        pack.removeEventListener(ContentEvent.PACKAGE_LOADED, this.handlePackageLoaded);
                        pack.dispose();
                    }
                }
                // now dispose of the content and content set.
                delete this.setsByName[setName];
                var setIndex:int = this.contentSets.indexOf(group);
                if (setIndex >= 0) this.contentSets.splice (setIndex, 1);
                group.dispose();
            }
        }

        /**
         * Determines whether a content set is ready for runtime use, with all
         * content having been loaded into runtime-ready form.
         * @param setName The name of the content set to check.
         * @return true if the content set is complete.
         */
        public function checkContentSet(setName:String) : Boolean
        {
            var group:ContentSet = this.setsByName[setName];
            if (group === null)  return false;

            var packageNames:Vector.<String> = group.packageList;
            for (var i:int = 0; i < packageNames.length; ++i)
            {
                var pack:ContentPackage = this.packagesByName[packageNames[i]];
                if (pack === null) return false;
                else if (!pack.isLoaded) return false;
            }
            return true;
        }

        /**
         * Executes a single update tick on the main UI thread where downloaded
         * content packages are unpacked and transformed into runtime resources.
         * @param maxTime The maximum number of milliseconds to spend loading.
         */
        public function unpackResources(maxTime:int) : void
        {
            var startTime:int = getTimer();
            var currTime:int  = startTime;
            while ((currTime  - startTime) < maxTime)
            {
                if (this.unpackQueue.length === 0)
                    return;

                var bundle:ContentPackage = this.unpackQueue[0];
                if (bundle.unpack())
                {
                    // the content package is in a wait state.
                    // allow the application to use the remaining time.
                    return;
                }
                currTime = getTimer();
            }
        }
    }
}
