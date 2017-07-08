
do
function run_bash(str)
    local cmd = io.popen(str)
    local result = cmd:read('*all')
    return result
end
local api_key = nil
local base_api = "https://maps.googleapis.com/maps/api"
function get_latlong(area)
  local api      = base_api .. "/geocode/json?"
  local parameters = "address=".. (URL.escape(area) or "")
  if api_key ~= nil then
    parameters = parameters .. "&key="..api_key
  end
  local res, code = https.request(api..parameters)
  if code ~=200 then return nil  end
  local data = json:decode(res)
 
  if (data.status == "ZERO_RESULTS") then
    return nil
  end
  if (data.status == "OK") then
    lat  = data.results[1].geometry.location.lat
    lng  = data.results[1].geometry.location.lng
    acc  = data.results[1].geometry.location_type
    types= data.results[1].types
    return lat,lng,acc,types
  end
end
function get_staticmap(area)
  local api        = base_api .. "/staticmap?"
  local lat,lng,acc,types = get_latlong(area)

  local scale = types[1]
  if     scale=="locality" then zoom=8
  elseif scale=="country"  then zoom=4
  else zoom = 13 end
    
  local parameters =
    "size=600x300" ..
    "&zoom="  .. zoom ..
    "&center=" .. URL.escape(area) ..
    "&markers=color:red"..URL.escape("|"..area)

  if api_key ~=nil and api_key ~= "" then
    parameters = parameters .. "&key="..api_key
  end
  return lat, lng, api..parameters
end


function run(msg, matches)
	local hash = 'usecommands:'..msg.sender_user_id_..':'..msg.chat_id_
	redis:incr(hash)
	local receiver	= msg.chat_id_
	local city = matches[1]
	if matches[1] == 'azan' and  is_momod(msg) then
	city = 'Dubai'
	end
	local lat,lng,url	= get_staticmap(city)

	local dumptime = run_bash('date +%s')
	local code = http.request('http://api.aladhan.com/timings/'..dumptime..'?latitude='..lat..'&longitude='..lng..'&timezonestring=Asia/Dubai&method=4')
	local jdat = json:decode(code)
	local data = jdat.data.timings
	local text = '🌍 <code>حسب توقيت مدينة  :</code> '..city
    text = text..'\n<code>-------------</code>'
text = text..'\n🌖 <code>اذان الفجر :</code> '..data.Fajr
      text = text..'\n<code>-------------</code>'
text = text..'\n☀ <code>الشروق :</code> '..data.Sunrise
	  text = text..'\n<code>-------------</code>'
text = text..'\n🌞 <code>اذان الظهر :</code> '..data.Dhuhr
      text = text..'\n<code>-------------</code>'
text = text..'\n🌓 <code>اذان العصر :</code> '..data.Asr
	   text = text..'\n<code>-------------</code>'
text = text..'\n🌚 <code>اذان المغرب :</code> '..data.Sunset
	   text = text..'\n<code>-------------</code>'
text = text..'\n🌒 <code>اذان العشاء :</code> '..data.Isha
       text = text..'\n<code>-------------</code>'
text = text..'\n🕑 <code>المنطقة الزمنية:Asia/Dubai</code> '
       text = text..'\n<code>-------------</code>'
text = text..'\n<code>Editor :</code> @botdiamond'
	  text = text..'\n\n'
	  tdcli.sendMessage(msg.chat_id_, 0, 1, text, 1, 'html')
end

return {
  patterns = {
  "^[/!#][Aa]zan (.*)$", 
   }, 
  run = run 
}

end

--@AccessDeni3d
