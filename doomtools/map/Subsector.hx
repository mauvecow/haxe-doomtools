package doomtools.map;

import doomtools._internal.*;

class Subsector {
    public static inline var BYTE_SIZE:Int = 4;
    public inline function GetByteSize() { return BYTE_SIZE; }
    
    public var numsegs:UInt;
    public var firstseg:Int;
    
    public function new() {
    }
    
    public function ReadData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'doomtools.map.Subsector.ReadData: Not enough space remaining! (${pos + BYTE_SIZE} > ${data.length})';
        }
        
        this.numsegs = Tools.ReadUInt16(data, pos);
        this.firstseg = Tools.ReadInt16(data, pos + 2);
    }
    
    public function WriteData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'doomtools.map.Subsector.WriteData: Not enough space remaining! (${pos + BYTE_SIZE} > ${data.length})';
        }
        
        Tools.WriteUInt16(data, pos + 0, this.numsegs);
        Tools.WriteInt16(data, pos + 2, this.firstseg);
    }
}
