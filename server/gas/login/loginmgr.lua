-- file: loginmgr.lua
-- desc:

Import "gas.login.logindata"
Import "gas.player.gasplayer"


CLoginMgr = Class("CLoginMgr")

function CLoginMgr:CLoginMgr()
	self.loginingGac = {}
	self.wait2SaveGac = {}
end

function CLoginMgr:Release()
	self.loginingGac = nil
	self.wait2SaveGac = nil
	self.loginQueryRPC = nil
end

function CLoginMgr:GetLoginData(connID)
	return self.loginingGac[connID]
end

function CLoginMgr:AddLoginData(connID, loginData)
	self.loginingGac[connID] = loginData
end

function CLoginMgr:DelLoginData(connID)
	self.loginingGac[connID] = nil
end

function CLoginMgr:Login(connID, gacIP, account, loginInfo)
	
end

function CLoginMgr:StartLoginByAccount(connID, gacIP, account, loginInfo)
	
end

function CLoginMgr:Dbs_OnLoadPlayerByAccount(dbsID, connID, account, playerData)
	
end

function CLoginMgr:OnLoginOK(connID, account, playerData)
end

function CLoginMgr:OnLoginFail(connID, playerID, reason)
	LOGWF("OnLoginFail| connID=%s, playerID=%s, reason=%s", connID, playerID, reason)
end