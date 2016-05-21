package doomtools.builders;

import doomtools._internal.*;

class NodeBuilder {
    var m_map:doomtools.map.Map;
    
    var m_algorithm:NBAlgorithm = null;
    
    var m_segArray:Array<NBSeg> = null;
    var m_nodes:Array<NBNode> = null;
    
    var m_activeNodes:Array<Int> = null;
    var m_activeNodeIndex:Int = 0;
    
    var m_linedefsChecked:Array<Bool> = null;
    
    var m_settings:NBSettings = null;
    
    var m_segCache:NBSegSideCache = null;
    var m_builtSegCache:Bool = false;
    
    var m_tempSeg:NBSeg = null;
    
    public function new() {
    }
    
    public function Initialize(targetMap:doomtools.map.Map, settings:NBSettings = null) {
        // - Apply the Settings.
        if (settings == null) {
            settings = new NBSettings();
        }
        
        m_settings = settings;
        
        // - Prepare map data.
        m_map = targetMap;
        m_map.ClearNodeData();
        
        doomtools.map.MapTools.RemoveUnusedVertices(targetMap);
        doomtools.map.MapTools.MergeCoincidentVertices(targetMap);
        
        // - Initialize builder data.
        m_tempSeg = new NBSeg(-1);
        InitializeSegArray();
        
        m_linedefsChecked = [ ];
        for (linedef in m_map.Linedefs) {
            m_linedefsChecked.push(false);
        }
        
        m_nodes = [ new NBNode(0, m_segArray, -1) ];
        
        m_activeNodes = [ 0 ];
        m_activeNodeIndex = 0;
        
        // - Initialize algorithm.
        m_algorithm = settings.Algorithm;
        if (m_algorithm == null) {
            m_algorithm = new NBAlgorithmBestSeg();
        }
        
        m_algorithm.Initialize(m_map, m_segCache);
    }
    
    private function InitializeSegArray() {
        m_segArray = [ ];
        
        var map = m_map;
        var sidedefs = map.Sidedefs;
        var linedefs = map.Linedefs;
        var count = linedefs.length;
        var reduceRedundantSegs = m_settings.ReduceRedundantSegs;
        var preventSplitLinedefArray = m_settings.PreventSplitLinedefArray;
        var preventSplitSectorArray = m_settings.PreventSplitSectorArray;
        for (n in 0...count) {
            var linedef = linedefs[n];
            var side1:doomtools.map.Sidedef = map.GetSidedef(linedef.side1);
            var side2:doomtools.map.Sidedef = map.GetSidedef(linedef.side2);
            
            var preventSplit:Bool = false;
            if (preventSplitLinedefArray.indexOf(n) >= 0) {
                preventSplit = true;
            }
            
            if (side1 != null && preventSplitSectorArray.indexOf(side1.sector) >= 0) {
                preventSplit = true;
            }
            if (side2 != null && preventSplitSectorArray.indexOf(side2.sector) >= 0) {
                preventSplit = true;
            }
            
            if (reduceRedundantSegs == true) {
                if (side1 != null && side2 != null && side1.sector == side2.sector) {
                    if (side1.midtexture == null || side1.midtexture == "-") {
                        side1 = null;
                    }
                    if (side2.midtexture == null || side2.midtexture == "-") {
                        side2 = null;
                    }
                }
            }
            
            if (side1 != null) {
                var seg = new NBSeg(m_segArray.length);
                seg.InitializeFromMapLinedef(map, n, true, side1.sector);
                seg.PreventSplit = preventSplit;
                m_segArray.push(seg);
            }
            if (side2 != null) {
                var seg = new NBSeg(m_segArray.length);
                seg.InitializeFromMapLinedef(map, n, false, side2.sector);
                seg.PreventSplit = preventSplit;
                m_segArray.push(seg);
            }
        }
        
        NBTools.MapColinearSegs(m_segArray);
        
        m_segArray.sort(NBTools.SorterSegSector);
        
        m_segCache = new NBSegSideCache();
        m_segCache.Initialize(m_segArray);
        m_builtSegCache = false;
    }
    
    private function SplitSeg(partitionSeg:NBSeg, seg:NBSeg, segArray:Array<NBSeg>, rightIndex:Int, leftIndex:Int) {
        var offset = partitionSeg.GetSplitOffsetOn(seg);
        
        var rightSeg = new NBSeg(m_segArray.length);
        rightSeg.InitializeFromNBSeg(seg, offset, 1.0);
        rightSeg.NBSide = partitionSeg.GetSideOfSeg(rightSeg);
        m_segArray.push(rightSeg);
        
        var leftSeg = new NBSeg(m_segArray.length);
        leftSeg.InitializeFromNBSeg(seg, 0, offset);
        leftSeg.NBSide = -rightSeg.NBSide;
        m_segArray.push(leftSeg);
        
        if (rightSeg.NBSide == -1) {
            segArray[rightIndex] = rightSeg;
            segArray[leftIndex] = leftSeg;
        } else {
            segArray[leftIndex] = rightSeg;
            segArray[rightIndex] = leftSeg;
        }
    }
    
    private function TryAlgorithm(nodeID:Int):Int {
        var node = m_nodes[nodeID];
        var segArray = node.SegArray;
        if (segArray.length <= 1) {
            return -1;
        }
        
        // - Reset linedefs checked list.
        var linedefCheckArray = m_linedefsChecked.copy();
        
        // - Query the algorithm to find the best split point.
        var algorithm = m_algorithm;
        algorithm.SetSegs(segArray, linedefCheckArray);
        
        var partitionFlag = algorithm.FindSplit();
        
        algorithm.ClearSegs();
        
        if (partitionFlag == false) {
            return -1;
        }
        
        // - Break everything up into left/split/right segArray.
        var partitionSeg:NBSeg = null;
        if (algorithm.BestSeg >= 0) {
            partitionSeg = segArray[algorithm.BestSeg];
        } else {
            partitionSeg = m_tempSeg;
            partitionSeg.InitializeTemporary(
                algorithm.LineX1, algorithm.LineY1,
                algorithm.LineX2, algorithm.LineY2
            );
        }
        
        var rightSegArray:Array<NBSeg> = [ ];
        var splitSegArray:Array<NBSeg> = [ ];
        var leftSegArray:Array<NBSeg> = [ ];
        
        var n:Int = 0;
        for (seg in segArray) {
            var side = partitionSeg.GetSideOfSeg(seg);
            seg.NBSide = side;
            switch(side) {
                case -1: rightSegArray.push(seg);
                case 1: leftSegArray.push(seg);
                default: splitSegArray.push(seg);
            }
        }
        
        // - Sanity check.
        if (splitSegArray.length == 0 && (rightSegArray.length == 0 || leftSegArray.length == 0)) {
            return -1;
        }
        
        // - Merge all three lists into one, leaving space for the split segs.
        var rightIndex = rightSegArray.length;
        var splitIndex = rightIndex + splitSegArray.length;
        segArray = rightSegArray;
        for (seg in splitSegArray) {
            segArray.push(null);
            segArray.push(null);
        }
        for (seg in leftSegArray) {
            segArray.push(seg);
        }
        leftSegArray = null;
        
        // - Create all the new split segments.
        for (n in 0...splitSegArray.length) {
            var seg = splitSegArray[n];
            SplitSeg(partitionSeg, seg, segArray, rightIndex + n, splitIndex + n);
        }
        splitSegArray = null;
        
        // - Finish up!
        node.SegArray = segArray;
        
        node.SetPartitionSeg(partitionSeg);
        
        return splitIndex;
    }
    
    private function CreateSubsector(node:NBNode) {
        // - Sort all segArray by linedef value.
        var segArray = node.SegArray;
        segArray.sort(NBTools.SorterSegLinedef);
        
        // - Create map segArray from builder segArray.
        var map = m_map;
        var mapSegs = map.Segs;
        var segStart = mapSegs.length;
        for (seg in segArray) {
            var mapSeg = seg.ToMapSeg(map);
            mapSegs.push(mapSeg);
        }
        var segLen = mapSegs.length - segStart;
        
        // - Add real subsector to map.
        var subsector = new doomtools.map.Subsector();
        subsector.firstseg = segStart;
        subsector.numsegs = segLen;
        node.SubsectorID = map.Subsectors.length;
        map.Subsectors.push(subsector);
    }
    
    public function RunOneStep():Bool {
        if (m_builtSegCache == false && m_segCache.RunStep() == true) {
            return true;
        }
        
        m_builtSegCache = true;
        
        if (m_activeNodes == null || m_activeNodeIndex >= m_activeNodes.length) {
            return false; // Done, no more to run.
        }
        
        // - Get the current node.
        var nodeID = m_activeNodes[m_activeNodeIndex];
        var node:NBNode = m_nodes[nodeID];
        m_activeNodeIndex += 1;
        
        if (node.SegArray.length > 1) {
            // - Try to find a partition line for this segment range.
            for (pass in 0...2) {
                var splitIndex = TryAlgorithm(nodeID);
                
                if (splitIndex >= 0) {
                    // - Partition found! Add two child nodes for later use.
                    var segArray = node.SegArray;
                    
                    var rightID = m_nodes.length;
                    m_activeNodes.insert(m_activeNodeIndex, rightID);
                    m_nodes.push(new NBNode(rightID, segArray.slice(splitIndex, segArray.length), nodeID));
                    node.RightChildID = rightID;
                    
                    var leftID = m_nodes.length;
                    m_activeNodes.insert(m_activeNodeIndex + 1, leftID);
                    m_nodes.push(new NBNode(leftID, segArray.slice(0, splitIndex), nodeID));
                    node.LeftChildID = leftID;
                    
                    node.SegArray = null; // No longer needed.
                    
                    return true;
                }
                
                // - No split found. SegArray are probably all convex, but just in case, round off and check again.
                if (pass == 0) {
                    var errorAcc:Float = 0;
                    var segArray = node.SegArray;
                    for (seg in segArray) {
                        errorAcc += seg.RoundCoords();
                    }
                    
                    if (errorAcc < 0.000001) {
                        break;
                    }
                }
            }
        }
        
        // - No partition found, so all segArray here become a new subsector.
        CreateSubsector(node);
        
        return true;
    }
    
    public function RunAll():Bool {
        while (RunOneStep() == true) {
            // - Nothing to do.
        }
        
        Finish();
        
        return true;
    }
    
    public function Finish() {
        // - Finish committing all of the generated data to the target map.
        var map = m_map;
        
        // - Remap all nodes so the ones that ended up subsectors are last and convert to their final form.
        var nodeRemap:Array<Int> = [ ];
        var newNodes:Array<NBNode> = [ ];
        var leftNodeIndex:Int = 0;
        var rightNodeIndex:Int = m_nodes.length - 1;
        var nodes = m_nodes;
        var nodeCount = nodes.length;
        for (n in 0...nodeCount) {
            nodeRemap.push(-1);
            newNodes.push(null);
        }
        
        // - Reverse the order of all nodes while we insert.
        var n:Int = nodeCount - 1;
        while (n >= 0) {
            var node = nodes[n];
            
            node.GetBoundingBox(nodes);
            if (node.SubsectorID >= 0) {
                nodeRemap[n] = rightNodeIndex;
                rightNodeIndex -= 1;
            } else {
                nodeRemap[n] = leftNodeIndex;
                leftNodeIndex += 1;
            }
            n -= 1;
        }

        // - Assign all nodes and children to their new IDs.
        for (n in 0...nodeCount) {
            var node = nodes[n];
            var nodeID = nodeRemap[node.NodeID];
            node.NodeID = nodeID;
            newNodes[nodeID] = node;
            
            if (node.LeftChildID >= 0) {
                node.LeftChildID = nodeRemap[node.LeftChildID];
            }
            if (node.RightChildID >= 0) {
                node.RightChildID = nodeRemap[node.RightChildID];
            }
        }
        m_nodes = newNodes;
        nodes = newNodes;
        
        // - Push the finalized nodes.
        for (n in 0...leftNodeIndex) {
            map.Nodes.push(nodes[n].ToMapNode(nodes));
        }
    }
}
