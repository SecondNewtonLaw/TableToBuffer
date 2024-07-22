--!strict
local request = {}

--[[
    Roblox Specific
]]

function request.create(offset)
	assert(typeof(offset) == "number", "offset must be a number.")

	return {
		--[=[
            Writes the CoordinateFrame into the provided buffer.
        ]=]
		write = function(buf: buffer, b: CFrame)
			local pX = b.Position.X
			local pY = b.Position.Y
			local pZ = b.Position.Z
			local rX, rY, rZ = b:ToEulerAnglesXYZ()

			buffer.writef64(buf, offset, pX)
			buffer.writef64(buf, offset + 0x8, pY)
			buffer.writef64(buf, offset + 0x8 + 0x8, pZ)
			buffer.writef64(buf, offset + 0x8 + 0x8 + 0x8, rX)
			buffer.writef64(buf, offset + 0x8 + 0x8 + 0x8 + 0x8, rY)
			buffer.writef64(buf, offset + 0x8 + 0x8 + 0x8 + 0x8 + 0x8, rZ)
		end,
		--[=[
            Reads the CoordinateFrame from the buffer.
        ]=]
		read = function(buf: buffer): CFrame
			local pX = buffer.readf64(buf, offset)
			local pY = buffer.readf64(buf, offset + 0x8)
			local pZ = buffer.readf64(buf, offset + 0x8 + 0x8)
			local rX = buffer.readf64(buf, offset + 0x8 + 0x8 + 0x8)
			local rY = buffer.readf64(buf, offset + 0x8 + 0x8 + 0x8 + 0x8)
			local rZ = buffer.readf64(buf, offset + 0x8 + 0x8 + 0x8 + 0x8 + 0x8)

			return CFrame.new(pX, pY, pZ) * CFrame.Angles(rX, rY, rZ)
		end,
		--[=[
            Returns the amount to increase the offset by after this operation.
        ]=]
		advanceBy = function(_: buffer?): number
			return 0x8 * 6 -- Buffer not required.
		end,
	}
end

return request
