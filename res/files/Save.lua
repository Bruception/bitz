
local lf = love.filesystem

Save = {}

Save.saveData = {
  highscore = 0,
  sounds = true,
  hapticFeedback = true,
  currentLevelIndex = 1,
  version = Game.version,
  levelData = {},
  unlockedAds = false
}

function Save:load()

  --Slib:clear("save.dat")

  -- Check for new levels
  local levels = lf.getDirectoryItems("res/levels/")

  for i = #levels, 1, -1 do
    local sub = string.sub(levels[i], 1, 1)
    if(sub ~= "l") then
      table.remove(levels, i)
    end
  end

  if(Slib:isFirst()) then
    self.saveData.currentLevelIndex = 1
    self.saveData.sounds = true
    self.saveData.hapticFeedback = true
    self.saveData.highscore = 0
    self.saveData.version = Game.version
    self.saveData.unlockedAds = false

    -- score : unlocked

    for i = 1, #levels do
      local pos = #self.saveData.levelData + 1
      self.saveData.levelData[pos] = {}
      if(i == 1 or i == 2) then
        self.saveData.levelData[pos].score = 0
        self.saveData.levelData[pos].unlocked = true
      else
        self.saveData.levelData[pos].score = 0
        self.saveData.levelData[pos].unlocked = false
      end
    end

    Slib:save(self.saveData)
  else

    local success, error = protectedLoadCall()

    if(success) then

      self.saveData = Slib:load()

      if(#self.saveData.levelData < #levels) then
        for i = 1, #levels - #self.saveData.levelData do
          local pos = #self.saveData.levelData + 1
          self.saveData.levelData[pos] = {}
          self.saveData.levelData[pos].score = 0
          self.saveData.levelData[pos].unlocked = false
        end
      end

      self.saveData.version = Game.version

      Slib:save(self.saveData)
    else
      Slib:clear("save.dat")
      self.saveData = {
        sounds = true,
        hapticFeedback = true,
        currentLevelIndex = 1,
        highscore = 0,
        levelData = {},
        version = Game.version,
        unlockedAds = false
      }
      Toast[#Toast + 1] = Toast:new({
          messageType = "ERROR",
          text = "Save Corrupted"
      })
      self:load()
    end

  end
end

function Save:save()
  Slib:save(self.saveData)
end

function Save.loadData(loadedData)
  saveData = loadedData

  if(type(saveData) ~= "table") then
    error("saveData corrupted!")
  end

  if(type(saveData.currentLevelIndex) ~= "number") then
    error("currentLevelIndex corrupted!")
  end

  if(type(saveData.highscore) ~= "number") then
    error("highscore corrupted!")
  end

  if(type(saveData.levelData) ~= "table") then
    error("saveData's levelData is corrupted!")
  end

  if(type(saveData.sounds) ~= "boolean") then
    error("saveData's sound data is corrupted!")
  end

  if(type(saveData.hapticFeedback) ~= "boolean") then
    error("saveData's hapticFeedback data is corrupted!")
  end


end

function protectedLoadCall()
  local success, error = pcall(Save.loadData, Slib:load())

  return success, error
end
