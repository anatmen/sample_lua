
DeleteResult = {}
DeleteResult.__tostringx = function (table_location)
	DeleteResult.__tostring = nil    
	local ret= "<DeleteResult object at " .. tostring(table_location) .. ">"
	DeleteResult.__tostring = DeleteResult.__tostringx
	return ret
end

---
-- Creates a MongoClient instance.
-- Uses MongoDB connection URI (http://docs.mongodb.org/manual/reference/connection-string/).
-- @tparam bool acknowledged Response from server.
-- @tparam string raw_result The response from the server converted into a Lua table.
function DeleteResult.new(acknowledged, raw_result)
	local self = setmetatable({}, DeleteResult)
	self.acknowledged = acknowledged
	self.deleted_count = raw_result['nRemoved']
	self.raw_result = raw_result
	return self
end

---
-- Checks whether the object is an DeleteResult or not.
-- @param object The object to be checked whether it is an DeleteResult.
-- @treturn bool Whether the object is an DeleteResult or not.
function DeleteResult.isDeleteResult(object)
	return getmetatable(object) == DeleteResult
end

DeleteResult.__tostring = DeleteResult.__tostringx    

local metatable = {
	__index = DeleteResult,
	__call = function(table, ...)
		-- table is the same as DeleteResult
		return DeleteResult.new(...)
	end
}

DeleteResult = setmetatable(DeleteResult, metatable)


InsertManyResult = {}
InsertManyResult.__tostringx = function (table_location)
	InsertManyResult.__tostring = nil    
	local ret = "<InsertManyResult object at " .. tostring(table_location) .. ">"
	InsertManyResult.__tostring = InsertManyResult.__tostringx
	return ret
end

---
-- Creates a InsertManyResult instance.
-- @tparam table raw_result Response from MongoDB converted into a Lua table.
-- @tparam {table,...} inserted_ids Array of _ids that were inserted.
function InsertManyResult.new(raw_result, inserted_ids)
	local self = setmetatable({}, InsertManyResult)
	self.raw_result = raw_result
	self.inserted_ids = inserted_ids
	return self
end

---
-- Checks whether the object is an InsertManyResult or not.
-- @param object The object to be checked whether it is an InsertManyResult.
-- @treturn bool Whether the object is an InsertManyResult or not.
function InsertManyResult.isInsertManyResult(object)
	return getmetatable(object) == InsertManyResult
end
InsertManyResult.__tostring = InsertManyResult.__tostringx    
local metatable = {
	__index = InsertManyResult,
	__call = function(table, ...)
		-- table is the same as DeleteResult
		return InsertManyResult.new(...)
	end
}
InsertManyResult = setmetatable(InsertManyResult, metatable)


InsertOneResult = {}
InsertOneResult.__tostringx = function (table_location)
	InsertOneResult.__tostring = nil    
	local ret= "<InsertOneResult object at " .. tostring(table_location) .. ">"
	InsertOneResult.__tostring = InsertOneResult.__tostringx
	return ret
end

---
-- Creates a InsertOneResult instance.
-- @tparam bool acknowledged Whether the insert was acknowledged or not.
-- @param inserted_id The _id of the inserted document.
function InsertOneResult.new(acknowledged, inserted_id)
	local self = setmetatable({}, InsertOneResult)
	self.acknowledged = acknowledged
	self.inserted_id = inserted_id
	return self
end

---
-- Checks whether the object is an InsertOneResult or not.
-- @param object The object to be checked whether it is an InsertOneResult.
-- @treturn bool Whether the object is an InsertOneResult or not.
function InsertOneResult.isInsertOneResult(object)
	return getmetatable(object) == InsertOneResult
end

InsertOneResult.__tostring = InsertOneResult.__tostringx    

local metatable = {
	__index = InsertOneResult,
	__call = function(table, ...)
		-- table is the same as DeleteResult
		return InsertOneResult.new(...)
	end
}
InsertOneResult = setmetatable(InsertOneResult, metatable)

UpdateResult = {}
UpdateResult.__tostringx = function (table_location)
	UpdateResult.__tostring = nil    
	local ret = "<UpdateResult object at " .. tostring(table_location) .. ">"
	UpdateResult.__tostring = UpdateResult.__tostringx
	return ret
end

---
-- Creates an UpdateOneResult instance.
-- @tparam table raw_result The response from the server after an update converted to a Lua table.
function UpdateResult.new(raw_result)
	local self = setmetatable({}, UpdateResult)
	self.matched_count = raw_result.nMatched
	self.modified_count = raw_result.nModified
	self.raw_result = raw_result
	if raw_result.upserted then
		self.upserted_id = raw_result.upserted[1]["_id"]
	end
	return self
end

---
-- Checks whether object is an UpdateResult or not.
-- @param object The object to be checked whether it is an UpdateResult.
-- @treturn bool Whether the object is an UpdateResult or not.
function UpdateResult.isUpdateResult(object)
	return getmetatable(object) == UpdateResult
end

UpdateResult.__tostring = UpdateResult.__tostringx    

local metatable = {
	__index = UpdateResult,
	__call = function(table, ...)
		-- table is the same as DeleteResult
		return UpdateResult.new(...)
	end
}

UpdateResult = setmetatable(UpdateResult, metatable)

AllResultObjects = setmetatable(
	{
		InsertOneResult = InsertOneResult,
		InsertManyResult = InsertManyResult,
		UpdateResult = UpdateResult,
		DeleteResult = DeleteResult
	},

	{
		__index = objects,
		__metatable = false,
		__newindex = function(table, key, value)
			error("resultObjects cannot be modified, it is a read-only table")
		end
	}
)

