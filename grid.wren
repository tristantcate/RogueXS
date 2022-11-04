class Grid {
    construct new(a_width, a_height, a_zero){
        _width = a_width
        _height = a_height
        _grid = List.new()

        for(tile in 0... _width * _height) {
            _grid.add(a_zero)
        }
    }

    

    [x,y]=(value) {
        _grid[y * _width + x] = value
    }

    [x,y] { _grid[y * _width + x] }
    [vec2]{ _grid[vec2.y * _width + vec2.x] }
    width   { _width }
    height  { _height }

    swap(fromX, fromY, toX, toY){
        var temp = this[toX, toY]
        this[toX, toY] = this[fromX, fromY]
        this[fromX, fromY] = temp
    }
}