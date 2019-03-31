
BSONNull = {}
BSONNull.__index = BSONNull

function BSONNull:__tostring()
	return "BSONNull"
end

function BSONNull:__eq(a, b)
	return BSONNull.isBSonNull(a) and BSONNull.isBSonNull(b)
end

---
-- Creates a MongoClient instance.
-- uses MongoDB connection URI (http://docs.mongodb.org/manual/reference/connection-string/).
-- @param db_uri The MongoDB connection URI.
function BSONNull.new()
	local self = setmetatable({}, BSONNull)
	return self
end

---
-- Checks whether the object is a BSONNull object or not.
-- @param object The object to be checked whether it is an BSONNull.
-- @treturn bool Whether the object is an BSONNull or not.
function BSONNull.isBSONNull(object)
	return getmetatable(object) == BSONNull
end


DateTime = {}
DateTime.__index = DateTime
function DateTime:__tostring()
	return string.format("DateTime(%s, )", self.utc_milliseconds)
end

function DateTime.new(utc_milliseconds )
	local self = setmetatable({}, DateTime)
	self.utc_milliseconds = utc_milliseconds
	return self
end

function DateTime.isDateTime(object)
	return getmetatable(object) == DateTime
end

function DateTime:getValue()
	return self.utc_milliseconds
end

function DateTime:getSecond()
	return self.utc_milliseconds/1000
end

ObjectId = {}
ObjectId.__index = ObjectId
function ObjectId:__tostring()
	return "ObjectID(\"" .. self.key .. "\")"
end

---
-- Creates an ObjectId object with the corresponding key.
-- @tparam string key A hexadecimal string representation of the ObjectId of length 24.
function ObjectId.new(key)
	assert(string.len(key) == 24, "key parameter must be a hexidecimal string representing an ObjectId with length of 24.")
	local self = setmetatable({}, ObjectId)
	self.key = key
	return self
end

---
-- Checks whether the object is a ObjectId object or not.
-- @param object The object to be checked whether it is an ObjectId.
-- @treturn bool Whether the object is an ObjectId or not.
function ObjectId.isObjectId(object)
	return getmetatable(object) == ObjectId
end

---
-- Returns hexidecimal string representation of the ObjectId.
-- @treturn String hexidecimal string representation of the ObjectId.
function ObjectId:getKey()
	return self.key
end

TimeStamp = {}
TimeStamp.__index = TimeStamp
function TimeStamp:__tostring()
	return string.format("TimeStamp(%s, %s)", self.timestamp, self.increment)
end

function TimeStamp.new(timestamp, increment)
	local self = setmetatable({}, TimeStamp)
	self.timestamp = timestamp
	self.increment = increment
	return self
end

function TimeStamp.isTimeStamp(object)
	return getmetatable(object) == TimeStamp
end

function TimeStamp:getValue()
	return self.timestamp, self.increment
end

function TimeStamp:getTime()
	return self.timestamp
end

local Objects = {
		BSONNull = BSONNull,
		ObjectId = ObjectId,
		TimeStamp = TimeStamp,
		DateTime = DateTime,
	}
AllBSONObjects = setmetatable(
	Objects, 
	{
		__index = Objects,
		__metatable = false,
		__newindex = function(table, key, value)
			error("resultObjects cannot be modified, it is a read-only table")
		end
	}
)
