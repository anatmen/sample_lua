-- file: preload.lua
-- desc: 预加载的脚本

function preloadModule()
end

function RegScriptExts(exts)
	local addFunc = SysLoader.AddScriptExtension
	for _, ext in pairs(exts) do
		addFunc(ext)
	end
end

function AddSearchPaths(paths)
	local addFunc = SysLoader.AddSearchPath
	for _, path in pairs(paths) do
		addFunc(path)
	end
end

function DoPreload()
	local exts = {
		".lua",
		".luac",
	}
	RegScriptExts(exts)

	local paths = {
		".",
		-- "globalcommon",
		"server",
	}
	AddSearchPaths(paths)

	local files = {
		"globalcommon/traceback.lua",
		"globalcommon/module.lua",
		"globalcommon/class.lua",
	}
	for _, file in pairs(files) do
		SysLoader.LoadStartScript(file)
	end

	Import "globalcommon.gcmgr"
	Import "common.gameframemgr"
	if SysGameFrame then -- 子线程没有 SysGameFrame 模块
		SysGameFrame.InitFrameScriptHandle(gameframemgr.OnEngineScriptUpdate)
	end

	preloadModule() -- 预加载公共模块模块
	RegGlobalObj("cjson", SysCJson)
	DisableGlobalENVWrite()
end

-- 脚本层屏蔽 dofile/loadfile/loadstring/load 接口
function dofile()
end

function loadfile()
end

function loadstring()
end

function load()
end

-- 这里有点 ugly, 先这样吧
DoPreload()
