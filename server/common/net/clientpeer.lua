-- file: clientpeer.lua
-- desc: 网络客户端

Import "common.servertick"

local Base = servertick.CServerTick
CClientPeer = Class("CClientPeer", Base)

function CClientPeer:CClientPeer(peerName)
	Base.CServerTick(self)
	self.peerName = peerName
	self.remoteIP = nil
	self.remotePort = nil
	self.netClient = nil
	self.agent = nil				-- 注意: 循环引用
end

function CClientPeer:Release()
	Base.Release(self)
	if self.netClient then
		self:Shutdown()
		self.netClient = nil
	end
	if self.agent then -- 注意: 循环引用
		self.agent = nil
	end
end

function CClientPeer:GetName()
	return self.peerName
end

function CClientPeer:SetAgent(agent)
	self.agent = agent
end

function CClientPeer:GetAgent()
	return self.agent
end

function CClientPeer:Connect(ip, port, inBuffSize, outBuffSize)
	assert(self.peerName ~= nil)
	self.remoteIP = ip
	self.remotePort = port
	if nil == inBuffSize then
		inBuffSize = GetApp():GetConfigMgr():GetMaxInputBuffSize()
	end
	if nil == outBuffSize then
		outBuffSize = GetApp():GetConfigMgr():GetMaxOutputBuffSize()
	end

	if nil == self.netClient then
		self.netClient = SysNetwork.CClientService(self.peerName, inBuffSize, outBuffSize, self)
	end

	local bOK = self.netClient:Connect(ip, port)
	if not bOK then
		LOGEF("CClientPeer| Connect to %s %s:%s failure!", self.peerName, ip, port)
	end
	return bOK
end

function CClientPeer:SendMsg(msgID, msgData)
	self.netClient:SendMsg(msgID, msgData)
end

function CClientPeer:Shutdown()
	self.netClient:Shutdown()
end

function CClientPeer:SetFrameEncryptor(key)
	self.netClient:SetFrameEncryptor(key)
end

function CClientPeer:GetRemoteIPPort()
	return self.netClient:GetRemoteIpPortPair()
end

function CClientPeer:GetLocalIPPort()
	return self.netClient:GetLocalIpPortPair()
end

-------------------------------------------------------------------------------
-- 以下是 C++ 回调
-------------------------------------------------------------------------------
function CClientPeer:OnConnected(connID)
	LOGIF("Connected to server| name=%s, ip=%s, port=%s", self.peerName, self.remoteIP, self.remotePort)
	self.agent:OnConnected()
end

function CClientPeer:OnDisconnect(connID, reason, bRemote)
	LOGIF("Disconnect from server| name=%s, ip=%s, port=%s, reason=%s, bRemote=%s", self.peerName, self.remoteIP, self.remotePort, reason, bRemote)
	self.agent:OnDisconnect(reason, bRemote)
end

function CClientPeer:OnDisconnected(connID, reason, bRemote)
	LOGIF("Disconnected from server| name=%s, ip=%s, port=%s, reason=%s, bRemote=%s", self.peerName, self.remoteIP, self.remotePort, reason, bRemote)
	self.agent:OnDisconnected(reason, bRemote)
end

function CClientPeer:OnConnectFailed(connID, reason)
	LOGIF("Connect to server failure| name=%s, ip=%s, port=%s, reason=%s", self.peerName, self.remoteIP, self.remotePort, reason)
	self.agent:OnConnectFailed(reason)
end

function CClientPeer:OnReceiveMsg(connID, msgID, msgData)
	self.agent:OnReceiveMsg(msgID, msgData)
end

function CClientPeer:OnReceiveData(connID)
end

function CClientPeer:OnSendDataAfter(connID)
end

function CClientPeer:OnBeforeWrite(connID, msgData)
end

function CClientPeer:OnAfterWrite(connID, size)
end

