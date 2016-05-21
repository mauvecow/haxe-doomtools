package;

class HXDoomNode {
    public static function main() {
        var println = Sys.println;
        var args = Sys.args();
        var inFile:String = null;
        var outFile:String = null;
        if (args.length >= 2) {
            inFile = args[0];
            outFile = args[1];
        }
        
        if (inFile == null || outFile == null) {
            println('usage: HXDoomNode input.wad output.wad [MAP01 [MAP02 ...]]');
            Sys.exit(0);
        }
        
        var levels:Array<String> = null;
        if (args.length > 2) {
            levels = args.splice(2, args.length - 2);
        }
        
        var filename = inFile;
        var wad:doomtools.wad.WAD = null;
        try {
            var bytes = sys.io.File.getBytes(inFile);
            var loadWad = new doomtools.wad.WAD();
            loadWad.LoadFromData(bytes, 0);
            wad = loadWad;
            bytes = null;
        }
        catch(e:Dynamic) {
            trace('Exception loading $filename: $e');
        }
        if (wad == null) {
            return;
        }
        
        var totalStartTime = Sys.time();
        var newWad = new doomtools.wad.WAD();
        var lumpIndex:Int = 0;
        var builtCount:Int = 0;
        while (lumpIndex < wad.Lumps.length) {
            var lump = wad.Lumps[lumpIndex];
            lumpIndex += 1;
            
            if ((levels != null && levels.indexOf(lump.name) >= 0) || (levels == null && lump.IsMapStart() == true)) {
                newWad.AddLump(lump);
                
                // Build nodes for this map.
                var map = new doomtools.map.Map();
                var success:Bool = false;
                try {
                    map.LoadFromWAD(wad, lump.name);
                    
                    println('  map: ${lump.name}');
                    println('    Vertices: ${map.Vertices.length} Linedefs: ${map.Linedefs.length} Sidedefs: ${map.Sidedefs.length} Sectors: ${map.Sectors.length}');
                    println('    Nodes: ${map.Nodes.length} Segs: ${map.Segs.length} Subsectors: ${map.Subsectors.length}');
                    
                    var startTime = Sys.time();
                    
                    var builder = new doomtools.builders.BlockmapBuilder();
                    println('  building blockmaps...');
                    builder.Initialize(map);
                    while (builder.RunOneStep() == true) {
                        //println('.');
                    }
                    builder.Finish();
                    
                    var builder = new doomtools.builders.NodeBuilder();
                    println('  building nodes...');
                    builder.Initialize(map);
                    while (builder.RunOneStep() == true) {
                        //println('.');
                    }
                    builder.Finish();
                    
                    var builder = new doomtools.builders.RejectBuilder();
                    println('  building rejects...');
                    builder.Initialize(map);
                    while (builder.RunOneStep() == true) {
                        //println('.');
                    }
                    builder.Finish();
                    
                    var endTime = Sys.time();
                    println('  done: ${endTime - startTime} seconds');
                    println('    Vertices: ${map.Vertices.length} Linedefs: ${map.Linedefs.length} Sidedefs: ${map.Sidedefs.length} Sectors: ${map.Sectors.length}');
                    println('    Nodes: ${map.Nodes.length} Segs: ${map.Segs.length} Subsectors: ${map.Subsectors.length}');
                    
                    map.WriteToWAD(newWad, lump.name);
                    
                    // Skip all sublumps of the source map.
                    while (lumpIndex < wad.Lumps.length) {
                        var lump = wad.Lumps[lumpIndex];
                        if (lump.IsMapSublump() == false) {
                            break;
                        }
                        lumpIndex += 1;
                    }
                    
                    builtCount += 1;
                }
                catch(e:Dynamic) {
                    trace('Exception building nodes for ${lump.name}: $e');
                }
            } else {
                newWad.AddLump(lump);
            }
        }
        
        newWad.IsIWAD = false;
        var newData = newWad.WriteToData();
        if (newData != null) {
            sys.io.File.saveBytes(outFile, newData);
            println('Saved $outFile');
        }
        
        var totalTime = Sys.time() - totalStartTime;
        Sys.println('Done! Time taken: $totalTime seconds');
        if (builtCount > 1) {
            Sys.println('       ($builtCount levels, ${totalTime / builtCount} per level)');
        }
    }
}
