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

       _walkableTiles = List.new()
    
        
    }
    

    GetWidth { _width }
    GetHeight { _height}

    getTile (a_x, a_y) {
        var x = a_x.round
        var y = a_y.round
        var index = (y * _width + x).round
        return _tiles[index]
    }

    getTile (a_vec2) { getTile(a_vec2.x, a_vec2.y) }

    GetTiles() {_tiles}

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

    GetAllWalkableTilePositions() {

        var walkableTiles = List.new()

        for (x in _width){
            for (y in _height){
                var currentTile = getTile(x,y) 

                if(!currentTile.passable && !currentTile.occupiedBy) {
                    walkableTiles.add(Vec2.add(x,y))
                }
            }
        }

        return walkableTiles
    }
    

    GenerateRandomWalkFiber(){

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