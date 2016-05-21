package doomtools.builders;

import doomtools._internal.*;
import doomtools.map.Linedef;

class BlockmapBuilder {
    var m_map:doomtools.map.Map;
    
    var m_settings:BBSettings;
    
    var m_mapX1:Int;
    var m_mapY1:Int;
    var m_mapX2:Int;
    var m_mapY2:Int;
    var m_cols:Int;
    var m_rows:Int;
    var m_blockCount:Int;
    var m_blocks:Array<Array<Int> >;
    
    var m_omitLines:Array<Bool>;
    
    var m_linedefIndex:Int;
    var m_invalidFlag:Bool;
    
    public function new() {
    }
    
    public function Initialize(map:doomtools.map.Map, settings:BBSettings = null) {
        if (settings == null) {
            settings = new BBSettings();
        }
        m_settings = settings;
        m_map = map;
        
        // - Determine map bounds.
        var mapX1:Int = 0;
        var mapY1:Int = 0;
        var mapX2:Int = 0;
        var mapY2:Int = 0;
        
        if (map.Vertices.length > 0) {
            var v = map.Vertices[0];
            mapX1 = v.x;
            mapY1 = v.y;
            mapX2 = mapX1;
            mapY2 = mapY1;
        }
        
        for (v in map.Vertices) {
            var x = v.x;
            var y = v.y;
            if (x < mapX1) { mapX1 = x; }
            if (y < mapY1) { mapY1 = y; }
            if (x > mapX2) { mapX2 = x; }
            if (y > mapY2) { mapY2 = y; }
        }
        
        m_mapX1 = mapX1 - 8;
        m_mapY1 = mapY1 - 8;
        m_mapX2 = mapX2 + 8;
        m_mapY2 = mapY2 + 8;
        
        // - Calculate data needed.
        var cols = Math.floor((mapX2 - mapX1) / MAPCELLSIZE) + 1;
        var rows = Math.floor((mapY2 - mapY1) / MAPCELLSIZE) + 1;
        var blockCount = cols * rows;
        var blocks = new Array<Array<Int> >();
        m_cols = cols;
        m_rows = rows;
        m_blockCount = blockCount;
        m_blocks = blocks;
        
        // - Iterate through all blocks to initialize with zero.
        for (i in 0...blockCount) {
            blocks.push([ 0 ]);
        }
        
        // - Get any lines we need to omit.
        var omitLines:Array<Bool> = [ ];
        if (m_settings.OmitLinesArray != null || m_settings.AutoOmitLinesFlag == true) {
            for (i in 0...map.Linedefs.length) {
                omitLines.push(false);
            }
            m_omitLines = omitLines;
            
            if (m_settings.OmitLinesArray != null) {
                for (lineID in m_settings.OmitLinesArray) {
                    if (lineID >= 0 && lineID < omitLines.length) {
                        omitLines[lineID] = true;
                    }
                }
            }
            
            if (m_settings.AutoOmitLinesFlag == true) {
                AutoOmitLines();
            }
        }
        
        
        m_linedefIndex = -1;
        m_invalidFlag = false;
        if (map.Linedefs.length >= 65535 || m_settings.EmptyBlockmap == true) {
            // - Can't build old-style blockmaps like this.
            m_linedefIndex = map.Linedefs.length;
            m_invalidFlag = true;
        }
    }
    
    static inline var MAPCELLSIZE:Int = 128;
    
    private function RunOneLine():Bool {
        var lineN = m_linedefIndex;
        var lineCount = m_map.Linedefs.length;
        while (lineN < lineCount) {
            lineN += 1;
            
            if (m_omitLines == null || m_omitLines[lineN] == false) {
                break;
            }
        }
        m_linedefIndex = lineN;
        
        if (lineN >= lineCount) {
            return false;
        }
        
        var line = m_map.Linedefs[lineN];
        if (line == null) {
            return true; // ?
        }
        
        var map = m_map;
        var v1 = map.Vertices[line.v1];
        var v2 = map.Vertices[line.v2];
        if (v1 == null || v2 == null) {
            return true;
        }
        
        var blocks = m_blocks;
        var cols = m_cols;
        
        // draw a line from v1~v2
        var dx = v2.x - v1.x;
        var dy = v2.y - v1.y;
        if (dx == 0 && dy == 0) {
            // Err.
            var blockX = Math.floor((v1.x - m_mapX1) / MAPCELLSIZE);
            var blockY = Math.floor((v1.y - m_mapY1) / MAPCELLSIZE);
            blocks[(blockY * cols) + blockX].push(lineN);
            return true;
        }
        
        if (Tools.iabs(dx) >= Tools.iabs(dy)) {
            // Horiz line. Make sure we always go right.
            if (dx < 0) {
                Tools.Swap(v1, v2);
                dx = -dx;
                dy = -dy;
            }
            
            var startX = (v1.x - m_mapX1);
            var startY = (v1.y - m_mapY1);
            var endX = (v2.x - m_mapX1);
            var endY = (v2.y - m_mapY1);
            var endBlockX = Math.floor(endX / MAPCELLSIZE);
            var endBlockY = Math.floor(endY / MAPCELLSIZE);
            var blockX = Math.floor(startX / MAPCELLSIZE);
            var blockY = Math.floor(startY / MAPCELLSIZE);
            var dn:Float = Math.abs(dy / dx);
            // The Y-adder determines how long until we reach the next Y,
            // offset by the position the infinite line enters this block as.
            var blockDY:Int = -1;
            var addY:Float = startY - (blockY * MAPCELLSIZE);
            if (dy > 0) {
                blockDY = 1;
                addY = MAPCELLSIZE - addY;
            }
            addY += ((startX - (blockX * MAPCELLSIZE)) * dn); // offset to X-start of block
            addY *= 1.0 / MAPCELLSIZE;
            
            // Iterate to the end!
            blocks[(blockY * cols) + blockX].push(lineN);
            while (blockX < endBlockX) {
                addY -= dn;
                if (addY < 0) {
                    blockY += blockDY;
                    addY += 1;
                    blocks[(blockY * cols) + blockX].push(lineN);
                }
                blockX += 1;
                blocks[(blockY * cols) + blockX].push(lineN);
            }
            
            if (endBlockY != blockY) {
                blocks[(endBlockY * cols) + blockX].push(lineN);
            }
        } else {
            // Vert line. Make sure we always go down.
            if (dy < 0) {
                Tools.Swap(v1, v2);
                dx = -dx;
                dy = -dy;
            }
    
            var startX = (v1.x - m_mapX1);
            var startY = (v1.y - m_mapY1);
            var endX = (v2.x - m_mapX1);
            var endY = (v2.y - m_mapY1);
            var endBlockX = Math.floor(endX / MAPCELLSIZE);
            var endBlockY = Math.floor(endY / MAPCELLSIZE);
            var blockX = Math.floor(startX / MAPCELLSIZE);
            var blockY = Math.floor(startY / MAPCELLSIZE);
            var dn:Float = Math.abs(dx / dy);
            // The X-adder determines how long until we reach the next X,
            // offset by the position the infinite line enters this block as.
            var blockDX:Int = -1;
            var addX:Float = startX - (blockX * MAPCELLSIZE);
            if (dx > 0) {
                blockDX = 1;
                addX = MAPCELLSIZE - addX;
            }
            addX += ((startY - (blockY * MAPCELLSIZE)) * dn); // offset to X-start of block
            addX *= 1.0 / MAPCELLSIZE;
            
            // Iterate to the end!
            blocks[(blockY * cols) + blockX].push(lineN);
            while (blockY < endBlockY) {
                addX -= dn;
                if (addX < 0) {
                    blockX += blockDX;
                    addX += 1;
                    blocks[(blockY * cols) + blockX].push(lineN);
                }
                blockY += 1;
                blocks[(blockY * cols) + blockX].push(lineN);
            }
            
            if (endBlockX != blockX) {
                blocks[(blockY * cols) + endBlockX].push(lineN);
            }
        }
        
        return true;
    }
    
    public function RunOneStep():Bool {
        if (RunOneLine() == true) {
            return true;
        }
        return false;
    }
    
    public function Finish() {
        var cols = m_cols;
        var rows = m_rows;
        var data:Array<Int> = [ ];
        
        if (m_invalidFlag == false) {
            // - Iterate through all blocks again to add the trailing -1.
            var blocks = m_blocks;
            var blockCount = m_blockCount;
            var blockSize = 4 + blockCount;
            var indices = [ ];
            for (i in 0...blockCount) {
                blocks[i].push(-1);
                blockSize += blocks[i].length;
                indices.push(i);
            }
            
            // - Perform basic blockmap compression. First, remove identical arrays.
            var targetIndices:Array<Int>;
            var targetBlocks:Array<Array<Int>>;
            var count:Int = 0;
            for (block in blocks) {
                count += block.length;
            }
            var size:Int = (count * 2) + (cols * rows * 2) + 8;
            
            if (m_settings.CompressBlockmapFlag == true || size >= 65536) {
                targetIndices = [ ];
                targetBlocks = [ ];
                CompressBlockmapData(indices, blocks, targetIndices, targetBlocks);
            } else {
                targetIndices = indices;
                targetBlocks = blocks;
            }
            
            // - Convert blocks to actual blockmap data.
            var count:Int = 0;
            for (block in targetBlocks) {
                count += block.length;
            }
            var size:Int = (count * 2) + (m_cols * m_rows * 2) + 8;
            if (m_settings.DumbBlockmap == true || (size >= 65536 && m_settings.AggressiveBlockmapMergeFlag == true)) { // Do an aggressive merge.
                var allow:Int = 1;
                var reduceBy:Int = size - 65536;
                if (m_settings.DumbBlockmap == true) {
                    allow = size;
                    reduceBy = size;
                }
                
                var newIndices:Array<Int> = [ ];
                var newBlocks:Array<Array<Int>> = [ ];
                AggressiveBlockmapMerge(targetIndices, targetBlocks, newIndices, newBlocks, reduceBy, allow);
                
                targetIndices = newIndices;
                targetBlocks = newBlocks;
                var count:Int = 0;
                for (block in targetBlocks) {
                    if (block != null) {
                        count += block.length;
                    }
                }
                size = (count * 2) + (cols * rows * 2) + 8;
            }
            
            if (size < 65536) {
                data.push(m_mapX1);
                data.push(m_mapY1);
                data.push(cols);
                data.push(rows);
                for (n in 0...blockCount) {
                    data.push(0);
                }
                var index:Int = blockCount + 4;
                // - Push indices.
                var dataIndices:Array<Int> = [ ];
                
                for (block in targetBlocks) {
                    dataIndices.push(index);
                    if (block != null) {
                        for (v in block) {
                            data[index] = v;
                            index += 1;
                        }
                    }
                }
                
                for (n in 0...blockCount) {
                    data[4 + n] = dataIndices[targetIndices[n]];
                }
            }
        }
        
        // - Done!
        var blockmap = m_map.Blockmap;
        if (blockmap == null) {
            blockmap = new doomtools.map.Blockmap();
            m_map.Blockmap = blockmap;
        }
        blockmap.data = data;
    }
    
    
    private function CompressBlockmapData(srcIndices:Array<Int>, srcBlocks:Array<Array<Int> >, targetIndices:Array<Int>, targetBlocks:Array<Array<Int> >) {
        // - Looks for identical blocks and merges their references.
        for (i in 0...srcIndices.length) {
            var block = srcBlocks[srcIndices[i]];
            var found:Bool = false;
            
            for (index in 0...targetBlocks.length) {
                var target = targetBlocks[index];
                
                if (target.length == block.length) {
                    var invalid:Bool = false;
                    for (n in 1...(block.length-1)) {
                        if (target.indexOf(block[n], 1) < 0) {
                            invalid = true;
                            break;
                        }
                    }
                    if (invalid == false) {
                        found = true;
                        targetIndices[i] = index;
                    }
                }
            }
            
            if (found == false) {
                targetIndices[i] = targetBlocks.length;
                targetBlocks.push(block);
            }
        }
    }
    
    private function AggressiveBlockmapMerge(
            srcIndices:Array<Int>, srcBlocks:Array<Array<Int> >,
            targetIndices:Array<Int>, targetBlocks:Array<Array<Int> >,
            targetSize:Int, startAllow:Int
    ) {
        // After a normal compression, we run this to further reduce lines.
        
        // - Initialize target indices/blocks to the desired position.
        for (n in srcIndices) {
            targetIndices.push(n);
        }
        for (n in srcBlocks) {
            targetBlocks.push(n);
        }
        
        // - Sort the srcBlocks by size, largest to smallest.
        var sortIndex:Array<Int> = [ ];
        for (n in 0...srcBlocks.length) {
            sortIndex.push(n);
        }
        
        sortIndex.sort(function(a:Int, b:Int) {
            return srcBlocks[b].length - srcBlocks[a].length;
        });
        
        // - Starting from the largest, try to compress any that are slightly smaller.
        var allow:Int = 1;
        while (targetSize > 0 && allow < srcBlocks[sortIndex[0]].length) {
            var lastBlockA:Array<Int> = null;
            for (n in 0...sortIndex.length) {
                var index1 = sortIndex[n];
                var blockA = targetBlocks[index1];
                if (blockA == null || blockA == lastBlockA) {
                    continue;
                }
                lastBlockA = blockA;
                
                var lastBlockB:Array<Int> = null;
                for (n2 in (n+1)...sortIndex.length) {
                    var index2 = sortIndex[n2];
                    var blockB = targetBlocks[index2];
                    if (blockB == null || blockA == blockB || blockB.length > blockA.length) {
                        continue;
                    }
                    if ((blockB.length + allow) < blockA.length) {
                        continue;
                    }
                    if (blockB == lastBlockB) {
                        continue;
                    }
                    lastBlockB = blockB;
                    
                    var invalid:Int = 1;
                    for (v in blockB) {
                        if (blockA.indexOf(v, 1) < 0) {
                            invalid += 1;
                            if (invalid > allow) {
                                break;
                            }
                        }
                    }
                    
                    if (invalid > allow) {
                        continue;
                    }
                    
                    // - If invalid is within tolerance, merge it in.
                    if (invalid >= 1) {
                        blockA.pop();
                        for (v in blockB) {
                            if (v == -1 || blockA.indexOf(v, 1) < 0) {
                                blockA.push(v);
                            }
                        }
                        targetSize += invalid;
                    }
                    
                    targetSize -= blockB.length;
                    sortIndex[n2] = index1;
                    targetBlocks[index2] = null;
                    
                    for (indexN in 0...targetIndices.length) {
                        if (targetIndices[indexN] == index2) {
                            targetIndices[indexN] = index1;
                        }
                    }
                }
            }
            sortIndex.sort(function(a:Int, b:Int) {
                return srcBlocks[b].length - srcBlocks[a].length;
            });
            allow *= 2;
        }
    }
    
    static var s_stairSpecials:Array<Int> = [ 258, 7, 256, 8, 259, 127, 256, 100 ];
    static var s_donutSpecials:Array<Int> = [ 191, 9, 155, 146 ];
    static inline var s_linedefFlags = Linedef.FLAG_TWOSIDED | Linedef.FLAG_BLOCKPLAYER | Linedef.FLAG_BLOCKMONSTERS;
    
    private function AutoOmitLines() {
        var map = m_map;
        var linedefs = map.Linedefs;
        var sidedefs = map.Sidedefs;
        var sectors = map.Sectors;
        var sectorArray:Array<Bool> = [ ];
        var sectorTagMap:Map<Int, Array<Int> > = new Map<Int, Array<Int> >();
        var omitArray:Array<Bool> = m_omitLines;
        
        for (n in 0...sectors.length) {
            sectorArray[n] = false;
            
            var sector = sectors[n];
            if (sector.tag != 0) {
                var taggedSectors:Array<Int> = sectorTagMap.get(sector.tag);
                if (taggedSectors != null) {
                    taggedSectors.push(sector.tag);
                } else {
                    taggedSectors = [ sector.tag ];
                    sectorTagMap.set(sector.tag, taggedSectors);
                }
            }
        }
        
        // - First pass: Find all tagged sectors.
        for (n in 0...linedefs.length) {
            var linedef = linedefs[n];
            
            if (linedef.special == 0) {
                continue;
            }
            var stairFlag:Bool = (s_stairSpecials.indexOf(linedef.special) > 0) ? true : false;
            var donutFlag:Bool = (s_donutSpecials.indexOf(linedef.special) > 0) ? true : false;
            var tag = linedef.tag;
            var taggedSectors = sectorTagMap.get(linedef.tag);
            if (taggedSectors == null) {
                continue;
            }
            
            for (s in taggedSectors) {
                var sector = sectors[s];
                sectorArray[s] = true;
                
                // - Don't allow trimming of  linedefs on donut sectors.
                if (donutFlag) {
                    for (donutN in 0...linedefs.length) {
                        var donutLine = linedefs[donutN];
                        
                        var leftSide = map.GetSidedef(linedef.side1);
                        var rightSide = map.GetSidedef(linedef.side2);
                        if ((leftSide != null && leftSide.sector == s) || (rightSide != null && rightSide.sector == s)) {
                            if (leftSide != null && map.GetSector(leftSide.sector) != null) {
                                sectorArray[leftSide.sector] = true;
                            }
                            if (rightSide != null && map.GetSector(rightSide.sector) != null) {
                                sectorArray[rightSide.sector] = true;
                            }
                            break;
                        }
                    }
                }
                
                // - Don't allow trimming of linedefs on staircase sectors.
                if (stairFlag) {
                    var prevS:Int;
                    var nextS:Int = s;
                    do {
                        // Find next sector until no more valid sectors.
                        prevS = nextS;
                        nextS = -1;
                        for (stairN in 0...linedefs.length) {
                            var leftSide = map.GetSidedef(linedef.side1);
                            var rightSide = map.GetSidedef(linedef.side2);
                            if (leftSide == null || rightSide == null || leftSide.sector != prevS) {
                                continue;
                            }
                            if (map.GetSector(rightSide.sector) != null) {
                                nextS = rightSide.sector;
                                sectorArray[nextS] = true;
                                break;
                            }
                        }
                    } while (nextS >= 0);
                }
            }
        }
        
        // - Check to make sure all omitted lines actually can be dropped.
        for (n in 0...linedefs.length) {
            var linedef = linedefs[n];
            
            if (omitArray[n] == true) {
                continue;
            }
            
            if ((linedef.flags & s_linedefFlags) != Linedef.FLAG_TWOSIDED) {
                continue;
            }
            
            var leftSide = map.GetSidedef(linedef.side1);
            var rightSide = map.GetSidedef(linedef.side2);
            if (leftSide == null || rightSide == null) {
                continue;
            }
            
            var leftSector = map.GetSector(leftSide.sector);
            var rightSector = map.GetSector(rightSide.sector);
            
            if (leftSector != rightSector) {
                if (leftSector == null || sectorArray[leftSide.sector] == true) {
                    continue;
                }
                if (rightSector == null || sectorArray[rightSide.sector] == true) {
                    continue;
                }
                
                if (leftSector.floorheight != rightSector.floorheight || leftSector.ceilingheight != rightSector.ceilingheight) {
                    continue;
                }
            }
            
            omitArray[n] = true;
        }
        
        return omitArray;
    }
}
