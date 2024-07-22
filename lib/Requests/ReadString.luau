--!strict
local lualzw = require(script.Parent.Parent.External.lualzw)

local request = {}

function request.create(offset, maxStringSize)
	assert(typeof(maxStringSize) == "number", "maxStringSize must be a number.")
	assert(typeof(offset) == "number", "offset must be a number.")
	assert(maxStringSize <= 1024, "maxStringSize is too big, serializer will not continue")

	return {
		write = function(buf: buffer, str: string)
			if #str > maxStringSize then
				warn(
					"[StringDynamicSerializer] The string will be truncated due to its size of "
						.. #str
						.. " while the allocated size originally was of "
						.. maxStringSize
				)
			end
			local compressedStr = lualzw.compress(str)
			local writeString = str
			if #compressedStr > #str then
				-- We only want to save a compressed string if it benefits us, thus, we want to leave a little flag for it to mark it, we can implement more compression algorithms in the future, and denominatee whcih to use based on this little u8.
				writeString = str
				buffer.writeu8(buf, offset, 0)
			else
				writeString = compressedStr
				buffer.writeu8(buf, offset, 1)
			end
			buffer.writeu32(buf, offset + 0x1, maxStringSize)
			buffer.writestring(
				buf,
				offset + 0x1 + 0x4,
				writeString,
				maxStringSize > #writeString and #writeString or maxStringSize
			)
		end,
		--[=[
            Reads the string from the buffer.
        ]=]
		read = function(buf: buffer): string
			local isCompressed = buffer.readu8(buf, offset)
			local sizeHeader = buffer.readu32(buf, offset + 0x1)
			local nStr = buffer.readstring(buf, offset + 0x1 + 0x4, sizeHeader)

			return isCompressed and lualzw.decompress(nStr) or nStr
		end,
		--[=[
            Returns the amount to increase the offset by after this operation.
        ]=]
		advanceBy = function(_: buffer?): number
			return maxStringSize + 0x4 + 0x1
		end,
	}
end

return request
