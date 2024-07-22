--!strict
local SerializerBuilder = require(script.SerializerBuilder)

--[=[
	@class TableToBuffer
	Contains functions exposed to users of this library
]=]
local TableToBuffer = {}

--[=[
	Automatically creates a binary serializer for a given table. Only string-keyed tables are allowed.

	@within TableToBuffer
	@error "This function only accepts tables" when argument t is not a table
	@error "Only maps of { [string]: boolean | number | string | table | vector (Vector3) | buffer } are supported. Mixed tables are not supported, neither are arrays." When the given map contains keys that are not only strings or contains non-primitive data types as values.

	@param t The table to make a binary serializer for
	@return serializer Serializer A serializer that can make the given table into a buffer
]=]
function TableToBuffer.GetSerializerForTable(t: { [string]: any })
	assert(type(t) == "table", "This function only accepts tables")
	local serializerBuilder = SerializerBuilder.Create()

	for idx, val in t do
		assert(
			type(idx) ~= "string"
				or not (
					type(val) ~= "boolean"
					and type(val) ~= "number"
					and type(val) ~= "string"
					and type(val) ~= "table"
					and type(val) ~= "vector"
					and type(val) ~= "buffer"
				),
			"Only maps of { [string]: boolean | number | string | table | vector (Vector3) | buffer } are supported. Mixed tables are not supported, neither are arrays."
		)

		if type(val) == "boolean" then
			serializerBuilder = serializerBuilder.booleanWithName(idx)
		elseif type(val) == "number" then
			-- Assume its a f64.
			serializerBuilder = serializerBuilder.doubleWithName(idx)
		elseif type(val) == "string" then
			serializerBuilder = serializerBuilder.stringWithName(idx, 1024)
		elseif type(val) == "table" then
			serializerBuilder = serializerBuilder.tableWithName(idx, TableToBuffer.GetSerializerForTable(val))
		elseif type(val) == "vector" then
			serializerBuilder = serializerBuilder.vectorWithName(idx)
		elseif type(val) == "buffer" then
			-- 0x1000 is the sizeof modern day memory pages, this isn't important really, and if the buffer is bigger, we will provide a bigger room for data (the length of it)
			local bufLen = buffer.len(val)
			serializerBuilder = serializerBuilder.bufferWithName(idx, bufLen > 0x1000 and bufLen or 0x1000)
		end
	end

	return serializerBuilder.build()
end

--[=[
	Generates a buffer for a given table. This will cause the table to be just a metatable into the buffer. Making all the data inside the buffer, and the table just a way to mutate it.
	
	@within TableToBuffer
	@error "This function does not support arrays or mixed tables." -- The table can only contain strings.
	@param tbl T -- The table to represent as a buffer.

	@return tableAsBuffer T -- A table with its __index metatable modified so that indexes access the buffer to write and read data.
]=]
function TableToBuffer.TableAsBuffer<T>(tbl: T): T
	for i, _ in (tbl :: any) :: { [string]: any } do
		assert(type(i) == "string", "This function does not support arrays or mixed tables.")
	end

	local serializer = TableToBuffer.GetSerializerForTable((tbl :: any) :: { [string]: any })

	local actionList = serializer.GetActionList()
	local _underlying_buffer = serializer.Serialize((tbl :: any) :: { [string]: any })

	local nT = setmetatable({}, {
		__index = function(_: any, index)
			for _, action in actionList do
				if action.DeserializedName == index then
					if action.Solver then
						return action.Solver.read(_underlying_buffer)
					elseif action.Serializer then
						--[[
							Reconsider this, there will be cases where doing this will cause some wrong logic.
							For Example:
								local t = { ..., special = { x = false } }
								local x = TableAsBuffer(t)
								x.special.x = true -- This will not mutate the underlying table inside of the buffer, making it very much just return a RO copy that then must be set,
												   -- one way we can fix it is by simply setting the parameter EVERY time we do something, but this could result in some edge cases making it unfeasable.

							Copies emitted by __index should be binded using metatables so it accesses the buffer and does not act as a standalone object. 
						]]

						local at = action.OffsetedAt
						local bSize = action.Serializer.GetBufferSize()

						local nBuf = buffer.create(bSize)
						buffer.copy(nBuf, 0x0, _underlying_buffer, at, bSize)
						return action.Serializer.Deserialize(nBuf)
					end
				end
			end

			error("Unknown key. Access failed.")
		end,
		__newindex = function(_: any, index: string, value: any)
			--[[
				When writing to the underlying buffer a dangerous possibility arises. We have built the table in the sense that the value will be of a certain type.
				However, luau loves to make us do whatever we want. So we can perfectly send a boolean to a key that is actually a string, and that will completely assassinate the serializer.
				Therefore, we must assure that the operation we are going to do is safe, i made a terrible choice, not naming the ActionType the same as the valid type(x) return,
				due to this, we are forced to type check value and see if the action that matches our serializer works as expected, but with the ActionType and making it make sense. Yay!
			]]

			for _, action in actionList do
				if action.DeserializedName == index then
					if type(value) == "number" then
						assert(
							action.ActionType == "int" or action.ActionType == "float",
							`Attempted to write a value of type '{type(value)}' when the serializer action that serializes parameter '{index}' expects a type that fits the description of a {action.ActionType}`
						)
					elseif type(value) == "string" then
						assert(
							action.ActionType == "dynamicstring",
							`Attempted to write a value of type '{type(value)}' when the serializer action that serializes parameter '{index}' expects a type that fits the description of a {action.ActionType}`
						)
					elseif type(value) == "boolean" then
						assert(
							action.ActionType == "boolean",
							`Attempted to write a value of type '{type(value)}' when the serializer action that serializes parameter '{index}' expects a type that fits the description of a {action.ActionType}`
						)
					elseif type(value) == "vector" then
						assert(
							action.ActionType == "vector",
							`Attempted to write a value of type '{type(value)}' when the serializer action that serializes parameter '{index}' expects a type that fits the description of a {action.ActionType}`
						)
					elseif type(value) == "buffer" then
						assert(
							action.ActionType == "buffer",
							`Attempted to write a value of type '{type(value)}' when the serializer action that serializes parameter '{index}' expects a type that fits the description of a {action.ActionType}`
						)
					elseif type(value) == "table" then
						assert(
							action.ActionType == "table",
							`Attempted to write a value of type '{type(value)}' when the serializer action that serializes parameter '{index}' expects a type that fits the description of a {action.ActionType}`
						)
					end

					if action.Solver then
						action.Solver.write(_underlying_buffer, value)
					elseif action.Serializer then
						local nBuf = action.Serializer.Serialize(value)
						local at = action.OffsetedAt
						local bSize = action.Serializer.GetBufferSize()

						buffer.copy(_underlying_buffer, at, nBuf, 0x0, bSize)
					end
				end
			end
		end,

		__tostring = function()
			return string.format("underlying_buffer: %s", buffer.tostring(_underlying_buffer))
		end,

		__metatable = "This metatable is locked!",
	})

	return (nT :: any) :: T
end

--[=[
	Gets a Serializer/Deserializer builder.

	@within TableToBuffer
	@return builder SerializerBuilder -- A builder that allows you to create a Serializable using a builder-style API
]=]
function TableToBuffer.GetDeserializerBuilder()
	return SerializerBuilder.Create()
end

return TableToBuffer
