
local assert, unpack, type, self, ipairs, tostring, table_remove = assert, unpack, type, self, ipairs, tostring, table.remove

local g, t = love.graphics, love.touch

local Console = {}

-- Constructor

function Console:init(properties)

  self.log = {}

  local p = properties or {
    x  = 0,
    y = 0,
    width = g.getWidth(),
    height = g.getHeight(),
    rgba = {0, 0, 0, 1},
    timers = {0}
  }

  -- properties
  self.x = p.x or 0
  self.y = p.y or 0
  self.width = p.width or g.getWidth() * 0.25
  self.height = p.height or g.getHeight() * 0.25
  self.rgba = p.rgba or {0, 0, 0, 1}
  self.timers = p.timers or {0}

  -- Private variables
  self.touched = false
  self.locationTouchedX = self.x
  self.locationTouchedY = self.y
  self.startLocationX = self.x
  self.startLocationY = self.y
  self.touch = nil

end

-- Private functions

local function isTouching(self, x, y)
  return (x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height)
end

local function getInverseColor(self)
 return ({1 - self.rgba[1], 1 - self.rgba[2], 1 - self.rgba[3], self.rgba[4]})
end

local function getTouch(self)
  local touches = t.getTouches()

  for i, id in ipairs(touches) do
    local x, y = t.getPosition(id)

    if(isTouching(self, x, y)) then
      self.touch = id
      return true
    end
  end
  return false
end

local function handleTouch(self)
  getTouch(self)

  if(getTouch(self)) then
    if(not self.touched) then
      local x, y = t.getPosition(self.touch)
      self.touched = true
      self.locationTouchedX = x
      self.locationTouchedY = y
      self.startLocationX = self.x
      self.startLocationY = self.y
    end
  else
    self.touched = false
  end

  if(self.touched) then
    local x, y = t.getPosition(self.touch)
    local dy, dx = (y - self.locationTouchedY), (x - self.locationTouchedX)

    self:setPosition(self.startLocationX + dx, self.startLocationY + dy)
  end
end

local function handleLog(self)
  local a = g.getFont()

  if((#self.log * a:getHeight()) > self.height) then
    table_remove(self.log, 1)
  end
end

-- Required functions

function Console:update()
  handleTouch(self)
  handleLog(self)
end

function Console:draw()
  g.push("all")
  g.setColor(self.rgba)
  g.rectangle("fill",self.x, self.y, self.width, self.height)

  g.setColor(getInverseColor(self))

  local a = g.getFont()

  g.setScissor(self.x, self.y, self.width, self.height)
  for i = 1, #self.log do
    local offsetY = ( (i - 1) * a:getHeight() )
    g.print(self.log[i], self.x, self.y + offsetY)
  end
  g.setScissor()
  g.pop()
end

-- Public Functions

function Console:print(...)
  local arg = {...}

  local result = ""

  for _, v in ipairs(arg) do
    result = (result .. tostring(v) .. "\t")
  end

  self.log[#self.log + 1] = result
end

function Console:intervalPrint(t, timer, dt, ...)
  assert(type(t) == "number", ("bad argument #1 to intervalPrint (number expected, got " .. type(t) ..")" ))
  assert(type(timer) == "number", ("bad argument #2 to intervalPrint (number expected, got " .. type(t) ..")" ))
  assert(type(dt) == "number", ("bad argument #3 to intervalPrint (number expected, got " .. type(dt) .. ")" ))
  assert(timer <= #self.timers and timer >= 1, ("bad argument #2 to intervalPrint (timer in index " .. timer).. " does not exist)")

  self.timers[timer] = self.timers[timer] + dt

  if(self.timers[timer] >= t) then
    self:print(...)
    self.timers[timer] = 0
  end
end

function Console:clear()
  for i = #self.log, 1, -1 do
    table_remove(self.log, i)
  end
end

function Console:setColor(rgba)
  local sizeOf = #rgba

  assert(type(rgba) == "table", ("bad argument #1 to setColor (table expected, got " .. type(rgba).. ")" ))

  assert(sizeOf <= 4 and sizeOf >= 1, ("bad argument #1 to setColor (invalid table size, size of 4 expected, got " .. sizeOf ..")"))

  self.rgba[1] = rgba[1]
  self.rgba[2] = rgba[2]
  self.rgba[3] = rgba[3]
  self.rgba[4] = rgba[4]
end

 function Console:setDimensions(width, height)
  assert(type(width) == "number", ("bad argument #1 to setDimensions (number expected, got " .. type(width) ..")" ))
  assert(type(height) == "number", ("bad argument #2 to setDimensions (number expected, got " .. type(height) .. ")" ))

  self.width = width
  self.height = height
end

function Console:setPosition(x, y)
  assert(type(x) == "number", ("bad argument #1 to setPosition (number expected, got " .. type(x) ..")" ))
  assert(type(y) == "number", ("bad argument #2 to setPosition (number expected, got " .. type(y) .. ")" ))

  self.x = x
  self.y = y
end

function Console:setAlpha(alpha)
  assert(type(alpha) == "number", ("bad argument #1 to setAlpha (number expected, got " .. type(alpha).. ")" ))

  self.rgba[4] = alpha
end

return Console
