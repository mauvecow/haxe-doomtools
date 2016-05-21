package doomtools.map;

import doomtools._internal.*;

@:access(doomtools.map.Map)

class MapTools {
    // - Trims unused vertices.
    public static function RemoveUnusedVertices(map:Map) {
        var vertices = map.Vertices;
        var used:Array<Bool> = [ ];
        var count:Int = vertices.length;
        
        if (count == 0) {
            return;
        }
        
        for (n in 0...count) {
            used[n] = false;
        }
        
        // - Check linedefs.
        for (linedef in map.Linedefs) {
            if (linedef.v1 >= 0 && linedef.v1 < count) {
                used[linedef.v1] = true;
            }
            if (linedef.v2 >= 0 && linedef.v2 < count) {
                used[linedef.v2] = true;
            }
        }
        
        // - Check segs.
        for (seg in map.Segs) {
            if (seg.v1 >= 0 && seg.v1 < count) {
                used[seg.v1] = true;
            }
            if (seg.v2 >= 0 && seg.v2 < count) {
                used[seg.v2] = true;
            }
        }
        
        // - Create remap array.
        var newVertexArray:Array<doomtools.map.Vertex> = [ ];
        var remapArray:Array<UInt> = [ ];
        for (n in 0...count) {
            if (used[n]) {
                remapArray.push(newVertexArray.length);
                newVertexArray.push(vertices[n]);
            } else {
                remapArray.push(0);
            }
        }
        
        if (newVertexArray.length != remapArray.length) {
            RemapVertices(map, newVertexArray, remapArray);
        }
    }
    
    // - Merges all vertices that occur at the same location.
    public static function MergeCoincidentVertices(map:Map) {
        var vertices = map.Vertices;
        var count:Int = vertices.length;
        var newCount:Int = 0;
        
        if (count == 0) {
            return;
        }
        
        // - Create a new vertex array containing only unique vertices.
        var newVertexArray:Array<doomtools.map.Vertex> = [ ];
        var remapArray:Array<UInt> = [ ];
        for (n in 1...count) {
            var vertex = vertices[n];
            var vertexX = vertex.x;
            var vertexY = vertex.y;
            var found:Bool = false;
            for (m in 0...newCount) {
                var testVertex = newVertexArray[m];
                
                if (vertexX == testVertex.x && vertexY == testVertex.y) {
                    found = true;
                    remapArray.push(m);
                    break;
                }
            }
            
            if (found == false) {
                remapArray.push(newCount);
                newVertexArray.push(vertex);
                newCount += 1;
            }
        }
        
        if (newVertexArray.length != remapArray.length) {
            RemapVertices(map, newVertexArray, remapArray);
        }
    }
        
    // - Gets a vertex at a given location, adding one if it doesn't exist.
    public static function GetNewVertex(map:Map, x:Int, y:Int):UInt {
        var vertices = map.Vertices;
        var count = vertices.length;
        for (n in 0...count) {
            var vertex = vertices[n];
            if (vertex.x == x && vertex.y == y) {
                return n;
            }
        }
        
        var vertex = new doomtools.map.Vertex();
        vertex.x = x;
        vertex.y = y;
        
        var index:UInt = vertices.length;
        vertices.push(vertex);
        
        return index;
    }
    
    // - Remaps all vertices to the new list. Used internally.
    private static function RemapVertices(map:Map, newVertexArray:Array<doomtools.map.Vertex>, remapArray:Array<UInt>) {
        map.Vertices = newVertexArray;
        
        var count = remapArray.length;
        
        // - Update all linedefs.
        for (linedef in map.Linedefs) {
            if (linedef.v1 >= 0 && linedef.v1 < count) {
                linedef.v1 = remapArray[linedef.v1];
            }
            if (linedef.v2 >= 0 && linedef.v2 < count) {
                linedef.v2 = remapArray[linedef.v2];
            }
        }
        
        // - Update all segs.
        for (seg in map.Segs) {
            if (seg.v1 >= 0 && seg.v1 < count) {
                seg.v1 = remapArray[seg.v1];
            }
            if (seg.v2 >= 0 && seg.v2 < count) {
                seg.v2 = remapArray[seg.v2];
            }
        }
    }
}
