
local lg = love.graphics

Level = {}

LEVEL_FONT = lg.newFont("res/fonts/BloggerSans.otf", Game:scaleWidth(26))

Level.__index = Level

local COLOR_KEYS
local PADDING
local RATING_SIZE

function Level:load()
  COLOR_KEYS = {
    Game.colorPal1:getColor("blue"),
    Game.colorPal1:getColor("orange"),
    Game.colorPal1:getColor("red")
  }

  PADDING = Game:scaleWidth(16)
  RATING_SIZE = Game:scaleWidth(7)

end

function Level:new(properties)
  local self = {}

  self.x = properties.x or 0
  self.y = properties.y or 0

  self.loadedData = properties.loadedData

  self.unlocked = self.loadedData.unlocked
  self.rating = self.loadedData.score
  self.completed = (self.rating > 0) and true or false

  self.file = properties.file
  self.page = properties.page or 1

  self.fileIndex = properties.fileIndex

  self.width = properties.width
  self.height = properties.height

  self.iWidth = self.width * 0.25

  self.name = tonumber(string.sub(self.file, 2, 3)) + 1

  self.button = Button:new({
    color = Game.colorPal3:getColor("blue_half"),
    colorHover = Game.colorPal3:getColor("blue_half_2"),
    textColor = Game.colorPal1:getColor("white"),
    x = self.x,
    y = self.y,
    width = self.width,
    height = self.height,
    text = self.name,
    func = function()
      if(Save.saveData.sounds) then
        local a = Loader.sfx["TouchForward"]:play()
      end

      Pointer:reset()

      LevelSelect:reset()
      LevelLoader:initParse(self.file)

      Save.saveData.currentLevelIndex = self.fileIndex

      Save:save()

      World.currentLevel = self
      Game.state = "game"
    end
  })

  return setmetatable(self, Level)
end

function Level:update(dt)
  self.button:update(dt)
  self.button.x = self.x
  self.button.y = self.y

  self.completed = (self.rating > 0)

  if(self.fileIndex >= 3) then
    self.unlocked = (LevelSelect.levels[self.fileIndex - 1].completed or LevelSelect.levels[self.fileIndex - 2].completed)
  end

  self.button.enabled = self.unlocked
end

local fill = "line"
local size = 0

function Level:draw()
  lg.setFont(LEVEL_FONT)
  self.button:draw()
  lg.setLineWidth(2)

  lg.setColor(Game.colorPal1:getColor("gray"))

  if(self.unlocked) then
    for i = 1, 3 do

      fill = (self.rating >= i) and "fill" or "line"
      size = (self.rating >= i) and RATING_SIZE * 1.75 or RATING_SIZE

      lg.setColor(COLOR_KEYS[i])

      lg.rectangle(fill, self.x + (i * self.iWidth) - size * 0.5, self.y + self.height * 0.8 - size * 0.5 - self.button.offset, size, size, size, size * 0.025, size * 0.025)
    end
  end

  if(self.fileIndex == Save.saveData.currentLevelIndex) then
    lg.setColor(Game.colorPal2:getColor("orange")[1], Game.colorPal2:getColor("orange")[2], Game.colorPal2:getColor("orange")[3], .4)
    lg.rectangle("line", self.button.x, self.button.y + (self.button.height * 0.05 - self.button.offset), self.width, self.height * 0.9525, 10, 10)
  end
end

function Level:touchReleased(id)
  self.button:touchReleased(id)
end
