package doomtools.builders;

import doomtools._internal.*;
import doomtools.map.*;

class RejectBuilder {
    var m_map:Map;
    
    var m_rejectTable:Array<Int>;
    var m_rejectCount:Int;
    var m_sectorCount:Int;
    
    public function new() {
    }
    
    public function Initialize(map:Map) {
        m_map = map;
        
        // If the map is too big, just fall out early.
        if (map.Nodes.length > 0x7fff || map.Subsectors.length > 0x7fff) {
            m_rejectTable = [ ];
            m_rejectCount = 0;
            return;
        }
        
        m_sectorCount = map.Sectors.length;
        
        m_rejectCount = ((m_sectorCount * m_sectorCount) + 7) >> 3;
        m_rejectTable = new Array<Int>(); // >>3 = /8
        
        for (i in 0...m_rejectCount) {
            m_rejectTable.push(0xff);
        }
        
        // Sectors can always get sight to themselves.
        for (i in 0...m_sectorCount) {
            var index = (i * m_sectorCount) + i;
            m_rejectTable[index >> 3] &= ~(1 << (index & 0x7));
        }
    }
    
    public function RunOneStep():Bool {
        // Previous implementation did not work very well, so we're just gonna dummy this out for now.
        for (i in 0...m_rejectCount) {
            m_rejectTable[i] = 0;
        }
        
        return false;
    }
    
    public function Finish() {
        if (m_map == null) {
            return;
        }
        
        // Commit to map's Reject table
        var reject = new Reject();
        reject.rejectmatrix = m_rejectTable;
        
        m_map.Reject = reject;
        
        // debug code
        //reject.DebugPrint(m_sectorCount);
    }
}
