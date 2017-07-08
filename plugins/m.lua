local database = 'https://www.parghazeh.ml/'
local function run(msg)
	local res = http.request(database.."danestani.db")
	local danestani = res:split(",") 
	return danestani[math.random(#danestani)]..'\n '
end
--danestani Hafez Plugin v1.0 By @AmirDark
return {
	description = "500 danestani Hafez",
	usage = "!joke : send random danestani",
	patterns = {
		"^[/#!]information",
		"^(information)$",
	    "^[/#!](معلومة)",
		"^[/#!](معلومه)",
		"^(معلومة)$",
		"^(معلومه)$",
		},
	run = run
}

-- by @mr_ahmadix
-- sp @suport_arabot