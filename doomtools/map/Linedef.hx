package doomtools.map;

import doomtools._internal.*;

class Linedef {
    public static inline var BYTE_SIZE:Int = 14;
    public inline function GetByteSize() { return BYTE_SIZE; }
    
    public static inline var FLAG_BLOCKPLAYER:Int = 0x1;
    public static inline var FLAG_BLOCKMONSTERS:Int = 0x2;
    public static inline var FLAG_TWOSIDED:Int = 0x4;
    
    public var v1:UInt;
    public var v2:UInt;
    public var flags:Int;
    public var special:Int;
    public var tag:Int;
    public var side1:UInt;
    public var side2:UInt;
    
    public function new() {
    }
    
    public function ReadData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'doomtools.map.Linedef.ReadData: Not enough space remaining! (${pos + BYTE_SIZE} > ${data.length})';
        }
        
        this.v1 = Tools.ReadInt16(data, pos);
        this.v2 = Tools.ReadInt16(data, pos + 2);
        this.flags = Tools.ReadInt16(data, pos + 4);
        this.special = Tools.ReadInt16(data, pos + 6);
        this.tag = Tools.ReadInt16(data, pos + 8);
        this.side1 = Tools.ReadInt16(data, pos + 10);
        this.side2 = Tools.ReadInt16(data, pos + 12);
    }
    
    public function WriteData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'doomtools.map.Linedef.WriteData: Not enough space remaining! (${pos + BYTE_SIZE} > ${data.length})';
        }
        
        Tools.WriteUInt16(data, pos + 0, v1);
        Tools.WriteUInt16(data, pos + 2, v2);
        Tools.WriteInt16(data, pos + 4, flags);
        Tools.WriteInt16(data, pos + 6, special);
        Tools.WriteInt16(data, pos + 8, tag);
        Tools.WriteUInt16(data, pos + 10, side1);
        Tools.WriteUInt16(data, pos + 12, side2);
    }
}
