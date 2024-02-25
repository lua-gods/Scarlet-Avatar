vanilla_model.ARMOR:setVisible(false)
vanilla_model.HELMET_ITEM:setVisible(true)
nameplate.ENTITY:shadow(true)

vanilla_model.ELYTRA:setVisible(false)
vanilla_model.HAT:setVisible(false)
vanilla_model.PLAYER:setVisible(false)

--models.sl.Torso.Head.mouth:setUV(0,1/11)

local root = action_wheel:newPage()

root:newAction():title("Wave"):item("minecraft:paper").leftClick = function ()
   pings.wave()
end

function pings.wave()
   animations.sl.wave:play()
end

action_wheel:setPage(root)

models.hat.hat.top.item:newItem("Feather"):setItem("minecraft:feather"):scale(0.5):rot(90,180,0):pos(2,0,-3)

local eye_height = 22 / 16
local body_size = 0.9

local r = 1/body_size
models.sl:scale(body_size,body_size,body_size)
models.sl.Torso.Hed:scale(r,r,r)
renderer:offsetCameraPivot(0,eye_height * body_size - eye_height,0)
renderer:setEyeOffset(0,eye_height * body_size - eye_height,0)
renderer:setShadowRadius(body_size*0.5)

avatar:store("hair_color",vectors.hexToRGB("#522933"))
avatar:store("plushie_height",10)