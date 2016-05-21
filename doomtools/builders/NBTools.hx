package doomtools.builders;

import doomtools._internal.*;

@:access(doomtools.builders.NodeBuilder)

class NBTools {
    
    public static inline function SorterSegNBSide(segA:NBSeg, segB:NBSeg) {
        return segA.NBSide - segB.NBSide;
    }
    public static inline function SorterSegLinedef(segA:NBSeg, segB:NBSeg) {
        var res = segA.LinedefID - segB.LinedefID;
        if (res != 0) {
            return res;
        }
        return (segA.RightSide ? 0 : 1) - (segB.RightSide ? 0 : 1);
    }
    public static inline function SorterSegAngle(segA:NBSeg, segB:NBSeg) {
        var res = (segA.Angle & 0x7fff) - (segB.Angle & 0x7fff);
        if (res != 0) {
            return res;
        }
        return SorterSegLinedef(segA, segB);
    }
    public static inline function SorterSegSector(segA:NBSeg, segB:NBSeg) {
        var res = segA.SectorID - segB.SectorID;
        if (res != 0) {
            return res;
        }
        return SorterSegLinedef(segA, segB);
    }
    
    public static function MapColinearSegs(segs:Array<NBSeg>) {
        var index:Int = 1;
        
        segs.sort(SorterSegAngle);
        
        var startIndex:Int = 0;
        var prevAngle:Int = -1;
        var segCount = segs.length;
        
        for (index in 0...segCount) {
            var seg = segs[index];
            if ((seg.Angle & 0x7fff) == prevAngle) {
                for (n in startIndex...index) {
                    var testSeg = segs[n];
                    if (seg.IsColinearWith(testSeg) == true) {
                        seg.SameAsLinedefID = testSeg.SameAsLinedefID;
                        seg.SameAsFlipped = testSeg.SameAsFlipped;
                        if (seg.Angle != testSeg.Angle) {
                            seg.SameAsFlipped = !seg.SameAsFlipped;
                        }
                        break;
                    }
                }
            } else {
                prevAngle = seg.Angle & 0x7fff;
                startIndex = index;
            }
        }
    }
}
