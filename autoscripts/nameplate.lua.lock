local from = vectors.hexToRGB("#D11E2B") 
local to = vectors.hexToRGB("#891E2B")
local prefix = '{"text":"${badges}:@scarlet:","color":"white"}'
local name = avatar:getEntityName()
local suffix = ""
local mid = ""
for i = 1, #name, 1 do
   local r = i/#name
   local hex = vectors.rgbToHex(
      vectors.vec3(
         math.lerp(from.x,to.x,r),
         math.lerp(from.y,to.y,r),
         math.lerp(from.z,to.z,r)
      )
   )
   mid = mid .. '{"text":"'..name:sub(i,i)..'","color":"#' .. hex .. '"}'
   if i ~= #name then
      mid = mid .. ","
   end
end

local lsyst = client:getSystemTime()

local ls = 0
local s = 1
events.TICK:register(function ()
   if IS_AFK then
      local csyst = client:getSystemTime()
      s = math.floor((csyst-TIME_SINCE_INACTIVE)/1000)
      if ls ~= s then
         local disp_time = ""
         local minute = math.floor(s / 60)
         
         if minute ~= 0 then
            local hour = math.floor(minute / 60)
            if hour ~= 0 then
               local day = math.floor(hour / 24)
               if day ~= 0 then
                  local year = math.floor(day / 356)
                  if year ~= 0 then
                     local century = math.floor(year / 100)
                     if century ~= 0 then
                        disp_time = century.."cnt " .. (year % 100).."yr " .. (day % 356).."dy " .. (hour % 24).."hr " .. (minute % 60) .."m " .. (s % 60) .."s"
                     else
                        disp_time = year.."yr " .. (day % 31).."dy " .. (hour % 24).."hr " .. (minute % 60).."m " .. (s % 60) .."s"
                     end
                  else
                     disp_time = (day % 31).."dy " .. (hour % 24).."hr " .. (minute % 60).."m " .. (s % 60) .."s"
                  end
               else
                  disp_time = (hour % 24).."hr " .. (minute % 60).."m " .. (s % 60) .."s"
               end
            else
               disp_time = (minute % 60).."m " .. (s % 60) .."s"
            end
         else
            disp_time = s.."s"
         end
         suffix = '{"text":"\n[zZzZ : '.. disp_time ..']","color":"gray"}'
      end
   else
      suffix = '{"text":""}'
   end
   nameplate.ALL:setText('[' .. prefix .. ',' .. mid .. ',' .. suffix .. ']')
   ls = s
end)

nameplate.ENTITY:backgroundColor(0,0,0,0)
nameplate.ENTITY:shadow(true)