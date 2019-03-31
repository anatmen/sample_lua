-- file: gasconst.lua
-- desc:

GAC_STATE = enum.Enum("GAC_STATE")
GAC_STATE.OutWorld			= 1
GAC_STATE.EnteringWorld		= 2
GAC_STATE.InWorld			= 3
GAC_STATE.WaitDisconnect	= 4
GAC_STATE.WaitReconnect		= 5

VERIFY_CODE = enum.Enum("VERIFY_CODE")
VERIFY_CODE.OK				= 1
VERIFY_CODE.NO_AGNET		= 2
VERIFY_CODE.NO_TOKENINFO	= 3		-- 没人验证信息
VERIFY_CODE.NEED_PEND		= 4		-- 人数满, 需要排队
VERIFY_CODE.TOKEN_MISMATCH	= 5
VERIFY_CODE.TIMEOUT			= 6
VERIFY_CODE.UNKNOWN			= 7