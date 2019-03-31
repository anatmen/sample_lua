-- file: gmcmd.lua
-- desc: GM 命令定义

Import "globalcommon.traceback"

CGMCmdMgr = Class("CGMCmdMgr")

function CGMCmdMgr:CGMCmdMgr()
end

function CGMCmdMgr:TryExecCmd(cmd, args)
	local func = self[cmd]
	if nil == func then
		return serverconst.GMCODE.CMD_NOT_FOUND, "Cmd Not found"
	end
	local params = {self, table.unpack(args)}
	local bOK, errMsg = xpcall(func, traceback.__PRINT_TRACKBACK__, table.unpack(params))
	if bOK == nil then
		bOK = true
	end
	if not bOK then
		return serverconst.GMCODE.EXEC_ERROR, errMsg
	end
	return serverconst.GMCODE.OK, errMsg
end

function CGMCmdMgr:GMTest(a, b, c)
	print("GMTest", a, b, c)
end