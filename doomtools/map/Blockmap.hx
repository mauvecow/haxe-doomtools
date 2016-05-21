package doomtools.map;

import doomtools._internal.*;

class Blockmap {
    // Do we honestly need blockmaps to be stored human readable?
    // For now, let's just store an array of ints, and the generator can convert.
    public var data = new Array<Int>();
    
    public function new() {
    }
    
    public function ReadLump(lump:doomtools.wad.Lump) {
        var lumpData = lump.data;
        data = new Array<Int>();
        for (i in 0...(lumpData.length >> 1)) {
            data[i] = Tools.ReadInt16(lumpData, i * 2);
        }
    }
    
    public function WriteLump():doomtools.wad.Lump {
        // - Write all data.
        var lumpData:haxe.io.Bytes = null;
        var size = data.length * 2;
        if (size > 0) {
            lumpData = haxe.io.Bytes.alloc(data.length * 2);
            for (i in 0...data.length) {
                Tools.WriteInt16(lumpData, i * 2, data[i]);
            }
        }
        
        // - Output the lump.
        var lump = new doomtools.wad.Lump();
        lump.name = "BLOCKMAP";
        lump.pos = 0;
        lump.len = size;
        lump.data = lumpData;
        
        return lump;
    }
}
