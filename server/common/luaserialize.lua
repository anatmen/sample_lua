-- file: luaserialize.lua
-- desc:

local SysSerialize = SysSerialize

-- Serialize是函数
Serialize = SysSerialize.Serialize

function Deserialize(data)
	local script = string.format("local data = %s;return data", data)
	local func, err = ImportStringCode(script)
	if func == nil then
		print("SpecialWarning: Deserialize error",err,script)
		newscript = string.gsub( script, ',name=""""",', ",name='\"\"\"'," )
		func, err = ImportStringCode( newscript )
		print( "newscript", newscript  )
	end
	return func()
end
