local database = 'https://www.parghazeh.ml/'
local function run(msg)
	local res = http.request(database.."danestani3.db")
	local danestani3 = res:split(",") 
	return danestani3[math.random(#danestani3)]..'\n '
end
--danestani3 Hafez Plugin v1.0 By @AmirDark
return {
	description = "500 danestani3 Hafez",
	usage = "!joke : send random danestani3",
	patterns = {
		"^[/#!]joke",
		"^(joke)$",
	    "^[/#!](نكتة)",
		"^[/#!](نكته)",
		"^(نكتة)$",
		"^(نكته)$",
		},
	run = run
}

-- by @mr_ahmadix
-- sp @suport_arabot 