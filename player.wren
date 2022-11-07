import "xs" for Render, Input
import "xs_math" for Vec2

class Actionable {
    Update(a_deltaTime){}
    Render(){}
}


class Enemy is Actionable {
    construct new(a_spritePath, a_gridRef, a_gridStartPos){

        var image = Render.loadImage(a_spritePath)
        _sprite = Render.createSprite(image, 0, 0, 1, 1)
        _spriteSize = a_gridRef.GetTileSize *  (1 / Render.getImageWidth(image))

        _gridRef = a_gridRef
        _gridPos = a_gridStartPos

    }

    Update(a_deltaTime){

    }


    Render(){
        var worldPos = _gridRef.TileToWorldPos(_gridPos)
            Render.sprite(_sprite, worldPos.x, worldPos.y, 1.0, _spriteSize.x, 0.0,
            0xFFFFFFFF, 0x00000000, Render.spriteCenter)
    }

}

class Player is Actionable {


    construct new(a_playerSpritePath, a_gridRef, a_gridStartPos){

        var playerImage = Render.loadImage(a_playerSpritePath)
        _sprite = Render.createSprite(playerImage, 0, 0, 1, 1)
        _spriteSize = a_gridRef.GetTileSize *  (1 / Render.getImageWidth(playerImage))

        _gridRef = a_gridRef
        _playerGridPos = a_gridStartPos
    }

    Update(a_deltaTime) {

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

        _playerGridPos = _playerGridPos + moveDir
    }

    Render() {

        var playerWorldPos = _gridRef.TileToWorldPos(_playerGridPos)
        Render.sprite(_sprite, playerWorldPos.x, playerWorldPos.y, 1.0, _spriteSize.x, 0.0,
        0xFFFFFFFF, 0x00000000, Render.spriteCenter)
    }

}