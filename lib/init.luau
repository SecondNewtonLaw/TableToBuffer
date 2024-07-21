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
			"Only maps of { [string]: boolean | number | string | table | vector (Vector3) | buffer } are supported."
		)

		if type(val) == "boolean" then
			serializerBuilder = serializerBuilder.booleanWithName(idx)
		elseif type(val) == "number" then
			-- Assume its a f64.
			serializerBuilder = serializerBuilder.doubleWithName(idx)
		elseif type(val) == "string" then
			serializerBuilder = serializerBuilder.stringWithName(idx, 1024)
		elseif type(val) == "table" then
			print(val)
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

function initModule.GetDeserializerBuilder()
	return Deserializable.Create()
end

return initModule
