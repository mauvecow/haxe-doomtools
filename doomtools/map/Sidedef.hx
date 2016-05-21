package doomtools.map;

import doomtools._internal.*;

class Sidedef {
    public static inline var BYTE_SIZE:Int = 30;
    public inline function GetByteSize() { return BYTE_SIZE; }
    
    public var textureoffset:Int;
    public var rowoffset:Int;
    public var toptexture:String; // 8 bytes
    public var bottomtexture:String; // 8 bytes.
    public var midtexture:String; // 8 bytes.
    public var sector:Int;
    
    public function new() {
    }
    
    public function ReadData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'doomtools.map.Sidedef.ReadData: Not enough space remaining! (${pos + BYTE_SIZE} > ${data.length})';
        }
        
        this.textureoffset = Tools.ReadInt16(data, pos);
        this.rowoffset = Tools.ReadInt16(data, pos + 2);
        this.toptexture = Tools.ReadString(data, pos + 4, 8);
        this.bottomtexture = Tools.ReadString(data, pos + 12, 8);
        this.midtexture = Tools.ReadString(data, pos + 20, 8);
        this.sector = Tools.ReadInt16(data, pos + 28);
    }
    
    public function WriteData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'doomtools.map.Sidedef.WriteData: Not enough space remaining! (${pos + BYTE_SIZE} > ${data.length})';
        }
        
        Tools.WriteInt16(data, pos + 0, this.textureoffset);
        Tools.WriteInt16(data, pos + 2, this.rowoffset);
        Tools.WriteString(data, pos + 4, this.toptexture, 8);
        Tools.WriteString(data, pos + 12, this.bottomtexture, 8);
        Tools.WriteString(data, pos + 20, this.midtexture, 8);
        Tools.WriteInt16(data, pos + 28, this.sector);
    }
}
