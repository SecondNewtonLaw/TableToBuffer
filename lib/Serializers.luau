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

	[MagicValues.TypeToMagic.Vector2] = function(vec: Vector2): buffer
		local buf = buffer.create(0xC + 0x8)
		buffer.writei32(buf, 0x0, MagicValues.TypeToMagic.Vector2)
		buffer.writef64(buf, 0x4, vec.X)
		buffer.writef64(buf, 0xC, vec.Y)

		return buf
	end,

	[MagicValues.TypeToMagic.Vector3int16] = function(vec: Vector3): buffer
		local buf = buffer.create(0x8 + 0x2)
		buffer.writei32(buf, 0x0, MagicValues.TypeToMagic.Vector3int16)
		buffer.writei16(buf, 0x4, vec.X)
		buffer.writei16(buf, 0x6, vec.Y)
		buffer.writei16(buf, 0x8, vec.Z)

		return buf
	end,

	[MagicValues.TypeToMagic.Vector2int16] = function(vec: Vector2): buffer
		local buf = buffer.create(0x6 + 0x2)
		buffer.writei32(buf, 0x0, MagicValues.TypeToMagic.Vector2int16)
		buffer.writei16(buf, 0x4, vec.X)
		buffer.writei16(buf, 0x6, vec.Y)

		return buf
	end,

	[MagicValues.TypeToMagic.EnumItem] = function(enumItem: EnumItem): buffer
		local enumName = tostring(enumItem.EnumType)

		local buf = buffer.create(0x4 + 0x4 + 0x4 + #enumName)
		buffer.writei32(buf, 0x0, MagicValues.TypeToMagic.EnumItem)

		buffer.writei32(buf, 0x4, enumItem.Value)

		buffer.writei32(buf, 0x4 + 0x4, #enumName)
		buffer.writestring(buf, 0x4 + 0x4 + 0x4, enumName, #enumName)

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
		local buf = buffer.create(0x8 + #animationId + 0x4 + #name)
		buffer.writei32(buf, 0x0, MagicValues.TypeToMagic.Animation)

		buffer.writei32(buf, 0x4, #animationId)
		buffer.writestring(buf, 0x8, animationId, #animationId)

		buffer.writei32(buf, 0x8 + #animationId, #name)
		buffer.writestring(buf, 0x8 + #animationId + 0x4, name, #name)

		return buf
	end,

	[MagicValues.TypeToMagic.BrickColor] = function(brickColor: BrickColor): buffer
		local buf = buffer.create(0x8)
		buffer.writei32(buf, 0x0, MagicValues.TypeToMagic.BrickColor)
		buffer.writei32(buf, 0x4, brickColor.Number)
		return buf
	end,

	--#endregion typeof(x) == "Instance" and x.ClassName ==
} :: { [number]: (obj: any) -> buffer })

function Serializers.GetMagicForUserdata(instance: any)
	assert(
		type(instance) == "userdata" or type(instance) == "vector",
		"Invalid input parameter, input must be of type userdata or vector"
	)

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
