package doomtools.builders;

class NBSettings {
    // - Sets the algorithm to use when splitting segs.
    // Defaults to NBAlgorithm.
    public var Algorithm:NBAlgorithm = null;
    
    // - Array of linedefs that are not to be split. null is invalid.
    public var PreventSplitLinedefArray:Array<Int> = [ ];
    
    // - Array of sectors that are not to be split. null is invalid.
    public var PreventSplitSectorArray:Array<Int> = [ ];
    
    // - Automatically removes linedefs that border the same sector and do not have a midTexture.
    public var ReduceRedundantSegs:Bool = false;
    
    public function new() {
    }
}
