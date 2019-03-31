-- file: logindata.lua
-- desc:

CLoginData = Class("CLoginData")

function CLoginData:CLoginData(connID, gacIP, account, loginInfo)
	self.connID = connID
	self.gacIP = gacIP
	self.account = account
	self.loginInfo = loginInfo
end

function CLoginData:Release()
	self.connID = nil
	self.gacIP = nil
	self.account = nil
	self.loginInfo = nil
end

