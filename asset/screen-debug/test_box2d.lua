local scene = {}
local debug_shapes = true
local debug_name = false
local run_right_away = true

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
  img = "wall",
  __scale = true,
})
obj_pool[#obj_pool+1] = Wblock.create_simple_object({
  x = 0,
  y = -10,
  w = 10,
  h = BASE_HEIGHT,
  body_type = "static",
  img = "floor",
  __scale = true,
})
obj_pool[#obj_pool+1] = Wblock.create_simple_object({
  x = BASE_WIDTH - 10,
  y = 0,
  w = 10,
  h = BASE_HEIGHT,
  body_type = "static",
  img = "wall",
})


  obj_pool[#obj_pool+1] = Wblock.create_simple_object({
    x = 150,
    y = 120,
    w = 64,
    h = 4,
    body_type = "dynamic",
    shape = "rectangle",
    __scale = true,
    density = 0.2,
  })
  obj_pool[#obj_pool+1] = Wblock.create_simple_object({
    x = 150 + 32 - 4,
    y = 124,
    w = 8,
    h = 8,
    body_type = "dynamic",
    shape = "triangle",
    __scale = true,
    density = 5,
  })
  
  obj_pool[#obj_pool+1] = Wblock.create_simple_object({
    x = 195,
    y = 0,
    w = 8,
    h = 8,
    body_type = "dynamic",
    shape = "triangle",
    __scale = true,
    name = "saw"
  })
  obj_pool[#obj_pool+1] = Wblock.create_simple_object({
    x = 160,
    y = -100,
    w = 8,
    h = 8,
    body_type = "dynamic",
    shape = "triangle",
    __scale = true,
    bullet = true,
  })
  obj_pool[#obj_pool+1] = Wblock.create_simple_object({
    x = 0,
    y = 0,
    w = 2,
    h = 2,
    body_type = "dynamic",
    shape = "rectangle",
    sensor = true,
    __scale = true,
    bullet = true,
    gravity_scale = 0,
    name = "mouse_boy"
  })

  -- Joints should create 


  obj_pool[#obj_pool].joint = {love.physics.newRevoluteJoint(obj_pool[5].body, obj_pool[5-1].body, obj_pool[5].settings.cx+0, obj_pool[5].settings.cy-4, true)}



Wblock.add_rule("pre", "test", function (a, b, coll)



end)

Wblock.add_rule("post", "test", function (a, b, coll, normalimpulse, tangentimpulse)

end)

Wblock.add_rule("begin", "test", function (a, b, coll)
  if b:getUserData().settings.name == "mouse_boy" or a:getUserData().settings.name == "mouse_boy" then 
    if a:getUserData().settings.name == "mouse_boy" then 
    else 

    end
    if b:getUserData().settings.name == "mouse_boy" then 
    else 

    end

  end
end)

Wblock.add_rule("end", "test", function (a, b, coll)


end)




--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function scene:update(dt)
  if dt > 1/29 then return end
  if not run_right_away then 
    dt = 0
  end
  obj_pool[#obj_pool].body:setX(Utilities.pixel_scale.mouse.x) 
  obj_pool[#obj_pool].body:setY(Utilities.pixel_scale.mouse.y) 

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

  Wblock.draw(list_of_obj_pools)


  -- Draw outlines of shapes. 
  if debug_shapes then 
    Wblock.debug_draw_pool(obj_pool, debug_name)
  end


  color("00FFFF")
  love.graphics.rectangle("fill", Utilities.pixel_scale.mouse.x, Utilities.pixel_scale.mouse.y, 1, 1)
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
  if key == "3" then 
    for i=1, #obj_pool do 
      if obj_pool[i].body then
        obj_pool[i].body:applyLinearImpulse(0, -50)
      end      
    end
  end
  if key == "0" then 
    Wblock.remove_all_from_pool(obj_pool)
  end
  if key == "9" then 
    run_right_away = true
  end
end

function scene:mousepressed(x,y,button)
  if button == 1 then 

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