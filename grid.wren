import "xs" for Render
import "xs_math" for Vec2

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

        _tileTypes.add(TileType.new("[game]/Art/Tiles/tile0.png", "BrownTile"))

        for (tile in 0..._width * _height) {
            _tiles.add(Tile.new(_tileTypes[0]))
        }

        
    }

    GetWidth { _width }
    GetHeight { _height}

    getTile (a_x, a_y) { _tiles[a_y * _width + a_x] }
    SetTile (a_x, a_y, a_tileType) { 
        _tiles[a_y * _width + a_x] = Tile.new()
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
    construct new(a_tileImagePath, a_tileName){
        var tileImage = Render.loadImage(a_tileImagePath)
        _tileSprite = Render.createSprite(tileImage, 0, 0, 1, 1)
        _tileImageSize = Render.getImageWidth(tileImage)
        _tileName = a_tileName
    }

    tileSprite { _tileSprite }
    tileImageSize {_tileImageSize}
    name {_tileName}

}

//Tile is the data inside the grid, populated by TileTypes which are essentially
//predefined data of possible Tile instances.
class Tile {
    construct new(a_tileType) {
        
        _tileSprite = a_tileType.tileSprite
        _tileImageSize = a_tileType.tileImageSize
    }
    
    tileSprite {_tileSprite}
    tileImageSize {_tileImageSize}

}