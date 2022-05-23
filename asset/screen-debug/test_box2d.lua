local scene = {}
local debug_shapes = true

local function color(str)
  str = str or "FFFFFF"
  love.graphics.setColor(Utilities.color.hex2color(str))
end

local img = Texture.zzzzz_test.kit_wooden_block

-------------------------------------------------------------------------------------------------------------------

local Wblock = require("library.Quilt.Kit.wooden_blocks")
Wblock.setup({
  -- We can optionally pass the world and callback functions, but this is not required.
  -- world = nil,
  -- beginContact = function(a, b, coll) end,
  -- endContact = function(a, b, coll) end,
  -- preSolve = function(a, b, coll) end,
  -- postSolve = function(a, b, coll, normalimpulse, tangentimpulse)  end,

  -- We can pass x/y/sleep options if we are not passing a world.
  -- world_gravity_x = 0,
   world_gravity_y = 1000,
  -- world_allow_sleep = true,
  meter = 16,

})


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local obj_pool = {}
local list_of_obj_pools = {obj_pool}
obj_pool[#obj_pool+1] = Wblock.create_simple_object({
  x = 0,
  y = BASE_HEIGHT - 10,
  w = BASE_WIDTH,
  h = 10,
  body_type = "static",
  mass = 100,
})
obj_pool[#obj_pool+1] = Wblock.create_simple_object({
  x = 0,
  y = -10,
  w = 10,
  h = BASE_HEIGHT,
  body_type = "static",
  mass = 100,
})
obj_pool[#obj_pool+1] = Wblock.create_simple_object({
  x = BASE_WIDTH - 10,
  y = 0,
  w = 10,
  h = BASE_HEIGHT,
  body_type = "static",
  mass = 100,
})

obj_pool[#obj_pool+1] = Wblock.create_simple_object({
  x = 100,
  y = 100,
  w = 10,
  h = 10,
  body_type = "static",
  mass = 100,
  center_pos = "bottom_right",
})

for v = 1, 5 do
  obj_pool[#obj_pool+1] = Wblock.create_simple_object({
    x = 40 + v*8,
    y = 25 + v,
    radius = 5,
    body_type = "dynamic",
    shape = "circle",
    img = "x10",

  })
end
for v = 1, 5 do
  obj_pool[#obj_pool+1] = Wblock.create_simple_object({
    x = 80 + v*8,
    y = 25 + v,
    w = 10,
    h = 10,
    body_type = "dynamic",
    shape = "rectangle",
    img = "sx10",
    lock_angle = true,
  })
end

Wblock.add_rule("post", "test", function (a, b, coll, normalimpulse, tangentimpulse)

end)




--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function scene:update(dt)
  Utilities.pixel_scale.update(dt)
  Wblock.update(dt, list_of_obj_pools)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function scene:draw()
  Utilities.pixel_scale.start()
  color("000000")
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  color()


  for i=1, #obj_pool do 
    if obj_pool[i].body then
      local s = obj_pool[i].fixture[1]:getUserData().settings
      if s.img then 
        local iw = math.floor(math.abs((img[s.img]:getWidth() - s.w)/2) + 0.5)
        local ih = math.floor(math.abs((img[s.img]:getHeight() - s.h)/2) + 0.5)
        --love.graphics.draw(img[s.img], math.floor(obj_pool[i].body:getX() + 0.5) , math.floor(obj_pool[i].body:getY() + 0.5), obj_pool[i].body:getAngle(), 1, 1, s.w/2 + iw, s.h/2 + ih)
        love.graphics.draw(img[s.img], math.floor(obj_pool[i].body:getX() + 0.5) , math.floor(obj_pool[i].body:getY() + 0.5), obj_pool[i].body:getAngle(), 1, 1, iw, ih)
      end
    end
  end

  -- Draw outlines of shapes. 
  if debug_shapes then 
    Wblock.debug_draw_pool(obj_pool)
  end

  color("00FFFF")
  love.graphics.rectangle("fill", 100, 100, 1, 1)
  color()

  Utilities.pixel_scale.stop()
  Utilities.debug_tools.on_screen_debug_info()
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function scene:keypressed( key, scancode, isrepeat )
  if key == "`" then 
    debug_shapes = not debug_shapes
  end

  if key == "1" then 
    for i=1, #obj_pool do 
      if obj_pool[i].body then
        obj_pool[i].body:applyLinearImpulse(math.random(-40, 40),math.random(-40, 40) )
      end      
    end
  end
  if key == "2" then 
    for i=1, #obj_pool do 
      if obj_pool[i].body then
        obj_pool[i].body:applyAngularImpulse(math.random(1,360))
      end      
    end
  end
  if key == "0" then 
    Wblock.remove_all_from_pool(obj_pool)
  end

end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
return scene

--[[
  Box2D Notes 
static
    Static bodies do not move.
dynamic
    Dynamic bodies collide with all bodies.
kinematic
    Kinematic bodies only collide with dynamic bodies.

WBox.add_rule("begin", "fun", function (a, b, coll)
  print("begin", a, b, coll)
end)

WBox.add_rule("end", "fun", function (a, b, coll) -- don't add remove rules here
  print("end", a, b, coll)
end)

WBox.add_rule("pre", "fun", function (a, b, coll)
  print("pre", a, b, coll)
end)

WBox.add_rule("post", "fun", function (a, b, coll, normalimpulse, tangentimpulse)
  print("post", a, b, coll, normalimpulse, tangentimpulse)
end)

WBox.remove_rule("begin", "fun")
WBox.remove_rule("end", "fun")
WBox.remove_rule("pre", "fun")
WBox.remove_rule("post", "fun")


WBox.add_rule("post", "test", function (a, b, coll, normalimpulse, tangentimpulse)
  WBox.add_pre_update("bounce", function ()
    if a:getUserData().settings.body_type == "dynamic" and normalimpulse > 25 then
     a:getUserData().remove = true  
    end 
  end)
end)
]]--