
local default_texture = textures:newTexture("1x1white",1,1):setPixel(0,0,vectors.vec3(1,1,1))
local eventLib = require("libraries.eventLib")
local utils = require("libraries.gnui.utils")
local core = require("libraries.gnui.core")


---@class Sprite
---@field Texture Texture
---@field Modelpart ModelPart?
---@field UV Vector4
---@field Size Vector2
---@field Position Vector3
---@field Color Vector3
---@field Scale number
---@field RenderTasks table<any,SpriteTask>
---@field RenderType ModelPart.renderType
---@field BorderThickness Vector4
---@field ExcludeMiddle boolean
---@field Visible boolean
---@field TEXTURE_CHANGED eventLib
---@field MODELPART_CHANGED eventLib
---@field DIMENSIONS_CHANGED eventLib
---@field BORDER_THICKNESS_CHANGED eventLib
---@field protected texture_applied boolean
---@field id integer
local sprite = {}
sprite.__index = sprite

local sprite_next_free = 0
---@param texture Texture?
---@param UVx number?
---@param UVy number?
---@param UVz number?
---@param UVw number?
---@return Sprite
function sprite.new(texture,UVx,UVy,UVz,UVw)
   local new = {}
   setmetatable(new,sprite)
   new.Texture                  = texture or default_texture
   new.TEXTURE_CHANGED          = eventLib.new()
   new.MODELPART_CHANGED        = eventLib.new()
   new.Position                 = vectors.vec3()
   new.UV                       = vectors.vec4(UVx or 0, UVy or 0, UVz or 1, UVw or 1)
   new.Size                     = vectors.vec2(16,16)
   new.Color                    = vectors.vec3(1,1,1)
   new.Scale                    = 1
   new.DIMENSIONS_CHANGED       = eventLib.new()
   new.RenderTasks              = {}
   new.RenderType               = "CUTOUT_EMISSIVE_SOLID"
   new.BorderThickness          = vectors.vec4(0,0,0,0)
   new.BORDER_THICKNESS_CHANGED = eventLib.new()
   new.ExcludeMiddle            = false
   new.Cursor                   = vectors.vec2()
   new.CURSOR_CHANGED           = eventLib.new()
   new.Visible                  = true
   new.texture_applied          = false
   new.id                       = sprite_next_free
   sprite_next_free = sprite_next_free + 1
   
   new.TEXTURE_CHANGED:register(function ()
      new:_applyTexture()
      new:_updateRenderTasks()
   end,core.internal_events_name)

   new.BORDER_THICKNESS_CHANGED:register(function ()
      new:_deleteRenderTasks()
      new:_buildRenderTasks()
   end,core.internal_events_name)
   
   new.DIMENSIONS_CHANGED:register(function ()
      new:_updateRenderTasks()
   end,core.internal_events_name)

   return new
end

---Sets the modelpart to parent to.
---@param part ModelPart
---@return Sprite
function sprite:setModelpart(part)
   if self.Modelpart then
      self.Modelpart:_deleteRenderTasks()
   end
   self.Modelpart = part
   self:_buildRenderTasks()
   self.MODELPART_CHANGED:invoke(self.Modelpart)
   return self
end


---Sets the displayed image texture on the sprite.
---@param texture Texture
---@return Sprite
function sprite:setTexture(texture)
   if type(texture) ~= "Texture" then error("Invalid texture, recived "..type(texture)..".",2) end
   self.Texture = texture
   local dim = texture:getDimensions()
   self.UV = vectors.vec4(0,0,dim.x-1,dim.y-1)
   self.TEXTURE_CHANGED:invoke(self,self.Texture)
   return self
end

---Sets the position of the Sprite, relative to its parent.
---@param xpos number
---@param y number
---@param depth number?
---@return Sprite
function sprite:setPos(xpos,y,depth)
   self.Position = utils.figureOutVec3(xpos,y,depth or 0)
   self.DIMENSIONS_CHANGED:invoke(self,self.Position,self.Size)
   return self
end

---Tints the Sprite multiplicatively
---@overload fun(self : self, rgb : Vector3): Sprite
---@param r number
---@param g number
---@param b number
---@return Sprite
function sprite:setColor(r,g,b)
   self.Color = utils.figureOutVec3(r,g,b)
   self.DIMENSIONS_CHANGED:invoke(self,self.Position,self.Size)
   return self
end

---Sets the size of the sprite duh.
---@param xpos number
---@param y number
---@return Sprite
function sprite:setSize(xpos,y)
   self.Size = utils.figureOutVec2(xpos,y)
   self.DIMENSIONS_CHANGED:invoke(self,self.Position,self.Size)
   return self
end

---@param scale number
---@return Sprite
function sprite:setScale(scale)
   self.Scale = scale
   self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
   return self
end

-->====================[ Border ]====================<--

---Sets the top border thickness.
---@param units number?
---@return Sprite
function sprite:setBorderThicknessTop(units)
   self.BorderThickness.y = units or 0
   self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
   return self
end

---Sets the left border thickness.
---@param units number?
---@return Sprite
function sprite:setBorderThicknessLeft(units)
   self.BorderThickness.x = units or 0
   self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
   return self
end

---Sets the down border thickness.
---@param units number?
---@return Sprite
function sprite:setBorderThicknessDown(units)
   self.BorderThickness.z = units or 0
   self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
   return self
end

---Sets the right border thickness.
---@param units number?
---@return Sprite
function sprite:setBorderThicknessRight(units)
   self.BorderThickness.w = units or 0
   self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
   return self
end

---Sets the padding for all sides.
---@param left number?
---@param top number?
---@param right number?
---@param bottom number?
---@return Sprite
function sprite:setBorderThickness(left,top,right,bottom)
   self.BorderThickness.x = left   or 0
   self.BorderThickness.y = top    or 0
   self.BorderThickness.z = right  or 0
   self.BorderThickness.w = bottom or 0
   self.BORDER_THICKNESS_CHANGED:invoke(self,self.BorderThickness)
   return self
end

---Sets the UV region of the sprite.
--- if x2 and y2 are missing, they will use x and y as a substitute
---@overload fun(self : Sprite, vec4 : Vector4): Sprite
---@param x number
---@param y number
---@param x2 number
---@param y2 number
---@return Sprite
function sprite:setUV(x,y,x2,y2)
   self.UV = utils.figureOutVec4(x,y,x2 or x,y2 or y)
   self.DIMENSIONS_CHANGED:invoke(self.BorderThickness)
   return self
end

---Sets the render type of your sprite
---@param renderType ModelPart.renderType
---@return Sprite
function sprite:setRenderType(renderType)
   self.RenderType = renderType
   self:_deleteRenderTasks()
   self:_buildRenderTasks()
   return self
end

---Set to true if you want a hole in the middle of your ninepatch
---@param toggle boolean
---@return Sprite
function sprite:excludeMiddle(toggle)
   self.ExcludeMiddle = toggle
   return self
end


---Copies the given source, except the events
---@param s Sprite
function sprite:copy(s)
   self:setTexture(s.Texture)
   self:setUV(s.UV.x,s.UV.y,s.UV.z,s.UV.w)
   self:setPos(s.Position.x,s.Position.y,s.Position.z)
   self:setColor(s.Color.x,s.Color.y,s.Color.z)
   self:setScale(s.Scale)
   self:setBorderThickness(s.BorderThickness.x,s.BorderThickness.y,s.BorderThickness.z,s.BorderThickness.w)
   return self
end

function sprite:duplicate()
   local clone = self.new():copy(self)
   return clone
end

function sprite:setVisible(visibility)
   sprite:_applyVisibility()
   self.Visible = visibility
   return self
end

---@return self
function sprite:_deleteRenderTasks()
   for _, task in pairs(self.RenderTasks) do
      self.Modelpart:removeTask(task:getName())
   end
   return self
end

---@protected
---@return self
function sprite:_applyMisc()
   if not self.Modelpart or not self.Texture then return self end
   for _, task in pairs(self.RenderTasks) do
      task
      :setColor(self.Color)
      :setRenderType(self.RenderType)
   end
   return self
end

---@protected
---@return self
function sprite:_buildRenderTasks()
   if not self.Modelpart or not self.Texture then return self end
   local b = self.BorderThickness
   self.is_ninepatch = not (b.x == 0 and b.y == 0 and b.z == 0 and b.w == 0)
   if not self.is_ninepatch then -- not 9-Patch
      self.RenderTasks[1] = self.Modelpart:newSprite("patch"..self.id)
   else
      self.RenderTasks = {
         self.Modelpart:newSprite("patch_tl"..self.id),
         self.Modelpart:newSprite("patch_t" ..self.id),
         self.Modelpart:newSprite("patch_tr"..self.id),
         self.Modelpart:newSprite("patch_ml"..self.id),
         self.Modelpart:newSprite("patch_m" ..self.id),
         self.Modelpart:newSprite("patch_mr"..self.id),
         self.Modelpart:newSprite("patch_bl"..self.id),
         self.Modelpart:newSprite("patch_b" ..self.id),
         self.Modelpart:newSprite("patch_br"..self.id),
      }
   end
   self:_applyTexture()
   return self
end

---@protected
---@return self
function sprite:_applyTexture()
   if not self.Modelpart or not self.Texture then return self end
   local d = self.Texture:getDimensions()
   for _, task in pairs(self.RenderTasks) do
      task:setTexture(self.Texture,d.x,d.y)
   end
   local res = self.Texture:getDimensions()
   local uv = self.UV:copy():add(0,0,1,1)
   if not self.is_ninepatch then
      self.RenderTasks[1]
      :setColor(self.Color)
      :setRenderType(self.RenderType)
      :setUVPixels(
         uv.x,
         uv.y
      ):region(
         uv.z-uv.x,
         uv.w-uv.y
      )
   else
      local border = self.BorderThickness             --border, used in UVs
      local uvsize = vectors.vec2(uv.z-uv.x,uv.w-uv.y)
      self.RenderTasks[1]:setUVPixels(
         uv.x,
         uv.y
      ):region(
         border.x,
         border.y
      )
      
      self.RenderTasks[2]:setUVPixels(
         uv.x+border.x,
         uv.y
      ):region(
         uvsize.x-border.x-border.z,
         border.y
      )

      self.RenderTasks[3]:setUVPixels(
         uv.z-border.z,
         uv.y
      ):region(
         border.z,
         border.y
      )

      self.RenderTasks[4]:setUVPixels(
         uv.x,
         uv.y+border.y
      ):region(
         border.x,
         uvsize.y-border.y-border.w
      )
      if not self.ExcludeMiddle then
         self.RenderTasks[5]:setUVPixels(
            uv.x+border.x,
            uv.y+border.y
         ):region(
            uvsize.x-border.x-border.z,
            uvsize.y-border.y-border.w
         )
      else
         self.RenderTasks[5]:setVisible(false)
      end

      self.RenderTasks[6]:setUVPixels(
         uv.z-border.z,
         uv.y+border.y
      ):region(
         border.z,
         uvsize.y-border.y-border.w
      )
      
      
      self.RenderTasks[7]:setUVPixels(
         uv.x,
         uv.w-border.w
      ):region(
         border.x,
         border.w
      )

      self.RenderTasks[8]
      :setUVPixels(
         uv.x+border.x,
         uv.w-border.w
      ):region(
         uvsize.x-border.x-border.z,
         border.w
      )

      self.RenderTasks[9]
      :setUVPixels(
         uv.z-border.z,
         uv.w-border.w
      ):region(
         border.z,
         border.w
      )
   end
   return self
end

---@protected
---@return self
function sprite:_applyVisibility()
   if not self.Modelpart then return self end
   for _, task in pairs(self.RenderTasks) do
      task:setVisible(self.Visible)
   end
   return self
end

function sprite:_updateRenderTasks()
   if not self.Modelpart then return self end
   if not self.texture_applied then
      self:_applyTexture()
      self.texture_applied = true
   end
   local res = self.Texture:getDimensions()
   local uv = self.UV:copy():add(0,0,1,1)
   if not self.is_ninepatch then
      self.RenderTasks[1]
      :setPos(self.Position)
      :setScale(self.Size.x/res.x,self.Size.y/res.y)
      :setColor(self.Color)
      :setRenderType(self.RenderType)
      :setUVPixels(
         uv.x,
         uv.y
      ):region(
         uv.z-uv.x,
         uv.w-uv.y
      )
   else
      local sborder = self.BorderThickness*self.Scale --scaled border, used in rendering
      local pos = self.Position
      local size = self.Size
      for _, task in pairs(self.RenderTasks) do
         task
         :setColor(self.Color)
         :setRenderType(self.RenderType)
      end
      self.RenderTasks[1]
      :setPos(
         pos
      ):setScale(
         sborder.x/res.x,
         sborder.y/res.y)
      
      self.RenderTasks[2]
      :setPos(
         pos.x-sborder.x,
         pos.y,
         pos.z
      ):setScale(
         (size.x-sborder.z-sborder.x)/res.x,
         sborder.y/res.y)

      self.RenderTasks[3]
      :setPos(
         pos.x-size.x+sborder.z,
         pos.y,
         pos.z
      ):setScale(
         sborder.z/res.x,sborder.y/res.y)

      self.RenderTasks[4]
      :setPos(
         pos.x,
         pos.y-sborder.y,
         pos.z
      ):setScale(
         sborder.x/res.x,
         (size.y-sborder.y-sborder.w)/res.y
      )
      if not self.ExcludeMiddle then
         self.RenderTasks[5]
         :setPos(
            pos.x-sborder.x,
            pos.y-sborder.y,
            pos.z
         )
         :setScale(
            (size.x-sborder.x-sborder.z)/res.x,
            (size.y-sborder.y-sborder.w)/res.y
         )
      else
         self.RenderTasks[5]:setVisible(false)
      end

      self.RenderTasks[6]
      :setPos(
         pos.x-size.x+sborder.z,
         pos.y-sborder.y,
         pos.z
      )
      :setScale(
         sborder.z/res.x,
         (size.y-sborder.y-sborder.w)/res.y
      )
      
      
      self.RenderTasks[7]
      :setPos(
         pos.x,
         pos.y-size.y+sborder.w,
         pos.z
      )
      :setScale(
         sborder.x/res.x,
         sborder.w/res.y
      )

      self.RenderTasks[8]
      :setPos(
         pos.x-sborder.x,
         pos.y-size.y+sborder.w,
         pos.z
      ):setScale(
         (size.x-sborder.z-sborder.x)/res.x,
         sborder.w/res.y
      )

      self.RenderTasks[9]
      :setPos(
         pos.x-size.x+sborder.z,
         pos.y-size.y+sborder.w,
         pos.z
      ):setScale(
         sborder.z/res.x,
         sborder.w/res.y
      )
   end
   return self
end

return sprite