local deserializable = {}

local readFloatRequest = require(script.Parent.Requests.ReadFloat)
local readIntRequest = require(script.Parent.Requests.ReadInteger)
local readStringRequest = require(script.Parent.Requests.ReadString)
local readBooleanRequest = require(script.Parent.Requests.ReadBoolean)

type Action = {
	DeserializedName: string,
	ActionType: "int" | "boolean" | "float" | "dynamicstring",
	Solver: {
		write: (buf: buffer, any) -> (),
		read: (buf: buffer) -> any,
		advanceBy: (buf: buffer) -> number,
	},
}

function deserializable.Create()
	local d = {}
	local actionList: { Action } = {}
	local bufferSize = 0x0

	function d.uint32WithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 4, false),
		})
		bufferSize += 0x4
		return d
	end

	function d.uint16WithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 2, false),
		})
		bufferSize += 0x2
		return d
	end

	function d.uint8WithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 1, false),
		})
		bufferSize += 0x1
		return d
	end

	function d.int32WithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 4, true),
		})
		bufferSize += 0x4
		return d
	end

	function d.int16WithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 2, true),
		})
		bufferSize += 0x2
		return d
	end

	function d.int8WithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 1, true),
		})
		bufferSize += 0x1
		return d
	end

	function d.floatWithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "float",
			Solver = readFloatRequest.create(bufferSize, 4),
		})
		bufferSize += 0x4
		return d
	end

	function d.doubleWithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "float",
			Solver = readFloatRequest.create(bufferSize, 8),
		})
		bufferSize += 0x8
		return d
	end

	function d.stringWithName(valueName, maxStringSize: number)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "dynamicstring",
			Solver = readStringRequest.create(bufferSize, maxStringSize),
		})

		-- uint32 = string_size
		-- ...    = string
		bufferSize += 0x4 + maxStringSize
		return d
	end

	function d.booleanWithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "boolean",
			Solver = readBooleanRequest.create(bufferSize),
		})
		bufferSize += 0x8
		return d
	end

	function d.build()
		return {
			Serialize = function(obj: { [string]: any })
				local foundDeserializerMatches = 0
				for idx, _ in obj do
					for _, deserializerAction in actionList do
						if deserializerAction.DeserializedName == idx then
							foundDeserializerMatches += 1
							break
						end
					end
				end

				if foundDeserializerMatches < #actionList then
					warn(
						"There are more deserializer actions, yet they're going to be ran with stub values due to there being no argument with such name"
					)
				end

				local buf = buffer.create(bufferSize)
				for _, action in actionList do
					local writeValue = obj[action.DeserializedName]
					if not obj[action.DeserializedName] then
						if action.ActionType == "int" or action.ActionType == "float" then
							writeValue = 0
						elseif action.ActionType == "boolean" then
							writeValue = false
						elseif action.ActionType == "dynamicstring" then
							writeValue = ""
						end
					end

					action.Solver.write(buf, writeValue)
				end

				return buf
			end,
			Deserialize = function(buf: buffer)
				local nTable = {}

				for _, action in actionList do
					nTable[action.DeserializedName] = action.Solver.read(buf)
				end

				return nTable
			end,
		}
	end

	return d
end

return deserializable
