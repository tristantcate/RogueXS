// This is just confirmation, remove this line as soon as you
// start making your game
System.print("Wren just got compiled to bytecode")

// The xs module is 
import "xs" for Render, Data, Input
import "grid" for Grid
import "xs_math" for Vec2, Math

class Type {
    static none      { 0 << 0}
    static player    { 1 << 0}
    static enemy     { 1 << 1}
    static bomb      { 1 << 2}
    static wall      { 1 << 3}
    static obstructed{ enemy | wall}
   
}

class Turn {
    static none     { 0 }
    static player   { 1 }
    static enemy    { 2 }
}

class Game {



    static config() {
        System.print("config")
        
        Data.setString("Title", "xs - Cool Rogue game", Data.system)
        Data.setNumber("Width", 640, Data.system)
        Data.setNumber("Height", 360, Data.system)
        Data.setNumber("Multiplier", 1, Data.system)
        Data.setBool("Fullscreen", false, Data.system)
    }


    static init() {        

        __time = 0

        __turn = Turn.player

        __grid = Grid.new(8, 8, Type.none)
        __grid[4,4] = Type.player

        //Enemies
        __grid[0,1] = Type.enemy
        __grid[3,6] = Type.enemy

        // for(x in 0...__grid.width){
        //     for (y in 0...__grid.height){
        //         //var tile = __grid[x, y]
        //         if(x == 0 || y == 0 || x == __grid.width - 1 || y == __grid.height - 1){
        //             __grid[x,y] = Type.wall
        //         }
        //     }
        // }

        System.print()
    }    

    // The update method is called once per tick.
    // Gameplay code goes here.
    static update(dt) {
        __time = __time + dt


        var playerPos = null
        for(x in 0...__grid.width){
            for (y in 0...__grid.height){
                var tile = __grid[x, y]
                if(tile == Type.player) {
                    playerPos = Vec2.new(x,y)
                }
            }
        }

        var dir = getDirection()
        if(dir != Vec2.new(0,0)){
            moveDirection(playerPos, dir)
        }

        if(__turn == Turn.player){
            playerTurn()
        }
        
    }

    static playerTurn(){

    }

    static getDirection(){
        if(Input.getKeyOnce(Input.keyUp)){
            return Vec2.new(0,1)
        }
        
        if(Input.getKeyOnce(Input.keyDown)){
            return Vec2.new(0,-1)
        }
        
        if(Input.getKeyOnce(Input.keyRight)){
            return Vec2.new(1,0)
        }
        
        if(Input.getKeyOnce(Input.keyLeft)){
            return Vec2.new(-1,0)
        }

        return Vec2.new(0,0)
    }

    static moveDirection(a_pos, a_dir){
        var fromPos = a_pos
        var toPos = a_pos + a_dir

        toPos.x = Math.mod(toPos.x, __grid.width)
        toPos.y = Math.mod(toPos.y, __grid.height)
        //toPos.y = toPos.y % __grid.height

        if(__grid[toPos] != Type.wall && __grid[toPos] != Type.enemy ){
        __grid.swap(fromPos.x, fromPos.y, toPos.x, toPos.y)
        

        }
    }

    // The render method is called once per tick, right after update.
    static render() {
        Render.setColor(1,1,1)
        var radius = 8
        var offset = 2 * radius
        var sx = -__grid.width * radius
        var sy = -__grid.height * radius

       for(x in 0...__grid.width){
            for (y in 0...__grid.height){
                //var tile = __grid[x, y]
                
                if(__grid[x,y] == Type.none){
                    Render.setColor(1,1,1)
                    Render.circle(x * offset + sx, y * offset + sy,  5, 12)
                }

                if(__grid[x,y] == Type.player){
                    Render.setColor(0,0,1)
                    Render.disk(x * offset + sx, y * offset + sy,  5, 12)
                }

                if(__grid[x,y] == Type.enemy){
                    Render.setColor(1,0,1)
                    Render.disk(x * offset + sx, y * offset + sy,  5, 12)
                }

                if(__grid[x,y] == Type.wall){
                    Render.setColor(0.5,0.5,0.5)
                    Render.disk(x * offset + sx, y * offset + sy,  5, 12)
                }

                //System.print("%(__grid[x, y])")
            }
        }

        Render.circle(0.0, 0.0, 5, 12)

    }
}