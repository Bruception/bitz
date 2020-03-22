
local lg = love.graphics
local lt = love.touch
local abs = math.abs

local function lerp(a, b, t)
  return a + (b - a) * t
end

local function constraint(value, min, max, min1, max1)
   return (value - min) * ( (max1 - min1) / (max - min) ) + min1
end

local function clamp(x, min, max)
 return x < min and min or (x > max and max or x)
end

Scroll = {}

Scroll.__index = Scroll

function Scroll:new(properties)

  local self = {}

  self.content = properties.content

  self.x = properties.x
  self.y = properties.y

  self.content.x = self.x

  self.width = properties.width
  self.height = properties.height

  self.scrollAlpha = 1

  self.scrollY = self.y
  self.scrollHeightOffset = 1
  self.minScrollHeight = self.height * 0.25
  self.scrollbarHeight = self.height * (self.height/self.content.height)

  self.scrollColor = properties.scrollColor

  ---------------------- FUNCTIONAL PROPERTIES ---------------------
  self.touchId = 0
  self.touched = false
  self.recordTouch = false
  self.jerkAmount = 0
  self.jerkMax = 0
  self.resistFactor = 1

  self.touchX = 0
  self.touchY = 0
  self.startLocationY = 0

  self.velocityBufferY = {}
  self.currentIndexY = 1
  self.velocityBufferX = {}
  self.currentIndexX = 1
  self.maxBuffer = properties.maxBuffer or 4

  self.max = 0

  self.velY = 0

  self.rVelY = 0
  self.rVelX = 0

  self.visible = {}

  self.scrolling = false

  self.timer = 0

  return setmetatable(self, Scroll)

end

function Scroll:update(dt, scrolling)
  -- We do not need to handle scrolling if the content pane's height if less than the scroll frame's height

  if(self.content.height > self.height) then


    self:handleScrollbar()

    self:handleScrolling(dt)

    self.touched = self:getTouch()

    if(self.touched) then
      self:handleTouch(dt, scrolling)
    else
      self:handleRelease(dt)
    end
  end
  --Console:print(#self.visible)
  self:getVisibleObjects()
  self.content:update(dt, self.visible)
end

function Scroll:handleScrolling(dt)
  if(self.scrolling) then
    self.timer = self.timer - dt

    if(self.timer <= 0) then
      self.scrolling = false
      self.timer = 0
    end
  end
end

function Scroll:handleTouch(dt, scrolling)
  local x, y = 0, 0

  if(pcall(lt.getPosition, self.touchId)) then
    x, y = lt.getPosition(self.touchId)
  else
    return
  end

  if(not self.recordTouch) then
    self.touchX = x
    self.touchY = y
    self.startLocationY = self.content.y
    self.recordTouch = true
    self.velY = 0
    self.rVelY = 0
    self.rVelX = 0
    self.content.dy = 0
    self.jerkAmount = 0
    self.jerkMax = 0
    self.resistFactor = 1
    self:clearVelocityBuffers()
  end

  self.rVelY = self:calculateAverageVelocityY()
  self.rVelX = self:calculateAverageVelocityX()

  self.max = (self.y - (self.content.height - self.height))

  if(abs(self.rVelY) > abs(self.rVelX) and not scrolling) then
    local dy = y - self.touchY

    if((self.content.y > self.y)) then

      local diff = abs(self.content.y - self.y)
      local diffRange = constraint(diff, 0, self.height * 0.5, 1, 0)

      self.resistFactor = lerp(self.resistFactor, diffRange, dt * 4)--lerp(self.resistFactor, (1 / math.sqrt(abs(self.y - self.content.y))), dt * 4)
    elseif(self.content.y < self.max) then

      local diff = abs(self.content.y - self.max)
      local diffRange = constraint(diff, 0, self.height * 0.5, 1, 0)

      self.resistFactor = lerp(self.resistFactor, diffRange, dt * 4)--lerp(self.resistFactor, (1 / math.sqrt(abs(self.max - self.content.y))), dt * 4)
    else
      self.resistFactor = lerp(self.resistFactor, 1, dt * 2)
    end

    self.content.y = (self.startLocationY + dy * self.resistFactor)
  end

  self.content.y = clamp(self.content.y, self.max - self.height * 0.5, self.y + self.height * 0.5)
--[[
  if(not scrolling) then
    self.scrollAlpha = lerp(self.scrollAlpha, 1, dt * 12)
  else
    self.scrollAlpha = 0
  end
  ]]--
end

function Scroll:handleRelease(dt)


  self.max = (self.y - (self.content.height - self.height))

  if(abs(self.rVelY) > abs(self.rVelX)) then
    self.content.y = self.content.y + (self.velY * 1 / ( (self.jerkAmount + 1) ^ 1.2 ))
  end

  if(not(self.content.y > self.max and self.content.y < self.y)) then
    self.jerkMax = 8
    local dy1 = (self.max - self.content.y) * (self.max - self.content.y)
    local dy2 = (self.y - self.content.y) * (self.y - self.content.y)

    if(dy1 < dy2) then
      self.content.y = Lume.smooth(self.content.y, self.max, dt * 12)
    else
      self.content.y = Lume.smooth(self.content.y, self.y, dt * 12)
    end
  end

  self.jerkAmount = Lume.lerp(self.jerkAmount, self.jerkMax, dt * 2)

  self.velY = Lume.smooth(self.velY, 0, dt * (8 + self.jerkAmount))

  self.recordTouch = false

  --self.content.y = --clamp(self.content.y, self.max, self.y)

  --if(abs(self.velY) <= dt) then
  --  self.scrollAlpha = lerp(self.scrollAlpha, 0, dt * 12)
  --end
end

function Scroll:draw()

  if(self.x + self.width >= 0 and self.x <= Game.WIDTH) then
    lg.setScissor(self.x, self.y, self.width, self.height)
    self.content:draw(self.visible)
    lg.setScissor()

    lg.setColor(self.scrollColor[1], self.scrollColor[2], self.scrollColor[3], self.scrollAlpha)
    lg.rectangle("fill", self.x + self.width - self.width * 0.025, self.scrollY, self.width * 0.015, self.scrollbarHeight, 3 , 3)

  end
end

function Scroll:getTouch()
  local touches = lt.getTouches()

  for i, id in ipairs(touches) do
    local x, y = lt.getPosition(id)

    if(self:isTouching(x, y)) then
      self.touchId = id
      return true
    end

  end

  return false
end

function Scroll:isTouching(x, y)
  return (x > self.x
    and x < self.x + self.width
    and y > self.y
    and y < self.y + self.height)
end

function Scroll:touchReleased(id)
  if(self.touchId == id) then
    self.velY = self:calculateAverageVelocityY()
    self.velX = self:calculateAverageVelocityX()

    if(abs(self.velY) > 0.25 and abs(self.velY) > (self.velX)) then
      self.scrolling = true
      self.timer = 0.25
    end

    if(abs(self.velY) < (self.velX)) then
      self.velY = 0
    end

    if(not self.scrolling) then
      self.content:touchReleased(id, self.visible)
    end
  end

  if(self.content.height <= self.height) then
    self.content:touchReleased(id, self.visible)
  end

end

function Scroll:touchMoved(id, x, y, dx, dy)
  if(self.touchId == id) then

    self.velocityBufferX[self.currentIndexX] = dx
    self.velocityBufferY[self.currentIndexY] = dy
    self.currentIndexX = self.currentIndexX + 1
    self.currentIndexY = self.currentIndexY + 1

    self.currentIndexX = (self.currentIndexX > self.maxBuffer) and 1 or self.currentIndexX
    self.currentIndexY = (self.currentIndexY > self.maxBuffer) and 1 or self.currentIndexY

    if(abs(dy) > 0) then
      self.scrolling = true
      self.timer = 0.25
    end

  end
end


function Scroll:getVisibleObjects()

  for i = #self.visible, 1, -1 do
    table.remove(self.visible, i)
  end

  for i = 1, #self.content.objects do
    if(self:checkCollision(self.content.objects[i])) then
      self.visible[#self.visible + 1] = i
    end
  end

end

function Scroll:checkCollision(object) -- We only need to check y axis!
  return (object.y + object.height > self.y and object.y < self.y + self.height)
end

function Scroll:calculateAverageVelocityX()
  local avg = 0
  for i = 1, self.maxBuffer do
    avg = avg + self.velocityBufferX[i]
  end
  return avg / self.maxBuffer
end

function Scroll:calculateAverageVelocityY()
  local avg = 0
  for i = 1, self.maxBuffer do
    avg = avg + self.velocityBufferY[i]
  end
  return avg / self.maxBuffer
end

function Scroll:clearVelocityBuffers()
  self.currentIndexY = 1
  self.currentIndexX = 1

  for i = 1, self.maxBuffer do
    self.velocityBufferY[i] = 0
    self.velocityBufferX[i] = 0
  end
end

function Scroll:handleScrollbar()

  if(self.content.y >= self.max and self.content.y <= self.y) then

    local testHeight = self.height * (self.height/self.content.height)

    self.scrollHeightOffset = 1

    self.scrollbarHeight = (testHeight > self.minScrollHeight) and testHeight or self.minScrollHeight
    self.scrollY = constraint(self.content.y, self.y, self.max, self.y, (self.y + self.height) - self.scrollbarHeight)
  elseif(self.content.y > self.y) then
    self.scrollY = self.y

    local testHeight = self.height * (self.height/self.content.height)

    self.scrollHeightOffset = abs(self.y - self.content.y)

    local diffRange = constraint(self.scrollHeightOffset, 0, self.height * 0.5, 1, 0)

    self.scrollbarHeight = (testHeight * diffRange > self.minScrollHeight * 0.15) and testHeight * diffRange or self.minScrollHeight * 0.15

  elseif(self.content.y < self.max) then

    local testHeight = self.height * (self.height/self.content.height)

    self.scrollHeightOffset = abs(self.max - self.content.y)

    local diffRange = constraint(self.scrollHeightOffset, 0, self.height * 0.5, 1, 0)

    self.scrollbarHeight = (testHeight * diffRange > self.minScrollHeight * 0.15) and testHeight * diffRange or self.minScrollHeight * 0.15

    self.scrollY = self.y + self.height - self.scrollbarHeight
  end

end
