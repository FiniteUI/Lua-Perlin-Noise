require("Vector")
require("SquirrelNoise5-LuaJIT")

PerlinNoise = {}
PerlinNoise.__index = PerlinNoise
PerlinNoise.__name = "PerlinNoise"

-- Perlin Noise Range : +/- sqrt(D/4) * M
-- where D is the number of dimensions, and M is the magnitude of the constanct vectors being used
-- for 1D, M = 1, N = 1, range = +/- sqrt(1/4) * 1 = +/- 0.5
-- for 2D, M = sqrt(2), N = 2, range = +/- sqrt(1/2) * sqrt(2) = +/- 1

--1D constants
PerlinNoise.MAX_1D = math.sqrt(1/4)
PerlinNoise.MIN_1D = -PerlinNoise.MAX_1D
PerlinNoise.RANGE_1D = PerlinNoise.MAX_1D - PerlinNoise.MIN_1D
PerlinNoise.NORMAL_1D = 1 / PerlinNoise.RANGE_1D

--2D constants
PerlinNoise.MAX_2D = math.sqrt(2) * math.sqrt(1/2)
PerlinNoise.MIN_2D = -PerlinNoise.MAX_2D
PerlinNoise.RANGE_2D = PerlinNoise.MAX_2D - PerlinNoise.MIN_2D
PerlinNoise.NORMAL_2D = 1 / PerlinNoise.RANGE_2D

--private functions
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

local function GeneratePermutationTable(size)
    local pt = {}
    for i = 0, size - 1 do
        table.insert(pt, i)
    end

    return pt
end

local function PerlinPermutationTable()
    -- this is Ken Perlin's original permutation table
    local t = {151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180}
    DoubleTable(t)
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

local function GetConstantVector1D(value)
    --choose one of the two directional vectors (left, right)
    value = value % 2
    if value == 0 then
        return -1
    else
        return 1
    end
end

local function GetConstantVector2D(value)
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
function PerlinNoise:new(seed, size, permutation_type)
    assert(permutation_type == 'perlin' or permutation_type == 'shuffled' or permutation_type == 'infinite' or permutation_type == nil, "Error: permutation_type must be perlin, shuffled, or infinite.")
    assert((type(size) == 'number' and math.fmod(size, 1) == 0) or  size == nil, "Error: Size must be an integer.")

    local new = {}

    new.seed = seed
    if size == nil then
        size = 256
    end
    new.size = size
    
    --perlin - use perlin's original permutation table
    --shuffled - use a shuffled permutation table of size size
    --infinite - use random values instead of a permutationt able
    if permutation_type == nil then
        permutation_type = 'shuffled'
    end
    new.permutation_type = permutation_type

    --generate permutation table
    if permutation_type == 'shuffled' then
        local permutations = GeneratePermutationTable(size)
        permutations = ShuffleTable(seed, permutations)
        DoubleTable(permutations)
        new.permutation_table = permutations
    elseif permutation_type == 'perlin' then
        new.permutation_table = PerlinPermutationTable()
    end
    
    setmetatable(new, self)
    return new
end

--1D functions
function PerlinNoise:Noise1D(x)
    --generate vectors from the integers on either side of the input
    local x_float = x - math.floor(x)
    local left = x_float
    local right = x_float - 1
    
    --grab the permutation table value for the integers on either side of the input
    -- compute dot product between the constant vector and left/right vectors
    local x_index = (math.floor(x) % self.size) + 1
    local dot_left
    local dot_right
    if self.permutation_type ~= 'infinite' then
        dot_left = left * GetConstantVector1D(self.permutation_table[x_index])
        dot_right = right * GetConstantVector1D(self.permutation_table[x_index + 1])
    else
        local noise = SquirrelNoise5:new(self.seed)
        dot_left = left * GetConstantVector1D(noise:rangeNoiseInteger(x_index, 0, self.size))
        dot_right = right * GetConstantVector1D(noise:rangeNoiseInteger(x_index + 1, 0, self.size))
    end

    -- lerp between them for result
    local x_fade = Fade(x_float)
    local result = Lerp(dot_left, dot_right, x_fade)

    return result
end

function PerlinNoise:NormalizedNoise1D(x)
    local n = self:Noise1D(x)
    n = n + math.abs(PerlinNoise.MIN_1D)
    n = n * PerlinNoise.NORMAL_1D

    --and just to be safe due to issues with precision
    if n < 0 then
        n = 0
    elseif n > 1 then
        n = 1
    end

    return n
end

function PerlinNoise:RangeNoise1D(x, min, max)
    -- returns perlin noise scaled to a given range
    assert(min < max, "Error: Min must be less than max.")

    local scale = max - min
    local n = self:NormalizedNoise1D(x)
    n = n * scale + min

    return n
end

function PerlinNoise:OctaveNoise1D(x, octaves, frequency, amplitude)
    frequency = frequency or 0.005
    amplitude = amplitude or 1

    local result = 0
    local n
    for i = 0, octaves do
        n = self:Noise1D(x * frequency) * amplitude
        result = result + n

        amplitude = amplitude * 0.5
        frequency = frequency * 2
    end

    return result
end

function PerlinNoise:NormalizedOctaveNoise1D(x, octaves, frequency, amplitude)
    local n = self:OctaveNoise1D(x, octaves, frequency, amplitude)
    n = n + math.abs(PerlinNoise.MIN_1D)
    n = n * PerlinNoise.NORMAL_1D

    --and just to be safe due to issues with precision
    if n < 0 then
        n = 0
    elseif n > 1 then
        n = 1
    end

    return n
end

function PerlinNoise:RangeOctaveNoise1D(x, octaves, frequency, amplitude, min, max)
    -- returns perlin noise scaled to a given range
    assert(min < max, "Error: Min must be less than max.")

    local scale = max - min
    local n = self:NormalizedOctaveNoise1D(x, octaves, frequency, amplitude)
    n = n * scale + min

    return n
end

--2D functions
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

    local dot_tr
    local dot_tl
    local dot_br
    local dot_bl

    --compute dot product between constant vectors and corner vectors
    if self.permutation_type ~= 'infinite' then
        dot_tr = Vector.Dot_Product(top_right, GetConstantVector2D(self.permutation_table[self.permutation_table[x_index + 1] + y_index + 1]))
        dot_tl = Vector.Dot_Product(top_left, GetConstantVector2D(self.permutation_table[self.permutation_table[x_index] + y_index + 1]))
        dot_br = Vector.Dot_Product(bottom_right, GetConstantVector2D(self.permutation_table[self.permutation_table[x_index + 1] + y_index]))
        dot_bl = Vector.Dot_Product(bottom_left, GetConstantVector2D(self.permutation_table[self.permutation_table[x_index] + y_index]))
    else
        local noise = SquirrelNoise5:new(self.seed)
        dot_tr = Vector.Dot_Product(top_right, GetConstantVector2D(noise:rangeNoiseInteger2D(x_index + 1, y_index + 1, 0, self.size)))
        dot_tl = Vector.Dot_Product(top_left, GetConstantVector2D(noise:rangeNoiseInteger2D(x_index, y_index + 1, 0, self.size)))
        dot_br = Vector.Dot_Product(bottom_right, GetConstantVector2D(noise:rangeNoiseInteger2D(x_index + 1, y_index, 0, self.size)))
        dot_bl = Vector.Dot_Product(bottom_left, GetConstantVector2D(noise:rangeNoiseInteger2D(x_index, y_index, 0, self.size)))
    end

    -- lerp between them for result
    local x_fade = Fade(x_float)
    local y_fade = Fade(y_float)
    local result = Lerp(Lerp(dot_bl, dot_tl, y_fade), Lerp(dot_br, dot_tr, y_fade), x_fade)

    return result
end

function PerlinNoise:NormalizedNoise2D(x, y)
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

function PerlinNoise:RangeNoise2D(x, y, min, max)
    -- returns perlin noise scaled to a given range
    assert(min < max, "Error: Min must be less than max.")

    local scale = max - min
    local n = self:NormalizedNoise2D(x, y)
    n = n * scale + min

    return n
end

function PerlinNoise:OctaveNoise2D(x, y, octaves, frequency, amplitude)
    frequency = frequency or 0.005
    amplitude = amplitude or 1

    local result = 0
    local n
    for i = 0, octaves do
        n = self:Noise2D(x * frequency, y * frequency) * amplitude
        result = result + n

        amplitude = amplitude * 0.5
        frequency = frequency * 2
    end

    return result
end

function PerlinNoise:NormalizedOctaveNoise2D(x, y, octaves, frequency, amplitude)
    local n = self:OctaveNoise2D(x, y, octaves, frequency, amplitude)
    n = n + math.abs(PerlinNoise.MIN_1D)
    n = n * PerlinNoise.NORMAL_1D

    --and just to be safe due to issues with precision
    if n < 0 then
        n = 0
    elseif n > 1 then
        n = 1
    end

    return n
end

function PerlinNoise:RangeOctaveNoise2D(x, y, octaves, frequency, amplitude, min, max)
    -- returns perlin noise scaled to a given range
    assert(min < max, "Error: Min must be less than max.")

    local scale = max - min
    local n = self:NormalizedOctaveNoise2D(x, y, octaves, frequency, amplitude)
    n = n * scale + min

    return n
end