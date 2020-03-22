
local table_insert = table.insert
local string_find, string_sub, string_len = string.find, string.sub, string.len

local lf = love.filesystem

LevelLoader = {}

LevelLoader.levelDir = "res/levels/"

LevelLoader.blockKeys = {
  ["b"] = "blue",
  ["o"] = "orange",
  ["r"] = "red",
  ["g"] = "green",
  ["w"] = "gray",
  ["p"] = "purple",
  ["y"] = "yellow"
}

LevelLoader.blockWidthKeys = {
  ["b"] = Game:scaleWidth(3 * 20),
  ["o"] = Game:scaleWidth(4 * 20),
  ["r"] = Game:scaleWidth(5 * 20),
  ["g"] = Game:scaleWidth(6 * 20),
  ["w"] = Game:scaleWidth(3 * 20),
  ["p"] = Game:scaleWidth(3 * 20),
  ["y"] = Game:scaleWidth(3 * 20)
}

LevelLoader.weightKeys = {
  ["b"] = 3,
  ["o"] = 4,
  ["r"] = 5,
  ["g"] = 6,
  ["1"] = 1,
  ["2"] = 2
}

LevelLoader.initStackContents = {}

LevelLoader.winStackContents = {}

LevelLoader.fileLines = {}

function LevelLoader:initParse(name)
  local fileDir = self.levelDir .. name

  local exists = lf.getInfo(fileDir)

  local firstChar = ""
  local colonPos = 0
  local contents = ""

  if(exists) then
    World:reset()
    self:reset()
    for line in lf.lines(fileDir) do
      firstChar = string_sub(line, 1, 1)
      if(line ~= "" and firstChar ~= "m" and firstChar ~= "M" and firstChar ~= "s") then
        table_insert(self.fileLines, line)
      end

      if(firstChar == "m") then
        colonPos = string_find(line, ":")
        contents = string_sub(line, colonPos + 1, string_len(line))

        World.message = contents
      elseif(firstChar == "M") then
        colonPos = string_find(line, ":")
        contents = string_sub(line, colonPos + 1, string_len(line))
        World.minMoves = tonumber(contents)
      elseif(firstChar == "s") then
        colonPos = string_find(line, ":")
        contents = string_sub(line, colonPos + 1, string_len(line))
        World.numStacks = tonumber(contents)
      end
    end
    self:parseFile()

  else -- The file does not exist
    return false
  end

end

function LevelLoader:parseFile()

  local colonPos, index, contents

  for lineNumber, line in ipairs(self.fileLines) do

    colonPos = string_find(line, ":")

    index = string_sub(line, 0, 1)
    contents = string_sub(line, colonPos + 1, string_len(line))
    if(lineNumber < 5) then
      self.initStackContents[tonumber(index)] = contents
    else
      self.winStackContents[tonumber(index - 4)] = contents
    end
  end

  self:loadLevel()

end

function LevelLoader:loadLevel()

  for i = 1, 4 do
    for block = 1, string_len(self.initStackContents[i]) do
      local b = string_sub(self.initStackContents[i], block, block)
      if(b ~= "n") then
        World.blocks[#World.blocks + 1] = Block:new({
          x = (World.stacks[i].x + World.stacks[i].width * 0.5) - self.blockWidthKeys[b] * 0.5,
          y = World.stacks[i].y - Game:scaleHeight(35),
          type = self.blockKeys[b]
        })
        World.stacks[i]:add(World.blocks[#World.blocks])
      end
    end
  end

  for i = 1, 4 do
    for block = 1, string_len(self.winStackContents[i]) do
      local b = string_sub(self.winStackContents[i], block, block)
      if(b ~= "n") then
        World.stacks[i].desiredWeight = World.stacks[i].desiredWeight + self.weightKeys[b]
      end
    end
    World.winCondition[i] = World.stacks[i].desiredWeight
  end

end

function LevelLoader:reset()
  for i = 1, 4 do
    self.initStackContents[i] = ""
    self.winStackContents[i] = ""
  end
  for i = #self.fileLines, 1, -1 do
    table.remove(self.fileLines, i)
  end
end
