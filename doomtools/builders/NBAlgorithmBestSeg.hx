package doomtools.builders;

class NBAlgorithmBestSeg extends NBAlgorithm {
    var m_bestRank:Int;
    var m_bestSeg:Int;
    var m_bestSideRank:Int;
    var m_bestSplitCount:Int;
    var m_bestInvalidCount:Int;
    
    public override function FindSplit():Bool {
        var segCount = m_segs.length;
        var maxRank = (segCount >> 1) * (segCount - (segCount >> 1));
        
        m_bestSplitCount = segCount;
        m_bestSideRank = -0x7fffffff;
        m_bestSeg = -1;
        m_bestInvalidCount = segCount;
        
        for (i in 0...segCount) {
            if (CheckSeg(i) == true) {
                if (m_bestRank == maxRank) {
                    break;
                }
            }
        }
        
        this.BestSeg = m_bestSeg;
        
        if (m_bestSeg < 0) {
            return false;
        } else {
            var seg = m_segs[m_bestSeg];
            
            this.LineX1 = seg.X1;
            this.LineY1 = seg.Y1;
            this.LineX2 = seg.X2;
            this.LineY2 = seg.Y2;
            
            return true;
        }
    }
    
    private function CheckSeg(segID:Int):Bool {
        var segs = m_segs;
        var seg = segs[segID];
        
        var linedefCheckArray = m_linedefCheckArray;
        if (linedefCheckArray[seg.SameAsLinedefID] == true) {
            return false;
        }
        linedefCheckArray[seg.SameAsLinedefID] = true;
        
        if (Math.abs(seg.Dx) < NBSeg.EPSILON && Math.abs(seg.Dy) < NBSeg.EPSILON) {
            return false;
        }
        
        var leftCount:Int = 0;
        var splitCount:Int = 0;
        var rightCount:Int = 0;
        var invalidCount:Int = 0;
        var segCount = m_segs.length;
        var bestSplitCount = m_bestSplitCount;
        var bestInvalidCount = m_bestInvalidCount;
        var sideCache = m_sideCache;
        
        for (n in 0...segCount) {
            var side = sideCache.GetSideOf(seg, segs[n]); //seg.GetSideOfSeg(segs[n]);
            if (side < 0) {
                leftCount += 1;
            } else if (side > 0) {
                rightCount += 1;
            } else {
                splitCount += 1;
                if (splitCount > bestSplitCount) {
                    return false;
                }
                
                if (seg.PreventSplit == true) {
                    invalidCount += 1;
                    if (invalidCount > bestInvalidCount) {
                        return false;
                    }
                }
            }
        }
        
        var sideRank = (leftCount * rightCount);
        if (sideRank != 0 && (sideRank > m_bestSideRank || (sideRank == m_bestSideRank && splitCount < bestSplitCount))) {
            m_bestSeg = segID;
            m_bestSideRank = sideRank;
            m_bestSplitCount = splitCount;
            m_bestInvalidCount = invalidCount;
            return true;
        }
        
        return false;
    }
}
