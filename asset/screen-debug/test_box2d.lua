local scene = {}
local Wb = require("library.Quilt.Kit.Wooden_Blocks")
Wb.setup({
  world_gravity_x = 0, -- Gravity V (Negitive is ^)
  world_gravity_y = 320, -- Gravity > (Negitive is <)
  world_allow_sleep = true, -- Allow non-moving objects to sleep. (Likely will always be true)
  pixels_per_meter = 16, -- How big is a meter in your world in pixels.
  mouse = {Pixelscreen.mouse.get_x, Pixelscreen.mouse.get_y}, -- Using a non-standard mouse? Pass the function here.
  pause = false, -- Start Paused?
  -- You can also pass a table to change the debug colors used for testing.
})

local debug_shapes = true
local debug_name = false





--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Create Objects
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "floor",
  x = 0,
  y = BASE_HEIGHT - 16,
  w = BASE_WIDTH,
  h = 16,
  body_type = "static",
  __scale = true,
})

Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "block1",
  x = BASE_WIDTH/2 - 18 * 2,
  y = BASE_HEIGHT/2, 
  w = 16,
  h = 16,
  body_type = "dynamic",
  shape = "star",
})
Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "block2",
  x = BASE_WIDTH/2 - 18 * 3,
  y = BASE_HEIGHT/2, 
  w = 16,
  h = 16,
  body_type = "dynamic",
  shape = "moon",
})

Wb.joint_pool[#Wb.joint_pool+1] = Wb.create_joint({
  name = "joint2",
  type = "distance",
  collide_connected = true,
  pool = Wb.object_pool,
  body1 = Wb.get_body_by_name("block1", Wb.object_pool),
  body2 = Wb.get_body_by_name("block2", Wb.object_pool),
  x1 = Wb.get_properties_by_name("block1").cx,
  y1 = Wb.get_properties_by_name("block1", Wb.object_pool).cy,
  x2 = Wb.get_properties_by_name("block2", Wb.object_pool).cx,
  y2 = Wb.get_properties_by_name("block2", Wb.object_pool).cy,
})

Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "floor",
  x = 0,
  y = BASE_HEIGHT - 16,
  w = BASE_WIDTH,
  h = 16,
  body_type = "static",
  __scale = true,
})

Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "block1",
  x = BASE_WIDTH/2 - 16 * 0,
  y = BASE_HEIGHT/2, 
  w = 16,
  h = 16,
  body_type = "dynamic",
  shape = "rectangle",
})
Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "block2",
  x = BASE_WIDTH/2 + 16 * 1,
  y = BASE_HEIGHT/2, 
  w = 16,
  h = 16,
  body_type = "dynamic",
  shape = "rectangle",
})

Wb.joint_pool[#Wb.joint_pool+1] = Wb.create_joint({
  name = "joint3",
  type = "weld",
  collide_connected = true,
  pool = Wb.object_pool,
  body1 = Wb.get_body_by_name("block1", Wb.object_pool),
  body2 = Wb.get_body_by_name("block2", Wb.object_pool),
  x = Wb.get_properties_by_name("block1").cx + Wb.get_properties_by_name("block1").w/2,
  y = Wb.get_properties_by_name("block1", Wb.object_pool).cy,
})

Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "floor",
  x = 0,
  y = BASE_HEIGHT - 16,
  w = BASE_WIDTH,
  h = 16,
  body_type = "static",
  __scale = true,
})

Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "block1",
  x = BASE_WIDTH/2 - 18 * 1,
  y = BASE_HEIGHT/2, 
  w = 16,
  h = 16,
  body_type = "dynamic",
  shape = "rectangle",
})
Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "block2",
  x = BASE_WIDTH/2 + 18 * 1,
  y = BASE_HEIGHT/2, 
  w = 16,
  h = 16,
  body_type = "dynamic",
  shape = "rectangle",
})

Wb.joint_pool[#Wb.joint_pool+1] = Wb.create_joint({
  name = "joint4",
  type = "revolute",
  collide_connected = true,
  pool = Wb.object_pool,
  body1 = Wb.get_body_by_name("block1", Wb.object_pool),
  body2 = Wb.get_body_by_name("block2", Wb.object_pool),
  x = Wb.get_properties_by_name("block1").cx + 8 + 10,
  y = Wb.get_properties_by_name("block1", Wb.object_pool).cy,
})

Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "floor",
  x = 0,
  y = BASE_HEIGHT - 16,
  w = BASE_WIDTH,
  h = 16,
  body_type = "static",
  __scale = true,
})

Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "block1",
  x = BASE_WIDTH/2 + 16 * 1,
  y = BASE_HEIGHT/2, 
  radius = 8,
  body_type = "dynamic",
  shape = "circle",
})

Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "block2",
  x = BASE_WIDTH/2 - 16 * 1,
  y = BASE_HEIGHT/2, 
  radius = 8,
  body_type = "dynamic",
  shape = "circle",
})


Wb.joint_pool[#Wb.joint_pool+1] = Wb.create_joint({
  name = "cool_wheel",
  type = "wheel",
  collide_connected = true,
  pool = Wb.object_pool,
  body1 = Wb.get_body_by_name("block1", Wb.object_pool),
  body2 = Wb.get_body_by_name("block2", Wb.object_pool),
  x1 = Wb.get_properties_by_name("block1", Wb.object_pool).cx,
  y1 = Wb.get_properties_by_name("block1", Wb.object_pool).cy,
  x2 = Wb.get_properties_by_name("block1", Wb.object_pool).cx,
  y2 = Wb.get_properties_by_name("block2", Wb.object_pool).cy,
  ax = 0.5,
  ay = 0,
})

Wb.get_joint_by_name("cool_wheel"):setMaxMotorTorque(1000)
Wb.get_joint_by_name("cool_wheel"):setMotorSpeed(360)
Wb.get_joint_by_name("cool_wheel"):setMotorEnabled(true)
Wb.get_joint_by_name("cool_wheel"):setSpringFrequency(10)
Wb.get_joint_by_name("cool_wheel"):setSpringDampingRatio(0)

Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "floor",
  x = 0,
  y = BASE_HEIGHT - 16,
  w = BASE_WIDTH,
  h = 16,
  body_type = "static",
  __scale = true,
})

Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "block1",
  x = BASE_WIDTH/2 - 18 * 1,
  y = BASE_HEIGHT/2, 
  w = 16,
  h = 16,
  body_type = "dynamic",
  shape = "rectangle",
})
Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "block2",
  x = BASE_WIDTH/2 + 18 * 1,
  y = BASE_HEIGHT/2, 
  w = 16,
  h = 16,
  body_type = "dynamic",
  shape = "rectangle",
})

Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "block3",
  x = BASE_WIDTH/2 + 18 * 3,
  y = BASE_HEIGHT/2, 
  w = 16,
  h = 16,
  body_type = "dynamic",
  shape = "rectangle",
})

Wb.joint_pool[#Wb.joint_pool+1] = Wb.create_joint({
  name = "jointa",
  type = "revolute",
  collide_connected = true,
  pool = Wb.object_pool,
  body1 = Wb.get_body_by_name("block1", Wb.object_pool),
  body2 = Wb.get_body_by_name("block2", Wb.object_pool),
  x = Wb.get_properties_by_name("block1").cx + 8 + 10,
  y = Wb.get_properties_by_name("block1", Wb.object_pool).cy,
})

Wb.joint_pool[#Wb.joint_pool+1] = Wb.create_joint({
  name = "jointb",
  type = "revolute",
  collide_connected = true,
  pool = Wb.object_pool,
  body1 = Wb.get_body_by_name("block2", Wb.object_pool),
  body2 = Wb.get_body_by_name("block3", Wb.object_pool),
  x = Wb.get_properties_by_name("block2").cx + 8 + 10,
  y = Wb.get_properties_by_name("block2", Wb.object_pool).cy,
})

Wb.joint_pool[#Wb.joint_pool + 1] = Wb.create_joint({
  name = "linked-jointa-jointb",
  type = "gear",
  collide_connected = true,
  pool = Wb.object_pool,
  joint1 = Wb.get_joint_by_name("jointa", Wb.joint_pool),
  joint2 = Wb.get_joint_by_name("jointb"),
  ratio = -1,
})

Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "floor",
  x = 0,
  y = BASE_HEIGHT - 16,
  w = BASE_WIDTH,
  h = 16,
  body_type = "static",
  __scale = true,
})

Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "block1",
  x = BASE_WIDTH/2 - 18 * 1,
  y = BASE_HEIGHT/2, 
  w = 16,
  h = 16,
  body_type = "dynamic",
  shape = "rectangle",
})
Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "block2",
  x = BASE_WIDTH/2 + 18 * 1,
  y = BASE_HEIGHT/2, 
  w = 16,
  h = 16,
  body_type = "dynamic",
  shape = "rectangle",
})


Wb.joint_pool[#Wb.joint_pool+1] = Wb.create_joint({
  name = "jointa",
  type = "prismatic",
  collide_connected = true,
  pool = Wb.object_pool,
  body1 = Wb.get_body_by_name("block1", Wb.object_pool),
  body2 = Wb.get_body_by_name("block2", Wb.object_pool),
  x1 = Wb.get_properties_by_name("block1").cx,
  y1 = Wb.get_properties_by_name("block1", Wb.object_pool).cy,
  x2 = Wb.get_properties_by_name("block2").cx,
  y2 = Wb.get_properties_by_name("block2", Wb.object_pool).cy,
  ax = 1,
  ay = 0,
})

Wb.get_joint_by_name("jointa"):setLowerLimit(24)
Wb.get_joint_by_name("jointa"):setUpperLimit(32)

Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "roof",
  x = 0,
  y = 0,
  w = BASE_WIDTH,
  h = 16,
  body_type = "static",
  __scale = true,
})

Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "block1",
  x = BASE_WIDTH/2 - 18 * 1,
  y = 50, 
  w = 16,
  h = 16,
  body_type = "dynamic",
  shape = "rectangle",
})
Wb.object_pool[#Wb.object_pool+1] = Wb.create_simple_object({
  name = "block2",
  x = BASE_WIDTH/2 + 18 * 1,
  y = 50, 
  w = 16,
  h = 16,
  body_type = "dynamic",
  shape = "rectangle",
})

Wb.joint_pool[#Wb.joint_pool + 1] = Wb.create_joint({
  name = "platf",
  type = "pulley",
  collide_connected = true,
  pool = Wb.object_pool,
  body1 = Wb.get_body_by_name("block1", Wb.object_pool),
  body2 = Wb.get_body_by_name("block2", Wb.object_pool),
  x1 = Wb.get_properties_by_name("block1", Wb.object_pool).cx,
  y1 = Wb.get_properties_by_name("block1", Wb.object_pool).cy-8,
  x2 = Wb.get_properties_by_name("block2", Wb.object_pool).cx,
  y2 = Wb.get_properties_by_name("block2", Wb.object_pool).cy-8,
  ax = 0,
  ay = 0,
  gx1 = Wb.get_properties_by_name("block1", Wb.object_pool).cx,
  gy1 = 16,
  gx2 = Wb.get_properties_by_name("block2", Wb.object_pool).cx,
  gy2 = 16,
  ratio = 1,
})

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * World Rules 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Wb.add_rule("begin", "test_rule_1", function (a, b, coll)
  print("begin", a, b, coll) -- Print Callback
end)

Wb.add_rule("end", "test_rule_2", function (a, b, coll)
  print("end", a, b, coll) -- Print Callback
end)

Wb.add_rule("pre", "test_rule_3", function (a, b, coll)
  print("pre", a, b, coll) -- Print Callback
end)

Wb.add_rule("post", "test_rule_4", function (a, b, coll, normalimpulse, tangentimpulse)
  print("post", a, b, coll, normalimpulse, tangentimpulse) -- Print Callback
end)

Wb.remove_rule("begin", "test_rule_1")
Wb.remove_rule("end", "test_rule_2")
Wb.remove_rule("pre", "test_rule_3")
Wb.remove_rule("post", "test_rule_4")

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Update
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function scene:update(dt)
  Pixelscreen.update(dt)
 
  Wb.update(dt, Wb.object_pool, Wb.joint_pool)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function scene:draw()
  Pixelscreen.start()
  -- Lazy Background 
  love.graphics.setColor(0.1,0.1,0.1,1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(1,1,1,1)

  -- Draw with draw functions on Wooden Block Bodies
  Wb.draw(Wb.object_pool)

  -- Draw Debug
  if debug_shapes then 
    Wb.debug_draw_pool(Wb.object_pool, Wb.joint_pool, debug_name)
  end

  Pixelscreen.stop()
  -- Small Text - Debug Data 
  Utilities.debug_tools.on_screen_debug_info()
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function scene:keypressed( key, scancode, isrepeat )
  if key == "`" then 
    debug_shapes = not debug_shapes
  end
  if key == "0" then 
    Wb.remove_all_from_pool(Wb.object_pool)
  end
  if key == "1" then 
    Wb.print_world_items(Wb.object_pool, Wb.joint_pool)
  end
  if key == "2" then 
    Wb.pause = not Wb.pause
  end
  if key == "x" then 
    Gamestate.switch(Debug_screen.menu)
  end
end

local mousecount = 0
function scene:mousepressed(x,y,button)
  if button == 1 then 
    local created = Wb.create_mouse_joint({
      joint_pool = Wb.joint_pool,
      more_than_one_mouse_joint = true,
      name = "mouse" .. tostring(mousecount)
    })
    if created then mousecount = mousecount + 1 end
  end
  if button == 2 then 
    local removed, removed_count = Wb.remove_mouse_joint({
      joint_pool = Wb.joint_pool,
      name = "mouse" .. tostring(mousecount - 1),
      remove_one = false,
    })
    if removed then mousecount = mousecount - removed_count end
  end -- print(mousecount)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
return scene

--[[



]]--

--[[
  -- JOINT SNAKE TEST 
  

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


for box=0, 7 do
scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
  x = 48,
  y = -40 + 16 * box,
  w = 8,
  h = 8,
  body_type = "dynamic",
  shape = "rectangle",
  __scale = true,
  name = "wood1",
  density = 1,
})
end



-- Joints
-- Rope 
scene.joint_pool[#scene.joint_pool + 1] = Wblock.create_joint({
  name = "see-saw",
  type = "rope",
  collide_connected = true,
  pool = scene.object_pool,
  body1 = scene.object_pool[5].body,
  body2 = scene.object_pool[5-1].body,
  x1 = scene.object_pool[5].settings.cx+0,
  y1 = scene.object_pool[5].settings.cy-scene.object_pool[5].settings.h/2,
  x2 = scene.object_pool[4].settings.cx+0,
  y2 = scene.object_pool[4].settings.cy+scene.object_pool[5].settings.h/2,
  max_length = 8,
})
-- Distance
scene.joint_pool[#scene.joint_pool + 1] = Wblock.create_joint({
  name = "see-saw",
  type = "distance",
  collide_connected = true,
  pool = scene.object_pool,
  body1 = scene.object_pool[6].body,
  body2 = scene.object_pool[5].body,
  x1 = scene.object_pool[6].settings.cx+0,
  y1 = scene.object_pool[6].settings.cy-scene.object_pool[5].settings.h/2,
  x2 = scene.object_pool[5].settings.cx+0,
  y2 = scene.object_pool[5].settings.cy+scene.object_pool[5].settings.h/2,
  max_length = 8,
})
scene.joint_pool[#scene.joint_pool + 1] = Wblock.create_joint({
  name = "see-saw",
  type = "distance",
  collide_connected = true,
  pool = scene.object_pool,
  body1 = scene.object_pool[6].body,
  body2 = scene.object_pool[5].body,
  x1 = scene.object_pool[6].settings.cx+scene.object_pool[5].settings.w/2,
  y1 = scene.object_pool[6].settings.cy-scene.object_pool[5].settings.h/2,
  x2 = scene.object_pool[5].settings.cx+scene.object_pool[5].settings.w/2,
  y2 = scene.object_pool[5].settings.cy+scene.object_pool[5].settings.h/2,
  max_length = 8,
})
scene.joint_pool[#scene.joint_pool + 1] = Wblock.create_joint({
  name = "see-saw",
  type = "distance",
  collide_connected = true,
  pool = scene.object_pool,
  body1 = scene.object_pool[6].body,
  body2 = scene.object_pool[5].body,
  x1 = scene.object_pool[6].settings.cx-scene.object_pool[5].settings.w/2,
  y1 = scene.object_pool[6].settings.cy-scene.object_pool[5].settings.h/2,
  x2 = scene.object_pool[5].settings.cx-scene.object_pool[5].settings.w/2,
  y2 = scene.object_pool[5].settings.cy+scene.object_pool[5].settings.h/2,
  max_length = 8,
})
-- Weld
scene.joint_pool[#scene.joint_pool + 1] = Wblock.create_joint({
  name = "see-saw",
  type = "weld",
  collide_connected = true,
  pool = scene.object_pool,
  body1 = scene.object_pool[7].body,
  body2 = scene.object_pool[6].body,
  x = scene.object_pool[6].settings.cx+0,
  y = scene.object_pool[7].settings.cy-scene.object_pool[5].settings.h,
})
-- Revolute
scene.joint_pool[#scene.joint_pool + 1] = Wblock.create_joint({
  name = "see-saw",
  type = "revolute",
  collide_connected = true,
  pool = scene.object_pool,
  body1 = scene.object_pool[8].body,
  body2 = scene.object_pool[7].body,
  x = scene.object_pool[7].settings.cx+0,
  y = scene.object_pool[8].settings.cy-scene.object_pool[5].settings.h,
})
scene.joint_pool[#scene.joint_pool + 1] = Wblock.create_joint({
  name = "see-saw",
  type = "revolute",
  collide_connected = true,
  pool = scene.object_pool,
  body1 = scene.object_pool[9].body,
  body2 = scene.object_pool[8].body,
  x = scene.object_pool[8].settings.cx+0,
  y = scene.object_pool[9].settings.cy-scene.object_pool[5].settings.h,
})
-- Gear
scene.joint_pool[#scene.joint_pool + 1] = Wblock.create_joint({
  name = "see-saw",
  type = "gear",
  collide_connected = true,
  pool = scene.object_pool,
joint1 = scene.joint_pool[#scene.joint_pool - 0].data,
joint2 = scene.joint_pool[#scene.joint_pool - 1].data,
ratio = -1,
})

scene.joint_pool[#scene.joint_pool + 1] = Wblock.create_joint({
  name = "see-saw",
  type = "wheel",
  collide_connected = true,
  pool = scene.object_pool,
  body1 = scene.object_pool[10].body,
  body2 = scene.object_pool[9].body,
  x1 = scene.object_pool[10].settings.cx+0,
  y1 = scene.object_pool[10].settings.cy-scene.object_pool[5].settings.h/2,
  x2 = scene.object_pool[9].settings.cx+0,
  y2 = scene.object_pool[9].settings.cy+scene.object_pool[5].settings.h/2,
  ax = 0,
  ay = 2,
})
scene.joint_pool[#scene.joint_pool + 1] = Wblock.create_joint({
  name = "see-saw",
  type = "prismatic",
  collide_connected = true,
  pool = scene.object_pool,
  body1 = scene.object_pool[11].body,
  body2 = scene.object_pool[10].body,
  x1 = scene.object_pool[11].settings.cx+0,
  y1 = scene.object_pool[11].settings.cy-scene.object_pool[5].settings.h,
  x2 = scene.object_pool[10].settings.cx+0,
  y2 = scene.object_pool[10].settings.cy+scene.object_pool[5].settings.h,
  ax = 0,
  ay = 2,
})

---

for box=0, 1 do
  scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
    x = 205 - 20 * box,
    y = 20,
    w = 8,
    h = 8,
    body_type = "dynamic",
    shape = "rectangle",
    __scale = true,
    name = "wood1",
    density = 20,
  })
  end

  scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
    x = 170,
    y = 0,
    w = 50,
    h = 8,
    body_type = "static",
    shape = "rectangle",
    __scale = true,
    name = "wood1",
    density = 1,
  })

  scene.joint_pool[#scene.joint_pool + 1] = Wblock.create_joint({
    name = "see-saw",
    type = "pulley",
    collide_connected = true,
    pool = scene.object_pool,
    body1 = scene.object_pool[#scene.object_pool-1].body,
    body2 = scene.object_pool[#scene.object_pool-2].body,
    x1 = scene.object_pool[#scene.object_pool-1].settings.cx,
    y1 = scene.object_pool[#scene.object_pool-1].settings.cy-scene.object_pool[5].settings.h,
    x2 = scene.object_pool[#scene.object_pool-2].settings.cx+0,
    y2 = scene.object_pool[#scene.object_pool-2].settings.cy+scene.object_pool[5].settings.h,
    ax = 0,
    ay = 0,
    gx1 = scene.object_pool[#scene.object_pool].settings.x + 10,
    gy1 = scene.object_pool[#scene.object_pool].settings.y,
    gx2 = scene.object_pool[#scene.object_pool].settings.cx + 10,
    gy2 = scene.object_pool[#scene.object_pool].settings.cy,
    ratio = 1,
  })


]]--