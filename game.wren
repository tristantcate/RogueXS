// This is just confirmation, remove this line as soon as you
// start making your game
System.print("Wren just got compiled to bytecode")

// The xs module is 
import "xs" for Render, Data, Input
import "xs_math" for Vec2

import "grid" for Grid, TileType, Tile


class Game {



    static config() {
        System.print("config")
        
        Data.setString("Title", "xs - Cool Rogue game", Data.system)
        Data.setNumber("Width", 640, Data.system)
        Data.setNumber("Height", 360, Data.system)
        Data.setNumber("Multiplier", 2, Data.system)
        Data.setBool("Fullscreen", false, Data.system)
    }


    static init() {        

        __time = 0

        __grid = Grid.new(20, 20, 0)
        

        var tileImage = Render.loadImage("[game]/Art/Tiles/tile0.png")
        __tilesprite = Render.createSprite(tileImage, 0, 0, 1, 1)
        __spriteImageSize = Render.getImageWidth(tileImage)



        __tileType = TileType.new(tileImage)
        __grid.SetAllTiles(__tileType)

        __tileSize = Vec2.new(32.0, 16.0)

    }    

    static update(dt) {
        __time = __time + dt


        
    }

    // The render method is called once per tick, right after update.
    static render() {
       
        var gridRenderCenterOffset = Vec2.new(
            __tileSize.x * __grid.GetWidth / 2.0 - __tileSize.x / 2.0,
            __tileSize.y * __grid.GetHeight / 2.0)
            
        var renderTileSize = (1/__spriteImageSize) * __tileSize.x

        for(x in 0...__grid.GetWidth){
            for (y in 0...__grid.GetHeight) {

                var tilePos =  Vec2.new(x  * __tileSize.x, y * __tileSize.y) - gridRenderCenterOffset

                Render.sprite(__tilesprite, tilePos.x, tilePos.y, 0.0, renderTileSize, 
                0.0, 0xFFFFFFFF, 0x00000000, Render.spriteCenter)
            }
        }
    }
}