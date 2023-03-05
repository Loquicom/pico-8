pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
_g=_ENV
null=false

function _init()
	a = ""
	b = new("animal", {"toufou"})
	c = "hello "
	name = "test"
	a = b:coucou(" !!!")
	--a = b.self.sleep
end

function _draw()
	cls()
	print(a, 2,2,7)
end

-->8
--utils

function contains(tab, val)
	for v in all(tab) do
		if (v == val) return true
	end
	return false
end

-->8
-- POO

function new(class, params)
	-- Check constructor
	if (_g[class] == nil) return nil
	-- Load object metadata
	local metadata = _g["class_"..class] or {}
	metadata.extend = metadata.extend or "object"
	metadata.private = metadata.private or {}
	add(metadata.private, "_metadata")
	-- Instenciate object and add metadata
	local obj = _g[class](unpack(params))
	obj._metadata = metadata
	-- Return object in the proxy
	return proxy(class, obj)
end

function proxy(class, obj)
	-- Create proxy to wrap the object
	return setmetatable(
		{_class=class, self=obj}, 
		{
			__index = function(table, key)
				-- If it's private return nil
				-- To get value use direct access in the object with self
				if(contains(table.self._metadata.private, key)) return nil
				-- If it's function add it on the object
				local global = _g[table._class.."_"..key]
				if (table.self[key] == nil and global != nil and type(global) == "function") then
					table.self[key] = global
				end
				-- If not present in wrapped object search in global scope
				if (table.self[key] == nil) then
					return _g[key]
				end
				return table.self[key]
			end,
			__newindex = function(table, key, value)
				-- Do nothing if it's private
				-- To update value use direct access in the object with self
				if (contains(table.self._metadata.private, key)) return
				-- Set new value
				if (table.self[key] == nil) then
					_g[key] = value
				else
					table.self[key] = value
				end
			end,
			__call = function(table, ...)
				return new(table._class)
			end
		}
	) 
end

-->8
--object class

function object()
	_g['a'] = "pouet"
end

function object_tostring(_ENV)
	return "[object]"
end

-->8
-- class animal

class_animal = {
	private = {"sleep"}
}

function animal(name)
	return {
		name=name,
		sleep=null
	}
end

function animal_coucou(_ENV, str)
	self.sleep = "oui"
	sleep = "non"
	return c..name..str.." "..self.sleep
end


__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
