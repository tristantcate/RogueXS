class MathF {
    static abs(a_val){
        var multVal = 1.0
        if(a_val < 0){
            multVal = -1.0
        }
        return a_val * multVal 
    }
}