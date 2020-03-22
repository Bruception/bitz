
local lt = love.touch
local lg = love.graphics
local lm = love.mouse

Stack = {}

Stack.__index = Stack

function Stack:new(properties)

  local self = {}

  self.x = properties.x
  self.y = properties.y

  self.highlight = false
  self.playedPop = false
  self.desiredWeight = 0

  self.goalWeight = properties.goalWeight

  self.blockWeights = 0

  self.blocks = {}

  self.weight = 0

  self.squeezeTimer = 0
  self.squeezeScale = 1
  self.squeezePivotX = 0
  self.squeezePivotY = 0

  self.height = Game:scaleHeight(180 * 0.85)
  self.width = Game:scaleWidth(120 * 0.85)

  self.blockHighlightAlpha = 0

  self.textTimer = 0
  self.textScale = 0

  self.lineX = self.x + self.width * 0.5
  self.lineWidth = 0

  return setmetatable(self, Stack)

end

function Stack:update(dt)
  self:updateBlockPositions(dt)

  for i = 1, #self.blocks do
    if(self.blocks[i] == BLOCK_TOUCHED) then
      self.blockAlpha = true
      break
    else
      self.blockAlpha = false
    end
  end

  if(self.blockAlpha) then
    self.blockHighlightAlpha = Lume.smooth(self.blockHighlightAlpha, 0.3, dt * 8)
  else
    self.blockHighlightAlpha = Lume.smooth(self.blockHighlightAlpha, 0, dt * 16)
  end

end

function Stack:draw()

  lg.setColor(Game.colorPal1:getColor("white")[1], Game.colorPal1:getColor("white")[2], Game.colorPal1:getColor("white")[3], 0.1)

  if(self.highlight) then
    lg.setLineWidth(4)
    self.textScale = 1.1
  else
    lg.setLineWidth(2)
  end
  lg.line(self.lineX, self.y + self.height, self.lineX + self.lineWidth, self.y + self.height)

  lg.setLineWidth(2)

  lg.setFont(LEVEL_FONT)
  lg.setColor(Game.colorPal1:getColor("white")[1], Game.colorPal1:getColor("white")[2], Game.colorPal1:getColor("white")[3], 0.35)

  if(self.desiredWeight == 0) then
    self.desiredWeight = tostring(self.desiredWeight)
  end

  lg.push()


  local hFontW = LEVEL_FONT:getWidth(self:sumBlockWeights() .. "  /  " .. self.desiredWeight) * 0.5
  local fontH = LEVEL_FONT:getHeight(self:sumBlockWeights() .. "  /  " .. self.desiredWeight) * 0.5

  lg.translate((self.x + self.width * 0.5 - hFontW) + hFontW, (self.y + self.height + fontH) + fontH * 0.5)
  lg.scale(self.textScale)
  lg.translate(-(self.x + self.width * 0.5 - hFontW) - hFontW, -(self.y + self.height + fontH) - fontH * 0.5)

  lg.print(self:sumBlockWeights() .. "  /  " .. self.desiredWeight, self.x + self.width * 0.5 - hFontW, self.y + self.height + fontH)

  lg.setColor(Game.colorPal1:getColor("white")[1], Game.colorPal1:getColor("white")[2], Game.colorPal1:getColor("white")[3], 0.65)
  lg.print(self:sumBlockWeights(), self.x + self.width * 0.5 - hFontW, self.y + self.height + fontH)


  lg.pop()

  if(#self.blocks > 0) then
    lg.setColor(Game.colorPal1:getColor("white")[1], Game.colorPal1:getColor("white")[2], Game.colorPal1:getColor("white")[3], self.blockHighlightAlpha)
    --lg.rectangle("line", self.x + self.width * 0.5 - self.blocks[i].size * 0.5, self.y + self.height - (i) * self.blocks[i].height, self.blocks[i].size, self.blocks[i].height, 10, 10)
    DottedSquare:draw(self.blocks[#self.blocks].weight,
     self.x + self.width * 0.5 - self.blocks[#self.blocks].size * 0.5,
      self.y + (self.height - 3) - (self.blocks[#self.blocks].pos) * self.blocks[#self.blocks].height,
      self.blocks[#self.blocks].size, self.blocks[#self.blocks].height)
  end

end

function Stack:sumBlockWeights()
  local weight = 0
  local mult = 0
  local div = 0
  for i = 1, #self.blocks do
    weight = weight + self.blocks[i].weight
    if(self.blocks[i].type == "purple") then
      mult = mult + 1
    elseif(self.blocks[i].type == "yellow") then
      div = div + 1
    end
  end

  if(self.highlight and BLOCK_TOUCHED ~= 0 and BLOCK_TOUCHED.stack ~= self and self:checkWeight(BLOCK_TOUCHED)) then
    weight = weight + BLOCK_TOUCHED.weight
    if(BLOCK_TOUCHED.type == "purple") then
      mult = mult + 1
    elseif(BLOCK_TOUCHED.type == "yellow") then
      div = div + 1
    end
  end

  mult = (mult > 0) and (2 * (mult)) or 1

  return (self:divide(weight, div)) * mult
end

function Stack:divide(num, times)
  for i = 1, times do
    num = num / 2
  end
  return num
end

function Stack:add(block)
  table.insert(self.blocks, block)
end

function outBounce(t, b, c, d)
  t = t / d

  if t < 1 / 2.75 then return c * (7.5625 * t * t) + b end

  if t < 2 / 2.75 then
    t = t - (1.5 / 2.75)

    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)

    return c * (7.5625 * t * t + 0.9375) + b
  end

  t = t - (2.625 / 2.75)
  return c * (7.5625 * t * t + 0.984375) + b
end

function Stack:updateBlockPositions(dt)

  if(#self.blocks > 0) then
    --self:swapBlocks()

    for i = 1, #self.blocks do
      if(BLOCK_TOUCHED ~= self.blocks[i]) then
        self.blocks[i].stack = self
        self.blocks[i].pos = i


        local dx = Lume.smooth(self.blocks[i].x, self.x + self.width * 0.5 - self.blocks[i].size * 0.5, dt * 12)
        --local dy = Lume.lerp(self.blocks[i].y, self.y + self.height - (i) * self.blocks[i].height, dt * 12)
        local dy = self.blocks[i].y

        --local duration = 0.025 * math.abs(self.blocks[i].startY - (( self.y + self.height - (i) * self.blocks[i].height)))

        self.blocks[i].timer = Lume.lerp(self.blocks[i].timer, 2.5, dt * 3.25)--self.blocks[i].timer + dt * 4

        if(Lume.roundP(self.blocks[i].timer, 2) < 2.25) then
          dy = outBounce(self.blocks[i].timer, self.blocks[i].startY, ( self.y + self.height - (i) * self.blocks[i].height) - self.blocks[i].startY, 2.5)
        elseif(Lume.roundP(self.blocks[i].timer, 2) >= 2.25) then
          dy = Lume.smooth(self.blocks[i].y, self.y + self.height - (i) * self.blocks[i].height, dt * 12)--( self.y + self.height - (i) * self.blocks[i].height)
        end

        self.blocks[i]:setPosition(dx, dy)

        if( math.abs( (self.y + self.height - (i) * self.blocks[i].height) - (self.blocks[i].y)) <= self.blocks[i].height * 0.1 and self.blocks[i].timer >= 0.25) then
          if(not self.blocks[i].dustAnimation) then
            self.blocks[i].dustAnimation = true
          end
        end

      end
    end
  end
end

function Stack:checkWeight(block)

  if(#self.blocks == 0) then
    return true
  end

  if(#self.blocks >= 4) then
    return false
  end

  if((self.blocks[#self.blocks].type == "purple") and not (block.type == "purple" or block.type == "yellow")) then
    return false
  end

  if((self.blocks[#self.blocks].type == "yellow") and not (block.type == "yellow" or block.type == "purple")) then
    return false
  end

  if(block.weight > self.blocks[#self.blocks].weight) then
    return false
  end
  return true
end

function Stack:remove(block)
  for i = #self.blocks, 1, -1 do
    if(block == self.blocks[i]) then
      table.remove(self.blocks, i)
    end
  end
end

function Stack:clear()
  self.blockHighlightAlpha = 0
  self.blockAlpha = false
  self.squeezeTimer = 0
  self.squeezeScale = 1
  self.squeezePivotX = 0
  self.squeezePivotY = 0
  self.desiredWeight = 0
  self.playedPop = false
  self.textScale = 0
  self.textTimer = 0
  self.lineX = self.x + self.width * 0.5
  self.lineWidth = 0
  for i = #self.blocks, 1, -1 do
    table.remove(self.blocks, i)
  end
end

function Stack:contains(block)
  for i = 1, #self.blocks do
    if(self.blocks[i] == block) then
      return true
    end
  end

  return false
end

function Stack:getPreviousWeight(pos)
  local previous = pos - 1

  if(previous <= 0) then
    return 0
  else
    return self.blocks[previous].weight
  end

end

function Stack:swapBlocks()
  for i = 1, #self.blocks do
    if(#self.blocks > 1 and i < #self.blocks) then
      if(self.blocks[i + 1].weight > self.blocks[i].weight) then
        local temp = self.blocks[i]
        self.blocks[i] = self.blocks[i + 1]
        self.blocks[i + 1] = temp
      end
    end
  end
end

function Stack:hasDesiredWeight()
  return tonumber(self:sumBlockWeights()) == tonumber(self.desiredWeight) and BLOCK_TOUCHED == 0
end


function Stack:isTouching(x, y)
  return (x > self.x
    and x < self.x + self.width
    and y > self.y
    and y < self.y + self.height)
end

local a = 0.9

function Stack:animate(dt)
--  self:updateBlockAnimate(dt)

  self.squeezeTimer = self.squeezeTimer + dt * 4
  self.squeezeScale = Lume.smooth(self.squeezeScale, a + ((1 - a) * self:squeeze(self.squeezeTimer)), dt * 20)

  if(#self.blocks > 0) then
    self.squeezePivotX = self.blocks[1].x + self.blocks[1].size * 0.5
    self.squeezePivotY = self.blocks[1].y + self.blocks[1].height * 0.5
  end

  if(not self.playedPop) then
    if(Save.saveData.sounds) then
      local a = Loader.sfx["StackPop"]:play()
      a:setPitch(math.random(90, 110) * 0.01)
    end
    self.playedPop = true
  end

  self.highlight = self:isTouching(lm.getPosition()) and BLOCK_TOUCHED ~= 0

  self.textTimer = Lume.lerp(self.textTimer, 1, dt * 2)
  self.lineX = Lume.outElastic(self.textTimer, self.x + self.width * 0.5, self.x - (self.x + self.width * 0.5), 1)
  self.lineWidth = Lume.outElastic(self.textTimer, 0, self.width, 1)
  self.textScale = Lume.outElastic(self.textTimer, 0, 1, 1)
end

function Stack:squeeze(time)
  time = (time > 1) and 1 or ((time < 0) and 0 or time)

  local c

  if(time <= 0.25) then

    c = 1.25 * math.cos(math.pi * time)

    return c * c
  end
  if(time <= 0.5) then
    c = 0.75 * math.cos(math.pi * time)

    return c * c
  end

  if(time <= 0.75) then
    c = 1.25 * math.cos(math.pi * time)

    return c * c
  end

  if(time < 1) then
    c = 1 * math.cos(math.pi * time)

    return c * c
  end

  return 1

end
