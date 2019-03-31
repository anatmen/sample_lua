-- file: gameadmin.lua
-- desc: 游戏管理

Import "common.serverconst"
Import "common.md5"
Import "common.robot.robots"

CGameAdmin = Class("CGameAdmin")

function CGameAdmin:CGameAdmin()
	self.gms = {}		-- {account: {prividge, clubs, pass}}
	self.dbsRPC = nil
end

function CGameAdmin:Release()
	GetApp():DelTick(self.LoadGameAdmins)
	self.gms = nil
	self.dbsRPC = nil
end

function CGameAdmin:InitGameAdmin()
	LOGIF("InitGameAdmin")
	GetApp():RegTick(self.LoadGameAdmins, self, 3000, 1)
end

function CGameAdmin:LoadGameAdmins()
	self.dbsRPC = svr2dbsrpc.CSvr2DbsGameAdminQuery(GetApp():GetAgentMgr():RandomPickSvrIDByType(serverconst.SERVER_TYPE.DBS))
	self.dbsRPC:Svr_LoadGameAdmins()
end

function CGameAdmin:Dbs_OnLoadGameAdmins(svrID, gms)
	LOGIF("Dbs_OnLoadGameAdmins| gms=%s, empty=%s", gms, nil == next(gms))
	if nil ~= next(gms) then
		self.gms = gms
	end
end

function CGameAdmin:UpdateGameAdmin(account)
	local auth = self.gms[account]
	if auth then
		if auth[2] == nil and auth[1] == serverconst.GM_PRIVILEGE.CLUB_ADMIN then
			self.dbsRPC:Svr_DelGameAdmin(account)
			self.gms[account] = nil
		else
			self.dbsRPC:Svr_UpdateGameAdmin(account, auth)
		end
	else
		self.dbsRPC:Svr_DelGameAdmin(account)
		self.gms[account] = nil
	end
end

function CGameAdmin:AuthDev(account)
	return false
end

function CGameAdmin:GetGMPrivilege(account)
	local auth = self.gms[account]
	if nil == auth then
		return serverconst.GM_PRIVILEGE.NIL
	end
	return auth[1]
end

function CGameAdmin:AuthRoot(account)
	return serverconst.GM_PRIVILEGE.ROOT == self:GetGMPrivilege(account)
end

function CGameAdmin:AuthGameAdmin(account)
	return serverconst.GM_PRIVILEGE.GAME_ADMIN == self:GetGMPrivilege(account)
end

function CGameAdmin:AuthGM(account, pass, nonce)
	-- 
end

function CGameAdmin:CanPlayerCheat(playerID)
	local player = GetApp():GetPlayerByID(playerID)
	if not player then
		return false
	end
	return player:GetRoom() ~= nil
end

function CGameAdmin:GrantGameAdmin(account, target)
	-- 
end

function CGameAdmin:RevokeGameAdmin(account, target)
	-- 
end

function CGameAdmin:GrantClubAdmin(account, target, clubID)
end

function CGameAdmin:RevokeClubAdmin(account, target, clubID)
end

local gGameAdmin = nil
function GetGM()
	if nil == gGameAdmin then
		gGameAdmin = CGameAdmin()
	end
	return gGameAdmin
end