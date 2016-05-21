package doomtools._internal;

// This code is to be used during debugging and is otherwise disabled.

class DebugDiagnostics {
    private static function GetSideOfLine(nodeX:Float, nodeY:Float, nodeDX:Float, nodeDY:Float,
        x1:Float, y1:Float, x2:Float, y2:Float):Int
    {
        if (nodeDX == 0 && nodeDY == 0) {
            return -1;
        }
        var lSq = (nodeDX * nodeDX) + (nodeDY * nodeDY);
        if (lSq != 1.0) {
            var l = Math.sqrt(lSq);
            nodeDX = nodeDX / l;
            nodeDY = nodeDY / l;
        }
        var d1 = ((x1 - nodeX) * nodeDY) - ((y1 - nodeY) * nodeDX);
        var d2 = ((x2 - nodeX) * nodeDY) - ((y2 - nodeY) * nodeDX);
        
        if (Math.abs(d1) < 1) {
            d1 = 0;
        }
        if (Math.abs(d2) < 1) {
            d2 = 0;
        }
        
        if (d1 == 0 && d2 == 0) {
            var n1 = ((x1 - nodeX) * nodeDX) + ((y1 - nodeY) * nodeDY);
            var n2 = ((x2 - nodeX) * nodeDX) + ((y2 - nodeY) * nodeDY);
            if (n1 < n2) {
                //trace('n1 $n1 $n2');
                return -1;
            } else {
                //trace('n2 $n1 $n2');
                return 1;
            }
        }
        
        if (d1 <= 1 && d2 <= 1) {
            //trace ('<= 1: $d1 $d2');
            return 1;
        } else if (d1 >= -1 && d2 >= -1) {
            //trace ('>= -1: $d1 $d2');
            return -1;
        } else {
            //trace ('?? $d1 $d2');
            return 0;
        }
    }
    
    public static function CheckNodes(map:Map):Bool {
        var retval:Bool = true;
        var nodes = map.Nodes;
        var ssectors = map.Subsectors;
        var segs = map.Segs;
        var vertices = map.Vertices;
        
        var checkNodeSubsector:doomtools.map.Node -> Int -> Int -> Bool = null;
        var checkNode:doomtools.map.Node -> Int -> Int -> Bool = null;
        checkNodeSubsector = function(rootNode:doomtools.map.Node, ssectorID:Int, targetSide:Int) {
            var ssector:doomtools.map.Subsector = null;
            if (ssectorID < 0 || ssectorID >= ssectors.length) {
                trace('--- Subsector $ssectorID is invalid!');
                return false;
            }
            ssector = ssectors[ssectorID];
            
            trace('-- descending to ssector $ssectorID');
            
            var firstseg = ssector.firstseg;
            var endseg = firstseg + ssector.numsegs;
            if (firstseg < 0 || endseg > segs.length) {
                trace('--- Subsector $ssectorID has invalid segs!');
                return false;
            }
            
            var nodeX:Float = rootNode.x;
            var nodeY:Float = rootNode.y;
            var nodeDX:Float = rootNode.dx;
            var nodeDY:Float = rootNode.dy;
            var box:BoundingBox = null;
            if (targetSide == -1) {
                box = rootNode.boundingBoxRight;
            } else {
                box = rootNode.boundingBoxLeft;
            }
            
            var lSq = (nodeDX * nodeDX) + (nodeDY * nodeDY);
            
            var retval:Bool = true;
            for (segN in firstseg...endseg) {
                var seg = segs[segN];
                if (seg.v1 < 0 || seg.v1 >= vertices.length || seg.v2 < 0 || seg.v2 >= vertices.length) {
                    trace('--- Seg $segN has invalid vertices!');
                    retval = false;
                    continue;
                }
                var v1 = vertices[seg.v1];
                var v2 = vertices[seg.v2];
                var side = GetSideOfLine(nodeX, nodeY, nodeDX, nodeDY, v1.x, v1.y, v2.x, v2.y);
                
                if (side != targetSide) {
                    trace('--- Seg $segN is on the wrong side! $nodeX $nodeY $nodeDX $nodeDY / ${v1.x} ${v1.y} ${v2.x} ${v2.y} | $side != $targetSide');
                    retval = false;
                }
                
                if (box.Contains(v1.x, v1.y) == false || box.Contains(v2.x, v2.y) == false) {
                    trace('--- Seg $segN is not within bounds! ${box.x1} ${box.y1} ${box.x2} ${box.y2} | ${v1.x} ${v1.y} | ${v2.x} ${v2.y}');
                    retval = false;
                }
                
                var p2:Float = ((nodeDX * (v2.y - nodeY)) - (nodeDY * (v2.x - nodeX))) / lSq;
                var p1:Float = ((nodeDX * (v1.y - nodeY)) - (nodeDY * (v1.x - nodeX))) / lSq;
                if (targetSide > 0) {
                    p1 = -p1;
                    p2 = -p2;
                }
                if (p1 >= 0.25 || p2 >= 0.25) {
                    trace('--- Seg $segN is not a valid member of the node! ($p1 $p2)');
                }
            }
            
            return retval;
        }
        checkNode = function(rootNode:doomtools.map.Node, nodeID:Int, targetSide:Int) {
            var thisNode:doomtools.map.Node = null;
            if (nodeID < 0 || nodeID > nodes.length) {
                trace('--- Node $nodeID is invalid!');
                return false;
            }
            thisNode = nodes[nodeID];
            
            trace('-- descending to node $nodeID');
            
            if (rootNode != thisNode) {
                // Verify that the split line is on the correct side
                var side = GetSideOfLine(rootNode.x, rootNode.y, rootNode.dx, rootNode.dy,
                    thisNode.x, thisNode.y,
                    thisNode.x + thisNode.dx,
                    thisNode.y + thisNode.dy);
                if (side != targetSide) {
                    trace('--- Node $nodeID is on the wrong side! ${rootNode.x} ${rootNode.y} ${rootNode.dx} ${rootNode.dy} / '
                    + '${thisNode.x} ${thisNode.y} ${thisNode.x + thisNode.dx} ${thisNode.y + thisNode.dy} | $side != $targetSide');
                }
            }
            
            // Go into children.
            var retval:Bool = true;
            if (thisNode.rightChild != 0xffff) {
                if (thisNode.rightChild >= 0x8000) {
                    retval = retval && checkNodeSubsector(rootNode, thisNode.rightChild - 0x8000, targetSide == 0 ? -1 : targetSide);
                } else {
                    retval = retval && checkNode(rootNode, thisNode.rightChild, targetSide == 0 ? -1 : targetSide);
                }
            }
            if (thisNode.leftChild != 0xffff) {
                if (thisNode.leftChild >= 0x8000) {
                    retval = retval && checkNodeSubsector(rootNode, thisNode.leftChild - 0x8000, targetSide == 0 ? 1 : targetSide);
                } else {
                    retval = retval && checkNode(rootNode, thisNode.leftChild, targetSide == 0 ? 1 : targetSide);
                }
            }
            
            return retval;
        }
        
        // Goals to check:
        // - Check that all subsegs are on the correct side of the given node line, and do not cross.
        for (n in 0...nodes.length) {
            var node = nodes[n];
            trace('- checking node $n');
            if (checkNode(node, n, 0) == false) {
                trace('Node $n is not correctly split!');
            }
        }
        
        // - Check that all subsectors are correctly aligned/enclosed/valid.
        for (n in 0...ssectors.length) {
            var ss = ssectors[n];
            var firstSeg = ss.firstseg;
            var endSeg = firstSeg + ss.numsegs;
            var area:Float = 0;
            
            for (i in firstSeg...endSeg) {
                var seg = segs[i];
                var v1 = vertices[seg.v1];
                var v2 = vertices[seg.v2];
                
                area += (v2.x + v1.x) - (v2.y * v1.y);
            }
            
            if (area > 0) {
                trace('subsector $n is invalid! ($area > 0)');
            }
        }
        
        return retval;
    }
    
    public static function CheckBlockmap(map:Map):Bool {
        return false;
    }
    
    public static function CheckSegs(segs:Array<NBSeg>, start:Int, end:Int, node:NBNode, flip:Bool) {
        var dx = node.PDX;
        var dy = node.PDY;
        var x = node.PX;
        var y = node.PY;
        if (flip) {
            x += dx;
            y += dy;
            dx = -dx;
            dy = -dy;
        }
        
        var lSq = (dx * dx) + (dy * dy);
        
        for (i in start...end) {
            var seg = segs[i];
            var p2:Float = ((dx * (seg.Y2 - y)) - (dy * (seg.X2 - x))) / lSq;
            var p1:Float = ((dx * (seg.Y1 - y)) - (dy * (seg.X1 - x))) / lSq;
            if (p1 >= 0.25 || p2 >= 0.25) {
                trace('Seg $i is invalid! $p1 $p2 [range: $start $end] ${seg.X1} ${seg.Y1} ${seg.X2} ${seg.Y2} | $x $y ${x + dx} ${y + dy}');
            }
        }
    }
}
