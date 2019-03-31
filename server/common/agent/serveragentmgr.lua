-- file: serveragentmgr.lua
-- desc: 其它所有服务器的 agent 管理器
-- 说明:
-- 服务之间的连接, 主动连接方发起第一条握手 RPC, 告知对方自己的身份

Import "common.agent.agentmgr"
Import "common.agent.svragent"

local Base = agentmgr.CAgentMgr
CServerAgentMgr = Class("CServerAgentMgr", Base)

function CServerAgentMgr:CServerAgentMgr(name)
	Base.CAgentMgr(self, name)
	self.svrID2Agent = {}			-- {svrID: agent}
	self.svrInService = {}			-- {svrID: state}
	self.notifiedSvrIDs = {}		-- {svrID: true}					-- 已经告知对方自己的状态
	self.svrID2Config = {}			-- {svrID: {name, config}}			-- 中心服才有这个
	self.svrType2SvrIDs = {}		-- {svrType: {svrID1, svrID2...}}
end

function CServerAgentMgr:Release()
	self.svrID2Agent = nil
	self.svrInService = nil
	self.svrID2Config = nil
	self.svrType2SvrIDs = nil
end

function CServerAgentMgr:AddAgent(agent)
	agent:OnAdd()
	self.svrID2Agent[agent:GetSvrID()] = agent
end

function CServerAgentMgr:DelAgent(agent)
	local svrID = agent:GetSvrID()
	self.svrID2Agent[svrID] = nil
	self:DelNotifiedSvrID(svrID)
	self.svrInService[svrID] = nil
	self.svrID2Config[svrID] = nil
	-- self.svrType2SvrIDs
	Base.DelAgent(self, agent)
end

function CServerAgentMgr:GetAgent(svrID)
	return self.svrID2Agent[svrID]
end

function CServerAgentMgr:AddNotifySvrID(svrID, state)
	self.notifiedSvrIDs[svrID] = state
end

function CServerAgentMgr:DelNotifiedSvrID(svrID)
	self.notifiedSvrIDs[svrID] = nil
end

function CServerAgentMgr:GetAllSvrIDs()
	return self.svrID2Agent
end

function CServerAgentMgr:GetAllSvrIDsByType(svrType)
	return self.svrType2SvrIDs[svrType]
end

function CServerAgentMgr:RandomPickSvrIDByType(svrType)
	local svrIDs = self:GetAllSvrIDsByType(svrType)
	if svrIDs and next(svrIDs) then
		local idx = math.random(#svrIDs)
		return svrIDs[idx]
	end
	return nil
end

function CServerAgentMgr:GetInServiceSvrIDs()
	return self.svrInService
end

function CServerAgentMgr:SendMsgBySvrID(svrID, rpcID, rpcData)
	local agent = self.svrID2Agent[svrID]
	agent:SendMsg(rpcID, rpcData)
end

function CServerAgentMgr:Connect(svrID, name, ip, port, inBuffSize, outBuffSize)
	local peerCls = self:GetPeerCls()
	local agent = peerCls(self, 0)
	agent:Connect(svrID, name, ip, port, inBuffSize, outBuffSize)
end

function CServerAgentMgr:BroadcastState(state)
	for svrID, agent in pairs(self.svrID2Agent) do
		if self.notifiedSvrIDs[svrID] ~= state then
			agent:NotifyStateChanged(state)
		end
	end
end

function CServerAgentMgr:SyncAllSvrConfigs(agent)
	local rpc = agent:GetAgentRPC()
	for _, config in pairs(self.svrID2Config) do
		rpc:Svr_OnAddServer(config[1], config[2])
	end
end

-- 主动 agent 的逻辑回调
function CServerAgentMgr:OnConnectedToServer(agent)
	self:AddAgent(agent)
end

function CServerAgentMgr:OnDisconnectFromServer(agent, reason, bRemote)
end

function CServerAgentMgr:OnDisconnectedFromServer(agent, reason, bRemote)
end

function CServerAgentMgr:OnConnectFailedToServer(agent, reason)
end

function CServerAgentMgr:OnReceiveMsgFromServer(agent, msgID, msgData)
end

function CServerAgentMgr:OnSvrUpdateState(agent, state)
	-- ...
end

function CServerAgentMgr:OnSvrUpdateConfig(agent, config)
	GetApp():OnSvrUpdateConfig(agent:GetSvrID(), agent:GetName(), config)
	self.svrID2Config[agent:GetSvrID()] = {agent:GetName(), config}
end

function CServerAgentMgr:OnAddServer(name, config)
	GetApp():OnAddServer(name, config)
end
