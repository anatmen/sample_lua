-- file: uuid.lua
-- desc: 创建唯一的 UUID

CUUID = Class("CUUID")

function CUUID:CUUID()
	self._svrID = 0				-- 15 bit
	self._idxWithinSec = 0		-- 17 bit
	self._time = 0				-- 32 bit
end

function CUUID:Init(svrID)
	self._svrID = svrID
end

function CUUID:GenUUID()
	local curTime = GetUTCTimeInSec()
	if curTime > self._time then
		self._time = curTime
		self._idxWithinSec = 0
	elseif 0x1FFFF == self._idxWithinSec then
		-- 同一秒内的 17 bit 全部用完了，占用下一秒的吧
		self._time = self._time + 1
		self._idxWithinSec = 0
	else
		self._idxWithinSec = self._idxWithinSec + 1
	end

	local uuid = 0
	uuid = uuid | (self._time << 32)
	uuid = uuid | (self._svrID << 17)
	uuid = uuid | self._idxWithinSec
	return uuid
end

