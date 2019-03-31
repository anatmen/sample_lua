-- File: documentmgr.lua
-- Desc:

Import "dbs.document.table2js"

CDocMgr = Class("CDocMgr", CSingleton)

function CDocMgr:Init()
	self.globalDocs = {}
	self.gameDocs = {}
end

function CDocMgr:AddDoc(doc)
	local docs = nil
	if doc.__IS_GLOBAL__ then
		docs = self.globalDocs
	else
		docs = self.gameDocs
	end
	assert(docs[doc.__COLLECTION__] == nil, string.format("Duplicated collection name: %s", doc.__COLLECTION__))
	docs[doc.__COLLECTION__] = self:BuildDocMeta(doc)
end

function CDocMgr:BuildDocMeta(doc)
	local tbl = {}
	tbl.name = doc.__COLLECTION__
	tbl.index = {}
	tbl.uniqueindex = {}
	tbl.hashed = nil
	tbl.shard = doc.__SHARDINFO__
	for name, field in pairs(doc.__FIELDS__) do
		if field.index then
			table.insert(tbl.index, name)
		end
		if field.uniqueindex then
			table.insert(tbl.uniqueindex, name)
		end
		if field.hashed then
			if tbl.hashed == nil then
				tbl.hashed = {}
			end
			tbl.hashed[name] = true
			assert(field.index, string.format("Collection field cannot has 'hashed' without 'index', field: %s", name))
		end
	end
	if 0 == #tbl.index then
		tbl.index = nil
	end
	if 0 == #tbl.uniqueindex then
		tbl.uniqueindex = nil
	end
	return tbl
end

function CDocMgr:SaveMeta()
	LOGIF("Save meta")
	-- 
	LOGIF("Save meta done!")
end

local gDocMgr = nil
function GetDocMgr()
	if gDocMgr == nil then
		gDocMgr = CDocMgr()
		gDocMgr:Init()
	end
	return gDocMgr
end