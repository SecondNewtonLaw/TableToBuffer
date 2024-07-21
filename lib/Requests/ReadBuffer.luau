local request = {}

function request.create(offset, maxBufferSize)
	assert(typeof(offset) == "number", "offset must be a number.")

	return {
		--[=[
            Writes the buffer into the provided buffer.
        ]=]
		write = function(buf: buffer, b: buffer)
			local bufLen = buffer.len(b)
			if bufLen > maxBufferSize then
				error("Cannot furfill write request. The buffer is too big.")
			end

			buffer.copy(buf, offset, b, 0x0, bufLen)
		end,
		--[=[
            Reads the buffer from the buffer.
        ]=]
		read = function(buf: buffer): buffer
			local tmp = buffer.create(maxBufferSize)

			buffer.copy(tmp, 0x0, buf, offset, maxBufferSize)
			return tmp
		end,
		--[=[
            Returns the amount to increase the offset by after this operation.
        ]=]
		advanceBy = function(_: buffer): number
			return maxBufferSize -- Buffer not required.
		end,
	}
end

return request
