// This is just confirmation, remove this line as soon as you
// start making your game
System.print("Wren just got compiled to bytecode")

// The xs module is 
import "xs" for Render, Data, Input
import "xs_math" for Vec2

import "grid" for Grid
import "player" for Player, Enemy


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

        

        __tileSize = Vec2.new(16.0, 16.0)
        __grid = Grid.new(20, 20, 0, __tileSize)
       
        __playerStartPos = Vec2.new(4.0, 7.0)

        __actionables = List.new()


        __player = Player.new("[game]/Art/hero.png", __grid, __playerStartPos)
        __actionables.add(__player)

        __actionables.add(Enemy.new("[game]/Art/ghoulEnemy.png", __grid, Vec2.new(10, 5), __player))
        __actionables.add(Enemy.new("[game]/Art/ghoulEnemy.png", __grid, Vec2.new(14, 8), __player))
        __actionables.add(Enemy.new("[game]/Art/ghoulEnemy.png", __grid, Vec2.new(5, 12),__player))

        __player.GiveTurn()
        __currentCharacterID = 0

       
        __gridRenderYieldTime = 0.05
        __gameplayYieldTime = 0.33

        __fiberTime = __gameplayYieldTime

        __gridRenderLoop = Fiber.new{__grid.GenerateSymmetricRoom()}
        __gameLoop = Fiber.new{this.GameLoop()}

        __currentLoop = __gridRenderLoop
        __currentYieldTime = __gridRenderYieldTime

        __grid.GenerateSymmetricRoom()
        
    }    

    static update(dt) {

        __time = __time + dt

        for (actionable in __actionables) {
            actionable.Update(dt)
        }

        if(__fiberTime == null){
            __fiberTime = 0
        }

        __fiberTime = __fiberTime - dt
        if(__fiberTime <= 0) {

            if(!__currentLoop.isDone){
                __fiberTime = __currentLoop.call()
            }else if(__currentLoop.isDone && __currentLoop == __gridRenderLoop){
                __currentLoop = __gameLoop
                __currentYieldTime = __gameplayYieldTime
                __fiberTime = 0
                this.GameLoop()
            }
        }


        
        
        
    }

    // The render method is called once per tick, right after update.
    static render() {
       
        __grid.Render()

        for (actionable in __actionables) {
            actionable.Render()
        }

    }

    static GameLoop(){

        while(true){
            var currentCharacter = 0

            for (actionable in __actionables) {
                if(actionable.HasTurn()){
                    currentCharacter = actionable
                }
            }

            if(currentCharacter == 0){

                __currentCharacterID =  __currentCharacterID + 1
                if(__currentCharacterID >= __actionables.count){
                    __currentCharacterID = 0
                }

                __actionables[__currentCharacterID].GiveTurn()
            }


            Fiber.yield(__currentYieldTime)
        }

        System.print("Gameloop Ended!")
    }
        
}