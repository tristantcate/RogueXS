import "xs" for Render, Input
import "xs_math" for Vec2, Math
import "RogueXS_math" for MathF

class Actionable {

    construct new(a_gridRef, a_gridStartPos) {
        _hasTurn = false

        _gridRef = a_gridRef
        _gridPos = a_gridStartPos
        _gridRef.getTile(a_gridStartPos).SetOccupiedBy(this)

        _isPlayer = false
    }

    IsPlayer() {_isPlayer}
    SetIsPlayer(a_isPlayer){
        _isPlayer = a_isPlayer
    }

    GetGridRef() { _gridRef }
    GetGridPos() { _gridPos }

    HasTurn() { _hasTurn }
    GiveTurn() {
        _hasTurn = true
    }

    SetTurn(a_hasTurn){
        _hasTurn = a_hasTurn
    }

    MoveToTile(a_toTileVec2) {
        System.print("gridPos:  %(_gridPos)")
        _gridRef.getTile(_gridPos).SetOccupiedBy(0)
        _gridPos = a_toTileVec2
        _gridRef.getTile(a_toTileVec2).SetOccupiedBy(this)
    }
    


    Update(a_deltaTime){}
    Render(){}
}


class Enemy is Actionable {
    construct new(a_spritePath, a_gridRef, a_gridStartPos, a_player){

        super(a_gridRef, a_gridStartPos)

        var image = Render.loadImage(a_spritePath)
        _sprite = Render.createSprite(image, 0, 0, 1, 1)
        _spriteSize = a_gridRef.GetTileSize *  (1 / Render.getImageWidth(image))

        _player = a_player

    }

    Update(a_deltaTime){
        if(!super.HasTurn()){
            return
        }


        var moveDir = _player.GetGridPos() - super.GetGridPos()
        var xMove = Vec2.new(MathF.clamp(moveDir.x,-1,1), 0.0)
        var yMove = Vec2.new(0.0, MathF.clamp(moveDir.y, -1, 1))

        var canMoveX = super.GetGridRef().CanMoveToTile(super.GetGridPos() + xMove)
        var canMoveY = super.GetGridRef().CanMoveToTile(super.GetGridPos() + yMove)

        if(!canMoveX && !canMoveY){
            super.SetTurn(false)
            return
        }

        if(!canMoveX && canMoveY){

            this.MoveToTile(super.GetGridPos() + yMove)
            super.SetTurn(false)
            return
        }

        if(canMoveX && !canMoveY){
            this.MoveToTile(super.GetGridPos() + xMove)
            super.SetTurn(false)
            return
        }


        var addMovePos = Vec2.new(0.0, 0.0)

        if(MathF.abs(moveDir.x) > MathF.abs(moveDir.y)){
            addMovePos = xMove
        }else{
            addMovePos = yMove
        }

        super.MoveToTile(super.GetGridPos() + addMovePos)
        super.SetTurn(false)

    }

    Render(){

        var worldPos = super.GetGridRef().TileToWorldPos(super.GetGridPos())
            Render.sprite(_sprite, worldPos.x, worldPos.y, 1.0, _spriteSize.x, 0.0,
            0xFFFFFFFF, 0x00000000, Render.spriteCenter)
    }

}

class Player is Actionable {


    construct new(a_playerSpritePath, a_gridRef, a_gridStartPos){

        super(a_gridRef, a_gridStartPos)

        var playerImage = Render.loadImage(a_playerSpritePath)
        _sprite = Render.createSprite(playerImage, 0, 0, 1, 1)
        _spriteSize = a_gridRef.GetTileSize *  (1 / Render.getImageWidth(playerImage))
        super.SetIsPlayer(true)
    }



    Update(a_deltaTime) {

        if(!super.HasTurn()){
            return
        }

        var moveDir = Vec2.new()
        if(Input.getKeyOnce(Input.keyRight)) {
            moveDir.x = moveDir.x + 1.0
        }

        if(Input.getKeyOnce(Input.keyLeft)) {
            moveDir.x = moveDir.x - 1.0
        }

        if(Input.getKeyOnce(Input.keyUp)) {
            moveDir.y = moveDir.y + 1.0
        }

        if(Input.getKeyOnce(Input.keyDown)) {
            moveDir.y = moveDir.y - 1.0
        }

        var canMoveToTile = super.GetGridRef().CanMoveToTile(super.GetGridPos() + moveDir)

        if(super.GetGridPos() != super.GetGridPos() + moveDir && canMoveToTile){
            super.MoveToTile(super.GetGridPos() + moveDir)
            super.SetTurn(false)
        }

        super.GetGridRef().SetPlayerPosition(super.GetGridPos())


    }

    Render() {

        var playerWorldPos = super.GetGridRef().TileToWorldPos(super.GetGridPos())
        Render.sprite(_sprite, playerWorldPos.x, playerWorldPos.y, 1.0, _spriteSize.x, 0.0,
        0xFFFFFFFF, 0x00000000, Render.spriteCenter)
    }

}