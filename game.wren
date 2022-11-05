// This is just confirmation, remove this line as soon as you
// start making your game
System.print("Wren just got compiled to bytecode")

// The xs module is 
import "xs" for Render, Data, Input
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

        __grid = Grid.new(50, 50, 0)
        

        var tileImage = Render.loadImage("[game]/Art/Tiles/tile0.png")
        __tilesprite = Render.createSprite(tileImage, 0, 0, 1, 1)
        __spriteImageSize = Render.getImageWidth(tileImage)



        __tileType = TileType.new(tileImage)
        __grid.SetAllTiles(__tileType)

    }    

    static update(dt) {
        __time = __time + dt


        
    }

    // The render method is called once per tick, right after update.
    static render() {
       


        for(x in 0...__grid.GetWidth){
            for (y in 0...__grid.GetHeight) {
                Render.sprite(__tilesprite, x , y, 0.0, 1/__spriteImageSize, 
                0.0, 0xFFFFFFFF, 0x00000000, Render.spriteCenter)
            }
        }
    }
}