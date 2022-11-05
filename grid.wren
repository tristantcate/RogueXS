class Grid {
    construct new(a_width, a_height, a_zero) {
        _tiles = List.new()
        _width = a_width
        _height = a_height

        for (tile in 0..._width * _height) {
            _tiles.add(a_zero)
        }
    }

    GetWidth { _width }
    GetHeight { _height}

    GetTile (a_x, a_y) { _tiles[a_y * _width + a_x] }
    SetTile (a_x, a_y, a_tileType) { 
        _tiles[a_y * _width + a_x] = Tile.new()
    }

    SetAllTiles(a_tileType) {
        for (i in 0..._width * _height) {
            _tiles[i] = Tile.new(a_tileType)
        }
    }

}

class TileType {
    construct new(a_tileSprite){
        _tileSprite
    }

    tileSprite { _tileSprite }

}

//Tile is the data inside the grid, populated by TileTypes which are essentially
//predefined data of possible Tile instances.
class Tile {
    construct new(a_tileType) {
        _tileSprite = a_tileType.tileSprite
    }
    

}