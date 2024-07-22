--!strict
local ldeflate = require(script.Parent.Parent.External.LuaDeflate)
local lualzw = require(script.Parent.Parent.External.lualzw)

local request = {}

local compressHeaderMap = {
	NoCompression = 0x0,
	lzw = 0x1,
	zlib = 0x2,
	deflate = 0x3,
}

function request.create(offset, maxStringSize, compressionAlgorithm: "NoCompression" | "zlib" | "lzw" | "deflate")
	assert(typeof(compressionAlgorithm) == "string", "compressionAlgorithm must be a string.")
	assert(typeof(maxStringSize) == "number", "maxStringSize must be a number.")
	assert(typeof(offset) == "number", "offset must be a number.")
	assert(maxStringSize <= 1024, "maxStringSize is too big, serializer will not continue")
	assert(
		not (
			compressionAlgorithm ~= "zlib"
			and compressionAlgorithm ~= "lzw"
			and compressionAlgorithm ~= "deflate"
			and compressionAlgorithm ~= "NoCompression"
		),
		"Only zlib and lzw are supported as compresison algorithms. If you do not wish to use compression, use NoCompression"
	)

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
			buffer.writeu8(buf, offset, compressHeaderMap[compressionAlgorithm])

			local compressedStr = str

			if compressionAlgorithm == "deflate" then
				compressedStr = ldeflate:CompressDeflate(str, nil)
			elseif compressionAlgorithm == "zlib" then
				compressedStr = ldeflate:CompressZlib(str, nil)
			elseif compressionAlgorithm == "lzw" then
				compressedStr = lualzw.compress(str)
			end

			buffer.writeu32(buf, offset + 0x1, maxStringSize)
			buffer.writestring(
				buf,
				offset + 0x1 + 0x4,
				compressedStr,
				maxStringSize > #compressedStr and #compressedStr or maxStringSize
			)
		end,
		--[=[
            Reads the string from the buffer.
        ]=]
		read = function(buf: buffer): string
			local compressionIdentifier = buffer.readu8(buf, offset)
			local sizeHeader = buffer.readu32(buf, offset + 0x1)
			local nStr = buffer.readstring(buf, offset + 0x1 + 0x4, sizeHeader)

			local finalString = nStr
			if compressionIdentifier == compressHeaderMap.deflate then
				finalString = ldeflate:DecompressDeflate(nStr)
			elseif compressionIdentifier == compressHeaderMap.zlib then
				finalString = ldeflate:DecompressZlib(nStr)
			elseif compressionIdentifier == compressHeaderMap.lzw then
				finalString = lualzw.decompress(nStr)
			end

			return finalString
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
