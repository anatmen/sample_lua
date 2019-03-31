-- file: serverpeer.lua
-- desc: 网络服务端
-- 说明:
-- peer - 网络层对远端的称呼
-- agent - 逻辑层对远端的称呼

Import "common.agent.svragent"
Import "common.servertick"

local Base = servertick.CServerTick
CServerPeer = Class("CServerPeer", Base)

function CServerPeer:CServerPeer(peerName)
	Base.CServerTick(self)
	self.peerName = peerName
	self.netServer = nil
	self.peerCls = nil
	self.connID2Peer = {}
end

function CServerPeer:Release()
	local funcDelPeer = self.DelPeer
	for _, agent in pairs(self.connID2Peer) do
		funcDelPeer(self, agent)
	end
	self.connID2Peer = nil
	self:EndService()
	Base.Release(self)
end

function CServerPeer:GetPeerCls()
	if nil == self.peerCls then
		self.peerCls = svragent.CSvrAgent -- 默认的 peer 类
	end
	return self.peerCls
end

function CServerPeer:SetPeerCls(cls)
	self.peerCls = cls
end

function CServerPeer:GetPeer(connID)
	return self.connID2Peer[connID]
end

function CServerPeer:GetAllPeers()
	return self.connID2Peer
end

function CServerPeer:AddPeer(peer)
	self.connID2Peer[peer:GetConnID()] = peer
end

function CServerPeer:DelPeer(peer)
	local connID = peer:GetConnID()
	peer:Release()
	self.netServer:ShutdownClient(connID)
	self.connID2Peer[connID] = nil
end

function CServerPeer:BeginService(ip, port, inBuffSize, outBuffSize)
	assert(self.peerName ~= nil)
	if nil == inBuffSize then
		inBuffSize = GetApp():GetConfigMgr():GetMaxInputBuffSize()
	end
	if nil == outBuffSize then
		outBuffSize = GetApp():GetConfigMgr():GetMaxOutputBuffSize()
	end
	self.netServer = SysNetwork.CServerService(self.peerName, inBuffSize, outBuffSize, self)
	return self.netServer:BeginService(ip, port)
end

function CServerPeer:EndService()
	return self.netServer:EndService()
end

function CServerPeer:GetRemoteIPPort(connID)
	if self.netServer and connID then
		return self.netServer:GetRemoteIpPortPair(connID)
	end
	return nil
end

function CServerPeer:GetLocalIPPort(connID)
	if self.netServer and connID then
		return self.netServer:GetLocalIpPortPair(connID)
	end
	return nil
end

function CServerPeer:SendMsg(connID, msgID, msgData)
	self.netServer:SendMsg(connID, msgID, msgData)
end

function CServerPeer:SendMsgToAll(msgID, msgData)
	self.netServer:SendMsgToAll(msgID, msgData)
end

function CServerPeer:ShutdownClient(connID)
	local peer = self:GetPeer(connID)
	if peer then
		self:DelPeer(peer)
	end
end

function CServerPeer:ShutdownAllClient()
	self.netServer:ShutdownAllClient()
end

function CServerPeer:GetConnectionNum()
	return self.netServer:GetConnectionNum()
end

function CServerPeer:IsValidConnection(connID)
	return self.netServer:IsValidConnection(connID)
end

function CServerPeer:SetFrameEncryptor(connID, key)
	return self.netServer:SetFrameEncryptor(connID, key)
end

-------------------------------------------------------------------------------
-- 以下是 C++ 回调
-------------------------------------------------------------------------------
function CServerPeer:OnConnected(connID)
	LOGIF("New Client connected| connection ID: %d", connID)
	local peerCls = self:GetPeerCls()
	local peer = peerCls(self, connID)
	peer:OnConnected()
	self:AddPeer(peer)
end

function CServerPeer:OnDisconnect(connID, reason, bRemote)
	local peer = self:GetPeer(connID)
	if peer then
		peer:OnDisconnect(reason, bRemote)
	end
end

function CServerPeer:OnDisconnected(connID, reason, bRemote)
	local peer = self:GetPeer(connID)
	if peer then
		peer:OnDisconnected(reason, bRemote)
	end
end

function CServerPeer:OnConnectFailed(connID, reason)
	local peer = self:GetPeer(connID)
	if peer then
		peer:OnConnectFailed(reason)
	end
end

function CServerPeer:OnReceiveMsg(connID, msgID, msgData)
	local peer = self:GetPeer(connID)
	if peer then
		peer:OnReceiveMsg(msgID, msgData)
	end
end

function CServerPeer:OnReceiveData(connID)
end

function CServerPeer:OnSendDataAfter(connID)
end

function CServerPeer:OnBeforeWrite(connID, msgData)
end

function CServerPeer:OnAfterWrite(connID, size)
end
