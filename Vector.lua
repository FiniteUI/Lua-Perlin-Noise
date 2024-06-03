Vector = {}
Vector.__index = Vector
Vector.__name = "Vector"

-- static functions
function Vector.Dot_Product (vector1, vector2)
    assert(vector1.__name == Vector.__name, "Error: argument 1 must be Vector.")
    assert(vector2.__name == Vector.__name, "Error: argument 2 must be Vector.")

    return vector1.x * vector2.x + vector1.y * vector2.y
end

--overrides
function Vector.to_string(v)
    return "{" .. v.x .. ", " .. v.y .. "}"
end
Vector.__tostring = Vector.to_string

--instance functions
function Vector:new(x, y)
    -- table for object
    local new_vector = {}
    
    -- inherit from Vector
    setmetatable(new_vector, self)
    
    new_vector.x = x
    new_vector.y = y
    return new_vector
end

function Vector:magnitude()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector:normalize()
    local magnitude = self:magnitude()
    return Vector:new(self.x / magnitude, self.y / magnitude)
end

function Vector:to_table()
    return {self.x, self.y}
end