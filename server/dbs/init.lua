-- file: init.lua
-- desc: 脚本入口, C++ 调进来

local function entry()
	gcmgr.InitGCParams()

	Import "dbs.dbsapp"
	RegGlobalObj("GetApp", dbsapp.GetApp)

	local bOK = GetApp():Start()
	if not bOK then
		assert(false)
	end
end

SysLoader.LoadStartScript("server/common/preload.lua")
local status, msg = xpcall(entry, __TRACKBACK__)
if not status then
	LOGE(msg)
end
