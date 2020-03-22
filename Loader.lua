
local lf = love.filesystem
local la = love.audio
local lg = love.graphics

local Loader = {}

Loader.RES_PATH = "res/"

Loader.gfx = {}
Loader.sfx = {}

Loader.paths = {
  ["files"] = Loader.RES_PATH .. "files/",
  ["gfx"] = Loader.RES_PATH .. "gfx/",
  ["sfx"] = Loader.RES_PATH .. "sfx/",
  ["lib"] = Loader.RES_PATH .. "lib/"
}

function Loader:load()
  self:loadMisc()
  self:loadFiles()
  self:loadSounds()
  self:loadImages()
end

function Loader:loadFiles()
  local files = lf.getDirectoryItems(self.paths["files"])

  self:removeDS_Store(files)

  for n, file in ipairs(files) do
    local fileNameOnly = string.sub(file, 0, string.len(file) - 4)

    require(self.paths["files"] .. fileNameOnly)
  end
end

function Loader:loadSounds()
  local sounds = lf.getDirectoryItems(self.paths["sfx"])

  self:removeDS_Store(sounds)

  for n, sound in ipairs(sounds) do
    local soundNameOnly = string.sub(sound, 0, string.len(sound) - 4)

    self.sfx[soundNameOnly] = la.newSource(self.paths["sfx"] .. sound, "static")

  end

end

function Loader:loadImages()
  local images = lf.getDirectoryItems(self.paths["gfx"])

  self:removeDS_Store(images)

  for n, image in ipairs(images) do
    local imageNameOnly = string.sub(image, 0, string.len(image) - 4)

    self.gfx[imageNameOnly] = lg.newImage(self.paths["gfx"] .. image)

  end

end

function Loader:loadMisc() -- Load Libraries and other items here
  require(self.paths["lib"] .. "Slam")
  Lume = require(self.paths["lib"] .. "Lume")
  Slib = require(self.paths["lib"] .. "Slib")
  Slib:init("Slib")

  Console = require(self.paths["lib"] .. "Console")
  Console:init({
    rgba = {0, 0, 0, 0.5},
    width = 350,
    height = 100,
  })

  Console:print("Console ready ... ")

  Gradient = lg.newShader(self.paths["lib"] .. "Gradient.glsl")

  Blur = lg.newShader(self.paths["lib"] .. "Blur.glsl")
end

function Loader:removeDS_Store(files) -- Handling that pesky .DS_Store file
  for i = #files, 1, -1 do
    if(files[i] == ".DS_Store") then
      table.remove(files, i)
    end
  end
end


return Loader
