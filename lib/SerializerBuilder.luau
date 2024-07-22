--!strict

--[=[
	@class SerializerBuilderFactory
	@ignore

	Allows you to create SerializerBuilders.
]=]
local serializerBuilder = {}

local types = require(script.Parent.TypeDefinitions)

local readFloatRequest = require(script.Parent.Requests.ReadFloat)
local readIntRequest = require(script.Parent.Requests.ReadInteger)
local readStringRequest = require(script.Parent.Requests.ReadString)
local readBooleanRequest = require(script.Parent.Requests.ReadBoolean)
local readVectorRequest = require(script.Parent.Requests.ReadVector)
local readBufferRequest = require(script.Parent.Requests.ReadBuffer)

--[=[
	Create a SerializerBuilder

	@within SerializerBuilderFactory
	@private

	@return SerializerBuilder -- A builder that allows you to build a Serializer.
]=]
function serializerBuilder.Create<T>()
	--[=[
		@class SerializerBuilder

		A builder used to make a simple an intuitive serializer at runtime.
	]=]
	local __self = {}
	local actionList: { types.Action<any> } = {}
	local bufferSize = 0x8

	--[=[
		Inserts an action to the deserializer action list, which indicates it to read 4 bytes and treat the return as an unsigned 32 bit integer.

		@within SerializerBuilder
		@param valueName string -- The index that this uint32 will have when it is deserialized into a table.
		@return SerializerBuilder -- The builder instance.
	]=]
	function __self.uint32WithName(valueName: string)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 4, false),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x4
		return __self
	end

	--[=[
		Inserts an action to the deserializer action list, which indicates it to read 2 bytes and treat the return as an unsigned 16 bit integer.

		@within SerializerBuilder
		@param valueName string -- The index that this uint16 will have when it is deserialized into a table.
		@return SerializerBuilder -- The builder instance.
	]=]
	function __self.uint16WithName(valueName: string)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 2, false),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x2
		return __self
	end

	--[=[
		Inserts an action to the deserializer action list, which indicates it to read 1 byte and treat the return as an unsigned 8 bit integer.

		@within SerializerBuilder
		@param valueName string -- The index that this uint8 will have when it is deserialized into a table.
		@return SerializerBuilder -- The builder instance.
	]=]
	function __self.uint8WithName(valueName: string)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 1, false),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x1
		return __self
	end

	--[=[
		Inserts an action to the deserializer action list, which indicates it to read 4 bytes and treat the return as an signed 32 bit integer.

		@within SerializerBuilder
		@param valueName string -- The index that this int32 will have when it is deserialized into a table.
		@return SerializerBuilder -- The builder instance.
	]=]
	function __self.int32WithName(valueName: string)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 4, true),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x4
		return __self
	end

	--[=[
		Inserts an action to the deserializer action list, which indicates it to read 2 bytes and treat the return as an signed 16 bit integer.

		@within SerializerBuilder
		@param valueName string -- The index that this int16 will have when it is deserialized into a table.
		@return SerializerBuilder -- The builder instance.
	]=]
	function __self.int16WithName(valueName: string)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 2, true),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x2
		return __self
	end

	--[=[
		Inserts an action to the deserializer action list, which indicates it to read 1 byte and treat the return as an signed 8 bit integer.

		@within SerializerBuilder
		@param valueName string -- The index that this int8 will have when it is deserialized into a table.
		@return SerializerBuilder -- The builder instance.
	]=]
	function __self.int8WithName(valueName: string)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "int",
			Solver = readIntRequest.create(bufferSize, 1, true),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x1
		return __self
	end

	--[=[
		Inserts an action to the deserializer action list, which indicates it to read 4 bytes and to treat the return as a IEEE-754 single-precision floating point number.

		@within SerializerBuilder
		@param valueName string -- The index that this float32 will have when it is deserialized into a table.
		@return SerializerBuilder -- The builder instance.
	]=]
	function __self.floatWithName(valueName: string)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "float",
			Solver = readFloatRequest.create(bufferSize, 4),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x4
		return __self
	end

	--[=[
		Inserts an action to the deserializer action list, which indicates it to read 8 bytes and to treat the return as a IEEE-754 double-precision floating point number.

		@within SerializerBuilder
		@param valueName string -- The index that this double/float64 will have when it is deserialized into a table.
		@return SerializerBuilder -- The builder instance.
	]=]
	function __self.doubleWithName(valueName: string)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "float",
			Solver = readFloatRequest.create(bufferSize, 8),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x8
		return __self
	end

	--[=[
		Inserts an action to the deserializer action list, which indicates it to read an arbitrary amount bytes and to treat the return as a string. The size of the string is placed four bytes before the string as an int32.

		@within SerializerBuilder
		@error "maxStringSize must be a number" -- Happens when maxStringSize is not of type number. 
		@error "maxStringSize is too big, serializer will not continue" -- Happens when maxSizeString exceeds 1025.

		@param valueName string -- The index that this string will have when it is deserialized into a table.
		@param maxStringSize number -- The length of the string, used to cap buffers from becoming too big.
		@return SerializerBuilder -- The builder instance.
	]=]
	function __self.stringWithName(valueName, maxStringSize: number)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "dynamicstring",
			Solver = readStringRequest.create(bufferSize, maxStringSize),
			OffsetedAt = bufferSize,
		})

		-- uint32 = string_size
		-- ...    = string
		bufferSize += 0x1 + 0x4 + maxStringSize
		return __self
	end

	--[=[
		Inserts an action to the deserializer action list, which indicates it to read 1 byte and to treat the return as a boolean.

		@within SerializerBuilder
		@param valueName string -- The index that this boolean will have when it is deserialized into a table.
		@return SerializerBuilder -- The builder instance.
	]=]
	function __self.booleanWithName(valueName: string)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "boolean",
			Solver = readBooleanRequest.create(bufferSize),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x8
		return __self
	end

	--[=[
		Inserts an action to the deserializer action list, which will indicate it to read three IEEE-754 double-precision floating point numbers, representing X, Y and Z for a Vector3.

		@within SerializerBuilder
		@param valueName string -- The index that this vector will have when it is deserialized into a table.
		@return SerializerBuilder -- The builder instance.
	]=]
	function __self.vectorWithName(valueName: string)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "vector",
			Solver = readVectorRequest.create(bufferSize),
			OffsetedAt = bufferSize,
		})
		bufferSize += 0x8 * 3
		return __self
	end

	--[=[
		Inserts an action to the deserializer action list, which will indicate it to read an aribitrary amount of bytes determined by the table serializer, and to then feed that into the given serializer to craft the table.

		@within SerializerBuilder
		@param valueName string -- The index that this table will have when it is deserialized into a table.
		@param tableSerializer Serializer<U> -- The serializer that the table will use when being turned from a buffer into a table and vice-versa.
		@return SerializerBuilder -- The builder instance.
	]=]
	function __self.tableWithName<U>(valueName, tableSerializer: types.Serializer<U>)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "table",
			Solver = nil,
			Serializer = tableSerializer,
			OffsetedAt = bufferSize,
		})
		bufferSize += tableSerializer.GetBufferSize()
		return __self
	end

	--[=[
		Inserts an action to the deserializer action list, which will read the given number of bytes, then it will copy those bytes into a new buffer.

		@within SerializerBuilder
		@param valueName string -- The index that this buffer will have when it is deserialized into a table.
		@param bufSize number? -- The size the buffer will have. If not specified, the size will be of 0x1000, or 4096 bytes.
		@return SerializerBuilder -- The builder instance.
	]=]
	function __self.bufferWithName(valueName, bufSize: number?)
		table.insert(actionList, {
			DeserializedName = valueName,
			ActionType = "buffer",
			Solver = readBufferRequest.create(bufferSize, bufSize or 0x1000),
			Serializer = nil,
			OffsetedAt = bufferSize,
		})
		bufferSize += (bufSize or 0x1000)
		return __self
	end

	function __self.getBufferSize(): number
		return bufferSize
	end

	function __self.build(): types.Serializer<T>
		--[=[
			@class Serializer

			A serializer used to serialize Tables into Buffers
		]=]
		local serializer = {}

		--[=[
			Deserializes the given buffer into a table.
			@within Serializer

			@error "Buffer cannot be deserialized: Wrong size" -- The given buffer is not the size that the Serializer predicts it to be.
			@return T -- The deserialized result
		]=]
		function serializer.Deserialize(buf: buffer)
			local nTable = {}

			assert(buffer.readf64(buf, 0x0) == bufferSize, "Buffer cannot be deserialized: Wrong size")

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

			return (nTable :: any) :: T
		end

		--[=[
			Obtains the max size of the buffer in bytes.
			@within Serializer

			@ignore
			@return number -- The max size, in bytes, of the buffer when it is serialized.
		]=]
		function serializer.GetBufferSize(): number
			return bufferSize
		end

		--[=[
			Serializes the table into a buffer
			@within Serializer

			@error "Attempted to write a value of type 'X' when the serializer action that serializes parameter 'index_of_table_being_serialized' expects a type that fits the description of a Z" -- Happens when the serializer attempts to write the wrong type using the wrong write operation. Caused by malformed tables 

			@param obj T -- The table to convert into a buffer
			@return { Action } -- Array of type Action describing how to serialize the table into a buffer
		]=]
		function serializer.Serialize(obj: T)
			local foundDeserializerMatches = 0
			-- local recursive = function(t: { [string]: any }) end
			for idx, _ in (obj :: any) :: { [string]: any } do
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
				local writeValue = ((obj :: any) :: { [string]: any })[action.DeserializedName]
				if not ((obj :: any) :: { [string]: any })[action.DeserializedName] then
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

				if type(writeValue) == "number" then
					assert(
						action.ActionType == "int" or action.ActionType == "float",
						`Attempted to write a value of type '{type(writeValue)}' when the serializer action that serializes parameter '{action.DeserializedName}' expects a type that fits the description of a {action.ActionType}`
					)
				elseif type(writeValue) == "string" then
					assert(
						action.ActionType == "dynamicstring",
						`Attempted to write a value of type '{type(writeValue)}' when the serializer action that serializes parameter '{action.DeserializedName}' expects a type that fits the description of a {action.ActionType}`
					)
				elseif type(writeValue) == "boolean" then
					assert(
						action.ActionType == "boolean",
						`Attempted to write a value of type '{type(writeValue)}' when the serializer action that serializes parameter '{action.DeserializedName}' expects a type that fits the description of a {action.ActionType}`
					)
				elseif type(writeValue) == "vector" then
					assert(
						action.ActionType == "vector",
						`Attempted to write a value of type '{type(writeValue)}' when the serializer action that serializes parameter '{action.DeserializedName}' expects a type that fits the description of a {action.ActionType}`
					)
				elseif type(writeValue) == "buffer" then
					assert(
						action.ActionType == "buffer",
						`Attempted to write a value of type '{type(writeValue)}' when the serializer action that serializes parameter '{action.DeserializedName}' expects a type that fits the description of a {action.ActionType}`
					)
				elseif type(writeValue) == "table" then
					assert(
						action.ActionType == "table",
						`Attempted to write a value of type '{type(writeValue)}' when the serializer action that serializes parameter '{action.DeserializedName}' expects a type that fits the description of a {action.ActionType}`
					)
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
		end

		--[=[ 
			Returns the list of actions the Serializer will do to convert the given table into a buffer.
			@within Serializer
			
			@ignore
			@return { Action } -- Array of type Action describing how to serialize the table into a buffer
		]=]
		function serializer.GetActionList(): { types.Action<T> }
			return actionList
		end

		return (serializer :: any) :: types.Serializer<T>
	end

	return __self
end

return serializerBuilder
