--!strict

local Serializers = require(script.Serializers)
local Deserializers = require(script.Deserializers)

local InstanceToBuffer = {}
InstanceToBuffer.Types = require(script.Types)

function InstanceToBuffer.CanBeSerialized<T>(instance: T): boolean
	if type(instance) == "userdata" or type(instance) == "vector" then
		return true
	end

	return false
end

function InstanceToBuffer.Serialize(instance: Instance): buffer
	local success, serialized = InstanceToBuffer.TrySerialize(instance)

	if not success then
		error("Serialization failed. Reason: " .. tostring(serialized))
	end

	if not serialized then
		error(
			"The instance " .. typeof(instance) == "Instance"
				and (instance :: Instance).ClassName .. " does not have a serializer for it."
		)
	end

	return serialized :: buffer
end

function InstanceToBuffer.TrySerialize(instance: Instance): (boolean, string | buffer?)
	return pcall(function()
		local magic = Serializers.GetMagicForUserdata(instance)

		return Serializers.FromInstanceAndMagic(instance, magic)
	end)
end

function InstanceToBuffer.TryDeserialize(buf: buffer): (boolean, string | unknown?)
	assert(typeof(buf) == "buffer", "Argument #1 was not a buffer")

	return pcall(function()
		local magic = Deserializers.ObtainMagicFromBuffer(buf)
		return Deserializers.FromBufferAndMagic(buf, magic)
	end)
end

return InstanceToBuffer
