--!strict
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
			buffer.writeu32(buf, offset, maxStringSize)
			buffer.writestring(buf, offset + 0x4, str, maxStringSize > #str and #str or maxStringSize)
		end,
		--[=[
            Reads the string from the buffer.
        ]=]
		read = function(buf: buffer): string
			local sizeHeader = buffer.readu32(buf, offset)
			local nStr = buffer.readstring(buf, offset + 0x4, sizeHeader)
			return nStr
		end,
		--[=[
            Returns the amount to increase the offset by after this operation.
        ]=]
		advanceBy = function(_: buffer?): number
			return maxStringSize + 0x4
		end,
	}
end

return request
