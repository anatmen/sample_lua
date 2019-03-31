-- file: svragent.lua
-- desc: 服务器之间的 agent, 用于标识一个客户端
-- 说明：
-- agent 有两种
-- 1. 运行于网络服务端, 代表到客户端的连接, 这种称为被动 agent (passive)
-- 2. 运行于网络客户端, 代表到服务端的连接, 这种称为主动 agent (active)

Import "common.net.peer"
Import "common.net.clientpeer"

local Base = peer.CPeer
CSvrAgent = Class("CSvrAgent", Base)

function CSvrAgent:CSvrAgent(mgr, connID)
	Base.CPeer(self, mgr, connID)
	self.svrType = nil			-- 握手后才知道
	self.svrID = 0				-- active - 主动设置, passive - 等待握手成功设置
	self.name = ""
	self.clientPeer = nil		-- 仅用于 active 主动连接服务器时
	self.svrAgentRPC = nil
end

function CSvrAgent:Release()
	if self.clientPeer ~= nil then
		self.clientPeer:Release()
		self.clientPeer = nil
	end
	Base.Release(self)
end

function CSvrAgent:GetSvrType()
	return self.svrType
end

function CSvrAgent:GetSvrID()
	return self.svrID
end

function CSvrAgent:SetSvrID(svrID)
	self.svrID = svrID
end

function CSvrAgent:GetName()
	return self.name
end

function CSvrAgent:SetName(name)
	self.name = name
end

function CSvrAgent:IsActive()
	return 0 == self.connID
end

function CSvrAgent:GetRemoteIPPort()
	if self:IsActive() then
		return self.clientPeer:GetRemoteIPPort()
	else
		return self:GetMgr():GetRemoteIPPort(self:GetConnID())
	end
end

function CSvrAgent:GetLocalIPPort()
	if self:IsActive() then
		return self.clientPeer:GetLocalIPPort()
	else
		return self:GetMgr():GetLocalIPPort()
	end
end

function CSvrAgent:OnAdd()
end

function CSvrAgent:OnDel()
end

function CSvrAgent:Connect(svrID, name, ip, port, inBuffSize, outBuffSize)
	-- 用于作为客户端主动连接服务器时
	assert(nil == self.clientPeer)
	self:SetSvrID(svrID)
	self:SetName(name)
	self.clientPeer = clientpeer.CClientPeer(name)
	self.clientPeer:SetAgent(self)
	return self.clientPeer:Connect(ip, port, inBuffSize, outBuffSize)
end

function CSvrAgent:GetAgentRPC()
	if nil == self.svrAgentRPC then
		self.svrAgentRPC = svragentrpc.CSvrAgentRPC(self:GetSvrID())
	end
	return self.svrAgentRPC
end

function CSvrAgent:SendMsg(msgID, msgData)
	if 0 == self.connID then
		self.clientPeer:SendMsg(msgID, msgData)
	else
		self.mgr:SendMsg(self.connID, msgID, msgData)
	end
end

function CSvrAgent:NotifyStateChanged(state)
	self:GetAgentRPC():Svr_UpdateState(state)
	self:GetMgr():AddNotifySvrID(self:GetSvrID(), state)
end

-- 逻辑层回调
function CSvrAgent:OnAdd()
end

function CSvrAgent:OnDel()
end

-- 网络层回调
function CSvrAgent:OnConnected()
	Base.OnConnected(self)
	if self:IsActive() then
		self.mgr:OnConnectedToServer(self)
		self:GetAgentRPC():Svr_ShakeHand(GetApp():GetSvrType(), GetApp():GetSvrID(), GetApp():GetName())
	end
end

function CSvrAgent:OnDisconnect(reason, bRemote)
	if self:IsActive() then
		self.mgr:OnDisconnectFromServer(self, reason, bRemote)
	end
end

function CSvrAgent:OnDisconnected(reason, bRemote)
	if self:IsActive() then
		self.mgr:OnDisconnectedFromServer(self, reason, bRemote)
	end
end

function CSvrAgent:OnConnectFailed(reason)
	if self:IsActive() then
		self.mgr:OnConnectFailedToServer(self, reason)
	end
end

function CSvrAgent:OnReceiveMsg(msgID, msgData)
	baserpc.ProcessRPCMsg(msgID, msgData, self)
end

function CSvrAgent:Svr_ShakeHand(_, svrType, svrID, name)
	-- ...
end

function CSvrAgent:Svr_UpdateState(svrID, state)
	self:GetMgr():OnSvrUpdateState(self, state)
end

function CSvrAgent:Svr_UpdateConfig(svrID, config)
	self:GetMgr():OnSvrUpdateConfig(self, config)
end

function CSvrAgent:Svr_OnAddServer(svrID, name, config)
	self:GetMgr():OnAddServer(name, config)
end

function CSvrAgent:Svr_GMCmd(svrID, msgID, cmd, args)
	local code, ret = GetApp():GetGMCmdMgr():TryExecCmd(cmd, args)
	self:GetAgentRPC():Svr_OnGMResult(msgID, cmd, code, ret)
end

function CSvrAgent:Svr_OnGMResult(svrID, msgID, cmd, code, ret)
end