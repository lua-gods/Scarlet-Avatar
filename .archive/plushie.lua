local config = {
   scale = 1.2,
   check_block = vec(0,-1,0),
   block_sound = {
      ["minecraft:bone_block"] = "grill"
   }
}
models.plushie:setScale(config.scale,config.scale,config.scale)

local rplushies = {}
local plushies = {}
local blockmap = {}
local lastblockmap = {}
local playing_sounds = {}

events.WORLD_RENDER:register(function(dt)
   plushies = rplushies
   rplushies = {}
end)

function table.shallowcopy(orig)
   local orig_type = type(orig)
   local copy
   if orig_type == 'table' then
       copy = {}
       for orig_key, orig_value in pairs(orig) do
           copy[orig_key] = orig_value
       end
   else -- number, string, boolean, etc
       copy = orig
   end
   return copy
end

events.SKULL_RENDER:register(function(dt,block)
   models.plushie:setScale(1,1,1)
   if block then
      local pos = block:getPos()
      table.insert(rplushies,pos)
      local b = lastblockmap[tostring(pos)]
      if b then
         if b.id == "minecraft:note_block" then
            if b.properties.powered == "true" then
               models.plushie:setScale(math.random()*0.5+1,math.random()*0.5+1,math.random()*0.5+1)
               if world.getBlockState(pos:add(0,-2,0)).id == "minecraft:bone_block" then
                  particles:newParticle("minecraft:campfire_cosy_smoke",vec(pos.x+0.5,pos.y,pos.z+0.5,0,0.2,0))
               end
            end
         end
      end
   end
end)

events.WORLD_TICK:register(function()
   lastblockmap = blockmap
   blockmap = {}
   for key, pos in pairs(plushies) do
      local b = world.getBlockState(pos+config.check_block)
      if b.id == "minecraft:note_block" then
         local data = table.shallowcopy(b.properties)
         data.pos = pos
         blockmap[tostring(b:getPos())] = data
      end
   end
   for pos, p in pairs(blockmap) do
      if lastblockmap[pos] then
         local lp = lastblockmap[pos]
         if (p.powered == "true" and lp.powered == "false") then
            if not playing_sounds[tostring(p.pos)] then
               local pitch = 2^((p.note-12)/12)
               local sound = "wavy"
               local block_bellow_noteblock = world.getBlockState(p.pos+config.check_block-vec(0,1,0))
               for block, sname in pairs(config.block_sound) do
                  if block == block_bellow_noteblock.id then
                     sound = sname
                  end
               end
               local new = sounds:playSound(sound,p.pos,1,pitch,true)
               playing_sounds[tostring(p.pos)] = {goal_volume=2,volume=0,pitch=pitch,goal_pitch=pitch,audio=new}
            else
               playing_sounds[tostring(p.pos)].goal_volume = 2
            end
         end
         if (p.powered == "false" and lp.powered == "true") then
            local s = playing_sounds[tostring(p.pos)]
            if s then
               s.goal_volume = 0
            end
         end
         if p.powered == "true" then
            if p.note ~= lastblockmap[pos].note then
               if playing_sounds[tostring(p.pos)] and playing_sounds[tostring(p.pos)].goal_pitch then
                  playing_sounds[tostring(p.pos)].goal_pitch = (2^((p.note-12)/12))
               end
            end
         end
      end
   end
   for key, s in pairs(playing_sounds) do
      s.volume = math.lerp(s.volume,s.goal_volume,0.4)
      s.pitch = math.lerp(s.pitch,s.goal_pitch,0.4)

      if s.volume < 0.05 then
         playing_sounds[key].audio:stop()
         playing_sounds[key] = nil
      end
      s.audio:volume(s.volume)
      s.audio:pitch(s.pitch)
   end
end)