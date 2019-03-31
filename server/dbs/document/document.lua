-- File: document.lua
-- Desc:

Import "dbs.document.documentmgr"
Import "dbs.mongorover.BSONObjectDef"

local pairs = pairs
local pcall = pcall
local ipairs = ipairs
local findF = string.find
local typeFunc = type

local RetryExceptionMsg = {
-- 
}

local DateTime = BSONObjectDef.AllBSONObjects.DateTime

CDocument = Class("CDocument")
CDocument.__COLLECTION__ = nil
CDocument.__FIELDS__ = nil
CDocument.__IS_GLOBAL__ = nil
CDocument.__SHARD_INFO__ = nil

-- static method
function CDocument.BuildFields(docCls, fieldTbl)
	docCls.__NAME2FIELDS__ = {}
	docCls.__DB_COLLECTION__ = nil
	docCls.__FIELDS__ = fieldTbl
	
	for name, field in pairs(fieldTbl) do
		field.name = name
		field.docName = docCls.__COLLECTION__
		field.docClsName = docCls.__ClassName__
		--LOGE(field.docName)
	end
	documentmgr.GetDocMgr():AddDoc(docCls)
end

function CDocument:GetCollection()
	if self.__DB_COLLECTION__ == nil then
		if self.__IS_GLOBAL__ then
			self.__DB_COLLECTION__ = GetApp():GetGlobalCollection(self.__COLLECTION__)
		else
			self.__DB_COLLECTION__ = GetApp():GetCollection(self.__COLLECTION__)
		end
	end
	return self.__DB_COLLECTION__
end

function CDocument:CreateDefault()
	local defV = {}
	for name, field in pairs(self.__FIELDS__) do
		defV[name] = field:CreateDefault()
	end
	return defV
end

function CDocument:_Mongo2Lua(val)
	if nil == val then
		return nil
	end
	local result = {}
	for name, v in pairs(val) do
		local f = self.__FIELDS__[name]
		if nil == f then
			if "_id" ~= name then
				LOGEF("Document(%s) doesn't contain field with name(%s)", self.__COLLECTION__, name)
			end
		else
			result[name] = f:Mongo2Lua(v)
		end
	end
	return result
end

function CDocument:_Lua2Mongo(data)
	local result = {}
	for name, val in pairs(data) do
		local field = self.__FIELDS__[name]
		if nil == field then
			LOGEF("Document(%s) doesn't contain field with name(%s)", self.__COLLECTION__, name)
		else
			result[name] = field:Lua2Mongo(val)
		end
	end
	return result
end

function CDocument:TimeStamp2DateTime(timestamp)
	return DateTime.new(timestamp * 1000)
end

-------------------------------------------------------------------------------
-- Mongo 接口封装，名字保持和 mongo 一致
-------------------------------------------------------------------------------
function CDocument:find(query, fields, cursor_params)
	if nil == query or nil == next(query) then
		assert(false, "find| query is invalid")
	end
	-- cursor_params: 可以不填  一个table  default {limit=0, skip=0, batchsize=0}
	return self:RetryQuery(self._find, self, query, fields, cursor_params)
end

function CDocument:find_one(query, fields)
	if nil == query or nil == next(query) then
		assert(false, "find_one| query is invalid")
	end
	return self:RetryQuery(self._find_one, self, query, fields)
end

function CDocument:insert_one(doc, notRetry)
	if notRetry then
		return self:_insert_one(doc)
	else
		return self:RetryQuery(self._insert_one, self, doc)
	end
end

function CDocument:insert_many(docs, ordered, notRetry)
	-- ordered: ???
	if notRetry then
		return self:_insert_many(docs, ordered)
	else
		return self:RetryQuery(self._insert_many, self, docs, ordered)
	end
end

function CDocument:update_one(filter, doc, upsert, notRetry)
	doc = {["$set"] = self:_Lua2Mongo(doc)}
	if notRetry then
		return self:_update_one(filter, doc, upsert)
	else
		return self:RetryQuery(self._update_one, self, filter, doc, upsert)
	end
end

function CDocument:update_many(filter, doc, upsert, notRetry)
	doc = {["$set"] = self:_Lua2Mongo(doc)}
	if notRetry then
		return self:_update_many(filter, doc, upsert)
	else
		return self:RetryQuery(self._update_many, self, filter, doc, upsert)
	end
end

function CDocument:find_and_modify(doc)
	return self:GetCollection():find_and_modify(doc)
end

function CDocument:delete_one(filter, notRetry)
	if notRetry then
		return self:_delete_one(filter)
	else
		return self:RetryQuery(self._delete_one, self, filter)
	end
end

function CDocument:delete_many(filter, notRetry)
	if notRetry then
		return self:_delete_many(filter)
	else
		return self:RetryQuery(self._delete_many, self, filter)
	end
end

function CDocument:aggregate(pipeline, notRetry)
	if notRetry then
		return self:_aggregate(pipeline)
	else
		return self:RetryQuery(self._aggregate, self, pipeline)
	end
end

function CDocument:count(query, skip, limit, notRetry)
	if notRetry then
		return self:_count(query, skip, limit)
	else
		return self:RetryQuery(self._count, self, query, skip, limit)
	end
end

function CDocument.GetInsertedID(insertRet)
	if "table" ~= type(insertRet) then
		return nil
	end
	return insertRet["inserted_id"]
end

function CDocument.GetUpdatedCount(updateRet)
	if "table" ~= type(updateRet) then
		return -1
	end
	return updateRet["modified_count"]
end

function CDocument.GetDeletedCount(delRet)
	if "table" ~= type(delRet) then
		return -1
	end
	return delRet["deleted_count"]
end

-------------------------------------------------------------------------------
-- 真正的查询接口
-------------------------------------------------------------------------------
function CDocument:_find(query, fields, cursor_params)
	-- 
end

function CDocument:_find_one(query, fields)
	if "table" == typeFunc(fields) and #fields > 0 then
		assert(false, "Fields must be hashed table")
	end
	local ret = self:GetCollection():find_one(query, fields)
	if nil == ret then
		return nil
	end
	return self:_Mongo2Lua(ret)
end

function CDocument:_insert_one(doc)
	local ret = self:_Lua2Mongo(doc)
	return self:GetCollection():insert_one(ret)
end

function CDocument:_insert_many(docs, ordered)
	local documents = {}
	for i, d in ipairs(docs) do
		documents[#documents + 1] = self:_Lua2Mongo(d)
	end
	return self:GetCollection():insert_many(documents, ordered)
end

function CDocument:_update_one(filter, doc, upsert)
	return self:GetCollection():update_one(filter, doc, upsert)
end

function CDocument:_update_many(filter, doc, upsert)
	return self:GetCollection():update_many(filter, doc, upsert)
end

function CDocument:_delete_one(filter)
	return self:GetCollection():delete_one(filter)
end

function CDocument:_delete_many(filter)
	return self:GetCollection():delete_many(filter)
end

function CDocument:_aggregate(pipeline)
	return self:GetCollection():aggregate(pipeline)
end

function CDocument:_count(query, skip, limit)
	return self:GetCollection():count(query, skip, limit)
end

function CDocument:RetryQuery(func, ...)
	-- 
end

function CDocument:CheckRetry(exceptMsg)
	for _, msg in pairs(RetryExceptionMsg) do
		if findF(exceptMsg, msg) ~= nil then
			return true
		end
	end
	return false
end
