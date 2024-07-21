--!strict
local request = {}

function request.create(offset, readSize: number)
	assert(typeof(offset) == "number", "offset must be a number.")
	assert(typeof(readSize) == "number", "readSize must be a number.")
	assert((readSize ~= 8 or readSize ~= 4), "Size must be a power of two less than 8 but bigger than 4")

	return {
		--[=[
			Write the float into the buffer.
		]=]
		write = function(buf: buffer, num: number)
			if readSize == 8 then
				buffer.writef64(buf, offset, num)
			elseif readSize == 4 then
				buffer.writef32(buf, offset, num)
			end
		end,
		--[=[
            Reads the float from the buffer.
        ]=]
		read = function(buf: buffer): number
			if readSize == 8 then
				return buffer.readf64(buf, offset)
			elseif readSize == 4 then
				return buffer.readf32(buf, offset)
			end

			error("This should never happen. This read is impossible")
		end,
		--[=[
            Returns the amount to increase the offset by after this operation.
        ]=]
		advanceBy = function(_: buffer?): number
			return readSize -- Buffer not required.
		end,
	}
end

return request
