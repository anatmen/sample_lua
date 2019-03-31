-- file: md5.lua
-- desc:

----------------------------------------------------------------------------
-- @param k String with original message.
-- @return String with the md5 hash value converted to hexadecimal digits
function md5Hex(k)
	k = SysMD5.sum(k)
	return (string.gsub(k, ".", function (c)
			return string.format("%02x", string.byte(c))
				end))
end
