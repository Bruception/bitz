
local lg = love.graphics
local lt = love.touch

local abs = math.abs

local function lerp(a, b, t)
  return a + (b - a) * t
end

local function clamp(x, min, max)
 return x < min and min or (x > max and max or x)
end

PageScroll = {}

PageScroll.__index = PageScroll

function PageScroll:new(properties)

  local self = {}

  self.x = properties.x
  self.y = properties.y

  self.width = properties.width
  self.height = properties.height

  self.pages = properties.pages

  self.scrollerColor = properties.scrollerColor
  self.scrollerColorPrimary = properties.scrollerColorPrimary

  self.selectedLockIndex = 1--self.pages[1]

  self.velX = 0
  self.velY = 0

  self.velocityBufferX = {0, 0, 0, 0}
  self.currentIndexX = 1
  self.velocityBufferY = {0, 0, 0, 0}
  self.currentIndexY = 1

  self.maxBuffer = properties.maxBuffer or 4

  self.touchId = 0
  self.touched = false
  self.recordTouch = false
  self.scrolling = false

  self.touchX = 0
  self.touchY = 0
  self.startLocationX = 0

  self.scaleTimer = 0

  self.lockPositions = {}

  for i = 1, #self.pages do
    self.pages[i].x = self.x + (i - 1) * self.pages[i].width
    self.lockPositions[i] = self.x - (i - 1) * self.pages[i].width
    self.pages[i].y = self.y
  end

  self.pageX = self.x

  self.scale = 0

  return setmetatable(self, PageScroll)

end

function outElastic(t, b, c ,d , a, p)
  if t == 0 then return b end

  t = t / d

  if t == 1 then return b + c end

  if not p then p = d * 0.5 end

  local s

  if not a or c < math.abs(c) then
    a = c * 0.8
    s = p / 4
  else
    s = p / (2 * math.pi) * math.asin(c/a)
  end

  return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) + c + b
end

function PageScroll:update(dt)

  self.scaleTimer = lerp(self.scaleTimer, 1, dt * 3)

  self.scale = outElastic(self.scaleTimer, 0, 1, 1)

  for i = 1, #self.pages do
    self.pages[i]:update(dt, self.scrolling)
  end

  self.touched = self:getTouch()

  if(self.touched) then
    self:handleTouch(dt)
  else
    self.pageX = lerp(self.pageX, self.lockPositions[self.selectedLockIndex], dt * 8)
    self.pages[1].x = self.pageX
  end

  for i = 2, #self.pages do
    self.pages[i].x = self.pages[1].x + (i - 1) * self.pages[i].width
    self.pages[i].y = self.y
  end

end

function PageScroll:draw()

  lg.push()
  lg.translate(self.x + self.width * 0.5, self.y + self.height * 0.5)
  lg.scale(self.scale)
  lg.translate(-self.x - self.width * 0.5, - self.y - self.height * 0.5)

  for i = 1, #self.pages do
    self.pages[i]:draw()
  end

  local projectedWidth = (#self.pages - 1) * 20

  for i = 1, #self.pages do
    local fill = (self.selectedLockIndex == i) and "fill" or "line"

    if(fill == "line") then
      lg.setColor(self.scrollerColor[1], self.scrollerColor[2], self.scrollerColor[3], .5)
      lg.circle(fill, self.x + self.width * 0.5 - projectedWidth * 0.5 + (i - 1) * 20, self.y + self.height + 20, 5, 25)
    else
      lg.setColor(self.scrollerColorPrimary[1], self.scrollerColorPrimary[2], self.scrollerColorPrimary[3], .5)
      lg.circle(fill, self.x + self.width * 0.5 - projectedWidth * 0.5 + (i - 1) * 20, self.y + self.height + 20, 5, 25)
    end
  end

  lg.pop()

  --lg.setColor(Game.colorPal1:getColor("white"))
  --lg.print(" More levels\ncoming soon ...", self.pageX + (#self.pages * self.width), self.y + self.height * 0.45)
end

function PageScroll:touchReleased(id)
  if(id == self.touchId) then
    self.recordTouch = false
    local dx = self:calculateAverageVelocityX()
    local dy = self:calculateAverageVelocityY()
    if(abs(dx) >= 8 and abs(dx) > abs(dy)) then

      if(dx < 0) then
        self.selectedLockIndex = self.selectedLockIndex + 1
        if(self.selectedLockIndex > #self.lockPositions) then
          self.selectedLockIndex = #self.lockPositions
        end
      else
        self.selectedLockIndex = self.selectedLockIndex - 1
        if(self.selectedLockIndex < 1) then
          self.selectedLockIndex = 1
        end
      end
    else
      self.selectedLockIndex = self:getClosestLockPositionIndex()
    end

    for i = 1, #self.pages do
      self.pages[i]:touchReleased(id)
    end
  end
end

function PageScroll:touchMoved(id, x, y, dx, dy)
  self.velocityBufferX[self.currentIndexX] = dx
  self.currentIndexX = self.currentIndexX + 1

  self.currentIndexX = (self.currentIndexX > self.maxBuffer) and 1 or self.currentIndexX

  self.velocityBufferY[self.currentIndexY] = dy
  self.currentIndexY = self.currentIndexY + 1

  self.currentIndexY = (self.currentIndexY > self.maxBuffer) and 1 or self.currentIndexY

  for i = 1, #self.pages do
    self.pages[i]:touchMoved(id, x, y, dx, dy)
  end
end

function PageScroll:handleTouch(dt)
  local x, y = 0, 0

  if(pcall(lt.getPosition, self.touchId)) then
    x, y = lt.getPosition(self.touchId)
  else
    return
  end

  if(not self.recordTouch) then
    self.touchX = x
    self.touchY = y
    self.startLocationX = self.pageX--self.x--self.content.y
    self.recordTouch = true
    self.scrolling = false
    self:clearVelocityBuffers()
    self.velX = 0
    self.velY = 0
  end

  self.velX = self:calculateAverageVelocityX()
  self.velY = self:calculateAverageVelocityY()

  if(abs(self.velX) > 8) then
    self.scrolling = true
  end

  if(self.scrolling or abs(self.velX) > 4 * abs(self.velY)) then
    local dx = x - self.touchX

    self.pageX = (self.startLocationX + dx)
  end

  self.max = (self.x - ((#self.pages - 1) * self.width))

  --self.pageX = clamp(self.pageX, self.max, self.x)

  self.pages[1].x = self.pageX
end

function PageScroll:getTouch()
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

function PageScroll:isTouching(x, y)
  return (x > self.x
    and x < self.x + self.width
    and y > self.y
    and y < self.y + self.height)
end

function PageScroll:calculateAverageVelocityX()
  local avg = 0
  for i = 1, self.maxBuffer do
    avg = avg + self.velocityBufferX[i]
  end
  return avg / self.maxBuffer
end

function PageScroll:calculateAverageVelocityY()
  local avg = 0
  for i = 1, self.maxBuffer do
    avg = avg + self.velocityBufferY[i]
  end
  return avg / self.maxBuffer
end

function PageScroll:clearVelocityBuffers()
  self.currentIndexX = 1
  self.currentIndexY = 1

  for i = 1, self.maxBuffer do
    self.velocityBufferX[i] = 0
    self.velocityBufferY[i] = 0
  end
end

function PageScroll:getClosestLockPositionIndex(args)
  local closest = 1
  local dist = abs(self.pageX - self.lockPositions[closest])

  for i = 1, #self.lockPositions do
    local dx = abs(self.pageX - self.lockPositions[i])
    if(dx < dist) then
      closest = i
      dist = abs(self.pageX - self.lockPositions[closest])
    end
  end

  return closest
end

function PageScroll:resetAnimation()
  self.scale = 0
  self.scaleTimer = 0
end
