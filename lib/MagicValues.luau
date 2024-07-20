--!strict
--[[
    This file contains a map for the magical values placed as a i32 at the start of Buffers to identify them.
    Int32 (i32) gives us a range of literally 2147483647 possibilities, which will suffice for any future userdatas' roblox may want to implement.
]]

-- Magical values structure.
local MagicValues = {}

MagicValues.TypeToMagic = {
	-- typeof(x) ==
	CFrame = 0x0,
	Vector3 = 0x2,
	DateTime = 0x4,
	Vector2 = 0x6,
	Vector2int16 = 0x8,
	Vector3int16 = 0xA,


	-- typeof(x) == "Instance" and x.ClassName ==
	Player = 0x10002,
	Animation = 0x10004,
}

MagicValues.MagicToType = {} :: { [number]: string }

for name, magic in MagicValues.TypeToMagic :: { [string]: any } do
	MagicValues.MagicToType[magic] = name
end

return MagicValues
