for key, value in pairs(listFiles("autoscripts")) do
   require(value)
end

for key, value in pairs(listFiles("apps")) do
   require(value)
end

models.sl:newSprite("test"):setTexture(textures["textures.endesga"]):setPos(0,32,0)