-- file: appbase.lua
-- desc: 服务端 app 基类

Import "common.uuid"
Import "common.servertick"
Import "common.serverconfigmgr"
Import "common.agent.serveragentmgr"
Import "common.gm.gmcmdmgr"
Import "common.http.httpmgr"

local funcAdvanceGC = SysLuaEngine.AdvanceGC

CAppBase = Class("CAppBase")

function CAppBase:CAppBase(svrType)
	self.svrType = svrType
	self.tickObj = servertick.CServerTick()
	self.configMgr = nil
	self.config = nil
	self.uuid = uuid.CUUID()
	self.uuid:Init(self:GetSvrID())
	self.state = serverconst.SERVER_STATE.UP
	self.agentMgr = self:GetAgentMgrCls()(string.format("%sAgentMgr", self:GetName()))
	self.gmCmdMgr = nil
	self.httpMgr = nil
end

function CAppBase:Release()
	if self.tickObj then
		self.tickObj:Release()
		self.tickObj = nil
	end
	self.agentMgr:Release()
	self.agentMgr = nil
	if self.configMgr then
		self.configMgr:Release()
		self.configMgr = nil
	end
	self.config = nil -- 不要 Release
	if self.uuid then
		self.uuid:Release()
		self.uuid = nil
	end
	self.state = serverconst.SERVER_STATE.DOWN
	if self.gmCmdMgr then
		self.gmCmdMgr:Release()
		self.gmCmdMgr = nil
	end
end

function CAppBase:GetName()
	return self:GetConfigMgr():GetName()
end

function CAppBase:GetSvrType()
	return self.svrType
end

function CAppBase:IsCentralSvr(svrType)
	if nil == svrType then
		svrType = self:GetSvrType()
	end
	return serverconst.SERVER_TYPE.GCC == svrType
end

function CAppBase:GetConfigMgr()
	if not self.configMgr then
		self.configMgr = serverconfigmgr.CServerConfigMgr()
		self.configMgr:Init()
	end
	return self.configMgr
end

function CAppBase:GetConfig()
	if nil == self.config then
		self.config = self:GetConfigMgr():GetConfigByName(self:GetName())
	end
	return self.config
end

function CAppBase:GetSvrID()
	return self:GetConfig()["ServerId"]
end

function CAppBase:GetFrameRate()
	return self:GetConfigMgr():GetFrameRate()
end

function CAppBase:GetState()
	return self.state
end

function CAppBase:SetState(state)
	local oldState = self.state
	self.state = state
	self:OnStateChanged(oldState)
end

function CAppBase:IsInService()
	return serverconst.SERVER_STATE.IN_SERVICE == self:GetState()
end

function CAppBase:GetAgentMgrCls()
	return serveragentmgr.CServerAgentMgr
end

function CAppBase:GetAgentMgr()
	return self.agentMgr
end

function CAppBase:GetSvrRPC(svrID)
	local agent = self:GetAgentMgr():GetAgent(svrID)
	if agent then
		return agent:GetAgentRPC()
	end
end

function CAppBase:GetGMCmdMgr()
	if nil == self.gmCmdMgr then
		self.gmCmdMgr = gmcmdmgr.CGMCmdMgr()
	end
	return self.gmCmdMgr
end

function CAppBase:GetHttpMgr()
	if self.httpMgr then
		return self.httpMgr
	end

	self.httpMgr = httpmgr.CHttpMgr()
	self.httpMgr:Init()
	return self.httpMgr
end

function CAppBase:RegTick(callback, args, interval, count)
	return self.tickObj:RegTick(callback, args, interval, count)
end

function CAppBase:DelTick(callback)
	self.tickObj:DelTick(callback)
end

function CAppBase:DelAllTick()
	self.tickObj:DelAllTick()
end

function CAppBase:Start()
	if SysGameFrame then
		SysGameFrame.SetFrameRate(self:GetFrameRate())
	end

	local config = self:GetConfig()
	local ip = config["IP"]
	local port = config["Port"]
	local name = self:GetName()
	if not self.agentMgr:BeginService(ip, port) then
		LOGEF("%s begin service fail on %s:%s", name, ip, port)
		return false
	end

	if not self:IsCentralSvr() then -- 不是 GCC 则连接到 GCC
		local centerName = "gcc"
		local gccCfg = self:GetConfigMgr():GetConfigByName(centerName)
		self.agentMgr:Connect(gccCfg["ServerId"], centerName, gccCfg["IP"], gccCfg["Port"])
	end

	math.randomseed(os.time() + self:GetSvrID() * 10000)
	LOGIF("%s started on %s:%s", name, ip, port)
	return true
end

function CAppBase:Stop()
	LOGIF("%s stop", self:GetName())
end

function CAppBase:OnStateChanged(oldState)
	local STATE = serverconst.SERVER_STATE
	LOGIF("OnStateChanged| %s => %s", STATE:Val2Key(oldState), STATE:Val2Key(self:GetState()))
	self:GetAgentMgr():BroadcastState(self:GetState())
end

function CAppBase:OnInService()
	LOGIF("%s is ready to server, my lord", self:GetName())
	self:SetState(serverconst.SERVER_STATE.IN_SERVICE)
end

function CAppBase:OnOutOfService()
	LOGIF("%s is out of service, my lord", self:GetName())
	self:SetState(serverconst.SERVER_STATE.OUT_OF_SERVICE)
end

function CAppBase:OnSvrUpdateState(svrType, svrID, name, state)
	LOGIF("OnSvrUpdateState| svrType=%s, svrID=%s, name=%s, state=%s", svrType, svrID, name, serverconst.SERVER_STATE:Val2Key(state))
end

function CAppBase:OnSvrUpdateConfig(svrID, name, config)
	-- 
end

function CAppBase:OnAddServer(name, config)
	-- 
end
