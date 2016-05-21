package doomtools.map;

import doomtools._internal.*;

class Thing {
    public static inline var BYTE_SIZE:Int = 10;
    public inline function GetByteSize() { return BYTE_SIZE; }
    
    public var x:Int;
    public var y:Int;
    public var angle:Int;
    public var type:Int;
    public var options:Int;
    
    public function new() {
    }
    
    public function ReadData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'doomtools.map.Thing.ReadData: Not enough space remaining! (${pos + BYTE_SIZE} > ${data.length})';
        }
        
        this.x = Tools.ReadInt16(data, pos);
        this.y = Tools.ReadInt16(data, pos + 2);
        this.angle = Tools.ReadInt16(data, pos + 4);
        this.type = Tools.ReadInt16(data, pos + 6);
        this.options = Tools.ReadInt16(data, pos + 8);
    }
    
    public function WriteData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'doomtools.map.Thing.WriteData: Not enough space remaining! (${pos + BYTE_SIZE} > ${data.length})';
        }
        
        Tools.WriteInt16(data, pos + 0, this.x);
        Tools.WriteInt16(data, pos + 2, this.y);
        Tools.WriteInt16(data, pos + 4, this.angle);
        Tools.WriteInt16(data, pos + 6, this.type);
        Tools.WriteInt16(data, pos + 8, this.options);
    }
}
