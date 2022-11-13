// This is just confirmation, remove this line as soon as you
// start making your game
System.print("Wren just got compiled to bytecode")

// The xs module is 
import "xs" for Render, Data, Input
import "xs_math" for Vec2

import "grid" for Grid
import "player" for Player, Enemy
import "BSPGenerator" for BSPGenerator

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

        

        __tileSize = Vec2.new(8.0, 8.0)
        __grid = Grid.new(40, 40, 0, __tileSize)
       
        __playerStartPos = Vec2.new(4.0, 7.0)

        __currentCharacterID = 0
        __actionables = List.new()
        __gameIsSetup = false
        

       
        __gridRenderYieldTime = 0.05
        __gameplayYieldTime = 0.33

        __fiberTime = __gameplayYieldTime

        __fiberList = List.new()
        __currentFiberID = 0

        // __gridRenderLoop = Fiber.new{__grid.GenerateRandomWalk()}
        var bspgen = BSPGenerator.new(__grid)

        __fiberList.add(FFiber.new(Fn.new{bspgen.GenerateBSPFiber(false, false)}, -0.01))
        __fiberList.add(FFiber.new(Fn.new{this.SetupGameFiber()}, 0.25))
        __fiberList.add(FFiber.new(Fn.new{this.GameLoopFiber()}, 0.25))

        __currentLoop = __fiberList[0]
        __currentYieldTime = __gridRenderYieldTime

        __fiberList[0].GetFunction().call()

        
    }    

    static update(dt) {

        __time = __time + dt


        if(__fiberTime == null){
            __fiberTime = 0
        }

        __fiberTime = __fiberTime - dt
        
        if(__fiberTime <= 0) {

            if(!__currentLoop.GetFiber().isDone){
                __fiberTime = __currentLoop.GetFiber().call()
                __fiberTime = __currentLoop.GetFiberTime()
            }else if(__currentLoop.GetFiber().isDone){
                
                this.SetNextFiber()

                __fiberTime = 0
            }
        }


        if(!__gameIsSetup){
            return
        }

        for (actionable in __actionables) {
            actionable.Update(dt)
        }

    }
    
    static SetNextFiber() {
        if(__currentFiberID < __fiberList.count - 1){
            __currentFiberID = __currentFiberID + 1
        }
        
        __currentLoop = __fiberList[__currentFiberID]
        System.print("Setting up fiber %(__currentFiberID)")
                
    }

    // The render method is called once per tick, right after update.
    static render() {
       
        __grid.Render()

        if(!__gameIsSetup){
            return
        }

        for (actionable in __actionables) {
            actionable.Render()
        }

    }

    static SetupGameFiber(){

        __player = Player.new("[game]/Art/hero.png", __grid, __playerStartPos)
        __actionables.add(__player)


        __actionables.add(Enemy.new("[game]/Art/ghoulEnemy.png", __grid, Vec2.new(10, 5), __player))
        __actionables.add(Enemy.new("[game]/Art/ghoulEnemy.png", __grid, Vec2.new(14, 8), __player))
        __actionables.add(Enemy.new("[game]/Art/ghoulEnemy.png", __grid, Vec2.new(5, 12), __player))

        System.print("ACtionables in game: %(__actionables.count)")

        __player.GiveTurn()
        
        this.SetGameIsSetup(true)
        
    }

    static SetGameIsSetup(a_bool){
        __gameIsSetup = a_bool
    }

    static GameLoopFiber(){
        
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

    }
        
}

class FFiber {
    construct new(a_function, a_fiberTime){
        _function = a_function
        _fiber = Fiber.new { _function.call() } //This is not a fiber inside a fiber, fiber functions in _function dont work bro
        _fiberTime = a_fiberTime
    }

    GetFunction() {_function}
    GetFiber() {_fiber}
    GetFiberTime() {_fiberTime}
}