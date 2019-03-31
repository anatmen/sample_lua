
Import 'dbs.mongorover.ResultObjectDef'
Import 'dbs.mongorover.BSONObjectDef'

local mongo_module = SysMongoDriver

local AllBSONObjects = BSONObjectDef.AllBSONObjects
local BSONNull = AllBSONObjects.BSONNull
local ObjectId = AllBSONObjects.ObjectId
local TimeStamp = AllBSONObjects.TimeStamp
local DateTime = AllBSONObjects.DateTime

local AllResultObjects = ResultObjectDef.AllResultObjects
local InsertOneResult = AllResultObjects.InsertOneResult
local InsertManyResult = AllResultObjects.InsertManyResult
local UpdateResult = AllResultObjects.UpdateResult
local DeleteResult = AllResultObjects.DeleteResult

--------------------------------------------------------------------------

Cursor = {__mode="k"}
Cursor.__index = Cursor
Cursor.__call = function (t)
    return t.cursor_t:next(AllBSONObjects)
end

function Cursor:__tostring()
	return string.format("Cursor")
end

function Cursor.new(collection, cursor_t)
	local self = setmetatable({}, Cursor)
	self.collection = collection
	self.cursor_t = cursor_t
	return self
end

--------------------------------------------------------------------------

--- Collection level utilities for Mongo.
-- @module mongorover.MongoCollection

--- Collection level utilities for Mongo.
-- @type mongorover.MongoCollection
MongoCollection = {__mode="k"}

---
-- Creates a new MongoCollection instance. Usually called by MongoDatabase's getCollection(...) method. 
-- @see MongoDatabase.getCollection
-- @tparam MongoDatabase database A MongoDatabase instance.
-- @tparam string collection_name The name of the collection.
-- @return A @{MongoCollection} instance.
function MongoCollection.new(database, collection_name)
	local self = {
		database = database,
		collection_t = mongo_module.collection_new(database.database_t, collection_name)
	}
	
	setmetatable(self, {
		__index = MongoCollection
	})
	return self
end

---
-- Drops collection.
function MongoCollection:drop()
	self.collection_t:collection_drop()
end

---
-- Returns the number of documents in a collection matching the query input parameter.
-- Example usage at @{update_many.lua}.
-- @tparam[opt] table query A table containing a query.
-- @tparam[opt] int skip The number of documents to skip.
-- @tparam[opt] int limit The maximum number of matching documents to return.
-- @treturn int The number of documents matching the query provided.
function MongoCollection:count(query, skip, limit)
	query = query or {}
	skip = skip or 0
	limit = limit or 0
	return self.collection_t:collection_count(AllBSONObjects, query, skip, limit)
end

---
-- Internal function used to create an anonymous function iterator that returns the next document.
-- in the given cursor every time it is iterated over.
-- @local
-- @tparam MongoCollection collection Needs to instantiate with a reference to the collection to ensure the collection is
-- not garbage collected before the cursor.
-- @tparam MongoCursor mongo_cursor A cursor from the C wrapper.
local function createCursorIterator (collection, mongo_cursor)
	-- Table necessary to prevent MongoCollection from being garbage collected before cursor.
	-- Table has to have relevant information in it, to prevent garbage collection.
	local mongoCursorPointer = {collection=collection, cursor_t=mongo_cursor}
	setmetatable(mongoCursorPointer, {__mode = "k"})
	
	return function ()
                   return mongoCursorPointer["cursor_t"]:next(AllBSONObjects)
               end
end

---
-- Selects documents in a collection and returns an iterator to the selected documents.
-- Example usage at @{find.lua}.
-- @tparam[opt] table query Specifies criteria using query operators. To return all documents, either
-- do not use query parameter or pass in an empty document ({}).
-- @tparam[opt] table fields projection  Specifies the fields to return using projection operators. Default value returns all fields.
-- @treturn iterator An iterator with results.
-- cursor_parms 可以不填  一个table  default {limit=0, skip=0, batchsize=0}
function MongoCollection:find(query, fields, cursor_parms)
	query = query or {}
	fields = fields or {}
	local cursor_t = self.collection_t:collection_find(AllBSONObjects, query, fields, cursor_parms)
	return Cursor.new(self, cursor_t)
end

--sort 例子：
--[[	query = {}
		query["$query"] = {}
			query["$orderby"] = {x=1}
			collection:find(query)
			相当于 collection:find({}).sort({x=1})
]]


---
-- Returns one document that satisfies the specified query criteria.
-- Example usage at @{find.lua}.
-- @tparam[opt] table query Specifies criteria using query operators. 
-- @tparam[opt] table fields Specifies the fields to return using projection operators. Default value returns all fields.
-- @treturn table First document found with the query provided.
function MongoCollection:find_one(query, fields)
	return self.collection_t:collection_find_one(AllBSONObjects, query, fields)
end

---
-- Update a single document matching the filter
-- Example usage at @{update_one.lua}.
-- @tparam table filter A query that matches the document to update.
-- @tparam table update The modifications to apply.
-- @tparam[opt] bool upsert If true, perform an insert if no documents match the filter.
-- @return @{ResultObjectDef.UpdateResult}
function MongoCollection:update_one(filter, update, upsert)
	upsert = upsert or false
	local raw_result = self.collection_t:collection_update_one(AllBSONObjects, filter, update, upsert, false)
	return UpdateResult(raw_result)
end

---
-- Update one or more documents that match the filter.
-- Example usage at @{update_many.lua}.
-- @tparam table filter A query that matches the documents to update.
-- @tparam table update The modifications to apply.
-- @tparam[opt] bool upsert If true, perform an insert if no documents match the filter.
-- @return @{ResultObjectDef.UpdateResult}
function MongoCollection:update_many(filter, update, upsert)
	upsert = upsert or false
	local raw_result = self.collection_t:collection_update_many(AllBSONObjects, filter, update, upsert, true)
	return UpdateResult(raw_result)
end

---
-- Insert a single document.
-- Example usage at @{insert_one.lua}.
-- @tparam table document The document to insert. Must be mutable. If the document does not have an _id field,
-- one will be added automatically.
-- @return @{ResultObjectDef.InsertOneResult}
function MongoCollection:insert_one(document)
	local acknowledged, inserted_id = self.collection_t:collection_insert_one(AllBSONObjects, document)
	return InsertOneResult(acknowledged, inserted_id)
end

---
-- Insert a list of documents.
-- Example usage at @{insert_many.lua}.
-- @tparam {table,...} documents A list of documents to insert.
-- @tparam[opt] bool ordered If true (the default), documents will be inserted on the server serially, in the order provided.
-- If false, documents will be inserted on the server in arbitrary order (possibly in parallel) and all documents inserts will
-- be attempted
-- @return @{ResultObjectDef.InsertManyResult}
function MongoCollection:insert_many(documents, ordered)
	ordered = ordered or true
	local raw_result, inserted_ids = self.collection_t:collection_insert_many(AllBSONObjects, documents, ordered)
	return InsertManyResult(raw_result, inserted_ids)
end

---
-- Delete a single document.
-- Example usage at @{delete_one.lua}.
-- @tparam table selector  Specifies criteria using query operators. 
-- @return @{ResultObjectDef.DeleteResult}
function MongoCollection:delete_one(selector)
	local acknowledged, raw_result = self.collection_t:collection_delete_one(AllBSONObjects, selector)
	return DeleteResult(acknowledged, raw_result)
end

---
-- Deletes all documents matching query selector.
-- Example usage at @{delete_many.lua}
-- @tparam table selector  Specifies criteria using query operators. 
-- @return @{ResultObjectDef.DeleteResult}
function MongoCollection:delete_many(selector)
	local acknowledged, raw_result = self.collection_t:collection_delete_many(AllBSONObjects, selector)
	return DeleteResult(acknowledged, raw_result)
end

function MongoCollection:find_and_modify(document)
	-- body
	local query = document.query
	local sort = document.sort
	local update = document.update
	local fields = document.fields
	local remove = document.remove
	local upsert = document.upsert 
	local new = document.new
	return self.collection_t:collection_find_and_modify(AllBSONObjects, query, sort, update, fields, remove, upsert, new)
end

---
-- Perform an aggregation using the aggregation framework on this collection.
-- Example usage at @{aggregation.lua}.
-- @tparam {table,...} aggregationPipeline A list of aggregation pipeline stages.
-- @treturn iterator An iterator with results.
function MongoCollection:aggregate(aggregationPipeline)
	local cursor_t = self.collection_t:collection_aggregate(AllBSONObjects, aggregationPipeline)
	return createCursorIterator(self, cursor_t)
end

local metatable = {
	__index = MongoCollection,
	__call = function(table, ...) 
					-- table is the same as MongoCollection
					return MongoCollection.new(...)
				end
}

MongoCollection = setmetatable(MongoCollection, metatable)

--------------------------------------------------------------------------

--- Database level operations.
-- @module mongorover.MongoDatabase

----
--- Database level operations.
-- @type mongorover.MongoDatabase

MongoDatabase = {__mode="k"}

---
-- Creates a new MongoDatabase instance. Called by MongoClient's getDatabase(...) method.
-- @see MongoClient.getDatabase
-- @tparam MongoClient client A MongoClient instance.
-- @tparam string database_name
-- @return A @{MongoDatabase} instance.
function MongoDatabase.new(client, database_name)
	local self = {
		database_t = mongo_module.database_new(client.client_t, database_name),
		client = client
	}
	setmetatable(self, {
			__index = function(table, key)
				if rawget(MongoDatabase, key) then
					return MongoDatabase[key]
				else
					return MongoCollection.new(table, key)
				end
			end
		})
	return self
end

---
-- Creates MongoCollection instance.
-- @tparam string collection_name Name of collection.
-- @return A @{MongoCollection} instance.
function MongoDatabase:getCollection(collection_name)
	return MongoCollection.new(self, collection_name)
end

---
-- Returns array of collection names.
-- @treturn {string,...} An array containing the names of collections in the database.
function MongoDatabase:getCollectionNames()
	return self.database_t:get_collection_names()
end

---
-- Drops the database.
function MongoDatabase:drop_database()
	self.database_t:database_drop()
	self.database_t = nil
end

---
-- Returns boolean whether the collection is present in the database.
-- @tparam string collectionName The name of the database.
-- @treturn boolean A boolean value whether the database has the collection.
function MongoDatabase:hasCollection(collectionName)
	return self.database_t:has_collection(collectionName)
end

---
-- Issue a command to MongoDB by and get response back.
-- @tparam string command 
-- @param[opt] value Value for command. Defaults to 1.
-- @tparam table options Additional options for database command.
-- @treturn table Response from server.
function MongoDatabase:command(command, value, options)
	value = value or 1
	code_options = code_options or nil
	return self.database_t:command_simple(AllBSONObjects, command, value, options)
end

local metatable = {
	__index = MongoDatabase,
	__call = function(table, ...)
					--table is the same as MongoDatabase
					return MongoDatabase.new(...)
				end
}

MongoDatabase = setmetatable(MongoDatabase, metatable)

--------------------------------------------------------------------------

MongoClient = {}

---
-- Creates a MongoClient instance.
-- For documentation to create a mongoDB connection URI (http://docs.mongodb.org/manual/reference/connection-string/).
-- @tparam string db_uri The MongoDB connection URI.
-- @return A @{MongoClient} instance.
function MongoClient.new(db_uri)
	db_uri = db_uri or "mongodb://localhost:27017"
	
	local self = {
		client_t = mongo_module.client_new(db_uri)
	}
	setmetatable(self, {
		__index = function(table, key)
			-- rawget(...) is the same as indexing into a table, however it does not invoke the metatable __index call if the key is not found
			-- which would cause an infinite loop. This will emulate the same behavior as doing MongoClient.__index = MongoClient
			-- but allows for us to get databases by indexing into the client
			if rawget(MongoClient, key) then
				return MongoClient[key]
			else
				return MongoClient.getDatabase(table, key)
			end
		end
	})
	return self
end

---
-- Returns array of database names.
-- @treturn {string,...} An array of database names.
function MongoClient:getDatabaseNames()
	return self.client_t:client_get_database_names()
end

--- 
-- Returns a MongoDatabase object.
-- @tparam string database_name The name of the database.
-- @treturn MongoDatabase A MongoDatabase object.
-- @return A @{MongoDatabase} instance.
function MongoClient:getDatabase(database_name)
	return MongoDatabase.new(self, database_name)
end

local metatable = {
	__index = MongoClient,
	__call = function(table, ...)
					--table is the same as MongoClient, so just use MongoClient
					return MongoClient.new(...)
				end
}
MongoClient = setmetatable(MongoClient, metatable)


