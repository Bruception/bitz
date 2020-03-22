
local lg = love.graphics

Pointer = {}

local DIR_UP = 0
local DIR_LEFT
local DIR_RIGHT
local DIR_DOWN = math.pi


function Pointer:load()
  self.x = 0
  self.y = Game.HEIGHT * 0.25

  self.scaleX = Game:scaleWidth(0.03)
  self.scaleY = Game:scaleWidth(0.03)

  self.width  = Loader.gfx["pointer"]:getWidth() * self.scaleX
  self.height = Loader.gfx["pointer"]:getHeight() * self.scaleY

  self.angle = DIR_DOWN

  self.timer = 0
  self.timer2 = 0

  self.alpha = 0

end

function Pointer:update(dt)
  if(World.currentLevel.file == "l00.stack") then
    self:levelZeroTutorial(dt)
  elseif(World.currentLevel.file == "l01.stack") then
    self:levelOneTutorial(dt)
  end
end

function Pointer:draw()
  lg.push()

  lg.translate(self.x + self.width * 0.5, self.y + self.height * 0.5)
  lg.rotate(self.angle)
  lg.translate(-self.x - self.width * 0.5, -self.y - self.height * 0.5)
  
  lg.setColor(Game.colorPal1:getColor("white")[1], Game.colorPal1:getColor("white")[2], Game.colorPal1:getColor("white")[3], self.alpha)
  lg.draw(Loader.gfx["pointer"], self.x, self.y, 0, self.scaleX, self.scaleY)

  lg.pop()
  lg.setColor(1, 1, 1, 1)
end

function Pointer:reset()

  self.x = 0
  self.y = 0

  self.angle = DIR_DOWN

  self.timer = 0
  self.timer2 = 0

  self.alpha = 0
end

function Pointer:levelZeroTutorial(dt)
  if(World.moves > World.minMoves) then
    self:pointAtReset(dt)
  elseif(BLOCK_TOUCHED ~= World.blocks[1]) then
    self:pointAtBlock(World.blocks[1], dt)
  elseif(BLOCK_TOUCHED == World.blocks[1] and World.blocks[1].stack ~= World.stacks[2]) then
    self:dragBlockToStack(World.blocks[1], World.stacks[2], dt)
  end
end

function Pointer:levelOneTutorial(dt)

  if(World.moves > World.minMoves or World.stacks[3].blocks[1] == World.blocks[2] or World.stacks[2].blocks[1] == World.blocks[1]) then
    self:pointAtReset(dt)

  elseif(BLOCK_TOUCHED ~= World.blocks[2] and World.blocks[2].stack == World.stacks[1]) then
    self:pointAtBlock(World.blocks[2], dt)

  elseif(BLOCK_TOUCHED == World.blocks[2] and World.blocks[2].stack == World.stacks[1] and World.blocks[1].stack ~= World.stacks[3]) then
    self:dragBlockToStack(World.blocks[2], World.stacks[2], dt)

  elseif(BLOCK_TOUCHED ~= World.blocks[1] and (World.blocks[2].stack == World.stacks[2] or World.blocks[2].stack == World.stacks[3]) and World.blocks[1].stack ~= World.stacks[3]) then
    self:pointAtBlock(World.blocks[1], dt)

  elseif(BLOCK_TOUCHED == World.blocks[1] and World.blocks[1].stack ~= World.stacks[3]) then
    self:dragBlockToStack(World.blocks[1], World.stacks[3], dt)

  elseif(BLOCK_TOUCHED ~= World.blocks[2] and World.blocks[1].stack == World.stacks[3]) then
    self:pointAtBlock(World.blocks[2], dt)

  elseif(BLOCK_TOUCHED == World.blocks[2] and World.blocks[1].stack == World.stacks[3]) then
    self:dragBlockToStack(World.blocks[2], World.stacks[3], dt)
  end
end

function Pointer:dragBlockToStack(block, stack, dt)
  self.angle = DIR_DOWN
  self.timer1 = 0
  self.timer2 = self.timer2 + dt

  self.alpha = 0.5 * math.sin(2 * self.timer2) + 0.5
  self.x = Lume.smooth(self.x, stack.x + World.stacks[1].width * 0.5 - self.width * 0.5, dt * 12)
  self.y = Lume.smooth(self.y, stack.y + World.stacks[1].height * 0.15, dt * 12)

  if(self.timer2 >= 2.25) then
    self.x = block.stack.x + World.stacks[1].width * 0.5 - self.width * 0.5
    self.y = block.stack.y + self.height * 0.15
    self.timer2 = 0
  end
end

function Pointer:pointAtBlock(block, dt)
  self.angle = DIR_DOWN
  self.timer2 = 2.25

  self.x = block.stack.x + World.stacks[1].width * 0.5 - self.width * 0.5
  self.timer = self.timer + dt * 4
  self.y = block.y - 1.5 * self.height + 10 * math.sin(self.timer)

  self.alpha = 0.5 * math.sin(self.timer) + 0.5
end

function Pointer:pointAtReset(dt)
  self.angle = DIR_UP
  self.timer2 = 2.25
  self.timer = self.timer + dt * 4
  self.alpha = 0.5 * math.sin(self.timer) + 0.5
  self.y = World.redo.y + World.redo.height * 2 + 10 * math.sin(self.timer)
  self.x = World.redo.x + World.redo.width * 0.5 - self.width * 0.5
end
