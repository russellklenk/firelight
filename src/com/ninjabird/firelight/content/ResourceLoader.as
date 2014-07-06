package com.ninjabird.firelight.content
{
    import flash.net.URLLoader;
    import flash.net.URLRequest;

    /**
     * Extends flash.net.URLLoader to add several additional fields for
     * storing request properties.
     */
    public final class ResourceLoader extends URLLoader
    {
        /**
         * The relative path to the requested resource.
         */
        public var resource:String;

        /**
         * A unique application-defined identifier for the request.
         */
        public var requestId:String;

        /**
         * The absolute URL being requested.
         */
        public var requestUrl:String;

        /**
         * Creates a ResourceLoader object.
         * @param request A URLRequest object specifying the URL to download.
         * If this parameter is omitted, no load operation begins. If specified,
         * the load operation begins immediately.
         */
        public function ResourceLoader(request:URLRequest=null)
        {
            super(request);
            this.resource   = '';
            this.requestId  = '';
            this.requestUrl = '';
        }
    }
}
