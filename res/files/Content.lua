
-- This is essentially a canvas

local lg = love.graphics

Content = {}

Content.__index = Content

function Content:new(properties)

  local self = {}

  self.x = properties.x
  self.y = properties.y

  self.width = properties.width
  self.height = properties.height

  self.objects = {}

  self.xCoords = {}
  self.yCoords = {}

  self.scroll = properties.scroll or nil

  self.dy = 0
  self.tempPos = 1

  return setmetatable(self, Content)

end

function Content:update(dt, visible)

  self.x = self.scroll.x

  if(math.abs(self.dy) > dt) then
    self.y = Lume.lerp(self.y, self.y - self.dy, dt * 2)
    self.dy = Lume.lerp(self.dy, 0, dt * 2)

    if(self.y < self.scroll.max) then
      self.dy = 0
    elseif(self.y > self.scroll.y) then
      self.dy = 0
    end
  end

  for i = 1, #self.objects do
    self.objects[i].x = self.x + self.xCoords[i]--self.x + self.xCoords[i]
    self.objects[i].y = self.y + self.yCoords[i]
  end

  for _, v in ipairs(visible) do
    self.objects[v]:update(dt)
  end
end

function Content:draw(visible)
  for _, v in ipairs(visible) do
    self.objects[v]:draw()
  end
end

function Content:addObject(object, x, y)
  self.objects[#self.objects + 1] = object
  self.xCoords[#self.xCoords + 1] = x
  self.yCoords[#self.yCoords + 1] = y
end

function Content:touchReleased(id, visible)
  for _, v in ipairs(visible) do
    self.objects[v]:touchReleased(id)
  end
end

function Content:setYPosition(object)
  -- Check to see if object exists
  local found = false
  local pos = 0

  for i = 1, #self.objects do
    found = (object == self.objects[i])
    if(found) then
      pos = i
      break
    end
  end

  if(not found) then
    return false
  end

  -- Do math
  self.tempPos = pos
  self.dy = (self.objects[self.tempPos].y + self.objects[self.tempPos].height * 0.5) - (self.scroll.y + self.scroll.height * 0.5)

  return true -- Successfully scrolled

end
