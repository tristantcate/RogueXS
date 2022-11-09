import "xs" for Render
import "xs_math" for Vec2, Math
import "random" for Random

class Grid {
    construct new(a_width, a_height, a_zero, a_tileSize) {
        _tileTypes = List.new()
        _tiles = List.new()

        _width = a_width
        _height = a_height
        
        _tileSize = a_tileSize

        _gridCenterOffset = Vec2.new(
            _tileSize.x * _width / 2.0 - _tileSize.x / 2.0,
            _tileSize.y * _height / 2.0)

        _tileTypes.add(TileType.new())
        _tileTypes.add(TileType.new("[game]/Art/Tiles/tile0.png", "WalkTile", true))
        _tileTypes.add(TileType.new("[game]/Art/Tiles/wall0.png", "BrownTile", false))

        _rand = Random.new()
        
        _rooms = List.new()

        // this.GenerateSymmetricRoom()

        
    }
    

    GetWidth { _width }
    GetHeight { _height}

    getTile (a_x, a_y) {
        var x = a_x.round
        var y = a_y.round
        var index = (y * _width + x).round
        // System.print("[%(x), %(y)]")
        return _tiles[index]
    }

    getTile (a_vec2) { getTile(a_vec2.x, a_vec2.y) }

    SetTileToNull (a_x, a_y) { 
        _tiles[a_y * _width + a_x] = null
    }

    SetTile (a_x, a_y, a_tileType) { 
        a_x = a_x.round
        a_y = a_y.round
        _tiles[a_y * _width + a_x] = Tile.new(a_tileType)
    }

    
    AddTileType(a_tileImagePath) {
        _tileTypes.add(TileType.new(a_tileImagePath))
    }

    GetTileTypeByIndex(a_tileIndex) {_tileTypes[a_tileIndex]}

    SetAllTiles(a_tileType) {
        for (i in 0..._width * _height) {
            _tiles[i] = Tile.new(a_tileType)
        }
    }

    GetTileSize { _tileSize }

    TileToWorldPos(a_x, a_y) {
        return Vec2.new(a_x  * _tileSize.x, a_y * _tileSize.y) - _gridCenterOffset   
    }

    TileToWorldPos(a_tileVec2) {
        return Vec2.new(a_tileVec2.x  * _tileSize.x, a_tileVec2.y * _tileSize.y) - _gridCenterOffset   
    }

    CanMoveToTile(a_tileVec2) {

        if(a_tileVec2.x < 0 || a_tileVec2.y < 0 || a_tileVec2.x >= _width - 1 || a_tileVec2.y >= _height - 1){
            return false
        }
        if(getTile(a_tileVec2).IsOccupied()){
            return false
        }

        return getTile(a_tileVec2).passable
    }

    IsTileInBounds(a_x, a_y){
        return a_x >= 0 && a_y >= 0 && a_x < _width && a_y < _height
        
    }

    IsTileInBounds(a_tileVec2){
        return this.IsTileInBounds(a_tileVec2.x, a_tileVec2.y)
    }


    GetTilesFromBspBox(a_box){
        var tiles = List.new()

        for(x in a_box.bottomLeftVec2.x + 1...a_box.topRightVec2.x){
            for(y in a_box.bottomLeftVec2.y + 1...a_box.topRightVec2.y){
                _tiles.add(getTile(x,y))
            }
        }

        return tiles
    }

    GenerateBSP(){
        var yieldTime = 0.005

        for (tile in 0..._width * _height) {
                _tiles.add(Tile.new(_tileTypes[1]))
        }

        var minBoxSize = Vec2.new(4,4)
        var maxBoxSize = Vec2.new(10,10)

        var boxes = List.new()
        boxes.add(BspBox.new(Vec2.new(0,0), Vec2.new(_width-1, _height-1)))

        var done = false



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

                    System.print("Splitting X")

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

                    System.print("Splitting Y")


                }
            }

            boxes = newBoxList

            done = true

            System.print("Current Boxes")
            for(i in 0...boxes.count){
                
                System.print("Box[%(i)], LeftBotPos: %(boxes[i].bottomLeftVec2), RightTopPos: %(boxes[i].topRightVec2), size: %(boxes[i].size)")

                if(boxes[i].size.x > maxBoxSize.x && boxes[i].size.y > maxBoxSize.y){
                    done = false
                    break
                }
            }

        }

        System.print("Done splitting boxes")
        

        var boxIndentChance = 0.4

        //Give all boxes chance to get indented
        for (box in boxes) {
            if(_rand.float(0.0, 1.0) < boxIndentChance){
                
                var leftIndentBool = _rand.float(0.0,1.0) > 0.5
                if(leftIndentBool){

                    for(boxY in box.bottomLeftVec2.y...box.topRightVec2.y){
                        this.SetTile(box.bottomLeftVec2.x, boxY, _tileTypes[2])
                        Fiber.yield(yieldTime)
                    }

                    box.bottomLeftVec2.x = box.bottomLeftVec2.x + 1

                    for(boxY in box.bottomLeftVec2.y...box.topRightVec2.y){
                        this.SetTile(box.bottomLeftVec2.x, boxY, _tileTypes[2])
                        Fiber.yield(yieldTime)
                    }
                    
                    box.bottomLeftVec2.x = box.bottomLeftVec2.x + 1

                } else{

                    for(boxX in box.bottomLeftVec2.x...box.topRightVec2.x){
                        this.SetTile(boxX, box.bottomLeftVec2.y, _tileTypes[2])
                        Fiber.yield(yieldTime)
                    }
                    box.bottomLeftVec2.y = box.bottomLeftVec2.y + 1

                    for(boxX in box.bottomLeftVec2.x...box.topRightVec2.x){
                        this.SetTile(boxX, box.bottomLeftVec2.y, _tileTypes[2])
                        Fiber.yield(yieldTime)
                    }
                    box.bottomLeftVec2.y = box.bottomLeftVec2.y + 1
                } 

            }
        }

        var mergeChance = 0.75

        var mergedRoomTilesToRemove = List.new()

        //Merge some rooms
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
                        newRoom.AddTile(getTile(tile.x, tile.y))
                    }

                    newRoom.SetBox(box)
                    newRoom.SetMergebox(mergeBox)

                    newRoom.AddTiles(this.GetTilesFromBspBox(box))
                    newRoom.AddTiles(this.GetTilesFromBspBox(mergeBox))

                    _rooms.add(newRoom)

                }
            }
        }

        //Create Rooms from boxes

        for (box in boxes) {
            
            //Merged boxes are already added while merging to keep destroyed tiles in mind
            if(box.IsMerged()){
                continue
            }

            var newRoom = Room.new()

            newRoom.AddTiles(this.GetTilesFromBspBox(box))
            newRoom.SetBox(box)

            _rooms.add(newRoom)

        }


        //Give every room appropriate neighbors
        //This is horrible code
        for (room in _rooms){

            var box = null
            var neighBox = null
            var neighDir = null

            for(neighborRoom in _rooms){
                
                if(room == neighborRoom || room.GetRoomNeighbors().contains(neighborRoom)){
                    continue
                }

                box = room.GetBox()
                neighBox = neighborRoom.GetBox()
                neighDir = this.GetBspBoxNeighborDir(box, neighBox)
                
                if(neighDir != null){
                    room.AddRoomNeighbor(neighborRoom)

                    

                    continue
                }
                
                if(room.GetMergebox() != null) {
                    box = room.GetMergebox()
                    neighBox = neighborRoom.GetBox()
                    neighDir = this.GetBspBoxNeighborDir(box, neighBox)

                    if(neighDir != null){
                        room.AddRoomNeighbor(neighborRoom)
                        continue
                    }
                }
                
                if(neighborRoom.GetMergebox() != null) {
                    box = room.GetBox()
                    neighBox = neighborRoom.GetMergebox()
                    neighDir = this.GetBspBoxNeighborDir(box, neighBox)
                    
                if(neighDir != null){
                        room.AddRoomNeighbor(neighborRoom)
                        continue
                    }
                }
                
                if(room.GetMergebox() != null && neighborRoom.GetMergebox() != null) {
                    box = room.GetMergebox()
                    neighBox = neighborRoom.GetMergebox()
                    neighDir = this.GetBspBoxNeighborDir(box, neighBox)

                    
                    if(neighDir != null){
                        room.AddRoomNeighbor(neighborRoom)
                        continue
                    }
                }

                
            }
        }

        //Place walls along left and bottom of boxes
        for (box in boxes) {
            for(boxX in box.bottomLeftVec2.x...box.topRightVec2.x){
                this.SetTile(boxX, box.bottomLeftVec2.y, _tileTypes[2])
                Fiber.yield(yieldTime)
            }

            for(boxY in box.bottomLeftVec2.y...box.topRightVec2.y){
                this.SetTile(box.bottomLeftVec2.x, boxY, _tileTypes[2])
                Fiber.yield(yieldTime)
            }
        }


        //place walls around the top and right
        for(x in 0..._width){
            this.SetTile(x, _height - 1, _tileTypes[2])
        }

        for(y in 0..._height){
            this.SetTile(_width - 1, y, _tileTypes[2])
        }


        //Empty surrounded tiles
        for (x in 0..._width){
            for (y in 0..._height){
                if(!getTile(x,y).passable && this.IsTileSurroundedByWalls(x,y)){
                    this.SetTile(x,y, _tileTypes[0])
                    Fiber.yield(yieldTime)
                }
            }
        }

        //Remove walls from merged rooms
        for(mergeRoomTile in mergedRoomTilesToRemove){
            this.SetTile(mergeRoomTile.x, mergeRoomTile.y, _tileTypes[1])
            Fiber.yield(yieldTime)
        }

        //Connect rooms through the removal of single wall tile in wall
        for (room in _rooms){
            for(neighborRoom in room.GetRoomNeighbors()){

                //if()

            }
        }

    }

    // GetDoorFromBoxes(a_fromBox, a_toBox, a_neighDir){
    //     if(neighDir == Vec2.new(1,0)) {
    //         var randDoorY = _rand.int(box.topRightVec2.)
    //     }
    // }

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

        var toLeft = a_fromBox.bottomLeftVec2.x - 1 == a_toBox.topRightVec2.x 
        var toBot = a_fromBox.bottomLeftVec2.y - 1 == a_toBox.topRightVec2.y
        var toRight = a_fromBox.topRightVec2.x + 1 == a_toBox.bottomLeftVec2.x
        var toTop = a_fromBox.topRightVec2.y + 1 == a_toBox.bottomLeftVec2.y

        if(toLeft)  return Vec2.new(-1,0)
        if(toBot)   return Vec2.new(0,-1)
        if(toRight) return Vec2.new(1,0)
        if(toTop)   return Vec2.new(0,1)

        return null
    }

    GenerateRandomWalk(){

        for (tile in 0..._width * _height) {
                _tiles.add(Tile.new(_tileTypes[2]))
        }

        var yieldTime = 0.005

        var startTileMaxEdge = 0.2
        var walkLength = 100
        var amountOfWalks = 8

        // var startTile = Vec2.new(_width/2.0,_height/2.0)

        var rotateChance = 0.2
        var rotateLeftChance = 0.5
        var currentTileVec2 = Vec2.new(0,0)        

        var directions = List.new()
        directions.add(Vec2.new(0,1))
        directions.add(Vec2.new(1,0))
        directions.add(Vec2.new(0,-1))
        directions.add(Vec2.new(-1,0))

        var currentDirID = 0
        var currentDirection = directions[currentDirID]

        for (walk in 0...amountOfWalks){
            
            currentTileVec2 = Vec2.new(
            _rand.int((_width * startTileMaxEdge).round, (_width * (1 - startTileMaxEdge)).round), 
            _rand.int((_height * startTileMaxEdge).round, (_height * (1 - startTileMaxEdge)).round)
            )


            for(i in 0...walkLength) {
                
                this.SetTile(currentTileVec2.x, currentTileVec2.y, _tileTypes[1])

                var goForward = _rand.float(0.0, 1.0) < rotateChance
                var nextTile = Vec2.new(0.0, 0.0)
                
                if(goForward) {
                    nextTile = currentTileVec2 + currentDirection 

                }else {

                    var goLeft = _rand.float(0, 1.0) < rotateLeftChance
                    var nextDir = Vec2.new(0.0,0.0)
                    var newDirID = Vec2.new(0.0,0.0)

                    if(goLeft){
                        newDirID = currentDirID - 1
                        if(newDirID < 0) newDirID = directions.count - 1

                    }else{
                        newDirID = currentDirID + 1
                        if(newDirID > directions.count - 1) newDirID = 0
                        
                    }

                    nextDir = directions[newDirID]
                    currentDirID = newDirID

                    nextTile = currentTileVec2 + nextDir
                    currentDirection = nextDir
                }

                if(!this.IsTileInBounds(nextTile)){
                    break
                }

                currentTileVec2 = nextTile
                               
                Fiber.yield(yieldTime)
            }
        }

        //Set walls around generated dungeon
         for(x in 0..._width){   
            for(y in 0..._height) {

                

                if(!getTile(x,y).passable){

                    if(this.IsTileSurroundedByWalls(x,y)){
                        this.SetTile(x,y, _tileTypes[0])
                    }

                    Fiber.yield(yieldTime)
                    continue
                }

                if(x == 0 || y == 0 || x == _width-1 || y == _height-1 &&
                    getTile(x,y).passable) {

                    this.SetTile(x, y, Tile.new(_tileTypes[2]))

                    Fiber.yield(yieldTime)
                    continue
                }
            }
        }

    }

    IsTileSurroundedByWalls(a_x, a_y){
        var rightWalktile = !getTile(a_x + 1, a_y).passable || !this.IsTileInBounds(a_x + 1, a_y)
        var leftWalktile =  !getTile(a_x - 1, a_y).passable || !this.IsTileInBounds(a_x - 1, a_y)
        var upWalktile =    !getTile(a_x, a_y + 1).passable || !this.IsTileInBounds(a_x, a_y + 1)
        var downWalktile =  !getTile(a_x, a_y - 1).passable || !this.IsTileInBounds(a_x, a_y - 1)

        var upRightWalktile =   !getTile(a_x + 1, a_y + 1).passable || !this.IsTileInBounds(a_x + 1, a_y + 1)
        var upLeftWalktile =    !getTile(a_x - 1, a_y + 1).passable || !this.IsTileInBounds(a_x - 1, a_y + 1)
        var downRightWalktile = !getTile(a_x + 1, a_y - 1).passable || !this.IsTileInBounds(a_x + 1, a_y - 1)
        var downLeftWalktile =  !getTile(a_x - 1, a_y - 1).passable || !this.IsTileInBounds(a_x - 1, a_y - 1)

        return rightWalktile && leftWalktile && upWalktile && downWalktile && upRightWalktile && upLeftWalktile && downRightWalktile && downLeftWalktile
       
        
    }

    IsTileSurroundedByWalls(a_tileVec2){
            return this.IsTileSurroundedByWalls(a_tileVec2.x, a_tileVec2.y)
    }

    

    GenerateSymmetricRoom(){

        var yieldTime = 0.02

        for (tile in 0..._width * _height) {
                _tiles.add(Tile.new(_tileTypes[1]))
        }


        for(x in 0..._width){   
            for(y in 0..._height) {

                if(x == 0 || y == 0 || x == _width-1 || y == _height-1){
                    this.SetTile(x, y, Tile.new(_tileTypes[2]))
                    Fiber.yield(yieldTime)
                }
            }
        }


        
        var randomWallAmountPerQuarter = 12
        for(randomTile in 0...randomWallAmountPerQuarter){
            

            var x = _rand.int(_width / 2, _width - 1)
            var y = _rand.int(_height / 2, _height - 1)

            this.SetTile(x, y, Tile.new(_tileTypes[2]))
            Fiber.yield(yieldTime)

            //Symmetry
            this.SetTile(_width - (x + 1), y, Tile.new(_tileTypes[2]))
            Fiber.yield(yieldTime)

            this.SetTile(x, _height - (y + 1), Tile.new(_tileTypes[2]))
            Fiber.yield(yieldTime)
            
            this.SetTile(_width - (x + 1), _height - (y + 1), Tile.new(_tileTypes[2]))
            Fiber.yield(yieldTime)
        }
    }

    Render(){

        for(x in 0..._width){
            for (y in 0..._height) {
                
                if(getTile(x,y).tileSprite == null) { 
                    continue
                }

                var tilePos =  this.TileToWorldPos(x,y)
                var tileSprite = getTile(x,y).tileSprite
                var tileImgSize = getTile(x,y).tileImageSize

                Render.sprite(tileSprite, tilePos.x, tilePos.y, -1.0, 
                _tileSize.x / tileImgSize, 0.0, 
                0xFFFFFFFF, 0x00000000, Render.spriteCenter)
            }
        }
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

class Room {
    construct new() {
        _roomTiles = List.new()
        _roomNeighbors = List.new()
        _box = null
        _mergebox = null
        _doors = null
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

}

class TileType {

    construct new(){
        _tileSprite = null
        _tileImageSize = 0
        _tileName = "null"
        _passable = false
    }


    construct new(a_tileImagePath, a_tileName, a_passable){
        var tileImage = Render.loadImage(a_tileImagePath)
        _tileSprite = Render.createSprite(tileImage, 0, 0, 1, 1)
        _tileImageSize = Render.getImageWidth(tileImage)
        _tileName = a_tileName
        _passable = a_passable
    }

    tileSprite { _tileSprite }
    tileImageSize {_tileImageSize}
    name {_tileName}
    passable {_passable}

}

//Tile is the data inside the grid, populated by TileTypes which are essentially
//predefined data of possible Tile instances.
class Tile {
    construct new(a_tileType) {
        
        _tileSprite = a_tileType.tileSprite
        _tileImageSize = a_tileType.tileImageSize
        _passable = a_tileType.passable
        _occupiedBy = 0
    }
    
    tileSprite {_tileSprite}
    tileImageSize {_tileImageSize}
    passable { _passable }
    occupiedBy { _occupiedBy }
    IsOccupied() { _occupiedBy != 0}
    
    SetOccupiedBy (a_occupier) {
        _occupiedBy = a_occupier
    }


}