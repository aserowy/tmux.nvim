local function contains(list, x)
	for _, v in pairs(list) do
		if v == x then
			return true
		end
	end
	return false
end

local M = {
	nvim = "warning",
	file = "disabled",
}

function M.set(options)
	if options == nil or options == "" then
		return
	end
	for index, _ in pairs(M) do
		if
			options[index] ~= nil
			and contains({ "disabled", "debug", "information", "warning", "error" }, options[index])
		then
			M[index] = options[index]
		end
	end
end

return M
