package doomtools.wad;

import doomtools._internal.*;

class WAD {
    private static inline var IWAD_ID:Int = 0x44415749;
    private static inline var PWAD_ID:Int = 0x44415750;
    
    public var IsIWAD:Bool = false;
    
    public var Lumps(default, null) = new Array<Lump>();
    
    public var LumpIndexByName(default, null) = new std.Map<String, Int>();
    
    // - Implementation.
    public function new() {
    }
    
    // - Adds a lump to the list and the lookup index.
    public function AddLump(lump:Lump) {
        if (lump != null) {
            if (lump.name != null) {
                LumpIndexByName.set(lump.name, Lumps.length);
            }
            Lumps.push(lump);
        }
    }
    
    public function GetLump(name:String):Lump {
        var index = LumpIndexByName.get(name);
        if (index == null || index < 0 || index >= Lumps.length) {
            return null;
        }
        return Lumps[index];
    }
    
    // - Loads from data. Will throw an exception if anything fails to check out.
    public function LoadFromData(data:haxe.io.Bytes, ?offset:UInt = 0):Bool {
        // - Clear existing data.
        Lumps = new Array<Lump>();
        LumpIndexByName = new std.Map<String, Int>();
        
        // - Read 4 byte IWAD or PWAD identifier.
        var wadType:Int = Tools.ReadUInt32(data, offset + 0);
        
        if (wadType == IWAD_ID) { // IWAD?
            IsIWAD = true;
        } else if (wadType == PWAD_ID) { // PWAD?
            IsIWAD = false;
        } else {
            throw "WAD.LoadFromData Error: Invalid WAD header.";
        }
        
        // - Read lump table information.
        var numlumps:Int = Tools.ReadUInt32(data, offset + 4); // Number of lumps.
        var infotableofs:Int = Tools.ReadUInt32(data, offset + 8); // Offset of lump info table.
        
        if (offset + infotableofs + (numlumps * 16) > data.length) {
            throw "WAD.LoadFromData Error: Invalid lump info chunk.";
        }
        
        // - Read lumps.
        for (i in 0...numlumps) {
            var lump = new Lump();
            var index = offset + infotableofs + (i * 16);
            lump.ReadLump(
                data,
                Tools.ReadUInt32(data, index),
                Tools.ReadUInt32(data, index + 4),
                Tools.ReadString(data, index + 8, 8),
                offset);
            
            AddLump(lump);
        }
        
        return false;
    }
    
    public function WriteToData():haxe.io.Bytes {
        var index:Int = 12;
        for (lump in Lumps) {
            lump.pos = index;
            index += lump.len;
        }
        
        var size = index + (Lumps.length * 16);
        var data = haxe.io.Bytes.alloc(size);
        
        if (IsIWAD) {
            Tools.WriteUInt32(data, 0, IWAD_ID);
        } else {
            Tools.WriteUInt32(data, 0, PWAD_ID);
        }
        
        Tools.WriteUInt32(data, 4, Lumps.length);
        Tools.WriteUInt32(data, 8, index);
        
        index = 12;
        for (lump in Lumps) {
            if (lump.len > 0) {
                data.blit(index, lump.data, 0, lump.len);
                index += lump.len;
            }
        }
        
        for (lump in Lumps) {
            Tools.WriteUInt32(data, index, lump.pos);
            Tools.WriteUInt32(data, index + 4, lump.len);
            Tools.WriteString(data, index + 8, lump.name, 8);
            
            index += 16;
        }
        
        return data;
    }
}
