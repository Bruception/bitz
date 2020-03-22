local lf = love.filesystem

local Slib = {
  _VERSION = 'Slib v1.2',
  _DESCRIPTION = 'Save files easy for Love2D',
  _LICENSE = [[MIT LICENSE]]
}

Slib.name = nil
Slib.defaultFilename = "save.dat"
Slib.defaultEncryption = {29, 58, 93, 28, 27}

function Slib:init(name, filename, enc)
  self.name = name
  self.defaultFilename = filename or self.defaultFilename
  self.defaultEncryption = enc or self.defaultEncryption
end

function Slib:isFirst(filename)
  filename = filename or self.defaultFilename
  if lf.getInfo(filename) then
    return false
  end
  return true
end

function Slib:save(table, filename, drop)
  filename = filename or self.defaultFilename

  if type(drop) == "table" then drop = drop else drop = {drop} or {} end
  if type(table) ~= "table" then table = {table} end
  local string = self:pack(table, drop)

  lf.write(filename, string)

  return true
end

function Slib:saveE(table, filename, drop, enc)
  filename = filename or self.defaultFilename
  enc = enc or self.defaultEncryption

  if type(drop) == "table" then drop = drop else drop = {drop} or {} end
  if type(table) ~= "table" then table = {table} end

  local string = self:pack(table, drop)

  local crypted = self:crypt(string, enc)
  lf.write(filename, crypted)
  lf.append(filename, "e", 1)

  return true
end

function Slib:load(filename, enc)
  filename = filename or self.defaultFilename
  enc = enc or self.defaultEncryption
  local tab = {}
  local str = nil

  if lf.getInfo(filename) then

    local fileInfo = lf.getInfo(filename)

    local size = fileInfo.size
    local str = lf.read(filename, size)
    local t = string.len(str)

    if string.sub(str, t) == 'e' then
      local str = string.sub(str, 1, t-1)
      str = self:crypt(str, enc, true)
      tab = self:unpack(str, true)
    else
      tab = self:unpack(str, true)
    end
  end

  local status = tab ~= nil

  return tab, status
end

function Slib:clear(filename)
  return lf.remove( filename )
end

function Slib:pack(t, drop, indend)
	assert(type(t) == "table", "Can only Slib:pack tables.")
	local s, empty, indent = "{"..(indent and "\n" or ""), true, indent and math.max(type(indent)=="number" and indent or 0,0)
	local function proc(k,v, omitKey)
  empty = nil
  local tk, tv, skip = type(k), type(v)

  if type(drop) == "table" and drop[k] then k = "["..drop[k].."]"
  elseif tk == "boolean" then k = k and "[true]" or "[false]"
  elseif tk == "string" then local f = string.format("%q",k) if f ~= '"'..k..'"' then k = '['..f..']' end
  elseif tk == "number" then k = "["..k.."]"
  elseif tk == "table" then k = "["..self:pack(k, drop, indent and indent+1).."]"
  elseif type(drop) == "function" then k = "["..string.format("%q",drop(k)).."]"
  elseif drop then skip = true
  else error("Attempted to Slib:pack a table with an invalid key: "..tostring(k))
  end

  if type(drop)=="table" and drop[v] then v = drop[v]
  elseif tv == "boolean" then v = v and "true" or "false"
  elseif tv == "string" then v = string.format("%q", v)
  elseif tv == "number" then
  elseif tv == "table" then v = self:pack(v, drop, indent and indent+1)
  elseif type(drop) == "function" then v = string.format("%q",drop(v))
  elseif drop then skip = true
  else error("Attempted to Slib:pack a table with an invalid value: "..tostring(v))
  end

  if not skip then return string.rep("\t",indent or 0)..(omitKey and "" or k.."=")..v..","..(indent and "\n" or "") end
  return ""
  end

	local l=-1 repeat l=l+1 until t[l+1]==nil
	for i=1,l do s = s..proc(i, t[i], true) end
	for k, v in pairs(t) do if not (type(k)=="number" and k<=l) then s = s .. proc(k, v) end end
	if not empty then s = string.sub(s, 1, string.len(s) - 1) end
	if indent then s = string.sub(s, 1, string.len(s) - 1).."\n" end
	return s..string.rep("\t", (indent or 1)-1) .. "}"
end

function Slib:unpack(s, safe)
	if safe then s = string.match(s, "(%b{})") end
  assert(type(s) == "string", "Can only Slib:unpack strings.")
  assert(type(self.name) == "string", "You must call Slib:init('Slib') first!")
	local f, result = loadstring(self.name .. ".table=" .. s)

	if not safe then assert(f,result) elseif not f then return nil, result end
	result = f()
	local t = self.table
	self.table = nil
	return t, result
end

function Slib:convert( chars, dist, inv )
  return string.char( ( string.byte( chars ) - 32 + ( inv and -dist or dist ) ) % 95 + 32 )
end

function Slib:crypt(str, k, inv)

  local enc = ""
  for i = 1, #str do
    if(#str - k[5] >= i or not inv) then
      for inc = 0, 3 do
        if(i % 4 == inc)then
          enc = enc .. self:convert(string.sub(str, i, i), k[inc+1], inv);
          break;
        end
      end
    end
  end

  if(not inv)then
    for i = 1, k[5] do
      enc = enc .. string.char(math.random(32, 126));
    end
  end

  return enc;
end

return Slib
