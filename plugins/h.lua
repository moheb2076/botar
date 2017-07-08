local database = 'https://www.parghazeh.ml/'
local function run(msg)
	local res = http.request(database.."danestani2.db")
	local danestani2 = res:split(",") 
	return danestani2[math.random(#danestani2)]..'\n '
end
--danestani2 Hafez Plugin v1.0 By @AmirDark
return {
	description = "500 danestani2 Hafez",
	usage = "!joke : send random danestani2",
	patterns = {
		"^[/#!]Wisdom",
		"^(wisdom)$",
	    "^[/#!](حكمة)",
		"^[/#!](حكمه)",
		"^(حكمة)$",
		"^(حكمه)$",
		},
	run = run
}

-- by @mr_ahmadix
-- sp @suport_arabot