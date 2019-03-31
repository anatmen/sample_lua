-- file: gacagentmgr.lua
-- desc:

Import "common.agent.agentmgr"

local Base = agentmgr.CAgentMgr
CGacAgentMgr = Class("CGacAgentMgr", Base)

function CGacAgentMgr:CGacAgentMgr(name)
	Base.CAgentMgr(self, name)
end

function CGacAgentMgr:Release()
	Base.Release(self)
end