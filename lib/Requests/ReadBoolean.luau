local request = {}

function request.create(offset)
	assert(typeof(offset) == "number", "offset must be a number.")

	return {
		--[=[
            Writes the boolean into the provided buffer.
        ]=]
		write = function(buf: buffer, b: boolean)
			buffer.writeu8(buf, offset, b and 1 or 0)
		end,
		--[=[
            Reads the boolean from the buffer.
        ]=]
		read = function(buf: buffer): boolean
			return buffer.readu8(buf, offset) == 1
		end,
		--[=[
            Returns the amount to increase the offset by after this operation.
        ]=]
		advanceBy = function(_: buffer): number
			return 1 -- Buffer not required.
		end,
	}
end

return request
