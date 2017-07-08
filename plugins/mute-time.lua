-- http://permag.ir
-- @permag_ir
-- @permag_bots
 --Begin MuteTime.lua By @MahDiRoO
local function pre_process(msg)
  local hash = 'mute_time:'..msg.chat_id_
  if redis:get(hash) and gp_type(msg.chat_id_) == 'channel' and not is_mod(msg)  then
    tdcli.deleteMessages(msg.chat_id_, {[0] = tonumber(msg.id_)})
  end
 end
 
local function run(msg, matches)
  if matches[1]:lower() == 'mt' and is_mod(msg) or matches[1]:lower() == 'صامت' and is_mod(msg) then
     local hash = 'mute_time:'..msg.chat_id_
     if not matches[2] then
		return "_رجاء قم بإدخال الساعات و الدقائق!_"
  else
     local hour = string.gsub(matches[2], 'h', '')
     local num1 = tonumber(hour) * 3600
     local minutes = string.gsub(matches[3], 'm', '')
     local num2 = tonumber(minutes) * 60
     local num4 = tonumber(num1 + num2)
	 redis:setex(hash, num4, true)
     return "⛔️المجموعة صامتة لمدة : \n`"..matches[2].."` ساعات\n`"..matches[3].."` دقيقة \n `لا تنسی ذکر الله`"
    end
  end
  if matches[1]:lower() == 'unmt' and is_mod(msg) or matches[1]:lower() == 'الغاء صامت' and is_mod(msg) then
     local hash = 'mute_time:'..msg.chat_id_
     redis:del(hash)
     return "*✅تم فتح المجموعة.*"
  end
end
return {
   patterns = {
      '^[/!#]([Mm][Tt])$',
      '^[/!#]([Uu][Nn][Mm][Tt])$',
	  '^[/!#]([Mm][Tt]) (%d+) (%d+)$',
      '^([Mm][Tt])$',
      '^([Uu][Nn][Mm][Tt])$',
	  '^([Mm][Tt]) (%d+) (%d+)$',
	  '^(صامت)$',
      '^(الغاء صامت)$',
	  '^(صامت) (%d+) (%d+)$',
 },
  run = run,
  pre_process = pre_process
}