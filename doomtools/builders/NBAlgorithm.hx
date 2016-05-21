package doomtools.builders;

import doomtools._internal.*;

class NBAlgorithm {
    var m_map:doomtools.map.Map;
    var m_sideCache:NBSegSideCache;
    
    var m_segs:Array<NBSeg>;
    var m_linedefCheckArray:Array<Bool>;
    
    public var BestSeg(default, null):Int;
    public var LineX1(default, null):Float;
    public var LineY1(default, null):Float;
    public var LineX2(default, null):Float;
    public var LineY2(default, null):Float;
    
    public function new() {
    }
    
    public function Initialize(map:doomtools.map.Map, sideCache:NBSegSideCache) {
        m_map = map;
        m_sideCache = sideCache;
    }
    
    public function SetSegs(segs:Array<NBSeg>, linedefCheckArray:Array<Bool>) {
        m_segs = segs;
        m_linedefCheckArray = linedefCheckArray;
        BestSeg = -1;
    }
    
    public function ClearSegs() {
        m_segs = null;
        m_linedefCheckArray = null;
    }
    
    public function FindSplit():Bool {
        return false;
    }
}
