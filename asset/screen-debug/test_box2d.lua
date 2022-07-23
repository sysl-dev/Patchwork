local scene = {}
local Wb = require("library.Quilt.Kit.Wooden_Blocks")
Wb.setup({
  world_gravity_x = 0, -- Gravity V (Negitive is ^)
  world_gravity_y = 320, -- Gravity > (Negitive is <)
  world_allow_sleep = true, -- Allow non-moving objects to sleep. (Likely will always be true)
  pixels_per_meter = 16, -- How big is a meter in your world in pixels.
  mouse = {Utilities.pixel_scale.mouse.get_x, Utilities.pixel_scale.mouse.get_y}, -- Using a non-standard mouse? Pass the function here.
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
  img = "floor",
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


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * World Rules 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Wb.add_rule("pre", "test", function (a, b, coll)

end)

Wb.add_rule("post", "test", function (a, b, coll, normalimpulse, tangentimpulse)

end)

Wb.add_rule("begin", "test", function (a, b, coll)

end)

Wb.add_rule("end", "test", function (a, b, coll)

end)


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Update
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function scene:update(dt)
  Utilities.pixel_scale.update(dt)
 
  Wb.update(dt, Wb.object_pool, Wb.joint_pool)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function scene:draw()
  Utilities.pixel_scale.start()
  -- Lazy Background 
  love.graphics.setColor(0.1,0.1,0.1,1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(1,1,1,1)

  -- Draw with draw functions on Wooden Block Bodies
  Wb.draw(Wb.object_pool, {image_table = Texture.zzzzz_test.kit_wooden_block})

  -- Draw Debug
  if debug_shapes then 
    Wb.debug_draw_pool(Wb.object_pool, Wb.joint_pool, debug_name)
  end

  Utilities.pixel_scale.stop()
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
  end

  print(mousecount)

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


Counting Attachments with the Mouse 

local mousecount = 0
function scene:mousepressed(x,y,button)
  if button == 1 then 
    local created = Wblock.create_mouse_joint({
      joint_pool = scene.joint_pool,
      more_than_one_mouse_joint = true,
      name = "mouse" .. tostring(mousecount)
    })
    if created then mousecount = mousecount + 1 end
  end
  if button == 2 then 
    local removed, removed_count = Wblock.remove_mouse_joint({
      joint_pool = scene.joint_pool,
      name = "mouse" .. tostring(mousecount - 1),
      remove_one = false,
    })
    if removed then mousecount = mousecount - removed_count end
  end

  print(mousecount)

end

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