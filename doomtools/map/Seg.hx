package doomtools.map;

import doomtools._internal.*;

class Seg {
    public static inline var BYTE_SIZE:Int = 12;
    public inline function GetByteSize() { return BYTE_SIZE; }
    
    public var v1:UInt;
    public var v2:UInt;
    public var angle:Int;
    public var linedef:UInt;
    public var side:Int;
    public var offset:Int;
    
    public function new() {
    }
    
    public function ReadData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'doomtools.map.Seg.ReadData: Not enough space remaining! (${pos + BYTE_SIZE} > ${data.length})';
        }
        
        this.v1 = Tools.ReadUInt16(data, pos);
        this.v2 = Tools.ReadUInt16(data, pos + 2);
        this.angle = Tools.ReadInt16(data, pos + 4);
        this.linedef = Tools.ReadUInt16(data, pos + 6);
        this.side = Tools.ReadInt16(data, pos + 8);
        this.offset = Tools.ReadInt16(data, pos + 10);
    }
    
    public function WriteData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'doomtools.map.Subsector.WriteData: Not enough space remaining! (${pos + BYTE_SIZE} > ${data.length})';
        }
        
        Tools.WriteUInt16(data, pos + 0, this.v1);
        Tools.WriteUInt16(data, pos + 2, this.v2);
        Tools.WriteInt16(data, pos + 4, this.angle);
        Tools.WriteUInt16(data, pos + 6, this.linedef);
        Tools.WriteInt16(data, pos + 8, this.side);
        Tools.WriteInt16(data, pos + 10, this.offset);
    }
}
