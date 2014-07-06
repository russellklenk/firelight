package com.ninjabird.firelight.content.events
{
    import flash.events.Event;
    import com.ninjabird.firelight.content.ContentPackage;

    /**
     * Defines a custom event type raised when the application content manifest
     * has been downloaded and parsed.
     */
    public final class ApplicationManifestLoadedEvent extends Event
    {
        /**
         * The parsed application manifest.
         */
        public var manifest:Object;

        /**
         * The set of content packages and other metadata defined for the
         * requested version.
         */
        public var version:Object;

        /**
         * The set of content package objects defined for the requested version.
         */
        public var packages:Vector.<ContentPackage>;

        /**
         * Constructor function for an event type raised when the application manifest has been downloaded and parsed.
         * @param manifestData The parsed application manifest.
         * @param versionInfo The metadata defined for the current version.
         * @param packageList The set of packages defined for the current version.
         * @param type The name of the event.
         * @param bubbles true if the event will bubble up.
         * @param cancelable true if the event is cancelable.
         */
        public function ApplicationManifestLoadedEvent(manifestData:Object, versionInfo:Object, packageList:Vector.<ContentPackage>, type:String=ContentEvent.MANIFEST_LOADED, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this.manifest = manifestData;
            this.version  = versionInfo;
            this.packages = packageList;
        }

        /**
         * Creates a new event instance with the same fields as this instance.
         * @return A new ApplicationManifestLoadedEvent instance.
         */
        override public function clone() : Event
        {
            return new ApplicationManifestLoadedEvent(this.manifest, this.version, this.packages, type, bubbles, cancelable);
        }
    }
}
