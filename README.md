# Lua-Perlin-Noise

This is a simple implementation of Perlin Noise in Lua. Currently, only 2D noise is supported.

This was built for LuaJIT.

## Usage

To use the library, put the [PerlinNoise.lua](PerlinNoise.lua) script in the same directory as the script that needs it. 

Pull it into your script with the require function:
```lua
require("PerlinNoise")
```

To create a new Perlin Noise generator, use the new function. Pass a seed (the seed for the noise generator):
```lua
local PN = PerlinNoise:new(math.floor(os.time()))
```

There are three noise functions: Noise2D, Normalized_Noise2D, and Range_Noise2D:
- Noise2D generates classic Perlin noise in the range [-1, 1].
- Normalized_Noise2D generates Perlin Noise in the range [0, 1].
- Range_noise2D accepts a range and returns Perlin Noise scaled to within that range.

```lua
local n = PN:Noise2D(x, y)
local nn = PN:Normalized_Noise2D(x, y)
local rn = PN:Range_Noise2D(x, y, min, max)
```

## Results
Below is a video with a 2D texture being generated using Normalized_Noise2D, where the noise value is used as the pixel color:
https://github.com/FiniteUI/Lua-Perlin-Noise/assets/33558498/7d10f027-3a42-409f-aceb-e57769f30102

## Requirements
This script relies on three of my other libraries:
- A library for working with Vectors: https://github.com/FiniteUI/Lua-Vectors
- A library for generating noise: https://github.com/FiniteUI/Lua-SquirrelNoise5
- A library for 32 bit unsigned integer math: https://github.com/FiniteUI/Lua-UInt32
