--Begin Fun.lua By @ap576
--------------------------------

local function run_bash(str)
    local cmd = io.popen(str)
    local result = cmd:read('*all')
    return result
end
--------------------------------
local api_key = nil
local base_api = "https://maps.googleapis.com/maps/api"
--------------------------------
local function get_latlong(area)
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
--------------------------------
local function get_staticmap(area)
	local api        = base_api .. "/staticmap?"
	local lat,lng,acc,types = get_latlong(area)
	local scale = types[1]
	if scale == "locality" then
		zoom=8
	elseif scale == "country" then 
		zoom=4
	else 
		zoom = 13 
	end
	local parameters =
		"size=600x300" ..
		"&zoom="  .. zoom ..
		"&center=" .. URL.escape(area) ..
		"&markers=color:red"..URL.escape("|"..area)
	if api_key ~= nil and api_key ~= "" then
		parameters = parameters .. "&key="..api_key
	end
	return lat, lng, api..parameters
end
--------------------------------
local function get_weather(location)
	print("Finding weather in ", location)
	local BASE_URL = "http://api.openweathermap.org/data/2.5/weather"
	local url = BASE_URL
	url = url..'?q='..location..'&APPID=eedbc05ba060c787ab0614cad1f2e12b'
	url = url..'&units=metric'
	local b, c, h = http.request(url)
	if c ~= 200 then return nil end
	local weather = json:decode(b)
	local city = weather.name
	local country = weather.sys.country
	local temp = 'الاحوال الجوية لمدينة :'..city..'\n\n🌡 درجة حرارة الهواء الحالية : '..weather.main.temp..' C\n\nالضغط الجوي :'..weather.main.pressure..'\nالرطوبة : '..weather.main.humidity..' %\n\n🔻الحد الأدنى من درجات الحرارة اليوم :'..weather.main.temp_min..'\n🔺درجة الحرارة القصوى اليوم:'..weather.main.temp_min..'\n\n🌬 سرعة الرياح : '..weather.wind.speed..'\nالرياح : '..weather.wind.deg..'\n\n🔸خط الطول : '..weather.coord.lon..'\n🔹خط العرض : '..weather.coord.lat..' '
	local conditions = 'أحوال الطقس الحالية:'
	 if weather.weather[1].main == 'Clear' then
    conditions = conditions .. 'مشمس ☀️'
  elseif weather.weather[1].main == 'Clouds' then
    conditions = conditions .. 'غائم ☁️☁️'
  elseif weather.weather[1].main == 'Rain' then
    conditions = conditions .. 'ممطر ☔️'
  elseif weather.weather[1].main == 'Thunderstorm' then
    conditions = conditions .. 'عاصف 🌪🌪🌪🌪'
  elseif weather.weather[1].main == 'Mist' then
conditions = conditions .. 'ضباب 🌫'
	end
	return temp .. '\n' .. conditions
end
--------------------------------
local function calc(exp)
	url = 'http://api.mathjs.org/v1/'
	url = url..'?expr='..URL.escape(exp)
	b,c = http.request(url)
	text = nil
	if c == 200 then
    text = 'Result = '..b..'\n🆔 Channel ™ : '..check_markdown('@ap576')..'\n=======================\n  diamondbot  '
	elseif c == 400 then
		text = b
	else
		text = 'Unexpected error\n=======================\n  diamondbot  '
		..'Is api.mathjs.org up?'
	end
	return text
end
--------------------------------
function exi_file(path, suffix)
    local files = {}
    local pth = tostring(path)
	local psv = tostring(suffix)
    for k, v in pairs(scandir(pth)) do
        if (v:match('.'..psv..'$')) then
            table.insert(files, v)
        end
    end
    return files
end
--------------------------------
function file_exi(name, path, suffix)
	local fname = tostring(name)
	local pth = tostring(path)
	local psv = tostring(suffix)
    for k,v in pairs(exi_file(pth, psv)) do
        if fname == v then
            return true
        end
    end
    return false
end
--------------------------------
function run(msg, matches) 
	if matches[1]:lower() == "calc" and matches[2] then 
		if msg.to.type == "pv" then 
			return 
       end
		return calc(matches[2])
	end
--------------------------------
	if matches[1]:lower() == 'وقت صلاة' or matches[1] == 'اذان' then
		if matches[2] then
			city = matches[2]
		elseif not matches[2] then
			city = 'Tehran'
		end
		local lat,lng,url	= get_staticmap(city)
		local dumptime = run_bash('date +%s')
		local code = http.request('http://api.aladhan.com/timings/'..dumptime..'?latitude='..lat..'&longitude='..lng..'&timezonestring=Asia/Tehran&method=7')
		local jdat = json:decode(code)
		local data = jdat.data.timings
		local text = '🛣 البلد : '..city
	  text = '🌍 <code>حسب توقيت مدينة  :</code> '..city
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
	  text = text..'\n\n🌔🌜🌕🌞⭐️🌞⭐️🌞🌕🌛🌖\n\n🆔 Channel ™ : @ap576 \n=======================\n™\n'
		return tdcli.sendMessage(msg.chat_id_, 0, 1, text, 1, 'html')
	end
--------------------------------
	if matches[1]:lower() == 'tophoto' and msg.reply_id then
		function tophoto(arg, data)
			function tophoto_cb(arg,data)
				if data.content_.sticker_ then
					local file = data.content_.sticker_.sticker_.path_
					local secp = tostring(tcpath)..'/data/sticker/'
					local ffile = string.gsub(file, '-', '')
					local fsecp = string.gsub(secp, '-', '')
					local name = string.gsub(ffile, fsecp, '')
					local sname = string.gsub(name, 'webp', 'jpg')
					local pfile = 'data/photos/'..sname
					local pasvand = 'webp'
					local apath = tostring(tcpath)..'/data/sticker'
					if file_exi(tostring(name), tostring(apath), tostring(pasvand)) then
						os.rename(file, pfile)
						tdcli.sendPhoto(msg.to.id, 0, 0, 1, nil, pfile, "🆔 Channel ™ : @ap576", dl_cb, nil)
					else
						tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This sticker does not exist. Send sticker again._', 1, 'md')
					end
				else
					tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This is not a sticker._', 1, 'md')
				end
			end
            tdcli_function ({ ID = 'GetMessage', chat_id_ = msg.chat_id_, message_id_ = data.id_ }, tophoto_cb, nil)
		end
		tdcli_function ({ ID = 'GetMessage', chat_id_ = msg.chat_id_, message_id_ = msg.reply_id }, tophoto, nil)
    end
--------------------------------
	if matches[1]:lower() == 'tosticker' and msg.reply_id then
		function tosticker(arg, data)
			function tosticker_cb(arg,data)
				if data.content_.ID == 'MessagePhoto' then
					file = data.content_.photo_.id_
					local pathf = tcpath..'/data/photo/'..file..'_(1).jpg'
					local pfile = 'data/photos/'..file..'.webp'
					if file_exi(file..'_(1).jpg', tcpath..'/data/photo', 'jpg') then
						os.rename(pathf, pfile)
						tdcli.sendDocument(msg.chat_id_, 0, 0, 1, nil, pfile, '🆔 Channel ™ : @ap576', dl_cb, nil)
					else
						tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This photo does not exist. Send photo again._', 1, 'md')
					end
				else
					tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This is not a photo._', 1, 'md')
				end
			end
			tdcli_function ({ ID = 'GetMessage', chat_id_ = msg.chat_id_, message_id_ = data.id_ }, tosticker_cb, nil)
		end
		tdcli_function ({ ID = 'GetMessage', chat_id_ = msg.chat_id_, message_id_ = msg.reply_id }, tosticker, nil)
    end
--------------------------------
	if matches[1]:lower() == 'طقس' then
		city = matches[2]
		local wtext = get_weather(city)
		if not wtext then
			wtext = '❌ *الموقع غير صحيح* ❌'
		end
		return wtext
	end
--------------------------------
	if matches[1]:lower() == 'time' then
local url , res = http.request('http://api.gpmod.ir/time/')
if res ~= 200 then
 return "No connection"
  end
local jdat = json:decode(url)
local answers = {'https://assets.imgix.net/examples/clouds.jpg?blur=120&w=700&h=400&fit=crop&txt=',
                   'https://assets.imgix.net/examples/redleaf.jpg?blur=120&w=700&h=400&fit=crop&txt=',
                   'https://assets.imgix.net/examples/blueberries.jpg?blur=120&w=700&h=400&fit=crop&txt=',
                   'https://assets.imgix.net/examples/butterfly.jpg?blur=120&w=700&h=400&fit=crop&txt=',
                   'https://assets.imgix.net/examples/espresso.jpg?blur=120&w=700&h=400&fit=crop&txt=',
                   'https://assets.imgix.net/unsplash/transport.jpg?blur=120&w=700&h=400&fit=crop&txt=',
                   'https://assets.imgix.net/unsplash/coffee.JPG?blur=120&w=700&h=400&fit=crop&txt=',
                   'https://assets.imgix.net/unsplash/citystreet.jpg?blur=120&w=700&h=400&fit=crop&txt=',
				   'http://assets.imgix.net/examples/vista.png?blur=120&w=700&h=400&fit=crop&txt='}

local fonts = {'American%20Typewriter%2CBold','Arial%2CBoldItalicMT','Arial%2CBoldMT','Athelas%2CBold',
               'Baskerville%2CBoldItalic','Charter%2CBoldItalic','DIN%20Alternate%2CBold','Gill%20Sans%2CUltraBold',
			   'PT%20Sans%2CBold','Seravek%2CBoldItalic','Verdana%2CBold','Yuanti%20SC%2CBold','Avenir%20Next%2CBoldItalic',
			   'Lucida%20Grande%2CBold','American%20Typewriter%20Condensed%2CBold','rial%20Rounded%20MT%2CBold','Chalkboard%20SE%2CBold',
			   'Courier%20New%2CBoldItalic','Charter%20Black%2CItalic','American%20Typewriter%20Light'}

local colors = {'00FF00','6699FF','CC99CC','CC66FF','0066FF','000000','CC0066','FF33CC','FF0000','FFCCCC','FF66CC','33FF00','FFFFFF','00FF00'}
local f = fonts[math.random(#fonts)]
local c = colors[math.random(#colors)]
local url = answers[math.random(#answers)]..jdat.ENtime.."&txtsize=200&txtclr="..c.."&txtalign=middle,center&txtfont="..f.."%20Condensed%20Medium&mono=ff6598cc=?markscale=60&markalign=center%2Cdown"
local file = download_to_file(url,'time.webp')
		tdcli.sendDocument(msg.to.id, 0, 0, 1, nil, file, '', dl_cb, nil)

	end
--------------------------------
if matches[1] == 'voice' then
 local text = matches[2]
    textc = text:gsub(' ','.')
    
  if msg.to.type == 'pv' then 
      return nil
      else
  local url = "http://tts.baidu.com/text2audio?lan=en&ie=UTF-8&text="..textc
  local file = download_to_file(url,'SDP_Team.mp3')
 				tdcli.sendDocument(msg.to.id, 0, 0, 1, nil, file, '🆔 Channel ™ : @ap576', dl_cb, nil)
   end
end

 --------------------------------
	if matches[1] == "tr" then 
		url = https.request('https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20160119T111342Z.fd6bf13b3590838f.6ce9d8cca4672f0ed24f649c1b502789c9f4687a&format=plain&lang='..URL.escape(matches[2])..'&text='..URL.escape(matches[3]))
		data = json:decode(url)
		return '🌍 *اللغة :* <<<'..data.lang..'>>>\n➖➖➖➖➖➖➖➖➖➖➖\n📝 *المعني :*《'..data.text[1]..'》\n=======================\n  diamondbot  '
	end
--------------------------------
	if matches[1]:lower() == 'short' then
		if matches[2]:match("[Hh][Tt][Tt][Pp][Ss]://") then
			shortlink = matches[2]
		elseif not matches[2]:match("[Hh][Tt][Tt][Pp][Ss]://") then
			shortlink = "https://"..matches[2]
		end
		local yon = http.request('http://api.yon.ir/?url='..URL.escape(shortlink))
		local jdat = json:decode(yon)
		local bitly = https.request('https://api-ssl.bitly.com/v3/shorten?access_token=f2d0b4eabb524aaaf22fbc51ca620ae0fa16753d&longUrl='..URL.escape(shortlink))
		local data = json:decode(bitly)
		local yeo = http.request('http://yeo.ir/api.php?url='..URL.escape(shortlink)..'=')
		local opizo = http.request('http://api.gpmod.ir/shorten/?url='..URL.escape(shortlink)..'&username=mersad565@gmail.com')
		local u2s = http.request('http://u2s.ir/?api=1&return_text=1&url='..URL.escape(shortlink))
		local llink = http.request('http://llink.ir/yourls-api.php?signature=a13360d6d8&action=shorturl&url='..URL.escape(shortlink)..'&format=simple')
		local text = ' 🌐 لینک اصلی :\n🆎 '..check_markdown(data.data.long_url)..'\n\nلینکهای کوتاه شده با 6 سایت کوتاه ساز لینک :\n___________________________\n》کوتاه شده با bitly :\n🆔 '..check_markdown(data.data.url)..'\n___________________________\n》کوتاه شده با yeo :\n🆔 '..check_markdown(yeo)..'\n___________________________\n》کوتاه شده با اوپیزو :\n🆔 '..check_markdown(opizo)..'\n___________________________\n》کوتاه شده با u2s :\n🆔 '..check_markdown(u2s)..'\n___________________________\n》کوتاه شده با llink : \n🆔 '..check_markdown(llink)..'\n___________________________\n》لینک کوتاه شده با yon : \n🆔 yon.ir/'..check_markdown(jdat.output)..'\n____________________\n⭐ Channel ™ : @ap576\n=======================\n  diamondbot  '
		return tdcli.sendMessage(msg.chat_id_, 0, 1, text, 1, 'html')
	end
--------------------------------
	if matches[1]:lower() == "sticker" then 
		local eq = URL.escape(matches[2])
		local w = "500"
		local h = "500"
		local txtsize = "100"
		local txtclr = "ff2e4357"
		if matches[3] then 
			txtclr = matches[3]
		end
		if matches[4] then 
			txtsize = matches[4]
		end
		if matches[5] and matches[6] then 
			w = matches[5]
			h = matches[6]
		end
		local url = "https://assets.imgix.net/examples/clouds.jpg?blur=150&w="..w.."&h="..h.."&fit=crop&txt="..eq.."&txtsize="..txtsize.."&txtclr="..txtclr.."&txtalign=middle,center&txtfont=Futura%20Condensed%20Medium&mono=ff6598cc"
		local receiver = msg.to.id
		local  file = download_to_file(url,'text.webp')
		tdcli.sendDocument(msg.to.id, 0, 0, 1, nil, file, '', dl_cb, nil)
	end
--------------------------------
	if matches[1]:lower() == "photo" then 
		local eq = URL.escape(matches[2])
		local w = "500"
		local h = "500"
		local txtsize = "100"
		local txtclr = "ff2e4357"
		if matches[3] then 
			txtclr = matches[3]
		end
		if matches[4] then 
			txtsize = matches[4]
		end
		if matches[5] and matches[6] then 
			w = matches[5]
			h = matches[6]
		end
		local url = "https://assets.imgix.net/examples/clouds.jpg?blur=150&w="..w.."&h="..h.."&fit=crop&txt="..eq.."&txtsize="..txtsize.."&txtclr="..txtclr.."&txtalign=middle,center&txtfont=Futura%20Condensed%20Medium&mono=ff6598cc"
		local receiver = msg.to.id
		local  file = download_to_file(url,'text.jpg')
		tdcli.sendPhoto(msg.to.id, 0, 0, 1, nil, file, "🆔 Channel ™ : @ap576", dl_cb, nil)
	end


--------------------------------
if matches[1] == "helpfun" then
local hash = "gp_lang:"..msg.to.id
local lang = redis:get(hash)
if not lang then
helpfun = [[
👑 _Shield Power Fun Help Commands:_ 👑
💜*!info*
💚_Show Your Info_
💜*!time*
💚_Get time in a text & sticker_
💜*!short* `[link]`
💚_Make short url_
💜*!voice* `[text]`
💚_Convert text to voice_
💜*!tr* `[lang] [word]`
💚_Translates FA to EN and EN to FA_
🗣_Example :_
💙*!tr fa hi*
💙*!tr fa hi*
💜*!sticker* `[word]`
💚_Convert text to sticker_
💜*!photo* `[word]`
💚_Convert text to photo_
💜*!azan* `[city]`
💚_Get Azan time for your city_
💜*!calc* `[number]`
💚_Calculator_
💜*!praytime* `[city]`
💚_Get Patent (Pray Time)_
💜*!tosticker* `[reply]`
💚_Convert photo to sticker_
💜*!tophoto* `[reply]`
💚_Convert text to photo_
💜*!weather* `[city]`
💚_Get weather_
💜*!me*
💚_Get your Office_
💜*!echo* `[text]`
💚_Reply your chat_
✅_You can use_ *[!/#]* _at the beginning of commands._
😍*Good luck ;)*
♊️♊️♊️♊️♊️♊️♊️♊️♊️♊️♊️
➣ ♈️️️вΦƮ vęЯsiΦП ••• V 4.0♈️
➣ 👑SHIELD™POWER👑
*_🇸 __🇭__🇮__🇪__🇱__🇩_*
=======================
  diamondbot  ]]
tdcli.sendMessage(msg.chat_id_, 0, 1, helpfun, 1, 'md')
else

helpfun = [[
👑 _راهنمای فان ربات شیلد پاور :_ 👑
💜*!info*
💚_نمایش مشخصات شخصی شما_
💜*!time*
💚_دریافت ساعت به صورت متن و استیکر_
💜*!short* `[link]`
💚_کوتاه کننده لینک_
💜*!voice* `[text]`
💚_تبدیل متن به صدا_
💜*!tr* `[lang]` `[word]`
💚_ترجمه متن فارسی به انگلیسی وبرعکس_
🗣*مثال :*
💙_!tr en سلام_
💙_!tr fa hi_
💜*!sticker* `[word]`
💚_تبدیل متن به استیکر_
💜*!photo* `[word]`
💚_تبدیل متن به عکس_
💜*!azan* `[city]`
💚_دریافت اذان به وقت محلی_
💜*!calc* `[number]`
💚_ماشین حساب_
💜*!praytime* `[city]`
💚_اعلام ساعات شرعی_
💜*!tosticker* `[reply]`
💚_تبدیل عکس به استیکر_
💜*!tophoto* `[reply]`
💚_تبدیل استیکر‌به عکس_
💜*!weather* `[city]`
💚_دریافت اب وهوا_
💜*!me*
💚_نشان دادن مقام شما گروه_
💜*!echo* `[text]`
💚_تکرار چت شما_
✅*شما میتوانید از [!/#] در اول دستورات برای اجرای آنها بهره بگیرید*
😍*موفق باشید* ;)
♊️♊️♊️♊️♊️♊️♊️♊️♊️♊️♊️
➣ ♈️️️вΦƮ vęЯsiΦП ••• V 4.0♈️
➣ 👑SHIELD™POWER👑
*_🇸 __🇭__🇮__🇪__🇱__🇩_*
=======================
  diamondbot  ]]
tdcli.sendMessage(msg.chat_id_, 0, 1, helpfun, 1, 'md')
end

end
end
--------------------------------
return {               
	patterns = {
      "^[!/#](helpfun)$",
    	"^[!/#](طقس) (.*)$",
		"^[#!/](calc) (.*)$",
		"^[#!/](time)$",
		"^[#!/](tophoto)$",
		"^[#!/](tosticker)$",
		"^[!/#](voice) +(.*)$",
		"^[/!#]([Pp]raytime) (.*)$",
		"^[/!#](اوقات صلاة)$",
		"^[/!#](اذان) (.*)$",
		"^[/!#](اذان)$",
		"^[#!/]([Tt]r) ([^%s]+) (.*)$",
		"^[#!/]([Ss]hort) (.*)$",
		"^[#!/](photo) (.+)$",
		"^[#!/](sticker) (.+)$"
		}, 
	run = run,
}