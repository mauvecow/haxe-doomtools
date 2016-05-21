package doomtools.map;

import doomtools._internal.*;

class Vertex {
    public static inline var BYTE_SIZE:Int = 4;
    public inline function GetByteSize() { return BYTE_SIZE; }
    
    public var x:Int;
    public var y:Int;
    
    public function new() {
    }

    public function ReadData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'doomtools.map.Vertex.ReadData: Not enough space remaining! (${pos + BYTE_SIZE} > ${data.length})';
        }
        
        this.x = Tools.ReadInt16(data, pos + 0);
        this.y = Tools.ReadInt16(data, pos + 2);
    }
    
    public function WriteData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'doomtools.map.Vertex.WriteData: Not enough space remaining! (${pos + BYTE_SIZE} > ${data.length})';
        }
        
        Tools.WriteInt16(data, pos + 0, this.x);
        Tools.WriteInt16(data, pos + 2, this.y);
    }
}
