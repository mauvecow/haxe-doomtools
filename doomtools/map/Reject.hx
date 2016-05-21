package doomtools.map;

import doomtools._internal.*;

class Reject {
    public var rejectmatrix = new Array<Int>();
    
    public function new() {
    }
    
    public function ReadLump(lump:doomtools.wad.Lump) {
        // - Convert all the byte data to our own byte array.
        var matrix = new Array<Int>();
        rejectmatrix = matrix;
        
        var data = lump.data;
        for (i in 0...data.length) {
            matrix[i] = data.get(i);
        }
    }
    
    public function WriteLump():doomtools.wad.Lump {
        // - Copy matrix to a new Bytes chunk.
        var matrix = rejectmatrix;
        var len = matrix.length;
        var data:haxe.io.Bytes = null;
        if (len > 0) {
            data = haxe.io.Bytes.alloc(matrix.length);
            for (i in 0...len) {
                data.set(i, matrix[i]);
            }
        }
        
        // - Write Lump data.
        var lump = new doomtools.wad.Lump();
        lump.name = "REJECT";
        lump.pos = 0;
        lump.len = rejectmatrix.length;
        lump.data = data;
        
        return lump;
    }
    
    public function DebugPrint(sectorCount:Int) {
        var rejectTable = rejectmatrix;
        for (y in 0...sectorCount) {
            Sys.print('$y ');
            if (y < 10) {
                Sys.print('  ');
            } else if (y < 100) {
                Sys.print(' ');
            }
            
            var baseIndex = (y * sectorCount);
            for (x in 0...sectorCount) {
                var index = baseIndex + x;
                var v = rejectTable[index >> 3] & (1 << (index & 0x7));
                if (v == 0) {
                    Sys.print('.');
                } else {
                    Sys.print('#');
                }
            }
            Sys.println(' .');
        }
    }
}
