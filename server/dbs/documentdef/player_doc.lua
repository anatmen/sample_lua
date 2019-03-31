-- file: player_doc.lua
-- desc: 玩家数据的 mongo 定义

Import "dbs.document.document"
Import "dbs.document.fields"

CPlayerDoc = Class("CPlayerDoc", document.CDocument)
CPlayerDoc.__COLLECTION__ = "player"
CPlayerDoc.__SHARD_INFO__ = {name = "_id", hashed = true}

CPlayerDoc:BuildFields(
{
	_id                         = fields.NumberField({index = true, uniqueindex = true, hashed = true}),
	account                     = fields.StringField({index = true, hashed = true}),
	locked                      = fields.BoolField(),
	name                        = fields.StringField(),
	sdkInfo                     = fields.TableField(),
	lastLoginTime               = fields.DateTimeField({default="now"}),
	lastSaveTime                = fields.NumberField(),
	loginNum                    = fields.NumberField(),
	var                         = fields.TableField(),
})
