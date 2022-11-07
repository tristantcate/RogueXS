import "xs" for Render, Input
import "xs_math" for Vec2, Math
import "RogueXS_math" for MathF

class Actionable {

    construct new() {
        _hasTurn = false
    }

    HasTurn() { _hasTurn }
    GiveTurn() {
        _hasTurn = true
    }

    SetTurn(a_hasTurn){
        _hasTurn = a_hasTurn
    }
    
    Update(a_deltaTime){}
    Render(){}
}


class Enemy is Actionable {
    construct new(a_spritePath, a_gridRef, a_gridStartPos, a_player){

        super()

        var image = Render.loadImage(a_spritePath)
        _sprite = Render.createSprite(image, 0, 0, 1, 1)
        _spriteSize = a_gridRef.GetTileSize *  (1 / Render.getImageWidth(image))

        _gridRef = a_gridRef
        _gridPos = a_gridStartPos

        _player = a_player

    }

    Update(a_deltaTime){
        if(!super.HasTurn()){
            return
        }


        var addMovePos = Vec2.new(1.0, 0.0)

        var moveDir = _player.GetGridPos() - _gridPos
        if(MathF.abs(moveDir.x) > MathF.abs(moveDir.y)){
            addMovePos = Vec2.new(moveDir.x, 0).normalise
        }else{
            addMovePos = Vec2.new(0, moveDir.y).normalise
        }



        _gridPos = _gridPos + addMovePos
        super.SetTurn(false)
    }


    Render(){
        var worldPos = _gridRef.TileToWorldPos(_gridPos)
            Render.sprite(_sprite, worldPos.x, worldPos.y, 1.0, _spriteSize.x, 0.0,
            0xFFFFFFFF, 0x00000000, Render.spriteCenter)
    }

}

class Player is Actionable {


    construct new(a_playerSpritePath, a_gridRef, a_gridStartPos){

        super()

        var playerImage = Render.loadImage(a_playerSpritePath)
        _sprite = Render.createSprite(playerImage, 0, 0, 1, 1)
        _spriteSize = a_gridRef.GetTileSize *  (1 / Render.getImageWidth(playerImage))

        _gridRef = a_gridRef
        _playerGridPos = a_gridStartPos
    }

    GetGridPos() { _playerGridPos }

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

        if(_playerGridPos != _playerGridPos + moveDir){
            _playerGridPos = _playerGridPos + moveDir
            super.SetTurn(false)
        }



    }

    Render() {

        var playerWorldPos = _gridRef.TileToWorldPos(_playerGridPos)
        Render.sprite(_sprite, playerWorldPos.x, playerWorldPos.y, 1.0, _spriteSize.x, 0.0,
        0xFFFFFFFF, 0x00000000, Render.spriteCenter)
    }

}