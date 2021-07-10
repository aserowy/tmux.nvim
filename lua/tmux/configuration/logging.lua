local M = {
	nvim = "warning",
	file = "disabled",
}

function M.set(options)
	if options == nil then
		return
	end
	for index, value in ipairs(options) do
		M[index] = value
	end
end

return M
