--!strict
local deserializable = {}

local readFloatRequest = require(script.Parent.Requests.ReadFloat)
local readIntRequest = require(script.Parent.Requests.ReadInteger)
local readStringRequest = require(script.Parent.Requests.ReadString)
local readBooleanRequest = require(script.Parent.Requests.ReadBoolean)
local readVectorRequest = require(script.Parent.Requests.ReadVector)
local readBufferRequest = require(script.Parent.Requests.ReadBuffer)

type Action = {
	DeserializedName: string,
	ActionType: "int" | "boolean" | "float" | "dynamicstring" | "table" | "vector" | "buffer",
	Solver: {
		write: (buf: buffer, any) -> (),
		read: (buf: buffer) -> any,
		advanceBy: (buf: buffer?) -> number,
	} | nil,
	Serializer: Serializer | nil,
	OffsetedAt: number,
}

type Serializer = {
	Deserialize: (buf: buffer) -> {
		[string]: any,
	},
	GetBufferSize: () -> number,
	Serialize: (obj: {
		[string]: any,
	}) -> buffer,
}

function deserializable.Create()
	local d = {}
	local actionList: { Action } = {}
	local bufferSize = 0x8

	function d.uint32WithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 4, false),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x4
		return d
	end

	function d.uint16WithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 2, false),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x2
		return d
	end

	function d.uint8WithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 1, false),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x1
		return d
	end

	function d.int32WithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 4, true),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x4
		return d
	end

	function d.int16WithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 2, true),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x2
		return d
	end

	function d.int8WithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 1, true),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x1
		return d
	end

	function d.floatWithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "float",
			Solver = readFloatRequest.create(bufferSize, 4),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x4
		return d
	end

	function d.doubleWithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "float",
			Solver = readFloatRequest.create(bufferSize, 8),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x8
		return d
	end

	function d.stringWithName(valueName, maxStringSize: number)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "dynamicstring",
			Solver = readStringRequest.create(bufferSize, maxStringSize),
			OffsetedAt = bufferSize,
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
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x8
		return d
	end

	function d.vectorWithName(valueName)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "vector",
			Solver = readVectorRequest.create(bufferSize),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x8 * 3
		return d
	end

	function d.tableWithName(valueName, tableSerializer: Serializer)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "table",
			Solver = nil,
			Serializer = tableSerializer,
			OffsetedAt = bufferSize,
		})
		bufferSize += tableSerializer.GetBufferSize()
		return d
	end

	function d.bufferWithName(valueName, bufSize: number?)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "buffer",
			Solver = readBufferRequest.create(bufferSize, bufSize or 0x1000),
			Serializer = nil,
			OffsetedAt = bufferSize,
		})
		bufferSize += (bufSize or 0x1000)
		return d
	end

	function d.getBufferSize(): number
		return bufferSize
	end

	function d.build(): Serializer
		return {
			Serialize = function(obj: { [string]: any })
				local foundDeserializerMatches = 0
				-- local recursive = function(t: { [string]: any }) end
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
					warn("This could mean your table is missing an argument. Beware of this when seeing your output.")
				end

				local buf = buffer.create(bufferSize)
				buffer.writef64(buf, 0x0, bufferSize)

				for _, action in actionList do
					local writeValue = obj[action.DeserializedName]
					if not obj[action.DeserializedName] then
						if action.ActionType == "int" or action.ActionType == "float" then
							writeValue = 0
						elseif action.ActionType == "boolean" then
							writeValue = false
						elseif action.ActionType == "dynamicstring" then
							writeValue = ""
						elseif action.ActionType == "table" then
							writeValue = {}
						elseif action.ActionType == "vector" then
							writeValue = Vector3.new(0, 0, 0)
						elseif action.ActionType == "buffer" then
							if action.Solver then
								local tBufSize = action.Solver.advanceBy(buf)
								writeValue = buffer.create(tBufSize)
								buffer.fill(writeValue, 0x0, 0xDEADBEEF, tBufSize)
							else
								warn("Solver is nil. Assuming the buffer size to be 4096 (0x1000)")
								writeValue = buffer.create(0x1000)
								buffer.fill(writeValue, 0x0, 0xDEADBEEF, 0x1000)
							end
						end
					end

					if action.ActionType == "table" and action.Serializer then
						local tBuf = action.Serializer.Serialize(writeValue)
						buffer.copy(buf, action.OffsetedAt, tBuf, 0x0, action.Serializer.GetBufferSize())
					end

					if action.Solver then
						action.Solver.write(buf, writeValue)
					end
				end

				return buf
			end,

			GetBufferSize = function(): number
				return bufferSize
			end,

			Deserialize = function(buf: buffer)
				local nTable = {}

				assert(buffer.readf64(buf, 0x0) == buffer.len(buf), "Malformed buffer?")
				assert(buffer.readf64(buf, 0x0) == bufferSize, "Buffer header check failed.")

				for _, action in actionList do
					if action.ActionType == "table" and action.Serializer then
						local temporalBuf = buffer.create(action.Serializer.GetBufferSize())
						buffer.copy(temporalBuf, 0x0, buf, action.OffsetedAt, action.Serializer.GetBufferSize())
						nTable[action.DeserializedName] = action.Serializer.Deserialize(temporalBuf)
						continue
					end
					if action.Solver then
						nTable[action.DeserializedName] = action.Solver.read(buf)
					end
				end

				return nTable
			end,
		}
	end

	return d
end

return deserializable
