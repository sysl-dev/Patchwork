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
  -- We can pass x/y/sleep options if we are not passing a world.
  world_gravity_x = 0,
  world_gravity_y = 1000,
  world_allow_sleep = true,
  pixels_per_meter = 16,
  maxdt = 1/15,
  pause = false,
})


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
scene.object_pool = {}
scene.joint_pool = {}

scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
  x = 0,
  y = BASE_HEIGHT - 10,
  w = BASE_WIDTH,
  h = 10,
  body_type = "static",
  img = "wall",
  __scale = true,
})
scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
  x = 0,
  y = -10,
  w = 10,
  h = BASE_HEIGHT,
  body_type = "static",
  img = "floor",
  __scale = true,
})
scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
  x = BASE_WIDTH - 10,
  y = 0,
  w = 10,
  h = BASE_HEIGHT,
  body_type = "static",
  img = "wall",
})


  scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
    x = 150,
    y = 122,
    w = 64,
    h = 4,
    body_type = "dynamic",
    shape = "rectangle",
    __scale = true,
    name = "dave",
    img = "wall",
  })
  scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
    x = 150 + 32 - 4,
    y = 126,
    w = 8,
    h = 8,
    body_type = "static",
    shape = "triangle",
    __scale = true,
  })
  
  scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
    x = 40 + 32 - 4,
    y = 126,
    w = 16,
    h = 8,
    body_type = "dynamic",
    shape = "glass",
    __scale = true,
  })
  
  scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
    x = 195,
    y = 0,
    w = 16,
    h = 16,
    body_type = "dynamic",
    shape = "star",
    __scale = true,
    name = "star",
    density = 1,
  })
  scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
    x = 160,
    y = -100,
    w = 16,
    h = 16,
    body_type = "dynamic",
    shape = "moon",
    __scale = true,
    bullet = true,
    density = 20,
  })



  -- Joints should create 


  scene.joint_pool[#scene.joint_pool + 1] = love.physics.newRevoluteJoint(scene.object_pool[5].body, scene.object_pool[5-1].body, scene.object_pool[5].settings.cx+0, scene.object_pool[5].settings.cy-4, true)



Wblock.add_rule("pre", "test", function (a, b, coll)

end)

Wblock.add_rule("post", "test", function (a, b, coll, normalimpulse, tangentimpulse)

end)

Wblock.add_rule("begin", "test", function (a, b, coll)

end)

Wblock.add_rule("end", "test", function (a, b, coll)

end)




--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function scene:update(dt)

  if not run_right_away then 
    dt = 0
  end

  if scene.joint_pool.mouse then 
    scene.joint_pool.mouse:setTarget(Utilities.pixel_scale.mouse.x, Utilities.pixel_scale.mouse.y)
  end
  Utilities.pixel_scale.update(dt)
  Wblock.update(dt, scene.object_pool, scene.joint_pool)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function scene:draw()
  Utilities.pixel_scale.start()
  color("000000")
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  color()

  Wblock.draw(scene.object_pool, {image_table = Texture.zzzzz_test.kit_wooden_block})


  -- Draw outlines of shapes. 
  if debug_shapes then 
    Wblock.debug_draw_pool(scene.object_pool, debug_name, scene.joint_pool)
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
    for i=1, #scene.object_pool do 
      if scene.object_pool[i].body then
        scene.object_pool[i].body:applyLinearImpulse(math.random(-40, 40),math.random(-40, 40) )
      end      
    end
  end
  if key == "2" then 
    for i=1, #scene.object_pool do 
      if scene.object_pool[i].body then
        scene.object_pool[i].body:applyAngularImpulse(math.random(1,360))
      end      
    end
  end
  if key == "3" then 
    for i=1, #scene.object_pool do 
      if scene.object_pool[i].body then
        scene.object_pool[i].body:applyLinearImpulse(0, -50)
      end      
    end
  end
  if key == "0" then 
    scene.joint_pool.mouse = nil 
    Wblock.remove_all_from_pool(scene.object_pool)
  end
  if key == "9" then 
    print("Object Pool")
    for k,v in pairs(scene.object_pool) do 
      print(k,v)
    end
    print("Joint Pool")
    for k,v in pairs(scene.joint_pool) do 
      print(k,v)
    end
    print("World Body List", Wblock.world:getBodyCount())
    for k,v in pairs(Wblock.world:getBodies()) do 
      print(k,v)
    end
    print("World Joint List", Wblock.world:getJointCount())
    for k,v in pairs(Wblock.world:getJoints()) do 
      print(k,v)
    end
    
  end
  if key == "space" then 
    run_right_away = true
  end
end

function scene:mousepressed(x,y,button)
  if button == 1 then 
    Wblock.world:queryBoundingBox(Utilities.pixel_scale.mouse.x, Utilities.pixel_scale.mouse.y, Utilities.pixel_scale.mouse.x + 1, Utilities.pixel_scale.mouse.y + 1, function(f) 
      local fnum = false
      print(f) 
      print(f:getBody():getUserData().fixture)
      for i=1, #f:getBody():getUserData().fixture do 
        print(f:getBody():getUserData().fixture[i]:testPoint(Utilities.pixel_scale.mouse.x, Utilities.pixel_scale.mouse.y ))
        if f:getBody():getUserData().fixture[i]:testPoint(Utilities.pixel_scale.mouse.x, Utilities.pixel_scale.mouse.y) then 
          fnum = true
        end
      end
      if scene.joint_pool.mouse then 
        local bodya, bodyb = scene.joint_pool.mouse:getBodies()
        print("b", bodya)
        print("gud", bodya:getUserData())

          bodya:setFixedRotation(bodya:getUserData().settings.lock_angle)
          print(bodya)
          print(bodyb)

        scene.joint_pool.mouse:destroy()
        scene.joint_pool.mouse = nil
      end
      if fnum then 
        scene.joint_pool.mouse = love.physics.newMouseJoint(f:getBody(), Utilities.pixel_scale.mouse.x, Utilities.pixel_scale.mouse.y)
        f:getBody():getUserData().body:setFixedRotation(true)
      end
      return not fnum
    
    end )
  end
  if button == 2 then 
      Wblock.add_pre_update("toot", function()      
        if scene.joint_pool.mouse then 
          local bodya, bodyb = scene.joint_pool.mouse:getBodies()
          print("b", bodya)
          print("gud", bodya:getUserData())

            bodya:setFixedRotation(bodya:getUserData().settings.lock_angle)
            print(bodya)
            print(bodyb)

          scene.joint_pool.mouse:destroy()
          scene.joint_pool.mouse = nil
        end
    end)
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