-- file: servertick.lua
-- desc:

local SysTick = SysTick

CServerTick = Class("CServerTick", basetick.CBaseTick)

function CServerTick:CServerTick()
	basetick.CBaseTick.CBaseTick(self)
end

function CServerTick:RegEngineTick(interval, count)
	return SysTick.RegTick(interval, count)
end

function CServerTick:UnRegEngineTick(tickID)
	SysTick.DelTick(tickID)
end

function GetTickClass()
	return CServerTick
end
