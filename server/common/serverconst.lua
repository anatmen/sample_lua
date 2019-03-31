-- file: serverconst.lua
-- desc: 服务器常量配置

Import "globalcommon.util.enum"

-- 选服策略
SELECT_SERVER_POLICY = {}
SELECT_SERVER_POLICY.DEAULT = 1					-- 默认选服策略
SELECT_SERVER_POLICY.EVEN_LOAD = 2				-- 均匀选择

-- 服务器类型
SERVER_TYPE = enum.Enum("SERVER_TYPE", true)

-- 服务器状态
SERVER_STATE = enum.Enum("SERVER_STATE")
SERVER_STATE.UP = 1
SERVER_STATE.IN_SERVICE = 2
SERVER_STATE.OUT_OF_SERVICE = 3
SERVER_STATE.DOWN = 4

GM_TIMEOUT = 5		-- GM 超时时间，单位秒

GMCODE = enum.Enum("GMCODE")
GMCODE.OK					= 0
GMCODE.AUTH_FAIL			= 1
GMCODE.INVALID_PARAMS		= 2
GMCODE.CMD_NOT_FOUND		= 3
GMCODE.NOT_AUTHORIZED		= 4
GMCODE.EXEC_ERROR			= 5
GMCODE.PARTIAL_RESULT		= 6
GMCODE.TIMEOUT				= 7

-- 微信渠道 appID


function GetWXAppConfig(appChannel)
	if appChannel then
		return WX_APP[appChannel]
	else
		return WX_APP[const.APP_CHANNEL.RYDS]
	end
end

-- GM 管理权限
GM_PRIVILEGE = enum.Enum("GM_PRIVILEGE")
GM_PRIVILEGE.DEV = 0				-- 开发
GM_PRIVILEGE.ROOT = 1				-- 超级管理员
GM_PRIVILEGE.GAME_ADMIN = 10		-- 游戏管理
GM_PRIVILEGE.CLUB_ADMIN = 100		-- 俱乐部管理员
GM_PRIVILEGE.NIL = 999999			-- 非 GM 人员

CLUB_ROOM_LISTENER_EXPIRED_TIME = 10 * 60

-- 开发账号
DEV_ACCOUNTS = {
}
