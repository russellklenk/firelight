package com.ninjabird.firelight.content.loaders
{
    import flash.utils.Endian;
    import flash.utils.ByteArray;
    import com.ninjabird.firelight.content.archive.TarFile;
    import com.ninjabird.firelight.debug.DebugTrace;
    import com.ninjabird.firelight.font.FontDefinition;
    import com.ninjabird.firelight.font.FontGlyph;

    /**
     * Implements the FileLoader interface to load a BMFont-Binary file.
     */
    public final class FontFileLoader extends FileLoader
    {
        /**
         * The set of file extensions supported by this loader type.
         */
        public static var extensions:Array = ['fnt'];

        /**
         * Creates a new FontFileLoader instance. This function is registered with the FileLoader interface.
         * @return A new FontFileLoader instance.
         */
        public static function factory() : FileLoader
        {
            return new FontFileLoader();
        }

        /**
         * Default Constructor (empty).
         */
        public function FontFileLoader()
        {
            /* empty */
        }

        /**
         * Begins loading the data for a file contained within an archive.
         * @param archive The archive containing the file data.
         * @param filename The name of the file to load within the archive.
         */
        override public function loadFile(archive:TarFile, file:String) : void
        {
            var data:ByteArray  = archive.loadFileBytes(file);
            if (data)
            {
                data.endian     = Endian.LITTLE_ENDIAN;
                var sig1:int    = data.readByte();
                var sig2:int    = data.readByte();
                var sig3:int    = data.readByte();
                var version:int = data.readByte();
                var font:FontDefinition = new FontDefinition();

                if (sig1 !== 66 || sig2 !== 77 || sig3 !== 70)
                {
                    DebugTrace.out('FontFileLoader::loadFile(2) - Invalid signature.');
                    this.notifyFailure(file, 'Invalid file signature.');
                }
                while (data.bytesAvailable)
                {
                    var blockId:int    = data.readByte();
                    var blockSize:uint = data.readUnsignedInt();
                    switch (blockId)
                    {
                        case 1:
                            {
                                var fontSize:int  = data.readShort();
                                var fontFlags:int = data.readByte();
                                var charset:int   = data.readByte();
                                var stretchH:int  = data.readUnsignedShort();
                                var aa:int        = data.readByte();
                                var padUp:int     = data.readByte();
                                var padRight:int  = data.readByte();
                                var padDown:int   = data.readByte();
                                var padLeft:int   = data.readByte();
                                var spacingH:int  = data.readByte();
                                var spacingV:int  = data.readByte();
                                if (version >= 2)   data.readByte(); // outline
                                var name:String   = '';
                                while (true)
                                {
                                    var byte:int  = data.readByte();
                                    if (byte === 0) break;
                                    name += String.fromCharCode(byte);
                                }
                                font.name     = name;
                                font.baseSize = fontSize;
                                font.flags    = fontFlags;
                            }
                            break;

                        case 2:
                            {
                                font.lineHeight = data.readUnsignedShort();
                                font.baseline   = data.readUnsignedShort();
                                font.pageWidth  = data.readUnsignedShort();
                                font.pageHeight = data.readUnsignedShort();
                                var npages:int  = data.readUnsignedShort();
                                font.setPageCount(npages);
                                var packed:int    = data.readByte();
                                font.alphaContent = data.readByte();
                                font.redContent   = data.readByte();
                                font.greenContent = data.readByte();
                                font.blueContent  = data.readByte();
                            }
                            break;

                        case 3:
                            {
                                for (var i:int = 0; i < font.pageCount; ++i)
                                {
                                    var path:String  = '';
                                    while (true)
                                    {
                                        var char:int =  data.readByte();
                                        if (char === 0) break;
                                        path += String.fromCharCode(char);
                                    }
                                    font.addPage(i, path);
                                }
                            }
                            break;

                        case 4:
                            {
                                var nchars:int = blockSize / 20;
                                for (var c:int = 0; c < nchars; ++c)
                                {
                                    var glyph:FontGlyph = new FontGlyph();
                                    glyph.codepoint     = data.readUnsignedInt();
                                    glyph.x             = data.readUnsignedShort();
                                    glyph.y             = data.readUnsignedShort();
                                    glyph.width         = data.readUnsignedShort();
                                    glyph.height        = data.readUnsignedShort();
                                    glyph.offsetX       = data.readUnsignedShort();
                                    glyph.offsetY       = data.readUnsignedShort();
                                    glyph.advanceX      = data.readUnsignedShort();
                                    glyph.pageIndex     = data.readByte() - 1;
                                    glyph.channelFlags  = data.readByte();
                                    font.addGlyph(glyph);
                                }
                            }
                            break;

                        case 5:
                            {
                                var first:uint  = data.readUnsignedInt();
                                var second:uint = data.readUnsignedInt();
                                var advance:int = data.readShort();
                                font.kerningTable.add(first, second, advance);
                            }
                            break;
                    }
                }
                this.notifySuccess(file, font);
            }
            else this.notifyFailure(file, 'File not found in archive.');
        }
    }
}
