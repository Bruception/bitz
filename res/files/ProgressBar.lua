
local lg = love.graphics

local function clamp (num, min , max)
  return (num > max) and (max) or ((num < min) and (min) or (num))
end

local function lerp (a, b, dt)
  local t = clamp(dt, 0, 1)
  local m = t * t * (3 - 2 * t)
  return a + (b - a) * m
end

local function map(value, min, max, min1, max1)
   return (value - min) * ( (max1 - min1) / (max - min) ) + min1
end

ProgressBar = {}

ProgressBar.__index = ProgressBar

function ProgressBar:new(properties)

  local self = {}

  self.x = properties.x or 0
  self.y = properties.y or 0
  self.width = properties.width or 100
  self.height = properties.height or 50

  self.backgroundColor = properties.backgroundColor or {1, 1, 1}
  self.barColor = properties.barColor or {0, 0, 0}

  self.alpha = properties.alpha or 1

  self.max = properties.max or 100
  self.min = properties.min or 0

  self.value = properties.value or 0
  self.trueValue = self.width
  self.desiredWidth = 0
  self.printedValue = 0

  self.font = properties.font

  return setmetatable(self, ProgressBar)

end

function ProgressBar:update(dt)
  self.printedValue = lerp(self.printedValue, self.trueValue, dt * 8)
  self.trueValue = clamp(self.trueValue, self.min, self.max)

  self.desiredWidth = map(self.trueValue, self.min, self.max, 0, self.width)

  self.value = lerp(self.value, self.desiredWidth, dt * 8)
end

function ProgressBar:setValue(value)
  self.trueValue = value
end

function ProgressBar:draw (args)
  lg.setColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.alpha)
  lg.rectangle("fill", self.x, self.y, self.width, self.height)
  lg.setColor(self.barColor[1], self.barColor[2], self.barColor[3], self.alpha)
  lg.rectangle("fill", self.x, self.y, self.value, self.height)

  lg.setFont(self.font)
  local fontW = self.font:getWidth(Lume.roundP(self.printedValue, 0))
  local fontH = self.font:getHeight(Lume.roundP(self.printedValue, 0))

  lg.print(Lume.roundP(self.printedValue, 0), self.x + self.value - fontW * 0.5, self.y - fontH)

--  fontW = self.font:getWidth(self.max)
--  fontH = self.font:getHeight(self.max)

  --lg.print(self.max, self.x + self.width + fontW * 0.5, self.y + self.height * 0.5 - fontH * 0.5)
end
