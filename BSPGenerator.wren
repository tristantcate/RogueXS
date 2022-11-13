import "xs_math" for Vec2, Math
import "random" for Random
import "grid" for Grid, Tile, TileType

class BSPGenerator {
    
    construct new(a_grid){
        _grid = a_grid
        _width = a_grid.GetWidth
        _height = a_grid.GetHeight
        _rand = Random.new()

        _rooms = List.new()

    }

    GenerateBSPFiber(a_mergeRooms, a_ignoreYield){
        var yieldTime = 0.001

        for (tile in 0..._width * _height) {
                _grid.GetTiles().add(Tile.new(_grid.GetTileTypeByIndex(1)))
        }

        var minBoxSize = Vec2.new(4,4)
        var maxBoxSize = Vec2.new(10,10)

        var boxes = List.new()
        boxes.add(BspBox.new(Vec2.new(0,0), Vec2.new(_width-1, _height-1)))

        var done = false

        Fiber.yield(yieldTime)


        while(!done){

            var newBoxList = List.new()

            for(box in boxes) {

                if(box.size.x < maxBoxSize.x && box.size.y < maxBoxSize.y){
                    newBoxList.add(box)
                    continue
                }

                if(box.size.x > box.size.y){
                    //split over X axis 
                    var splitRatio = _rand.float(1.7, 2.3)
                    var xSplit = (box.bottomLeftVec2.x + box.size.x / splitRatio)

                    var newBox1BotLeft = Vec2.new(box.bottomLeftVec2.x, box.bottomLeftVec2.y)
                    var newBox1TopRight = Vec2.new(xSplit, box.topRightVec2.y)

                    var newBox2BotLeft = Vec2.new(xSplit, box.bottomLeftVec2.y)
                    var newBox2TopRight = Vec2.new(box.topRightVec2.x, box.topRightVec2.y)

                    newBoxList.add(BspBox.new(newBox1BotLeft, newBox1TopRight))
                    newBoxList.add(BspBox.new(newBox2BotLeft, newBox2TopRight))

                }else{
                    //split over Y axis

                    var splitRatio = _rand.float(1.7, 2.3)
                    var ySplit = (box.bottomLeftVec2.y + box.size.y / splitRatio)

                    var newBox1BotLeft = Vec2.new(box.bottomLeftVec2.x, box.bottomLeftVec2.y)
                    var newBox1TopRight = Vec2.new(box.topRightVec2.x, ySplit)

                    var newBox2BotLeft = Vec2.new(box.bottomLeftVec2.x, ySplit)
                    var newBox2TopRight = Vec2.new(box.topRightVec2.x, box.topRightVec2.y)

                    newBoxList.add(BspBox.new(newBox1BotLeft, newBox1TopRight))
                    newBoxList.add(BspBox.new(newBox2BotLeft, newBox2TopRight))

                }
            }

            boxes = newBoxList

            done = true

            for(i in 0...boxes.count){
                
                if(boxes[i].size.x > maxBoxSize.x && boxes[i].size.y > maxBoxSize.y){
                    done = false
                    break
                }
            }

        }

        
        Fiber.yield(yieldTime)
        

        var boxIndentChance = 0.4

        //Give all boxes chance to get indented
        for (box in boxes) {
            if(_rand.float(0.0, 1.0) < boxIndentChance){
                
                var leftIndentBool = _rand.float(0.0,1.0) > 0.5
                if(leftIndentBool){

                    for(boxY in box.bottomLeftVec2.y...box.topRightVec2.y){
                        _grid.SetTile(box.bottomLeftVec2.x, boxY, _grid.GetTileTypeByIndex(2))
                         if(!a_ignoreYield) Fiber.yield(yieldTime)
                    }

                    box.bottomLeftVec2.x = box.bottomLeftVec2.x + 1

                    for(boxY in box.bottomLeftVec2.y...box.topRightVec2.y){
                        _grid.SetTile(box.bottomLeftVec2.x, boxY, _grid.GetTileTypeByIndex(2))
                         if(!a_ignoreYield) Fiber.yield(yieldTime)
                    }
                    
                    box.bottomLeftVec2.x = box.bottomLeftVec2.x + 1

                } else{

                    for(boxX in box.bottomLeftVec2.x...box.topRightVec2.x){
                        _grid.SetTile(boxX, box.bottomLeftVec2.y, _grid.GetTileTypeByIndex(2))
                         if(!a_ignoreYield) Fiber.yield(yieldTime)
                    }
                    box.bottomLeftVec2.y = box.bottomLeftVec2.y + 1

                    for(boxX in box.bottomLeftVec2.x...box.topRightVec2.x){
                        _grid.SetTile(boxX, box.bottomLeftVec2.y, _grid.GetTileTypeByIndex(2))
                         if(!a_ignoreYield) Fiber.yield(yieldTime)
                    }
                    box.bottomLeftVec2.y = box.bottomLeftVec2.y + 1
                } 

            }
        }

        Fiber.yield(yieldTime)


        var mergeChance = 0.75

        var mergedRoomTilesToRemove = List.new()

        //Merge some rooms
        if(a_mergeRooms){

            for (box in boxes) {
                if(box.IsMerged()){
                    continue
                }

                if(_rand.float(0.0, 1.0) < mergeChance){

                    for(mergeBox in boxes){

                        if(box.IsMerged()){
                            break
                        }

                        if(box == mergeBox || mergeBox.IsMerged()){
                            continue
                        }


                        var removableRoomTiles = List.new()

                        if(box.topRightVec2.x.round == mergeBox.bottomLeftVec2.x.round) {
                            
                            for (overlapPoint in this.GetOverlappingLinePoints(box.bottomLeftVec2.y, box.topRightVec2.y, mergeBox.bottomLeftVec2.y, mergeBox.topRightVec2.y)){
                                removableRoomTiles.add(Vec2.new(box.topRightVec2.x.round, overlapPoint))
                            }
                        }

                        if(box.topRightVec2.y.round == mergeBox.bottomLeftVec2.y.round) {

                            for (overlapPoint in (this.GetOverlappingLinePoints(box.bottomLeftVec2.y, box.topRightVec2.y, mergeBox.bottomLeftVec2.y, mergeBox.topRightVec2.y))) {
                                removableRoomTiles.add(Vec2.new(overlapPoint, box.topRightVec2.y.round))
                            }
                        }
                            
                        mergedRoomTilesToRemove = mergedRoomTilesToRemove + removableRoomTiles

                        box.Merge(mergeBox)
                        mergeBox.Merge(box)

                        var newRoom = Room.new()
                        for(tile in removableRoomTiles){
                            newRoom.AddTile(_grid.getTile(tile.x, tile.y))
                        }

                        newRoom.SetBox(box)
                        newRoom.SetMergebox(mergeBox)

                        newRoom.AddTiles(_grid.GetTilesFromBspBox(box))
                        newRoom.AddTiles(_grid.GetTilesFromBspBox(mergeBox))

                        _rooms.add(newRoom)

                    }
                }
            }

        }

        
        Fiber.yield(yieldTime)

        //Create Rooms from boxes

        for (box in boxes) {
            
            //Merged boxes are already added while merging to keep destroyed tiles in mind
            if(box.IsMerged()){
                continue
            }

            var newRoom = Room.new()

            newRoom.AddTiles(_grid.GetTilesFromBspBox(box))
            newRoom.SetBox(box)

            _rooms.add(newRoom)
            

        }

        Fiber.yield(yieldTime)

        //Give every room appropriate neighbors

        for (i in  0..._rooms.count - 1){
            for(i2 in i + 1..._rooms.count){
                    
                var room = _rooms[i]
                var neighborRoom = _rooms[i2]

                var box = null
                var neighBox = null
                var neighDir = null

                if(room.GetRoomNeighbors().contains(neighborRoom)){
                    continue
                }


                
                if(room.GetMergebox() == null && neighborRoom.GetMergebox() == null){
                    box = room.GetBox()
                    neighBox = neighborRoom.GetBox()
                    neighDir = this.GetBspBoxNeighborDir(box, neighBox)

                    if(neighDir != Vec2.new(0,0)){
                        room.AddRoomNeighbor(neighborRoom)

                        room.AddDoor(this.GetDoorFromBoxes(box, neighBox, neighDir))

                        continue
                    }
                }
                
                if(room.GetMergebox() != null && neighborRoom.GetMergebox() == null) {
                    box = room.GetMergebox()
                    neighBox = neighborRoom.GetBox()
                    neighDir = this.GetBspBoxNeighborDir(box, neighBox)

                    if(neighDir != Vec2.new(0,0)){
                        room.AddRoomNeighbor(neighborRoom)

                        room.AddDoor(this.GetDoorFromBoxes(box, neighBox, neighDir))

                        continue
                    }
                } 
                
                if(room.GetMergebox() == null && neighborRoom.GetMergebox() != null) {
                    box = room.GetBox()
                    neighBox = neighborRoom.GetMergebox()
                    neighDir = this.GetBspBoxNeighborDir(box, neighBox)
                    
                    if(neighDir != Vec2.new(0,0)){
                        room.AddRoomNeighbor(neighborRoom)

                        room.AddDoor(this.GetDoorFromBoxes(box, neighBox, neighDir))

                        continue
                    }
                }
                
                if(room.GetMergebox() != null && neighborRoom.GetMergebox() != null) {
                    box = room.GetMergebox()
                    neighBox = neighborRoom.GetMergebox()
                    neighDir = this.GetBspBoxNeighborDir(box, neighBox)

                    
                    if(neighDir != Vec2.new(0,0)){
                        room.AddRoomNeighbor(neighborRoom)

                        room.AddDoor(this.GetDoorFromBoxes(box, neighBox, neighDir))

                        continue
                    }
                }
            }
            

        }

        Fiber.yield(yieldTime)

        //Place walls along left and bottom of boxes
        for (box in boxes) {
            for(boxX in box.bottomLeftVec2.x...box.topRightVec2.x){
                _grid.SetTile(boxX, box.bottomLeftVec2.y, _grid.GetTileTypeByIndex(2))
                 if(!a_ignoreYield) Fiber.yield(yieldTime)
            }

            for(boxY in box.bottomLeftVec2.y...box.topRightVec2.y){
                _grid.SetTile(box.bottomLeftVec2.x, boxY, _grid.GetTileTypeByIndex(2))
                 if(!a_ignoreYield) Fiber.yield(yieldTime)
            }
        }

        Fiber.yield(yieldTime)



        //place walls around the top and right
        for(x in 0..._width){
            _grid.SetTile(x, _height - 1, _grid.GetTileTypeByIndex(2))
        }

        for(y in 0..._height){
            _grid.SetTile(_width - 1, y, _grid.GetTileTypeByIndex(2))
        }

        Fiber.yield(yieldTime)


        //Empty surrounded tiles
        for (x in 0..._width){
            for (y in 0..._height){
                if(!_grid.getTile(x,y).passable && _grid.IsTileSurroundedByWalls(x,y)){
                    _grid.SetTile(x,y, _grid.GetTileTypeByIndex(0))
                     if(!a_ignoreYield) Fiber.yield(yieldTime)
                }
            }
        }
        Fiber.yield(yieldTime)

        //Remove walls from merged rooms
        for(mergeRoomTile in mergedRoomTilesToRemove){
            _grid.SetTile(mergeRoomTile.x, mergeRoomTile.y, _grid.GetTileTypeByIndex(1))
             if(!a_ignoreYield) Fiber.yield(yieldTime)
        }

        Fiber.yield(yieldTime)

        //Connect rooms through the removal of single wall tile in wall
        for (room in _rooms){

            var roomdoorcount = room.GetDoors().count

            for(door in room.GetDoors()){

                if(door == Vec2.new(0,0)){
                    continue
                }

                _grid.SetTile(door.x, door.y, _grid.GetTileTypeByIndex(1))
                if(!a_ignoreYield) Fiber.yield(yieldTime)
            }
        }

    }

    AddNeighborAndDoorToRoomIfBoxesOverlap(a_room, a_neighRoom, a_box1, a_box2){

        var neighDir = this.GetBspBoxNeighborDir(a_box1, a_box2)
                    
        if(neighDir != Vec2.new(0,0)){
            room.AddRoomNeighbor(neighborRoom)

            room.AddDoor(this.GetDoorFromBoxes(a_box1, a_box2, neighDir))

            //continue
        }
    }

    GetDoorFromBoxes(a_fromBox, a_toBox, a_neighDir){

        if(a_neighDir == Vec2.new(1,0)) {

            var possibleDoorPlaces = this.GetOverlappingLinePoints(
                a_fromBox.bottomLeftVec2.y, a_fromBox.topRightVec2.y, 
                a_toBox.bottomLeftVec2.y, a_toBox.topRightVec2.y)

            if(possibleDoorPlaces.count == 0) return Vec2.new(0,0)
            return Vec2.new(a_fromBox.topRightVec2.x, possibleDoorPlaces[_rand.int(1, possibleDoorPlaces.count - 1)])
        }

        if(a_neighDir == Vec2.new(-1,0)) {

            var possibleDoorPlaces = this.GetOverlappingLinePoints(
                a_fromBox.bottomLeftVec2.y, a_fromBox.topRightVec2.y, 
                a_toBox.bottomLeftVec2.y, a_toBox.topRightVec2.y)

            if(possibleDoorPlaces.count == 0) return Vec2.new(0,0)

            return Vec2.new(a_fromBox.bottomLeftVec2.x, possibleDoorPlaces[_rand.int(1, possibleDoorPlaces.count - 1)])
        }

        if(a_neighDir == Vec2.new(0,1)) {

            var possibleDoorPlaces = this.GetOverlappingLinePoints(
                a_fromBox.bottomLeftVec2.x, a_fromBox.topRightVec2.x, 
                a_toBox.bottomLeftVec2.x, a_toBox.topRightVec2.x)
                
            if(possibleDoorPlaces.count == 0) return Vec2.new(0,0)

            return Vec2.new(possibleDoorPlaces[_rand.int(1, possibleDoorPlaces.count - 1)], a_fromBox.topRightVec2.y)
        }

        if(a_neighDir == Vec2.new(0,-1)) {

            var possibleDoorPlaces = this.GetOverlappingLinePoints(
                a_fromBox.bottomLeftVec2.x, a_fromBox.topRightVec2.x, 
                a_toBox.bottomLeftVec2.x, a_toBox.topRightVec2.x)

            if(possibleDoorPlaces.count == 0) return Vec2.new(0,0)

            return Vec2.new(possibleDoorPlaces[_rand.int(1, possibleDoorPlaces.count - 1)], a_fromBox.bottomLeftVec2.y)
        }

        return Vec2.new(0,0)
    }

    GetOverlappingLinePoints(a_line1_low, a_line1_high, a_line2_low, a_line2_high) {
        a_line1_low = a_line1_low.round
        a_line1_high = a_line1_high.round
        a_line2_low = a_line2_low.round
        a_line2_high = a_line2_high.round

        var overlappingPoints = List.new()

        for(p1 in a_line1_low + 1...a_line1_high){
            for(p2 in a_line2_low + 1...a_line2_high){
                
                if(p1.round == p2.round){
                    overlappingPoints.add(p1)
                }

            }
        }

        return overlappingPoints

    }

    GetBspBoxNeighborDir(a_fromBox, a_toBox) {


        var toLeft = a_fromBox.bottomLeftVec2.x.round == a_toBox.topRightVec2.x.round
        var toBot = a_fromBox.bottomLeftVec2.y.round == a_toBox.topRightVec2.y.round
        var toRight = a_fromBox.topRightVec2.x.round == a_toBox.bottomLeftVec2.x.round
        var toTop = a_fromBox.topRightVec2.y.round == a_toBox.bottomLeftVec2.y.round

        if(toLeft)  return Vec2.new(-1,0)
        if(toBot)   return Vec2.new(0,-1)  
        if(toRight) return Vec2.new(1,0)
        if(toTop)   return Vec2.new(0,1)

        return Vec2.new(0,0)
    }


    
}

class Room {
    construct new() {
        _roomTiles = List.new()
        _roomNeighbors = List.new()
        _box = null
        _mergebox = null
        _doors = List.new()
    }

    AddTile(a_tile){
        _roomTiles.add(a_tile)
    }

    AddTiles(a_tiles){
        _roomTiles = _roomTiles + a_tiles
    }

    AddRoomNeighbor(a_room){
        _roomNeighbors.add(a_room)
    }

    GetRoomTiles(){ _roomTiles }
    GetRoomNeighbors(){ _roomNeighbors }

    HasTile(a_tile){
        for(tile in _roomTiles){
            if(tile == a_tile) {
                return true
            }
        }

        return false
    }

    IsRoomNeighbor(a_room){
        for(room in _roomNeighbors){
            if(room == a_room){
                return true
            }
        }
        return false
    }

    GetBox() {
        return _box
    }
    GetMergebox() {
        return _mergebox
    }

    SetBox(a_box) {
        _box = a_box
    }

    SetMergebox(a_box){
        _mergebox = a_box
    }

    GetDoors() { _doors }
    SetDoors(a_doors) {
        _doors = a_doors
    }

    AddDoor(a_door){
        _doors.add(Vec2.new(a_door.x.round, a_door.y.round))
    }

}


class BspBox {
    construct new(a_bottomLeftVec2, a_topRightVec2){
        _bottomLeftVec2 = a_bottomLeftVec2
        _topRightVec2 = a_topRightVec2
        _mergedWithBox = null
    }

    bottomLeftVec2 { _bottomLeftVec2 }
    topRightVec2 { _topRightVec2 }
    size { _topRightVec2 - _bottomLeftVec2 }
    mergedWithBox {_mergedWithBox}
    Merge(a_mergeWith){
        _mergedWithBox = a_mergeWith
    } 

    IsMerged() { _mergedWithBox != null }
}

