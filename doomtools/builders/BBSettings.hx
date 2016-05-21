package doomtools.builders;

class BBSettings {
    // - Automatically removes all lines which have no relevance to blocking the player.
    public var AutoOmitLinesFlag:Bool = true;
    
    // - List of lines to be omitted.
    public var OmitLinesArray:Array<Int> = [ ];
    
    // - Merges identical blocks.
    public var CompressBlockmapFlag:Bool = true;
    
    // - If size still exceeds maximum, try to merge similar seeming blocks.
    // May end up being equivalent to DumbBlockmap.
    public var AggressiveBlockmapMergeFlag:Bool = false;
    
    // - Force-merges all non-blank blocks into one giant block.
    public var DumbBlockmap:Bool = false;
    
    // - Skips blockmap building entirely.
    public var EmptyBlockmap:Bool = false;
    
    // Other stuff to add:
    // - JitterStep - jitters the map around to try to find a 'best fit' blockmap.
    
    public function new() {
    }
}
