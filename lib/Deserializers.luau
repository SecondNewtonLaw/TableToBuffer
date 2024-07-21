--!strict
local Players = game:GetService("Players")

local MagicValues = require(script.Parent.MagicValues)
local Deserializers = {}

Deserializers.Deserializers = table.freeze({
	--#region typeof(x) ==

	[MagicValues.TypeToMagic.CFrame] = function(buf: buffer): CFrame
		assert(buffer.readi32(buf, 0x0) == MagicValues.TypeToMagic.CFrame, "Invalid magic for buffer.")

		local posX = buffer.readf64(buf, 0x4)
		local posY = buffer.readf64(buf, 0xC)
		local posZ = buffer.readf64(buf, 0x14)
		local pos = Vector3.new(posX, posY, posZ)

		local vxX = buffer.readf64(buf, 0x14 + 0x8)
		local vxY = buffer.readf64(buf, 0x14 + 0x10)
		local vxZ = buffer.readf64(buf, 0x14 + 0x18)
		local vX = Vector3.new(vxX, vxY, vxZ)

		local vyX = buffer.readf64(buf, 0x2C + 0x8)
		local vyY = buffer.readf64(buf, 0x2C + 0x10)
		local vyZ = buffer.readf64(buf, 0x2C + 0x18)
		local vY = Vector3.new(vyX, vyY, vyZ)

		local vzX = buffer.readf64(buf, 0x44 + 0x8)
		local vzY = buffer.readf64(buf, 0x44 + 0x10)
		local vzZ = buffer.readf64(buf, 0x44 + 0x18)
		local vZ = Vector3.new(vzX, vzY, vzZ)

		return CFrame.fromMatrix(pos, vX, vY, vZ)
	end,

	[MagicValues.TypeToMagic.Vector3] = function(buf: buffer): Vector3
		assert(buffer.readi32(buf, 0x0) == MagicValues.TypeToMagic.Vector3, "Invalid magic for buffer.")
		local x = buffer.readf64(buf, 0x4)
		local y = buffer.readf64(buf, 0xC)
		local z = buffer.readf64(buf, 0x14)

		return Vector3.new(x, y, z)
	end,

	[MagicValues.TypeToMagic.Vector2] = function(buf: buffer): Vector2
		assert(buffer.readi32(buf, 0x0) == MagicValues.TypeToMagic.Vector2, "Invalid magic for buffer.")
		local x = buffer.readf64(buf, 0x4)
		local y = buffer.readf64(buf, 0xC)

		return Vector2.new(x, y)
	end,

	[MagicValues.TypeToMagic.Vector3int16] = function(buf: buffer): Vector3int16
		assert(buffer.readi32(buf, 0x0) == MagicValues.TypeToMagic.Vector3int16, "Invalid magic for buffer.")
		local x = buffer.readi16(buf, 0x4)
		local y = buffer.readi16(buf, 0x6)
		local z = buffer.readi16(buf, 0x8)

		return Vector3int16.new(x, y, z)
	end,

	[MagicValues.TypeToMagic.Vector2int16] = function(buf: buffer): Vector2int16
		assert(buffer.readi32(buf, 0x0) == MagicValues.TypeToMagic.Vector2int16, "Invalid magic for buffer.")
		local x = buffer.readi16(buf, 0x4)
		local y = buffer.readi16(buf, 0x6)

		return Vector2int16.new(x, y)
	end,

	[MagicValues.TypeToMagic.EnumItem] = function(buf: buffer): EnumItem
		assert(buffer.readi32(buf, 0x0) == MagicValues.TypeToMagic.EnumItem, "Invalid magic for buffer.")

		local enumItemValue = buffer.readi32(buf, 0x4)
		local enumNameSize = buffer.readi32(buf, 0x4 + 0x4)
		local enumName = buffer.readstring(buf, 0x4 + 0x4 + 0x4, enumNameSize)

		local enum
		for _, v in (Enum :: any)[enumName]:GetEnumItems() do
			if v.Value == enumItemValue then
				enum = v
				break
			end
		end

		return enum
	end,
	--#endregion typeof(x) ==

	--#region typeof(x) == "Instance" and x.ClassName ==

	[MagicValues.TypeToMagic.Player] = function(buf: buffer): Player
		assert(buffer.readi32(buf, 0x0) == MagicValues.TypeToMagic.Player, "Invalid magic for buffer.")

		local uid = buffer.readu32(buf, 0x4)
		local player = Players:GetPlayerByUserId(uid)

		assert(player ~= nil, "Invalid UserId for the serialized player. Serialization will not continue.")

		return player
	end,

	[MagicValues.TypeToMagic.Animation] = function(buf: buffer): Animation
		assert(buffer.readi32(buf, 0x0) == MagicValues.TypeToMagic.Animation, "Invalid magic for buffer.")

		local animationIdSize = buffer.readi32(buf, 0x4)
		local animationId = buffer.readstring(buf, 0x8, animationIdSize)

		local nameSize = buffer.readi32(buf, 0x8 + animationIdSize)
		local name = buffer.readstring(buf, 0x8 + animationIdSize + 0x4, nameSize)

		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		animation.Name = name

		return animation
	end,

	[MagicValues.TypeToMagic.BrickColor] = function(buf: buffer): BrickColor
		assert(buffer.readi32(buf, 0x0) == MagicValues.TypeToMagic.BrickColor, "Invalid magic for buffer.")

		return BrickColor.new(buffer.readi32(buf, 0x4))
	end,

	--#endregion typeof(x) == "Instance" and x.ClassName ==
} :: { [number]: (buf: buffer) -> unknown })

function Deserializers.ObtainMagicFromBuffer(buf: buffer)
	assert(typeof(buf) == "buffer", "Argument #1 is not a buffer.")

	local magic = buffer.readi32(buf, 0x0)

	assert(MagicValues.MagicToType[magic], `Malformed buffer header, serialization will not continue.`)

	return magic
end

function Deserializers.FromBufferAndMagic(buf: buffer, magic: number): unknown
	assert(typeof(buf) == "buffer", "Argument #1 is not a buffer.")
	assert(typeof(magic) == "number", "Argument #2 is not a number.")

	local userdataObject = Deserializers.Deserializers[magic](buf)

	return userdataObject
end

function Deserializers.FromBuffer(buf: buffer): unknown
	assert(typeof(buf) == "buffer", "Argument #1 is not a buffer.")

	return Deserializers.FromBufferAndMagic(buf, Deserializers.ObtainMagicFromBuffer(buf))
end

return table.freeze(Deserializers)
