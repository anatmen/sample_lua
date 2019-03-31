-- file: agentmgr.lua
-- desc: 用于网络服务端, 管理客户端的连接。每一个 agent 代表一个客户端连接

Import "common.net.serverpeer"

local Base = serverpeer.CServerPeer
CAgentMgr = Class("CAgentMgr", Base)

function CAgentMgr:CAgentMgr(name)
	Base.CServerPeer(self, name)
end

function CAgentMgr:OnAgentReady(agent)
	LOGIF("OnAgentReady| connID=%s", agent:GetConnID())
end