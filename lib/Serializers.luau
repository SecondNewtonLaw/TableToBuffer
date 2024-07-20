--!strict

local MagicValues = require(script.Parent.MagicValues)
local Serializers = {}

Serializers.Serializers = table.freeze({
	--#region typeof(x) ==

	[MagicValues.TypeToMagic.CFrame] = function(coordinateFrame: CFrame): buffer
		local buf = buffer.create(0x44 + 0x18 + 0x8)

		buffer.writei32(buf, 0x0, MagicValues.TypeToMagic.CFrame)

		local pos = coordinateFrame.Position
		buffer.writef64(buf, 0x4, pos.X)
		buffer.writef64(buf, 0xC, pos.Y)
		buffer.writef64(buf, 0x14, pos.Z)

		local vX = coordinateFrame.XVector
		buffer.writef64(buf, 0x14 + 0x8, vX.X)
		buffer.writef64(buf, 0x14 + 0x10, vX.Y)
		buffer.writef64(buf, 0x14 + 0x18, vX.Z)

		local vY = coordinateFrame.YVector
		buffer.writef64(buf, 0x2C + 0x8, vY.X)
		buffer.writef64(buf, 0x2C + 0x10, vY.Y)
		buffer.writef64(buf, 0x2C + 0x18, vY.Z)

		local vZ = coordinateFrame.ZVector
		buffer.writef64(buf, 0x44 + 0x8, vZ.X)
		buffer.writef64(buf, 0x44 + 0x10, vZ.Y)
		buffer.writef64(buf, 0x44 + 0x18, vZ.Z)

		return buf
	end,

	[MagicValues.TypeToMagic.Vector3] = function(vec: Vector3): buffer
		local buf = buffer.create(0x14 + 0x8)
		buffer.writei32(buf, 0x0, MagicValues.TypeToMagic.Vector3)
		buffer.writef64(buf, 0x4, vec.X)
		buffer.writef64(buf, 0xC, vec.Y)
		buffer.writef64(buf, 0x14, vec.Z)

		return buf
	end,

	--#endregion typeof(x) ==

	--#region typeof(x) == "Instance" and x.ClassName ==

	[MagicValues.TypeToMagic.Player] = function(player: Player): buffer
		local uid = player.UserId
		local buf = buffer.create(0x8)
		buffer.writei32(buf, 0x0, MagicValues.TypeToMagic.Player)
		buffer.writeu32(buf, 0x4, uid)

		return buf
	end,

	[MagicValues.TypeToMagic.Animation] = function(animation: Animation): buffer
		local animationId = animation.AnimationId
		local name = animation.Name
		local buf = buffer.create(0x8)
		buffer.writei32(buf, 0x0, MagicValues.TypeToMagic.Animation)

		buffer.writei32(buf, 0x4, #animationId)
		buffer.writestring(buf, 0x8, animationId, #animationId)

		buffer.writei32(buf, 0x8 + #animationId + 0x4, #name)
		buffer.writestring(buf, 0x8 + #animationId + 0x8, name, #name)

		return buf
	end,

	--#endregion typeof(x) == "Instance" and x.ClassName ==
} :: { [number]: (obj: any) -> buffer })

function Serializers.GetMagicForUserdata(instance: any)
	assert(type(instance) == "userdata", "Invalid input parameter, input must be of type userdata")

	local typeName = ""
	if typeof(instance) == "Instance" then
		typeName = instance.ClassName
	else
		typeName = typeof(instance)
	end

	local typeTag = MagicValues.TypeToMagic[typeName]

	assert(typeTag, `No magic found for type '{typeName}'.`)

	return typeTag
end

function Serializers.GetUserdataNameFromMagic(magic: number): string
	local typeName = MagicValues.MagicToType[magic]
	assert(typeName, `No type found with magic '{magic}'.`)

	return typeName
end

function Serializers.FromInstanceAndMagic(instance: any, magic: number): buffer
	assert(
		Serializers.GetMagicForUserdata(instance) == magic,
		"The provided magic does not corelate with the given instance."
	)

	local buf = Serializers.Serializers[magic](instance)

	return buf
end

return table.freeze(Serializers)
