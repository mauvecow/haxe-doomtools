package doomtools.wad;

import doomtools._internal.*;

class Lump {
    public var name:String = null;
    public var pos:UInt = 0;
    public var len:UInt = 0;
    public var data:haxe.io.Bytes;
    
    public function new() {
    }
    
    public function IsMapStart():Bool {
        var lumpName = name;
        if (lumpName.length == 5
            && lumpName.charCodeAt(0) == 0x4d // 'M'
            && lumpName.charCodeAt(1) == 0x41 // 'A'
            && lumpName.charCodeAt(2) == 0x50  // 'P'
            && lumpName.charCodeAt(3) >= 48 && lumpName.charCodeAt(3) <= (48+9) // 0-9
            && lumpName.charCodeAt(4) >= 48 && lumpName.charCodeAt(4) <= (48+9) // 0-9
        ) {
            return true;
        } else if (lumpName.length == 4
            && lumpName.charCodeAt(0) == 0x45 // 'E'
            && lumpName.charCodeAt(1) >= 48 && lumpName.charCodeAt(1) <= (48+9) // 0-9
            && lumpName.charCodeAt(2) == 0x4d // 'M'
            && lumpName.charCodeAt(3) >= 48 && lumpName.charCodeAt(3) <= (48+9) // 0-9
        ) {
            return true;
        }
        return false;
    }
    
    public function IsMapSublump():Bool {
        switch(name) {
            case "THINGS":
            case "LINEDEFS":
            case "SIDEDEFS":
            case "VERTEXES":
            case "SEGS":
            case "SSECTORS":
            case "NODES":
            case "SECTORS":
            case "REJECT":
            case "BLOCKMAP":
            case "BEHAVIOR":
            default: return false;
        }
        return true;
    }
    
    public function ReadLump(input:haxe.io.Bytes, pos:UInt, len:UInt, name:String, ?offset:UInt = 0) {
        if (offset + pos + len > input.length) {
            throw "Lump.ReadLump Error: Data out of bounds.";
        }
        
        this.name = name;
        this.pos = pos;
        this.len = len;
        this.data = input.sub(offset + pos, len);
    }
}
