import "xs" for Render
import "xs_math" for Vec2
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

        _tileTypes.add(TileType.new("[game]/Art/Tiles/tile0.png", "WalkTile", true))
        _tileTypes.add(TileType.new("[game]/Art/Tiles/wall0.png", "BrownTile", false))

        
        for (tile in 0..._width * _height) {
                _tiles.add(Tile.new(_tileTypes[0]))
        }


        for(x in 0..._width){   
            for(y in 0..._height) {

                if(x == 0 || y == 0 || x == _width-1 || y == _height-1){
                    this.SetTile(x, y, Tile.new(_tileTypes[1]))
                }
            }
        }


        _rand = Random.new()
        
        var randomWallAmountPerQuarter = 6
        for(randomTile in 0...randomWallAmountPerQuarter){
            

            var x = _rand.int(_width / 2, _width - 1)
            var y = _rand.int(_height / 2, _height - 1)

            this.SetTile(x, y, Tile.new(_tileTypes[1]))

            //Symmetry
            this.SetTile(_width - (x + 1), y, Tile.new(_tileTypes[1]))
            this.SetTile(x, _height - (y + 1), Tile.new(_tileTypes[1]))
            this.SetTile(_width - (x + 1), _height - (y + 1), Tile.new(_tileTypes[1]))
        }

        

        
    }

    GetWidth { _width }
    GetHeight { _height}

    getTile (a_x, a_y) {
        var x = a_x.floor
        var y = a_y.floor
        var index = (y * _width + x).floor
        // System.print("[%(x), %(y)]")
        return _tiles[index]
    }

    getTile (a_vec2) { getTile(a_vec2.x, a_vec2.y) }

    SetTile (a_x, a_y, a_tileType) { 
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

    Render(){

        for(x in 0..._width){
            for (y in 0..._height) {

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