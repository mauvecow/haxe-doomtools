package doomtools._internal;

class Tools {
    public static inline var FRACBITS = 16;
    
    public static inline function iabs(v:Int):Int { // Haxe...
        return (v > 0) ? v : -v;
    }
    
    public static inline function ReadInt16(data:haxe.io.Bytes, pos:Int):Int {
        var v = data.getUInt16(pos);
        if (v >= 32768) {
            return v - 65536;
        }
        return v;
    }
    public static inline function ReadUInt16(data:haxe.io.Bytes, pos:Int):UInt {
        return data.getUInt16(pos);
    }
    public static inline function ReadInt32(data:haxe.io.Bytes, pos:Int):Int {
        return data.getInt32(pos);
    }
    public static inline function ReadUInt32(data:haxe.io.Bytes, pos:Int):UInt {
        return data.getUInt16(pos) | (data.getUInt16(pos + 2) << 16);
    }
    
    public static inline function ReadString(data:haxe.io.Bytes, pos:Int, len:Int):String {
        var stringbuf = new StringBuf();
        for (i in 0...len) {
            var b = data.get(pos + i);
            if (b == 0) {
                break;
            }
            
            stringbuf.addChar(b);
        }
        
        return stringbuf.toString();
    }
    
    public static inline function WriteInt16(data:haxe.io.Bytes, pos:Int, value:Int) {
        data.set(pos, value & 0xff);
        data.set(pos + 1, (value & 0xff00) >> 8);
    }
    public static inline function WriteUInt16(data:haxe.io.Bytes, pos:Int, value:UInt) {
        data.set(pos, value & 0xff);
        data.set(pos + 1, (value & 0xff00) >> 8);
    }
    public static inline function WriteInt32(data:haxe.io.Bytes, pos:Int, value:Int) {
        data.setInt32(pos, value);
    }
    public static inline function WriteUInt32(data:haxe.io.Bytes, pos:Int, value:UInt) {
        data.set(pos, value & 0xff);
        data.set(pos + 1, (value & 0xff00) >> 8);
        data.set(pos + 2, (value & 0xff0000) >> 16);
        data.set(pos + 3, (value & 0xff000000) >> 24);
    }
    
    public static inline function WriteString(data:haxe.io.Bytes, pos:Int, s:String, len:Int) {
        var max = len;
        if (s.length < max) {
            max = s.length;
        }
        var n:Int = 0;
        while (n < max) {
            data.set(pos + n, s.charCodeAt(n));
            n += 1;
        }
        while (n < len) {
            data.set(pos + n, 0);
            n += 1;
        }
    }
    
    public macro static function Swap(a, b) {
        return macro { var tmp = $a; $a = $b; $b = tmp; }
    }
}
