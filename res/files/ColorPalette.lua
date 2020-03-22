
local random = math.random

local function normalizeRgb(rgb)

  local conversion = 1/255

  for i = 1, 3 do
    rgb[i] = rgb[i] * conversion
  end

end

ColorPalette = {}

ColorPalette.__index = ColorPalette

function ColorPalette:new(colors, rgbMax)
  local colorPalette = {}

  colorPalette.colors = {}

  colorPalette.colorRef = {}

  colorPalette.rgbMax = (rgbMax == 255 or rgbMax == 1) and rgbMax or 1

  for color, rgb in pairs(colors) do

    if(colorPalette.rgbMax == 255) then
      normalizeRgb(rgb)
    end

    colorPalette.colorRef[#colorPalette.colorRef + 1] = color

    colorPalette.colors[color] = rgb
  end

  colorPalette.numColors = #colorPalette.colorRef

  return setmetatable(colorPalette, ColorPalette)
end

function ColorPalette:addColor(key, rgb)
  self.colors[key] = rgb
end

function ColorPalette:getColor(key)

  if(self.colors[key] == nil) then
    return self.colors["white"]
  end

  return self.colors[key]
end

function ColorPalette:pickRandomColor()
  return self.colors[self.colorRef[random(self.numColors)]][1], self.colors[self.colorRef[random(self.numColors)]][2], self.colors[self.colorRef[random(self.numColors)]][3]
end
