LOVE = require("love")
require("SquirrelNoise5-LuaJIT")
require("PerlinNoise")

local function loadOctavePerlinNoise2D()
    NOISE = {}
    local width = math.floor(LOVE.graphics.getWidth() / SCALE)
    local height = math.floor(LOVE.graphics.getHeight() / SCALE)
    local PN = PerlinNoise:new(SEED)

    for i = 0, width do
        local temp = {}
        for j = 0, height do
            local color = PN:NormalizedOctaveNoise2D(i, j, OCTAVES, FREQUENCY, AMPLITUDE)
            table.insert(temp, color)
        end
        table.insert(NOISE, temp)
    end
end

local function loadOctavePerlinNoise1D()
    NOISE = {}
    local PN = PerlinNoise:new(SEED)
    local width = math.floor(LOVE.graphics.getWidth() / SCALE)

    for i = 0, width do
        local value = PN:OctaveNoise1D(i, OCTAVES, FREQUENCY, AMPLITUDE)
        table.insert(NOISE, value)
    end
end

local function PrintDebugData(t)
    local text_color = {138 / 255, 247 / 255, 64 / 255}

    local offset = 0
    local interval = 12

    LOVE.graphics.setColor(text_color)
    for k, v in pairs(t) do
        LOVE.graphics.print(v, 0, offset)
        offset = offset + interval
    end
end

local function loadNoise()
    if CURRENT_NOISE_TYPE == NOISE_TYPES.OCTAVE_PERLIN_1D then
        loadOctavePerlinNoise1D()
    elseif CURRENT_NOISE_TYPE == NOISE_TYPES.OCTAVE_PERLIN_2D then
        loadOctavePerlinNoise2D()
    end
end

--load data when the game starts
function LOVE.load()
    -- love set up
    LOVE.keyboard.setKeyRepeat(true)
    LOVE.graphics.setBackgroundColor(7 / 255, 12 / 255, 20 /255)

    -- load initial values
    math.randomseed(math.floor(os.time()))
    SEED = math.random(0, 4294967296)
    NOISE = {}
    SCALE = 1
    FREQUENCY = 0.1
    AMPLITUDE = 1
    OCTAVES = 1
    NOISE_TYPES = {
        OCTAVE_PERLIN_1D = "OCTAVE_PERLIN_1D",
        OCTAVE_PERLIN_2D = "OCTAVE_PERLIN_2D"
    }
    CURRENT_NOISE_TYPE = NOISE_TYPES.OCTAVE_PERLIN_1D

    HEADER = 90

    loadNoise()
end

function LOVE.draw()
    --draw noise
    if CURRENT_NOISE_TYPE == NOISE_TYPES.OCTAVE_PERLIN_1D then
        local base = math.floor(LOVE.graphics.getHeight() / 2)
        local last_point = {0, 0}
        for k, v in pairs(NOISE) do
            LOVE.graphics.setColor(1, 1, 1)
            LOVE.graphics.line(last_point[1] * SCALE, base + last_point[2] * SCALE, k * SCALE, base + v * SCALE)
    
            LOVE.graphics.setColor(156 / 255, 51 / 255, 51 / 255)
            LOVE.graphics.circle('fill', k * SCALE, base + v * SCALE, 4)
            last_point = {k, v}
        end 
    elseif CURRENT_NOISE_TYPE == NOISE_TYPES.OCTAVE_PERLIN_2D then
        --draw perlin noiose
        local x
        local y
        for k, v in pairs(NOISE) do
            for k2, v2 in pairs(v) do
                LOVE.graphics.setColor(v2, v2, v2)

                x = (k - 1) * SCALE 
                y = (k2 - 1) * SCALE
                --LOVE.graphics.points(k, k2)
                LOVE.graphics.rectangle('fill', x, y, SCALE, SCALE)
            end
        end
    end

    --draw header zone for text
    LOVE.graphics.setColor(7 / 255, 12 / 255, 20 /255)
    LOVE.graphics.rectangle('fill', 0, 0, LOVE.graphics.getWidth(), HEADER)

    local debug_data = {
        "Change Seed: F12, Change Type: F11, +/- Frequency: F2/F1, +/- Amplitude: F4/F3, +/- Scale: F6/F5, +/- Octaves: F8/F7",
        "Type: " .. CURRENT_NOISE_TYPE,
        "Seed: " .. SEED,
        "Scale: " .. SCALE,
        "Frequency: " .. FREQUENCY,
        "Amplitude: " .. AMPLITUDE,
        "Octaves: " .. OCTAVES
    }
    PrintDebugData(debug_data)
end

function LOVE.keypressed(key)
    local change = false
    if key == "f12" then
        SEED = math.random(0, 4294967296)
        change = true
    elseif key == "f11" then
        if CURRENT_NOISE_TYPE == NOISE_TYPES.OCTAVE_PERLIN_1D then
            CURRENT_NOISE_TYPE = NOISE_TYPES.OCTAVE_PERLIN_2D
        elseif CURRENT_NOISE_TYPE == NOISE_TYPES.OCTAVE_PERLIN_2D then
            CURRENT_NOISE_TYPE = NOISE_TYPES.OCTAVE_PERLIN_1D
        end
        change = true
    elseif key == "f2" then
        -- increase frequency
        FREQUENCY = FREQUENCY + 0.001
        change = true
    elseif key == "f1" then
        -- decrease frequency
        FREQUENCY = FREQUENCY - 0.001
        change = true
    elseif key == "f4" then
        -- increase amplitude
        AMPLITUDE = AMPLITUDE + 1
        change = true
    elseif key == "f3" then
        --decrease amplitude
        if AMPLITUDE > 1 then
            AMPLITUDE = AMPLITUDE - 1
        end
        change = true
    elseif key == "f6" then
        -- increase scale
        SCALE = SCALE + 1
        change = true
    elseif key == "f5" then
        --decrease scale
        if SCALE > 1 then
            SCALE = SCALE - 1
        end
        change = true
    elseif key == "f8" then
        -- increase octave
        OCTAVES = OCTAVES + 1
        change = true
    elseif key == "f7" then
        --decrease octave
        if OCTAVES > 1 then
            OCTAVES = OCTAVES - 1
        end
        change = true
    end

    if change then
        loadNoise()
    end
end