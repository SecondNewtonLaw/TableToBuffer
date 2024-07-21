--!strict
local request = {}

--[[
    This is for a Vector3 on Roblox. On Roblox, Vector3's are of primitive `vector`. This differs from things like Vector2s, which are considered `userdata`.

    This implementation was written FOR Roblox. If you have a custom Luau environment and want to use this, you may need to modify it a little bit.
]]

function request.create(offset)
	assert(typeof(offset) == "number", "offset must be a number.")

	return {
		--[=[
            Writes the vector into the provided buffer.
        ]=]
		write = function(buf: buffer, b: Vector3)
			local x = b.X
			local y = b.Y
			local z = b.Z
			buffer.writef64(buf, offset, x)
			buffer.writef64(buf, offset + 0x8, y)
			buffer.writef64(buf, offset + 0x8 + 0x8, z)
		end,
		--[=[
            Reads the vector from the buffer.
        ]=]
		read = function(buf: buffer): Vector3
			local x = buffer.readf64(buf, offset)
			local y = buffer.readf64(buf, offset + 0x8)
			local z = buffer.readf64(buf, offset + 0x8 + 0x8)

			return Vector3.new(x, y, z)
		end,
		--[=[
            Returns the amount to increase the offset by after this operation.
        ]=]
		advanceBy = function(_: buffer?): number
			return 0x8 * 3 -- Buffer not required.
		end,
	}
end

return request
