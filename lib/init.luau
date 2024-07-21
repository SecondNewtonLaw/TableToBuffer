--!strict
local Deserializable = require(script.Deserializable)

local initModule = {}

function initModule.GetSerializerForTable(t: { [string]: any })
	assert(typeof(t) == "table", "This function only accepts tables")
	local serializerBuilder = Deserializable.Create()

	for idx, val in t do
		assert(
			typeof(idx) ~= "string"
				or (typeof(val) ~= "boolean" and typeof(val) ~= "number" and typeof(val) ~= "string"),
			"Only maps of { [string]: boolean | number | string } are supported."
		)
		if typeof(val) == "boolean" then
			serializerBuilder = serializerBuilder.booleanWithName(idx)
		elseif typeof(val) == "number" then
			-- Assume its a f64.
			serializerBuilder = serializerBuilder.doubleWithName(idx)
		elseif typeof(val) == "string" then
			serializerBuilder = serializerBuilder.stringWithName(idx, 255)
		end
	end

	return serializerBuilder.build()
end

function initModule.GetDeserializerBuilder()
	return Deserializable.Create()
end

return initModule
