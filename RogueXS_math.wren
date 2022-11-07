class MathF {
    static abs(a_val){
        var multVal = 1.0
        if(a_val < 0){
            multVal = -1.0
        }
        return a_val * multVal 
    }

    static clamp(a_val, a_min, a_max){
        if(a_val < a_min){
          a_val = a_min  
        } 

        if(a_val > a_max){
          a_val = a_max 
        } 

        return a_val 
    }
}