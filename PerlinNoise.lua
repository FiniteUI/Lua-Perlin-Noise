require("Vector")
require("SquirrelNoise5-LuaJIT")

PerlinNoise = {}
PerlinNoise.__index = PerlinNoise
PerlinNoise.__name = "PerlinNoise"
PerlinNoise.MAX_2D = math.sqrt(2) * math.sqrt(1/2)
PerlinNoise.MIN_2D = -PerlinNoise.MAX_2D
PerlinNoise.RANGE_2D = PerlinNoise.MAX_2D - PerlinNoise.MIN_2D
PerlinNoise.NORMAL_2D = 1 / PerlinNoise.RANGE_2D

--private functions
local function PerlinPermutationTable()
    -- this is Ken Perlin's original permutation table
    return {151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180}
end

local function GeneratePermutationTable(size)
    local pt = {}
    for i = 0, size - 1 do
        table.insert(pt, i)
    end

    return pt
end

local function ShuffleTable(seed, t)
    local noise = SquirrelNoise5:new(seed)
    local shuffled = {}
    local iterations = #t
    local index

    --build the new table one item at a time
    for i=0, iterations do

        --grab a random item from the original table and add it to the new table
        if #t > 1 then
            index = noise:randomIntegerRange(1, #t)
        else
            index = 1
        end
        table.insert(shuffled, t[index])

        --remove original item so it doesn't get repeated
        table.remove(t, index)
    end

    return shuffled
end

local function DoubleTable(t)
    local length = #t
    for i = 1, length do
        table.insert(t, t[i])
    end

    return t
end

local function Lerp(a, b, p)
    return a + (b - a) * p
end

local function Fade(t)
    --return the F(t) value along the ease curve
    --6t^5 - 15t^4 + 10t^3
    return t * t * t * (t * (t * 6 - 15) + 10)
end

local function GetConstantVector(value)
    --choose one of the four directional vectors (up-right, up-left, down-left, down-right)
    value = value % 4
    local v
    if value == 0 then
        --up-right
        return Vector:new(1, 1)
    elseif value == 1 then
        --up-left
        return Vector:new(-1, 1)
    elseif value == 2 then
        --down-left
        return Vector:new(-1, -1)
    else
        --down-right
        return Vector:new(1, -1)
    end
end

--instance functions
function PerlinNoise:new(seed, size)
    local new = {}
    setmetatable(new, self)

    new.seed = seed
    new.size = size or 256
    
    --generate permutation table
    local permutations = GeneratePermutationTable(size)
    permutations = ShuffleTable(seed, permutations)
    DoubleTable(permutations)
    new.permutation_table = permutations

    return new
end

function PerlinNoise:Noise2D(x, y)
    --generate vectors from the corners of the 'grid' to the input point
    local x_float = x - math.floor(x)
    local y_float = y - math.floor(y)
    local top_right = Vector:new(x_float - 1, y_float - 1)
    local top_left = Vector:new(x_float, y_float - 1)
    local bottom_right = Vector:new(x_float - 1, y_float)
    local bottom_left = Vector:new(x_float, y_float)

    --grab the permutation table value for each corner
    --because lua tables are 1-indexed, we add 1 to the value
    --this only affects grabbing values from the permutation table
    local x_index = (math.floor(x) % self.size) + 1
    local y_index = (math.floor(y) % self.size) + 1

    local top_right_value = self.permutation_table[self.permutation_table[x_index + 1] + y_index + 1]
    local top_left_value = self.permutation_table[self.permutation_table[x_index] + y_index + 1]
    local bottom_right_value = self.permutation_table[self.permutation_table[x_index + 1] + y_index]
    local bottom_left_value = self.permutation_table[self.permutation_table[x_index] + y_index]

    -- compute dot product between constant vectors and corner vectors
    local dot_tr = Vector.Dot_Product(top_right, GetConstantVector(top_right_value))
    local dot_tl = Vector.Dot_Product(top_left, GetConstantVector(top_left_value))
    local dot_br = Vector.Dot_Product(bottom_right, GetConstantVector(bottom_right_value))
    local dot_bl = Vector.Dot_Product(bottom_left, GetConstantVector(bottom_left_value))

    -- lerp between them for result
    local x_fade = Fade(x_float)
    local y_fade = Fade(y_float)
    local result = Lerp(Lerp(dot_bl, dot_tl, y_fade), Lerp(dot_br, dot_tr, y_fade), x_fade)

    return result
end

function PerlinNoise:Normalized_Noise2D(x, y)
    -- if using normalized constant vectors, the range is:
    -- [- (N/4) ^ -2, (N/4 ^ -2)]
    -- where N is the dimensions. So for 2D, it's -sqrt(1/2) to sqrt(1/2)
    -- however most implementations don't use normalized constant vectors
    -- in this case you need to scale by the magnitude of the constant vectors
    -- for perlin's original vectors, this is sqrt(2)
    -- so, theoretically, the range should be -(sqrt(2) * sqrt(1/2)) to (sqrt(2) * sqrt(1/2))
    -- which just so happens to be -1 to 1

    local n = self:Noise2D(x, y)
    n = n + math.abs(PerlinNoise.MIN_2D)
    n = n * PerlinNoise.NORMAL_2D

    --and just to be safe due to issues with precision
    if n < 0 then
        n = 0
    elseif n > 1 then
        n = 1
    end

    return n
end

function PerlinNoise:Range_Noise2D(x, y, min, max)
    -- returns perlin noise scaled to a given range
    assert(min < max, "Error: Min must be less than max.")

    local scale = max - min
    local n = self:Normalized_Noise2D(x, y)
    n = n * scale + min
    return n
end