-- file: peer.lua
-- desc: 对远端(remote-end)的封装

CPeer = Class("CPeer")

function CPeer:CPeer(mgr, connID)
	self.mgr = mgr
	self.connID = connID		-- 可能为 0, 0 表示作为客户端主动连接服务器
end

function CPeer:Release()
	self.mgr = nil
	self.connID = nil
end

function CPeer:GetConnID()
	return self.connID
end

function CPeer:GetMgr()
	return self.mgr
end

function CPeer:IsActive()
	return 0 == self.connID
end

function CPeer:IsPassive()
	-- 主动 peer - 客户端
	-- 被动 peer - 服务端中的每一个 agent
	return not self:IsActive()
end

-- 网络层回调
function CPeer:OnConnected()
end

function CPeer:OnDisconnect(reason, bRemote)
end

function CPeer:OnDisconnected(reason, bRemote)
end

function CPeer:OnConnectFailed(reason)
end

function CPeer:OnReceiveMsg(msgID, msgData)
end