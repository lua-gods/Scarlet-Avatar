local profiler = {
   marks = {},
   results = {},
}

require("libraries.debug.query")

---@param name string
function profiler.mark(name)
   profiler.marks[name] = client.getSystemTime()
end

---@param name string
function profiler.stop(name)
   profiler.results[name] = (profiler.results[name] or 0) + (client.getSystemTime() - profiler.marks[name])
end

local function results()
   local result = {}
   local i = 0
   local baseline = profiler.results.baseline or 0
   profiler.results.baseline = nil
   local sum = query.list(profiler.results):reduce(query.sum)
   local n = #utils.list(profiler.results)
   result[#result+1] = "§eProfiler §7» §aresults\n"
   local results = {}
   for k, v in pairs(profiler.results) do
       results[#results+1] = { k, v }
   end
   table.sort(results, function(a, b) return a[2] > b[2] end)
   for i = 1, #results do
       local k, v = table.unpack(results[i])
       result[#result+1] = "§7" .. (i == n and "└" or "├") .. "§r" .. k .. "§7: §r" .. (v - baseline) .. "§7 ms (" .. math.floor((v - baseline) / sum * 100) .. "%)\n"
   end
   return result
end

function profiler.log()
   logJson(toJson(results()))
end

local gui = models:newPart("profiler_readout", "GUI")
function profiler.readout(val)
   if val == false then
       gui:visible(false):removeTask()
       return
   end

   local result = toJson(results())
   gui:newText("profiler_readout_text"):pos(-2, -2, -20):text(result):shadow(true)
end

_G.profiler = profiler