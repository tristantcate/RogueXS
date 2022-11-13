import "xs_math" for Vec2

class Camera {
    construct new(){
        __cameraPos = Vec2.new(0,0)
    }

    static SetPosition(a_cameraPos){
        __cameraPos = a_cameraPos
    }

    static GetPosition(){
        return __cameraPos
    }
}