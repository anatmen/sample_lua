-- file: gacagent.lua
-- desc:

Import "common.net.peer"


local Base = peer.CPeer
CGacAgent = Class("CGacAgent", Base)

function CGacAgent:CGacAgent(mgr, connID)
	Base.CPeer(self, mgr, connID)
	self.gacRPC = nil
	self.gacRPCCls = nil
end

function CGacAgent:Release()
	Base.Release(self)
end

-- 逻辑层回调
function CGacAgent:OnAdd()
end

function CGacAgent:OnDel()
end

function CGacAgent:GetGacRPCCls()
	LOGE("子类需要重载这个接口")
	assert(false)
end

function CGacAgent:SetGacRPCCls(cls)
	self.gacRPCCls = cls
end

function CGacAgent:GetGacRPC()
	if nil == self.gacRPC then
		self.gacRPC = self:GetGacRPCCls()(self:GetConnID())
	end
	return self.gacRPC
end

-- 网络层回调
function CGacAgent:OnConnected()
	Base.OnConnected(self)
end

function CGacAgent:OnDisconnect(reason, bRemote)
end

function CGacAgent:OnDisconnected(reason, bRemote)
end

function CGacAgent:OnConnectFailed(reason)
end

function CGacAgent:OnReceiveMsg(msgID, msgData)
	baserpc.ProcessRPCMsg(msgID, msgData, self)
end

CGacAgent.RPC = {
	Gac_ShakeHand = true,
	Gac_VerifyAccount = true,
	Gac_EnterServer = true,
}

function CGacAgent:Gac_ShakeHand()
	-- 超时不握手就干掉
end