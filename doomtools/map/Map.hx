package doomtools.map;

import doomtools._internal.*;

private typedef _TMapChunkType = {
    public function new():Void;
    public function GetByteSize():Int;
    public function ReadData(data:haxe.io.Bytes, pos:Int):Void;
    public function WriteData(data:haxe.io.Bytes, pos:Int):Void;
}

class Map {
    // - Main data.
    public var Things(default, null):Array<Thing> = [ ];
    public var Vertices(default, null):Array<Vertex> = [ ];
    public var Linedefs(default, null):Array<Linedef> = [ ];
    public var Sidedefs(default, null):Array<Sidedef> = [ ];
    public var Sectors(default, null):Array<Sector> = [ ];
    
    // - Node data.
    public var Segs(default, null):Array<Seg> = [ ];
    public var Subsectors(default, null):Array<Subsector> = [ ];
    public var Nodes(default, null):Array<Node> = [ ];
    
    // - Other lumps.
    public var Blockmap = new Blockmap();
    public var Reject = new Reject();
    
    // - Source port lumps go here?
    
    public function new() {
    }
    
    public function ClearNodeData() {
        Segs = [ ];
        Subsectors = [ ];
        Nodes = [ ];
    }
    
    @:generic
    private function ReadLump<T:_TMapChunkType>(list:Array<T>, lump:doomtools.wad.Lump, lumpName:String) {
        if (lump.name != lumpName) {
            throw 'doomtools.LoadFromWAD: Lump "${lump.name}" should be "$lumpName"!';
        }
        
        var data = lump.data;
        var obj:T = null;
        var index:Int = 0;
        while (index < data.length) {
            var obj:T = new T();
            obj.ReadData(data, index);
            list.push(obj);
            
            index += obj.GetByteSize();
        }
    }
    
    @:generic
    private function WriteLump<T:_TMapChunkType>(list:Array<T>, lumpName:String):doomtools.wad.Lump {
        var lumpData:haxe.io.Bytes;
        var totalSize:Int = 0;
        if (list.length > 0) {
            var size = list[0].GetByteSize();
            totalSize = size * list.length;
            lumpData = haxe.io.Bytes.alloc(totalSize);
            
            var index:Int = 0;
            
            for (obj in list) {
                obj.WriteData(lumpData, index);
                index += size;
            }
        } else {
            lumpData = haxe.io.Bytes.alloc(0);
        }
        
        var lump = new doomtools.wad.Lump();
        lump.name = lumpName;
        lump.len = totalSize;
        lump.data = lumpData;
        return lump;
    }
    
    public function LoadFromWAD(wad:doomtools.wad.WAD, name:String) {
        var lumps = wad.Lumps;
        
        // - Find the lump index.
        var index = wad.LumpIndexByName.get(name);
        if (index == null || index < 0 || index >= lumps.length) {
            throw 'doomtools.LoadFromWAD: No such lump $name!';
        }
        
        // - Verify that enough indices remain.
        if (index + 8 >= lumps.length) {
            throw 'doomtools.LoadFromWAD: Not enough lumps for map!';
        }
        
        // - Read the lumps!
        ReadLump(Things, lumps[index + 1], "THINGS");
        ReadLump(Linedefs, lumps[index + 2], "LINEDEFS");
        ReadLump(Sidedefs, lumps[index + 3], "SIDEDEFS");
        ReadLump(Vertices, lumps[index + 4], "VERTEXES");
        ReadLump(Segs, lumps[index + 5], "SEGS");
        ReadLump(Subsectors, lumps[index + 6], "SSECTORS");
        ReadLump(Nodes, lumps[index + 7], "NODES");
        ReadLump(Sectors, lumps[index + 8], "SECTORS");
        index += 9;
        
        // - Read optional reject chunk.
        if (index < lumps.length && lumps[index].name == "REJECT") {
            Reject.ReadLump(lumps[index]);
            index += 1;
        }
        
        // - Read blockmap chunk.
        if (index < lumps.length && lumps[index].name == "BLOCKMAP") {
            Blockmap.ReadLump(lumps[index]);
            index += 1;
        }
        
        // - Done!
    }
    
    public function WriteToWAD(wad:doomtools.wad.WAD, name:String) {
        // - First lump just has the name and is zero length.
        var startLump = new doomtools.wad.Lump();
        startLump.name = name;
        wad.AddLump(startLump);
        
        // - Write all the mandatory lumps.
        wad.AddLump(WriteLump(Things, "THINGS"));
        wad.AddLump(WriteLump(Linedefs, "LINEDEFS"));
        wad.AddLump(WriteLump(Sidedefs, "SIDEDEFS"));
        wad.AddLump(WriteLump(Vertices, "VERTEXES"));
        wad.AddLump(WriteLump(Segs, "SEGS"));
        wad.AddLump(WriteLump(Subsectors, "SSECTORS"));
        wad.AddLump(WriteLump(Nodes, "NODES"));
        wad.AddLump(WriteLump(Sectors, "SECTORS"));
        
        wad.AddLump(Reject.WriteLump());
        wad.AddLump(Blockmap.WriteLump());
        
        // - Done, unless there are other lumps to do!
    }
    
    public inline function GetLinedef(linedefID:Int):Linedef {
        return (linedefID < 0 || linedefID >= Linedefs.length) ? null : Linedefs[linedefID];
    }
    public inline function GetSidedef(sidedefID:Int):Sidedef {
        return (sidedefID < 0 || sidedefID >= Sidedefs.length) ? null : Sidedefs[sidedefID];
    }
    public inline function GetSector(sectorID:Int):Sector {
        return (sectorID < 0 || sectorID >= Sectors.length) ? null : Sectors[sectorID];
    }
    public inline function GetNode(nodeID:Int):Node {
        return (nodeID < 0 || nodeID >= Nodes.length) ? null : Nodes[nodeID];
    }
}
