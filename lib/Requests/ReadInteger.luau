local request = {}

function request.create(offset, readSize: number, signed: boolean)
	assert(typeof(offset) == "number", "offset must be a number.")
	assert(typeof(readSize) == "number", "readSize must be a number.")
	assert(typeof(signed) == "boolean", "signed must be a boolean.")
	assert((readSize ~= 4 or readSize ~= 2 or readSize ~= 1), "Size must be a power of two less than 4")

	return {
		--[=[
			Write the integer into the buffer.
		]=]
		write = function(buf: buffer, num: number)
			if readSize == 4 then
				if signed then
					buffer.writei32(buf, offset, num)
				else
					buffer.writeu32(buf, offset, num)
				end
			elseif readSize == 2 then
				if signed then
					buffer.writei16(buf, offset, num)
				else
					buffer.writeu16(buf, offset, num)
				end
			elseif readSize == 1 then
				if signed then
					buffer.writei8(buf, offset, num)
				else
					buffer.writeu8(buf, offset, num)
				end
			end
		end,
		--[=[
            Reads the integer from the buffer.
        ]=]
		read = function(buf: buffer): number
			if readSize == 4 then
				if signed then
					return buffer.readi32(buf, offset)
				else
					return buffer.readu32(buf, offset)
				end
			elseif readSize == 2 then
				if signed then
					return buffer.readi16(buf, offset)
				else
					return buffer.readu16(buf, offset)
				end
			elseif readSize == 1 then
				if signed then
					return buffer.readi8(buf, offset)
				else
					return buffer.readu8(buf, offset)
				end
			end

			error("This should never happen. This read is impossible")
		end,
		--[=[
            Returns the amount to increase the offset by after this operation.
        ]=]
		advanceBy = function(_: buffer): number
			return readSize -- Buffer not required.
		end,
	}
end

return request
