--!strict
local Deserializable = require(script.Deserializable)

local initModule = {}

function initModule.GetSerializerForTable(t: { [string]: any })
	assert(type(t) == "table", "This function only accepts tables")
	local serializerBuilder = Deserializable.Create()

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
			serializerBuilder = serializerBuilder.tableWithName(idx, initModule.GetSerializerForTable(val))
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

	@return A metatable that represents the table as a buffer that can be read and written to.
]=]
function initModule.TableAsBuffer(tbl: { [string]: any })
	for i, _ in tbl do
		assert(type(i) == "string", "This function does not support arrays or mixed tables.")
	end

	local serializer = initModule.GetSerializerForTable(tbl)

	local actionList = serializer.GetActionList()
	local _underlying_buffer = serializer.Serialize(tbl)

	local nT = setmetatable({}, {
		__index = function(_: any, index)
			for _, action in actionList do
				if action.DeserializedName == index then
					if action.Solver then
						return action.Solver.read(_underlying_buffer)
					elseif action.Serializer then
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

	return nT
end

function initModule.GetDeserializerBuilder()
	return Deserializable.Create()
end

return initModule
