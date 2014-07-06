package com.ninjabird.firelight.renderer
{
    /**
     * Stores metadata associated with a shader program.
     */
    public dynamic class ProgramDesc
    {
        /**
         * The handle of the program within the resource pool.
         */
        public var programHandle:int;

        /**
         * Default constructor (empty).
         */
        public function ProgramDesc()
        {
            this.programHandle = -1;
        }
    }
}
