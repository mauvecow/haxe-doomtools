package doomtools.builders;

import doomtools._internal.*;

class NBSeg {
    public static inline var EPSILON:Float = 0.0001;
    static inline var EPSILON_SQ = EPSILON * EPSILON;
    
    public var SegID(default, null):Int;
    public var LinedefID(default, null):Int;
    public var SameAsLinedefID:Int;
    public var SameAsFlipped:Bool;
    public var SectorID:Int;
    
    public var RightSide:Bool;
    
    public var X1(default, null):Float;
    public var Y1(default, null):Float;
    public var X2(default, null):Float;
    public var Y2(default, null):Float;
    public var Length(default, null):Float;
    
    public var Angle(default, null):Int;
    
    public var Dx(default, null):Float;
    public var Dy(default, null):Float;
    
    public var DNx(default, null):Float;
    public var DNy(default, null):Float;
    
    public var Offset(default, null):Float;
    
    public var PreventSplit:Bool = false;
    public var IsDerivativeSeg(default, null):Bool = false;
    
    public var NBSide:Int = 0;
    
    public function new(segID:Int) {
        SegID = segID;
    }
    
    private function SetCoords(x1:Float, y1:Float, x2:Float, y2:Float) {
        this.X1 = x1;
        this.Y1 = y1;
        this.X2 = x2;
        this.Y2 = y2;
        this.Dx = (X2 - X1);
        this.Dy = (Y2 - Y1);
        this.Length = Math.sqrt((Dx * Dx) + (Dy * Dy));
        if (this.Length == 0) {
            this.DNx = 1.0;
            this.DNy = 0.0;
        } else {
            this.DNx = this.Dx / this.Length;
            this.DNy = this.Dy / this.Length;
        }
        this.Angle = (Math.round(Math.atan2(-this.Dy, -this.Dx) * (0x8000 / Math.PI)) + 0x8000) & 0xffff;
    }
    
    public function InitializeTemporary(x1:Float, y1:Float, x2:Float, y2:Float) {
        this.LinedefID = -1;
        this.SectorID = -1;
        this.SameAsLinedefID = -1;
        this.SameAsFlipped = true;
        this.RightSide = true;
        this.Offset = 0;
        this.PreventSplit = true;
        this.IsDerivativeSeg = false;
        
        SetCoords(x1, y1, x2, y2);
    }
    
    private function InitializeFromLinedefIDVerts(linedef:doomtools.map.Linedef, v1:doomtools.map.Vertex, v2:doomtools.map.Vertex, rightSide:Bool) {
        this.RightSide = rightSide;
        this.Offset = 0;
        if (this.RightSide) {
            SetCoords(v1.x, v1.y, v2.x, v2.y);
        } else {
            SetCoords(v2.x, v2.y, v1.x, v1.y);
        }
    }
    
    public function InitializeFromMapLinedef(map:doomtools.map.Map, linedefID:Int, rightSide:Bool, sectorID:Int) {
        this.LinedefID = linedefID;
        this.SectorID = sectorID;
        this.SameAsLinedefID = linedefID;
        this.SameAsFlipped = rightSide;
        
        var linedef = map.Linedefs[linedefID];
        var vertices = map.Vertices;
        InitializeFromLinedefIDVerts(linedef, vertices[linedef.v1], vertices[linedef.v2], rightSide);
    }
    
    public function InitializeFromNBSeg(src:NBSeg, start:Float, end:Float) {
        this.LinedefID = src.LinedefID;
        this.SameAsLinedefID = src.SameAsLinedefID;
        this.SameAsFlipped = src.SameAsFlipped;
        this.SectorID = src.SectorID;
        this.RightSide = src.RightSide;
        this.PreventSplit = src.PreventSplit;
        this.IsDerivativeSeg = true;
        
        this.Offset = src.Offset + (start * src.Length);
        
        SetCoords(
            src.X1 + (src.Dx * start), src.Y1 + (src.Dy * start),
            src.X1 + (src.Dx * end), src.Y1 + (src.Dy * end)
        );
    }
    
    public function GetSplitOffsetOn(seg:NBSeg):Float {
        var sdx = seg.X1 - this.X1;
        var sdy = seg.Y1 - this.Y1;
        
        var d = (seg.Dx * this.DNy) - (seg.Dy * this.DNx);
        
        var r = (this.DNx * sdy) - (this.DNy * sdx);
        
        //var tx = seg.X1 + (seg.Dx * (r / d));
        //var ty = seg.Y1 + (seg.Dy * (r / d));
        
        return r / d;
    }
    
    public function GetSideOfSeg(seg:NBSeg) {
        // - If lines are the same, just use the angle check.
        if (seg.SameAsLinedefID == this.SameAsLinedefID) {
            var retval = -1;
            if (seg.Angle == Angle) {
                retval = 1;
            }
            
            return retval;
        }
        
        // - Get the distance from theis line.
        var d1:Float;
        var d2:Float;
        if (this.Dx == 0) {
            d1 = Math.round(this.X1) - Math.round(seg.X1);
            d2 = Math.round(this.X1) - Math.round(seg.X2);
            if (this.Dy < 0) {
                d1 = -d1;
                d2 = -d2;
            }
        } else if (this.Dy == 0) {
            d1 = Math.round(seg.Y1) - Math.round(this.Y1);
            d2 = Math.round(seg.Y2) - Math.round(this.Y1);
            if (this.Dx < 0) {
                d1 = -d1;
                d2 = -d2;
            }
        } else {
            var sdx1 = seg.X1 - this.X1;
            var sdy1 = seg.Y1 - this.Y1;
            var sdx2 = seg.X2 - this.X1;
            var sdy2 = seg.Y2 - this.Y1;
            
            d1 = ((sdy1 * this.DNx) - (sdx1 * this.DNy));
            d2 = ((sdy2 * this.DNx) - (sdx2 * this.DNy));
            
            // - Test intersect point if there is a chance that it intersects.
            if (d1 > 0 && d1 < 1 && d2 > 0 && d2 < 1) {
                var d = (seg.Dx * this.DNy) - (seg.Dy * this.DNx);
                if (d != 0.0) {
                    var l = d1 / d;
                    var ix = Math.round(seg.X1 + (seg.Dx * l));
                    var iy = Math.round(seg.Y1 + (seg.Dy * l));
                    if (Math.round(seg.X1) == ix && Math.round(seg.Y1) == iy) {
                        d1 = 0;
                    }
                    if (Math.round(seg.X2) == ix && Math.round(seg.Y2) == iy) {
                        d2 = 0;
                    }
                }
            }
        }
        
        // - If less than the epsilon value, clip.
        if (Math.abs(d1) < EPSILON) {
            d1 = 0;
        }
        if (Math.abs(d2) < EPSILON) {
            d2 = 0;
        }
        
        if (d1 == 0 && d2 == 0) {
            if (seg.Angle == this.Angle) {
                return -1;
            } else if ((seg.Angle & 0x7fff) == (this.Angle & 0x7fff)) {
                return 1;
            }
            
            // - If both points are on the same line, figure out if the point order is aligned or opposite.
            var sdx1 = seg.X1 - this.X1;
            var sdy1 = seg.Y1 - this.Y1;
            var sdx2 = seg.X2 - this.X1;
            var sdy2 = seg.Y2 - this.Y1;
            
            var p1 = (this.DNx * sdx1) + (this.DNy * sdy1);
            var p2 = (this.DNx * sdx2) + (this.DNy * sdy2);
            
            if (p1 < p2) {
                return 1;
            } else {
                return -1;
            }
        } else if (d1 >= 0 && d2 >= 0) {
            return -1;
        } else if (d1 <= 0 && d2 <= 0) {
            return 1;
        } else {
            return 0;
        }
    }
    
    public function IsColinearWith(seg:NBSeg) {
        if ((seg.Angle & 0x7fff) != (this.Angle & 0x7fff)) {
            return false;
        }
        
        if (this.Dx == 0) {
            return ((seg.X1 - this.X1) == 0);
        } else if (this.Dy == 0) {
            return ((seg.Y1 - this.Y1) == 0);
        }
        
        var segDX1 = seg.X1 - this.X1;
        var segDY1 = seg.Y1 - this.Y1;
        var segDX2 = seg.X2 - this.X1;
        var segDY2 = seg.Y2 - this.Y1;
        
        var d = (segDX1 * this.DNy) - (segDY1 * this.DNx);
        
        return (Math.abs(d) < EPSILON);
    }
    
    public function RoundCoords():Float {
        var sX1 = X1;
        var sY1 = Y1;
        var sX2 = X2;
        var sY2 = Y2;
        
        SetCoords(Math.fround(X1), Math.fround(Y1), Math.fround(X2), Math.fround(Y2));
        
        return Math.abs(X1 - sX1) + Math.abs(Y1 - sY1) + Math.abs(X2 - sX2) + Math.abs(Y2 - sY2);
    }
    
    public function ToMapSeg(map:doomtools.map.Map):doomtools.map.Seg {
        var seg = new doomtools.map.Seg();
        
        seg.v1 = doomtools.map.MapTools.GetNewVertex(map, Math.round(this.X1), Math.round(this.Y1));
        seg.v2 = doomtools.map.MapTools.GetNewVertex(map, Math.round(this.X2), Math.round(this.Y2));
        
        seg.linedef = this.LinedefID;
        seg.offset = Math.round(this.Offset);
        seg.side = (this.RightSide == true) ? 0 : 1;
        seg.angle = this.Angle;
        
        return seg;
    }
}
