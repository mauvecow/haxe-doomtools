package doomtools.map;

import doomtools._internal.*;

class Sector {
    public static inline var BYTE_SIZE:Int = 26;
    public inline function GetByteSize() { return BYTE_SIZE; }
    
    public var floorheight:Int;
    public var ceilingheight:Int;
    public var floorpic:String;
    public var ceilingpic:String;
    public var lightlevel:Int;
    public var special:Int;
    public var tag:Int;
    
    public function new() {
    }
    
    public function ReadData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'doomtools.map.Sector.ReadData: Not enough space remaining! (${pos + BYTE_SIZE} > ${data.length})';
        }
        
        this.floorheight = Tools.ReadInt16(data, pos);
        this.ceilingheight = Tools.ReadInt16(data, pos + 2);
        this.floorpic = Tools.ReadString(data, pos + 4, 8);
        this.ceilingpic = Tools.ReadString(data, pos + 12, 8);
        this.lightlevel = Tools.ReadInt16(data, pos + 20);
        this.special = Tools.ReadInt16(data, pos + 22);
        this.tag = Tools.ReadInt16(data, pos + 24);
    }
    
    public function WriteData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'doomtools.map.Sector.WriteData: Not enough space remaining! (${pos + BYTE_SIZE} > ${data.length})';
        }
        
        Tools.WriteInt16(data, pos + 0, this.floorheight);
        Tools.WriteInt16(data, pos + 2, this.ceilingheight);
        Tools.WriteString(data, pos + 4, this.floorpic, 8);
        Tools.WriteString(data, pos + 12, this.ceilingpic, 8);
        Tools.WriteInt16(data, pos + 20, this.lightlevel);
        Tools.WriteInt16(data, pos + 22, this.special);
        Tools.WriteInt16(data, pos + 24, this.tag);
    }
}
