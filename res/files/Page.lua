
local lg = love.graphics

Page = {}

Page.__index = Page

function Page:new(properties)
  local self = {}

  self.x = properties.x
  self.y = properties.y

  self.width = properties.width
  self.height = properties.height

  self.objects = {}

  self.xCoords = {}
  self.yCoords = {}

  self.index = properties.index

  self.color = {math.random(255)/255, math.random(255)/255, math.random(255)/255}

  self.pageScroller = properties.pageScroller or nil

  return setmetatable(self, Page)
end

function Page:addObject(object, x, y)
  self.objects[#self.objects + 1] = object
  self.xCoords[#self.xCoords + 1] = x
  self.yCoords[#self.yCoords + 1] = y
end

function Page:update(dt, scrolling)
  for i = 1, #self.objects do
    self.objects[i].x = self.x + self.xCoords[i]
    self.objects[i].y = self.y + self.xCoords[i]
    self.objects[i]:update(dt, scrolling)
  end
end

function Page:touchReleased(id)
  for i = 1, #self.objects do
    self.objects[i]:touchReleased(id)
  end
end

function Page:touchMoved(id, x, y, dx, dy)
  for i = 1, #self.objects do
    self.objects[i]:touchMoved(id, x, y, dx, dy)
  end
end

function Page:draw()
  lg.setScissor(self.x, self.y, self.width, self.height)
  for i = 1, #self.objects do
    self.objects[i]:draw()
  end
  lg.setScissor()

end
