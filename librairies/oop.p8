-->8
--oop

function new(class, params)
	-- Check constructor
	if (_g[class] == nil) return nil
	-- Load object metadata
	local metadata = _g["class_"..class] or {}
	metadata.extend = metadata.extend or "object"
	metadata.private = metadata.private or {}
	add(metadata.private, "_metadata")
	-- Instenciate object and add metadata
	local obj = _g[class](params)
	obj._metadata = metadata
	-- Manage inheritance
	local parent = {}
	if (metadata.extend and class != "object") then
		parent = new(metadata.extend, params)
		parent._global = false -- Disabled global mode to avoid the main object have acces to the global scope with __index (by the proxy of parent object)
		-- Add parent private metadata
		for private in all(parent.self._metadata.private) do
			add(obj._metadata.private, private)
		end
	end
	obj.super = parent
	obj = setmetatable(obj, {__index=parent})
	-- Return object in the proxy
	return proxy(class, obj)
end

function proxy(class, obj)
	-- Create proxy to wrap the object
	return setmetatable(
		{_class=class, self=obj, _global=true}, 
		{
			__index = function(table, key)
				-- If it's private error
				-- To get value use direct access in the object with self
				assert(not contains(table.self._metadata.private, key), "Try to access a private attribute outside the object.")
				-- If it's function add it on the object
				local global = _g[table._class.."_"..key]
				if (table.self[key] == nil and global != nil and type(global) == "function") then
					table.self[key] = global
				end
				-- If not present in wrapped object search in global scope if global mode is activate
				if (table._global and table.self[key] == nil) then
					return _g[key]
				end
				return table.self[key]
			end,
			__newindex = function(table, key, value)
				-- If it's private error
				-- To update value use direct access in the object with self
				assert(not contains(table.self._metadata.private, key), "Try to access a private attribute outside the object.")
				-- Set new value
				if (table.self[key] == nil) then
					a = "ici "..key
					_g[key] = value
				else
					table.self[key] = value
				end
			end
		}
	) 
end

-->8
--object class

function object()
	return {}
end

function object_tostring()
	return "[object]"
end
