
local lg = love.graphics
local lf = love.filesystem
local ls = love.system

LevelSelect = {}

function LevelSelect:load()

  self.titleFont = lg.newFont("res/fonts/BloggerSans.otf", Game:scaleWidth(48))
  self.titleAlpha = 0
  self.titleScale = 0
  self.titleTimer = 0
  self.lerpTimer = 0

  self.back =  Button:new({
    color = Game.colorPal1:getColor("red"),
    colorHover = Game.colorPal2:getColor("red"),
    textColor = Game.colorPal1:getColor("white"),
    x = Game.WIDTH * 0.5 - Game.WIDTH * 0.15 * 0.5,
    y = Game.HEIGHT * 1.25,
    width = Game.WIDTH * 0.15,
    height = Game.WIDTH * 0.15,
    paddingX = -0.075,
    paddingY = -0.075,
    text = "",
    image = Loader.gfx["home"],
    func = function()
      if(Save.saveData.sounds) then
        local a = Loader.sfx["TouchForward"]:play()
      end
      Game.state = "menu"
      self:reset()
    end
  })

  self.scoreFont = lg.newFont("res/fonts/BloggerSans.otf", Game:scaleWidth(24 * 0.85))

  local levels = lf.getDirectoryItems("res/levels/")

  for i = #levels, 1, -1 do
    local sub = string.sub(levels[i], 1, 1)
    if(sub ~= "l") then
      table.remove(levels, i)
    end
  end

  local offsetX = Game.WIDTH * 0.125
  local offsetY = Game.HEIGHT * 0.05

  local paddingX = Game:scaleWidth(25)
  local paddingY = Game:scaleHeight(150)

  local buttonSize = Game:scaleWidth(100)

  self.pages = {}

  local currentLevel = 0
  local levelsPerPage = 21
  local max = 0

  self.levels = {}

  for i = 1, math.ceil(#levels / levelsPerPage) do
    self.pages[i] = Page:new({
      x = 0,
      y = 0,
      index = 1,
      width = Game.WIDTH,
      height = Game.HEIGHT * 0.5,
    })
    local x, y

    local dif = #levels - currentLevel

    max = (dif > levelsPerPage) and levelsPerPage or dif--(#levels) / (math.ceil( (#levels) / (levelsPerPage) ))

    self.pages[i].content = Content:new({
      x = 0,
      y = Game.HEIGHT * 0.5 * 0.5,
      width = Game.WIDTH,
      height = (offsetY + (max / 3) * buttonSize) + buttonSize,
    })

    for j = 1, max do
      currentLevel = currentLevel + 1
      local level = Level:new({
        x = 0,
        y = 0,
        loadedData = Save.saveData.levelData[currentLevel],
        file = levels[currentLevel],
        fileIndex = currentLevel,
        width = buttonSize * 0.75,
        height = buttonSize * 0.75,
        page = i
      })

      self.levels[#self.levels + 1] = level

      x = offsetX + ((j - 1) % 3) * buttonSize
      y = offsetY + math.floor((j - 1) / 3) * buttonSize

      self.pages[i].content:addObject(level, x, y)

    end

    self.pages[i].scroll = Scroll:new({
      x = 0,
      y = Game.HEIGHT * 0.5 * 0.5,
      width = Game.WIDTH,
      height = Game.HEIGHT * 0.5,
      content = self.pages[i].content,
      scrollColor = Game.colorPal3:getColor("blue_half_2")
    })

    self.pages[i].content.scroll = self.pages[i].scroll

    self.pages[i]:addObject(self.pages[i].scroll, 0, 0)

  end

  self.pageScroller = PageScroll:new({
    width = Game.WIDTH,
    height = Game.HEIGHT * 0.5,
    x = 0,
    y = Game.HEIGHT * 0.25,
    pages = self.pages,
    scrollerColorPrimary = Game.colorPal1:getColor("white"),
    scrollerColor = Game.colorPal1:getColor("white")
  })

  self.numLevels = #self.levels

  self.barFont = lg.newFont("res/fonts/BloggerSans.otf", Game:scaleWidth(20))
--[[
  self.progress = ProgressBar:new({
    max = self.numLevels * 3,
    min = 0,
    x = Game.WIDTH * 0.5 - Game.WIDTH * 0.25,
    y = Game.HEIGHT * 0.24,
    width = Game.WIDTH * 0.5,
    height = Game.HEIGHT * 0.0075,
    backgroundColor = Game.colorPal3:getColor("blue"),
    barColor = Game.colorPal1:getColor("white"),
    font = self.barFont
  })
]]--
end

function LevelSelect:update(dt)
  self.back:update(dt)

  self:animate(dt)

  --self.progress:setValue(Game.blockCount)

  --self.progress:update(dt)

  self.pageScroller:update(dt)
end

function LevelSelect:draw()
  self.back:draw()

  lg.push()

  lg.translate(Game.WIDTH * 0.5, Game.HEIGHT * 0.5)
  lg.scale(self.titleScale, 1)
  lg.translate(-Game.WIDTH * 0.5, -Game.HEIGHT * 0.5)

  lg.setFont(self.titleFont)
  lg.setColor(Game.colorPal1:getColor("white")[1], Game.colorPal1:getColor("white")[2], Game.colorPal1:getColor("white")[3], self.titleAlpha)
  lg.print("Levels", Game.WIDTH * 0.5 - self.titleFont:getWidth("Levels") * 0.5, Game.HEIGHT * 0.125)

  lg.setColor(Game.colorPal1:getColor("white"))
  local fontW = self.scoreFont:getWidth(Game.blockCount .. "  /  " .. self.numLevels * 3)
  local fontH = self.scoreFont:getHeight(Game.blockCount .. "  /  " .. self.numLevels * 3)
  lg.setFont(self.scoreFont)
  lg.print(Game.blockCount .. "  /  " .. self.numLevels * 3, Game.WIDTH * 0.5 - fontW * 0.5, self.pages[1].scroll.y - fontH)

  lg.pop()

  self.pageScroller:draw()

  --self.progress:draw()

end

function LevelSelect:touchReleased(id)
  self.back:touchReleased(id)
  self.pageScroller:touchReleased(id)
end

function LevelSelect:animate(dt)
  self.back.y = Lume.smooth(self.back.y, Game.HEIGHT * 0.85, dt * 16)
  self.lerpTimer = Lume.lerp(self.lerpTimer, 1, dt * 4)
  self.titleAlpha = Lume.lerp(self.titleAlpha, 1, self.lerpTimer * self.lerpTimer)

  self.titleTimer = Lume.lerp(self.titleTimer, 1, dt)
  self.titleScale = Lume.outElastic(self.titleTimer, 0, 1, 1)
end

function LevelSelect:touchMoved(id, x, y, dx, dy)
  self.pageScroller:touchMoved(id, x, y, dx, dy)
end

function LevelSelect:reset()
  self.titleScale = 0
  self.titleTimer = 0
  self.lerpTimer = 0
  self.pages[1].scroll.velY = 0
  self.titleAlpha = 0
  self.back.y = Game.HEIGHT * 1.25
  self.pageScroller:resetAnimation()
end
