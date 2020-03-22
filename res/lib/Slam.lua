local newInstance = love.audio.newSource
local stop = love.audio.stop

------------------
-- source class --
------------------
local Source = {}
Source.__index = Source
Source.__newindex = function(_,k) error(('Cannot write key %s'):format(tostring(k))) end

local function remove_stopped(sources)
	local remove = {}
	for s in pairs(sources) do
		remove[s] = true
	end
	for s in pairs(remove) do
		sources[s] = nil
	end
end

local function get_target(target)
	if type(target) == 'table' then
		return target[math.random(1,#target)]
	end
	return target
end

local play_instance, stop_instance
function Source:play()
	remove_stopped(self.instances)
	if self._paused then self:stop() end
	local instance = newInstance(get_target(self.target), self.how)

	-- overwrite instance:stop() and instance:play()
	if not (play_instance and stop_instance) then
		play_instance = getmetatable(instance).play
		getmetatable(instance).play = error

		stop_instance = getmetatable(instance).stop
		getmetatable(instance).stop = function(this)
			stop_instance(this)
			self.instances[this] = nil
		end
	end

	instance:setLooping(self.looping)
	instance:setPitch(self.pitch)
	instance:setVolume(self.volume)

	self.instances[instance] = instance
	play_instance(instance)
	return instance
end

function Source:stop()
	for s in pairs(self.instances) do
		s:stop()
	end
	self._paused = false
	self.instances = {}
end

function Source:pause()
	if self._paused then return end
	for s in pairs(self.instances) do
		s:pause()
	end
	self._paused = true
end

function Source:resume()
	if not self._paused then return end
	for s in pairs(self.instances) do
		s:resume()
	end
	self._paused = false
end

function Source:addTags(tag, ...)
	if not tag then return end
	love.audio.tags[tag][self] = self
	return Source.addTags(self, ...)
end

function Source:removeTags(tag, ...)
	if not tag then return end
	love.audio.tags[tag][self] = nil
	return Source.removeTags(self, ...)
end

function Source:isStatic()
	return self.how ~= "stream"
end

-- getter/setter for looping, pitch and volume
for _, property in ipairs{'looping', 'pitch', 'volume'} do
	local name = property:sub(1,1):upper() .. property:sub(2)
	Source['get' .. name] = function(self)
		return self[property]
	end

	Source['set' .. name] = function(self, val)
		self[property] = val
		for s in pairs(self.instances) do
			s['set' .. name](s, val)
		end
	end
end
Source.isLooping = Source.getLooping

--------------------------
-- love.audio interface --
--------------------------
function love.audio.newSource(target, how)
	local s = {
		_paused   = false,
		target    = target,
		how       = how,
		instances = {},
		looping   = false,
		pitch     = 1,
		volume    = 1,
	}
	if how == 'static' and type(target) == 'string' then
		s.target = love.sound.newSoundData(target)
	end
	love.audio.tags.all[s] = s
	return setmetatable(s, Source)
end

function love.audio.play(source)
	assert(source and source.instances, "Can only play source objects.")
	return source:play()
end

function love.audio.stop(source)
	if source and source.stop then return source:stop() end
	stop()
end

----------
-- tags --
----------
local Tag = { __mode = "kv" }
function Tag:__index(func)
	-- calls a function on all tagged sources
	return function(...)
		for s in pairs(self) do
			assert(type(s[func]) == "function", ("`%s' does not name a function."):format(func))
			s[func](s, ...)
		end
	end
end

love.audio.tags = setmetatable({}, {
	__newindex = error,
	__index = function(t,k)
		local tag = setmetatable({}, Tag)
		rawset(t, k, tag)
		return tag
	end,
})
