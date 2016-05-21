package doomtools.builders;

import doomtools._internal.*;

class NBSegSideCache {
    static inline var INVALID_SEGID:Int = -999999;
    
    var m_segArray:Array<NBSeg>;
    var m_linedefLookup:Array<Int>;
    var m_sideTable:Array<Array<Int> >;
    
    var m_segIndex:Int = 0;
    
    public function new() {
    }
    
    public function Initialize(segArray:Array<NBSeg>) {
        m_segArray = segArray;
        
        var linedefLookup:Array<Int> = [ ];
        var sideTable:Array<Array<Int> > = [ ];
        for (seg in m_segArray) {
            var linedefID = seg.SameAsLinedefID;
            while (linedefLookup.length <= linedefID) {
                linedefLookup.push(-1);
            }
            
            if (linedefLookup[linedefID] == -1) {
                linedefLookup[linedefID] = sideTable.length;
                sideTable.push([ ]);
            }
        }
        
        m_linedefLookup = linedefLookup;
        m_sideTable = sideTable;
        
        m_segIndex = 0;
    }
    
    public function RunStep():Bool {
        // Get seg and side table.
        var seg:NBSeg = null;
        var table:Array<Int> = null;
        while (m_segIndex < m_segArray.length) {
            seg = m_segArray[m_segIndex];
            var index = m_linedefLookup[seg.SameAsLinedefID];
            if (index >= 0) {
                table = m_sideTable[index];
                if (table.length == 0) {
                    break;
                }
            }
            m_segIndex += 1;
        }
        
        if (m_segIndex >= m_segArray.length) {
            return false;
        }
        
        var mul:Int = 1;
        if (seg.SameAsFlipped == false) {
            mul = -mul;
        }
        
        for (i in 0...m_segArray.length) {
            var seg2 = m_segArray[i];
            var side = seg.GetSideOfSeg(seg2);
            while (table.length < seg2.SegID) {
                table.push(INVALID_SEGID);
            }
            table[seg2.SegID] = side * mul;
        }
        
        return true;
    }
    
    public function InitializeAll(segArray:Array<NBSeg>) {
        Initialize(segArray);
        
        while (RunStep() == true) {
            // ;
        }
    }
    
    public function GetSideOf(seg1:NBSeg, seg2:NBSeg):Int {
        do {
            if (seg2.IsDerivativeSeg) {
                break;
            }
            
            var linedefID1 = seg1.SameAsLinedefID;
            var lookup = m_linedefLookup;
            if (linedefID1 >= lookup.length) {
                break;
            }
            
            var index1 = m_linedefLookup[linedefID1];
            if (index1 == -1) {
                break;
            }
            
            var table = m_sideTable[index1];
            if (seg2.SegID < 0 || seg2.SegID >= table.length) {
                break;
            }
            
            var tableValue = table[seg2.SegID];
            if (tableValue == INVALID_SEGID) {
                break;
            }
            
            var mul:Int = 1;
            if (seg1.SameAsFlipped == false) {
                mul = -mul;
            }
            
            return tableValue * mul;
        } while (false);
        
        return seg1.GetSideOfSeg(seg2);
    }
}
