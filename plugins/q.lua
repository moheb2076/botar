local database = 'https://www.parghazeh.ml/'
local function run(msg)
	local res = http.request(database.."fal.db")
	local fal = res:split(",") 
	return fal[math.random(#fal)]..'\n https://telegram.me/botdiamond'
end
--Fal Hafez Plugin v1.0 By @AmirDark
return {
	description = "500 Fal Hafez",
	usage = "!joke : send random fal",
	patterns = {
		"^[/#!]poem",
		"^(poem)$",
	    "^[/#!](قصيدة)",
		"^[/#!](شعر)",
		"^(قصيدة)$",
		"^(شعر)$",
		},
	run = run
}

-- by @mr_ahmadix
-- sp @suport_arabot