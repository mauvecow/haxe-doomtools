package doomtools.map;

import doomtools._internal.*;

class Node {
    public static inline var BYTE_SIZE:Int = 28;
    public inline function GetByteSize() { return BYTE_SIZE; }
    
    public var x:Int;
    public var y:Int;
    public var dx:Int;
    public var dy:Int;
    public var boundingBoxLeft:BoundingBox = new BoundingBox();
    public var boundingBoxRight:BoundingBox = new BoundingBox();
    public var leftChild:UInt;
    public var rightChild:UInt;
    
    public function new() {
    }
    
    public function ReadData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'doomtools.map.Node.ReadData: Not enough space remaining! (${pos + BYTE_SIZE} > ${data.length})';
        }
        
        this.x = Tools.ReadInt16(data, pos);
        this.y = Tools.ReadInt16(data, pos + 2);
        this.dx = Tools.ReadInt16(data, pos + 4);
        this.dy = Tools.ReadInt16(data, pos + 6);
        this.boundingBoxRight.ReadData(data, pos + 8);
        this.boundingBoxLeft.ReadData(data, pos + 16);
        this.rightChild = Tools.ReadUInt16(data, pos + 24);
        this.leftChild = Tools.ReadUInt16(data, pos + 26);
    }
    
    public function WriteData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'doomtools.map.Node.WriteData: Not enough space remaining! (${pos + BYTE_SIZE} > ${data.length})';
        }
        
        Tools.WriteInt16(data, pos + 0, this.x);
        Tools.WriteInt16(data, pos + 2, this.y);
        Tools.WriteInt16(data, pos + 4, this.dx);
        Tools.WriteInt16(data, pos + 6, this.dy);
        this.boundingBoxRight.WriteData(data, pos + 8);
        this.boundingBoxLeft.WriteData(data, pos + 16);
        Tools.WriteUInt16(data, pos + 24, this.rightChild);
        Tools.WriteUInt16(data, pos + 26, this.leftChild);
    }
}
