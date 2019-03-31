-- file: robotmgr.lua
-- desc:

Import "gas.player.gasplayer"
Import "common.robot.robots"

CRobotMgr = Class("CRobotMgr")

function CRobotMgr:CRobotMgr()
	self.robots = {}
	self.loginInfo = {}
end

function CRobotMgr:Release()
	for rid, robot in pairs(self.robots) do
		robot:Release()
		self.robots[rid] = nil
	end
	self.robots = nil
end

function CRobotMgr:StartRobots()
	LOGIF("Start to activate robots...")
	for robotID, _ in pairs(robots.ROBOTS) do
		self:LoadRobot(robotID)
	end
end

function CRobotMgr:LoadRobot(robotID)
	if self.robots[robotID] then
		LOGWF("LoadRobot| robots[%s]=%s", robotID, self.robots[robotID])
		return false -- 可能正在 load DB, 也可能已经登陆完成
	end
	LOGIF("LoadRobot| robotID=%s", robotID)
	self.robots[robotID] = true
	self.dbsRPC:Gas_LoadRobot(robotID)
end

function CRobotMgr:GetRobotPlayer(robotID)
	local robotPlayer = self.robots[robotID]
	if "table" ~= type(robotPlayer) then
		return nil
	end
	return robotPlayer
end

function CRobotMgr:EnterRoom(robotID, roomID)
end

function CRobotMgr:JoinClub(robotID, clubID)
end

function CRobotMgr:Dbs_OnLoadRobot(dbsID, robotID, robotData)
end