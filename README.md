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

You can also specify the size of the permutation table used, and the type of permutation table used.
The permutation table types used are:
- shuffled: A table of the specified size shuffled randomly.
- perlin: Perlin's original permutation table.
- infinite: Values are generated randomly instead of using a permutation table.
```lua
local PN = PerlinNoise:new(math.floor(os.time()), 256, 'shuffled')
```

The following noise functions are available:
- Noise1D takes x and generates classic Perlin noise in the range [-0.5, 0.5].
- NormalizedNoise1D takes x generates Perlin noise in the range [0, 1].
- RangeNoise1D takes x, min, and max, and returns Perlin noise within the range [min, max].
- OctaveNoise1D taxes x, octaves, frequency, and amplitude and layers Perlin noise in octaves to generate more detail.
- NormalizedOctaveNoise1D is the same as NormalizedNoise1D but uses OctaveNoise1D as the base instead of Noise1D.
- RangeOctaveNoise1D is the same as RangeNoise1D but uses OctaveNoise1D as the base instead of Noise1D.
- Noise2D takes x and y and generates classic Perlin noise in the range [-0.5, 0.5].
- NormalizedNoise2D takes x and y generates Perlin noise in the range [0, 1].
- RangeNoise2D takes x, y, min, and max, and returns Perlin noise within the range [min, max].
- OctaveNoise2D taxes x, y, octaves, frequency, and amplitude and layers Perlin noise in octaves to generate more detail.
- NormalizedOctaveNoise2D is the same as NormalizedNoise2D but uses OctaveNoise2D as the base instead of Noise2D.
- RangeOctaveNoise2D is the same as RangeNoise2D but uses OctaveNoise2D as the base instead of Noise2D.

```lua
local n1 = PN:Noise1D(x)
local nn1 = PN:NormalizedNoise1D(x)
local rn1 = PN:RangeNoise1D(x, min, max)
local on1 = PN:OctaveNoise1D(x, octaves, frequency, amplitude)
local non1 = PN:NormalizedOctaveNoise1D(x, octaves, frequency, amplitude)
local ron1 = PN:RangeOctaveNoise1D(x, octaves, frequency, amplitude, min, max)
local n2 = PN:Noise2D(x, y)
local nn2 = PN:NormalizedNoise2D(x, y)
local rn2 = PN:RangeNoise2D(x, y, min, max)
local on2 = PN:OctaveNoise2D(x, y, octaves, frequency, amplitude)
local non2 = PN:NormalizedOctaveNoise2D(x, y, octaves, frequency, amplitude)
local ron2 = PN:RangeOctaveNoise2D(x, y, octaves, frequency, amplitude, min, max)
```

## Visualizer
A noise visualizer is included in the Visualizer folder, here: [Visualizer](https://github.com/FiniteUI/Lua-Perlin-Noise/tree/main/Visualizer)

This was built using Love2D. The source code is in the [Visualizer/Code](https://github.com/FiniteUI/Lua-Perlin-Noise/tree/main/Visualizer/Code) folder. It can be run by downloading the zip file, unzipping it, and running the NoiseVisualizer.exe file within.

Below is an example of 1D noise in the visualizer:
![Screenshot 2024-06-05 012725](https://github.com/FiniteUI/Lua-Perlin-Noise/assets/33558498/ed11e802-5076-42e3-aea3-a885aa90f3ca)

Below is an example of 2D noise in the visualizer:
![Screenshot 2024-06-05 012748](https://github.com/FiniteUI/Lua-Perlin-Noise/assets/33558498/77f09743-f87b-4a3d-a47a-856d1062683f)

## Requirements
This script relies on three of my other libraries:
- A library for working with Vectors: https://github.com/FiniteUI/Lua-Vectors
- A library for generating noise: https://github.com/FiniteUI/Lua-SquirrelNoise5
- A library for 32 bit unsigned integer math: https://github.com/FiniteUI/Lua-UInt32
