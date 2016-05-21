package doomtools.builders;

import doomtools._internal.*;

class NBNode {
    public var NodeID:UInt;
    public var SegArray:Array<NBSeg> = null;
    public var LeftChildID:Int = -1;
    public var RightChildID:Int = -1;
    public var ParentNodeID:Int = -1;
    
    public var PX:Int = 0;
    public var PY:Int = 0;
    public var PDX:Int = 0;
    public var PDY:Int = 0;
    
    public var Flip:Bool = false;
    
    public var SubsectorID:Int = -1;
    
    public var BoundingBox:doomtools.map.BoundingBox = null;
    
    public function new(nodeID:UInt, segArray:Array<NBSeg>, parentNode:Int) {
        this.NodeID = nodeID;
        this.SegArray = segArray;
        this.ParentNodeID = parentNode;
    }
    
    public function SetPartitionSeg(partitionSeg:NBSeg) {
        var x1 = Math.round(partitionSeg.X1);
        var y1 = Math.round(partitionSeg.Y1);
        var x2 = Math.round(partitionSeg.X2);
        var y2 = Math.round(partitionSeg.Y2);
        PX = x1;
        PY = y1;
        PDX = x2 - x1;
        PDY = y2 - y1;
    }
    
    public function GetBoundingBox(srcNodes:Array<NBNode>) {
        if (this.BoundingBox == null) {
            this.BoundingBox = new doomtools.map.BoundingBox();
            if (this.SubsectorID >= 0) {
                CalculateBoundingBoxFromSegs();
            } else {
                var leftBoundingBox = null;
                var rightBoundingBox = null;
                
                leftBoundingBox = srcNodes[LeftChildID].GetBoundingBox(srcNodes);
                rightBoundingBox = srcNodes[RightChildID].GetBoundingBox(srcNodes);
                
                this.BoundingBox.InitializeBoundingBox(leftBoundingBox);
                this.BoundingBox.UnionBoundingBox(rightBoundingBox);
            }
        }
        
        return this.BoundingBox;
    }
    
    private function CalculateBoundingBoxFromSegs() {
        if (this.BoundingBox == null) {
            this.BoundingBox = new doomtools.map.BoundingBox();
        }
        
        var bb = BoundingBox;
        var segArray = SegArray;
        var len = segArray.length;
        if (len < 1) {
            bb.Clear();
        } else {
            var seg = segArray[0];
            bb.InitializeBounds(
                Math.round(seg.X1), Math.round(seg.Y1),
                Math.round(seg.X2), Math.round(seg.Y2)
            );
            
            for (n in 1...len) {
                var seg = segArray[n];
                bb.UnionBounds(
                    Math.round(seg.X1), Math.round(seg.Y1),
                    Math.round(seg.X2), Math.round(seg.Y2)
                );
            }
        }
    }
    
    public function ToMapNode(mapNodes:Array<NBNode>):doomtools.map.Node {
        var node = new doomtools.map.Node();
        node.x = PX;
        node.y = PY;
        node.dx = PDX;
        node.dy = PDY;
        
        var leftChild = mapNodes[this.LeftChildID];
        node.boundingBoxLeft.CopyFrom(leftChild.GetBoundingBox(mapNodes));
        if (leftChild.SubsectorID >= 0) {
            node.leftChild = 0x8000 | leftChild.SubsectorID;
        } else {
            node.leftChild = this.LeftChildID & 0x7fff;
        }
        
        var rightChild = mapNodes[this.RightChildID];
        node.boundingBoxRight.CopyFrom(rightChild.GetBoundingBox(mapNodes));
        if (rightChild.SubsectorID >= 0) {
            node.rightChild = 0x8000 | rightChild.SubsectorID;
        } else {
            node.rightChild = this.RightChildID & 0x7fff;
        }
        
        return node;
    }
}
