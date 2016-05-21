package doomtools.map;

import doomtools._internal.*;

class BoundingBox {
    public static inline var BYTE_SIZE:Int = 8;
    
    public var x1:Int;
    public var y1:Int;
    public var x2:Int;
    public var y2:Int;
    
    public function new() {
    }
    
    public function CopyFrom(src:BoundingBox) {
        x1 = src.x1;
        y1 = src.y1;
        x2 = src.x2;
        y2 = src.y2;
    }
    
    public function Clear() {
        x1 = 0;
        y1 = 0;
        x2 = 0;
        y2 = 0;
    }
    
    public inline function IsEmpty() {
        return (x1 == x2) && (y1 == y2);
    }
    
    public function InitializeAtPoint(x:Int, y:Int) {
        x1 = x;
        y1 = y;
        x2 = x;
        y2 = y;
    }
    public function InitializeBounds(x1:Int, y1:Int, x2:Int, y2:Int) {
        if (x1 > x2) {
            Tools.Swap(x1, x2);
        }
        if (y1 > y2) {
            Tools.Swap(y1, y2);
        }
        
        this.x1 = x1;
        this.y1 = y1;
        this.x2 = x2;
        this.y2 = y2;
    }
    public function InitializeBoundingBox(box:BoundingBox) {
        InitializeBounds(box.x1, box.y1, box.x2, box.y2);
    }
    
    public function UnionBounds(x1:Int, y1:Int, x2:Int, y2:Int) {
        if (x1 > x2) {
            Tools.Swap(x1, x2);
        }
        if (y1 > y2) {
            Tools.Swap(y1, y2);
        }
        
        if (x1 < this.x1) {
            this.x1 = x1;
        }
        if (x2 > this.x2) {
            this.x2 = x2;
        }
        if (y1 < this.y1) {
            this.y1 = y1;
        }
        if (y2 > this.y2) {
            this.y2 = y2;
        }
    }
    public function UnionBoundingBox(box:BoundingBox) {
        UnionBounds(box.x1, box.y1, box.x2, box.y2);
    }
    
    public inline function Contains(x:Int, y:Int) {
        return (x >= this.x1 && y >= this.y1 && x <= this.x2 && y <= this.y2);
    }
    
    public function ReadData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE > data.length) {
            throw 'BoundingBox.ReadData: Not enough space remaining! (${pos + BYTE_SIZE} >= ${data.length})';
        }
        
        y2 = Tools.ReadInt16(data, pos + 0);
        y1 = Tools.ReadInt16(data, pos + 2);
        x1 = Tools.ReadInt16(data, pos + 4);
        x2 = Tools.ReadInt16(data, pos + 6);
    }
    
    public function WriteData(data:haxe.io.Bytes, pos:Int) {
        if (pos + BYTE_SIZE >= data.length) {
            throw 'BoundingBox.WriteData: Not enough space remaining! (${pos + BYTE_SIZE} >= ${data.length})';
        }
        
        Tools.WriteInt16(data, pos + 0, y2);
        Tools.WriteInt16(data, pos + 2, y1);
        Tools.WriteInt16(data, pos + 4, x1);
        Tools.WriteInt16(data, pos + 6, x2);
    }
}
