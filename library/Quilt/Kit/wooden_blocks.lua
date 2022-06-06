local m = {
  __NAME        = "Quilt-Kit-Wooden Block",
  __VERSION     = "1.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "Löve2D - Box2D - Wrapper",
  __URL         = "http://github.sysl.dev/",
  __LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2022 Chris / Systemlogoff

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]],
  __LICENSE_TITLE = "MIT LICENSE"
}
-- TODO: 
-- Create Custom Object [Allow a shapes table to be passed in.]
-- Change obj pool to just obj [x]

-- Check Area
  -- Rectangle
  -- Circle
  -- Raycast
  -- Point

-- Drawing helpers 
  -- Debug [X]
  -- Basic [X]
  -- Own Draw Function [ ]

-- Update Helpers
  -- Correct Remove to always use tables since that's how the system works [x]

-- Joints
  -- Joints should create a record in joints table. [ ]
  -- Oh god joints are a nightmare. [X]
  -- Create mouse joint helper [X]
    -- DistanceJoint [ ]
    -- FrictionJoint [ ]
    -- GearJoint [ ]
    -- MotorJoint [ ]
    -- MouseJoint [X]
    -- PrismaticJoin [ ]
    -- PulleyJoint [ ]
    -- RevoluteJoint [ ]
    -- RopeJoint [ ]
    -- WeldJoint [ ]
    -- WheelJoint [ ]

-- Helper Functions
  -- Update Shape
    -- Fixture [ ]
    -- Body [ ]
    -- Shape [ ]

  -- Update World 
    -- Gravity
    -- Meter 
    -- ??


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Library Debug Mode
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.debug = true
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Locals and Housekeeping
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local print = print
local debugprint = print
local function print(...)
  if m.debug then
    debugprint(m.__NAME .. ": ", unpack({...}))
  end
end print(m.__DESCRIPTION)

-- Not 100% accurate on deep floats, but close enough.
local function round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Wooden Blocks - World Information
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
-- Container to hold world
m.world = nil

-- Don't update if slower than
m.maxdt = 1/15

-- Don't update if we're paused
m.paused = false

-- Debug Colors 
m.debug_colors = {
shape = {1,1,1,0.8},
joint = {1,1,1,1},
name = {0,1,1,1},
}

-- Mouse Functions 
m.mouse = {
  love.mouse.getX,
  love.mouse.getY,
  }

-- Callback and Rules Containers 
m.rules_beginContact = {}
m.beginContact = function(a, b, coll) 
  for rule_number=1, #m.rules_beginContact do 
    m.rules_beginContact[rule_number].fun(a, b, coll)
  end
end

m.rules_endContact = {}
m.endContact = function(a, b, coll) 
  for rule_number=1, #m.rules_endContact do 
    m.rules_endContact[rule_number].fun(a, b, coll)
  end
end

m.rules_preSolve = {}
m.preSolve = function(a, b, coll) 
  for rule_number=1, #m.rules_preSolve do 
    m.rules_preSolve[rule_number].fun(a, b, coll)
  end
end

m.rules_postSolve = {}
m.postSolve = function(a, b, coll, normalimpulse, tangentimpulse) 
  for rule_number=1, #m.rules_postSolve do 
    m.rules_postSolve[rule_number].fun(a, b, coll, normalimpulse, tangentimpulse)
  end
end

-- Commands to do before update
m.do_before_update = {}
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Add a rule to the callback list above
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.add_rule(rule_table, rule_name, rule_function)
  -- I'm very lazy.
  if type(rule_table) == "number" then 
    local table_list = {m.rules_beginContact, m.rules_endContact, m.rules_preSolve, m.rules_postSolve}
    rule_table = table_list[rule_table]
  end
  -- Very very lazy.
  if type(rule_table) == "string" then 
    local table_list = {["begin"] = m.rules_beginContact, ["end"] = m.rules_endContact, pre = m.rules_preSolve, post = m.rules_postSolve}
    rule_table = table_list[rule_table]
  end

  rule_table[#rule_table + 1] = {name = rule_name, fun = rule_function} 
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Remove a rule from the callback list above
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.remove_rule(rule_table, rule_name)
  -- I'm very lazy.
  if type(rule_table) == "number" then 
    local table_list = {m.rules_beginContact, m.rules_endContact, m.rules_preSolve, m.rules_postSolve}
    rule_table = table_list[rule_table]
  end
  -- Very very lazy.
  if type(rule_table) == "string" then 
    local table_list = {["begin"] = m.rules_beginContact, ["end"] = m.rules_endContact, pre = m.rules_preSolve, post = m.rules_postSolve}
    rule_table = table_list[rule_table]
  end

  for length = #rule_table, 1, -1 do 
    if rule_table[length].name == rule_name then 
      table.remove(rule_table, length)
    end
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Add to the 'Do before update' list.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.add_pre_update(rule_name, rule_function)
  m.do_before_update[#m.do_before_update + 1] = {name = rule_name, fun = rule_function} 
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Create world or import world, apply rule based contacts or used imported contacts if set.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.setup(settings)
  settings = settings or {}

  -- Step 1 - Create a new world with the settings.
    settings.world_gravity_x = settings.world_gravity_x or 0
    settings.world_gravity_y = settings.world_gravity_y or 0
    settings.world_allow_sleep = settings.world_allow_sleep or true
    m.world = love.physics.newWorld(settings.world_gravity_x, settings.world_gravity_y, settings.world_allow_sleep)

  -- Step 2 - Apply Callbacks 
  m.world:setCallbacks(m.beginContact, m.endContact, m.preSolve, m.postSolve)

  -- Step 3 - Set 1 Meter = 16 PX
  love.physics.setMeter(settings.pixels_per_meter or 16)

  -- Step 4 - Other Settings
  m.maxdt = settings.maxdt or m.maxdt
  m.pause = settings.pause or m.pause
  m.debug_colors = settings.debug_colors or m.debug_colors
  m.mouse = settings.mouse or m.mouse
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Update the world.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.update(dt, object_pool, joint_pool)
  -- Don't update if we're going to slow. (Usually happens when dragging the love2d window.)
  if dt > m.maxdt then return end

  -- If the world is paused, don't update.
  if m.pause then return end

  -- If the world exists we can start work.
  if m.world then 
    --[[--------------------------------------------
    * Pre Update Callbacks
    ---------------------------------------------]]--
    for i=#m.do_before_update, 1, -1 do 
      m.do_before_update[i].fun()
      table.remove(m.do_before_update, i)
    end

    --[[--------------------------------------------
    * Pool Loop - Object
    ---------------------------------------------]]--
    for physics_item = #object_pool, 1, -1 do
      local selected_physics_item = object_pool[physics_item]
      local b = selected_physics_item.body
      local f = selected_physics_item.fixture
      local s = selected_physics_item.shape
      local j = b:getJoints()
      --[[--------------------------------------------
      * Removal
      ---------------------------------------------]]--
      if selected_physics_item.__remove then 
        -- Destory Joints
        for obj_joint=1, #j do 
          for joint=#joint_pool, 1, -1 do
            if joint_pool[joint].data == j[obj_joint] then
              j[obj_joint]:destroy()
              table.remove(joint_pool, joint)
            end
          end
        end
        -- Destroy Fixtures
          for x=1, #f do
            f[x]:destroy()
          end
        -- Release Shapes
        if s then 
          for x=1, #s do
            s[x]:release()
          end
        end
        -- Destory the Body
        b:destroy()
        -- Remove the object from thr pool.
        table.remove(object_pool,physics_item)
      end
      --[[--------------------------------------------
      * /Removal
      ---------------------------------------------]]--
    end
    --[[--------------------------------------------
    * Pool Loop - Joints
    ---------------------------------------------]]--
    for i=#joint_pool, 1, -1 do 
      --[[--------------------------------------------
      * Mouse Joints Move Towards Mouse
      ---------------------------------------------]]--
      if joint_pool[i].data:getType() == "mouse" then 
        joint_pool[i].data:setTarget(m.mouse[1](), m.mouse[2]())
      end
    end

    --[[--------------------------------------------
    * World Update
    ---------------------------------------------]]--
    m.world:update(dt)

  end
  -- End of world only updates
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw images for things
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.draw(object_pool, settings)
  local image_table = settings.image_table
    for item=1, #object_pool do 
    -- Shortcut to the current pool.
    local b = object_pool[item].body
    local s = b:getUserData().settings
    --[[--------------------------------------------
    * Simple Draw
    ---------------------------------------------]]--
    if s.__type == "simple" and s.img then
      local image = image_table[s.img]
      local image_w = image:getWidth()
      local image_h = image:getHeight()
      local iw = round(s.w/2) + round(image_table[s.img]:getWidth()/2 - s.w/2)
      local ih = round(s.h/2) + round(image_table[s.img]:getHeight()/2 - s.h/2)
      local sx = 1
      local sy = 1
      -- Should we scale our image to fit the object?
      if s.__scale then
        sx = ((s.w - image_w)) / image_w
        sx = 1 + 1 * (sx)
        sy = ((s.h - image_h)) / image_h
        sy = 1 + 1 * (sy)
      end
      -- Draw the final image
      love.graphics.draw(image, round(b:getX()), round(b:getY()), b:getAngle(), sx, sy, iw, ih)
    end
    -- End Simple Draw
    --[[--------------------------------------------
    * x Draw
    ---------------------------------------------]]--
    if s.__type == "x" then

    end
    -- End X Draw 
  end
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Create Objects

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Simple Shape
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
-- A simple object is an object with only one shape
function m.create_simple_object(settings)
  -- Use our world if none was provided.
  local world = settings.world or m.world

  -- Create a table to store our new object
  local obj = {}
  obj.settings = {}
  obj.body = nil
  obj.shape = nil
  obj.fixture = nil

  --[[--------------------------------------------
  * Body Settings
  ---------------------------------------------]]--
  -- W/H are not required but will cause an error if left out.
  -- settings.w, settings.h, settings.x, settings.y

  -- Name
  settings.name = settings.name or tostring(settings.shape) .. tostring(m.world:getBodyCount())

  -- If we have just radius, set width/height based on it.
  if settings.radius then 
    settings.w = settings.radius * 2
    settings.h = settings.radius * 2
  end

  settings.cx = settings.x + settings.w/2
  settings.cy = settings.y + settings.h/2

  -- Weight of the object, default is about 100 Pounds. (45~ KG)
  settings.mass = settings.mass or 45

  -- Angle the object is created at
  settings.angle = settings.angle or 0
  -- Shape Type - Expected: rectangle, circle
  settings.shape = settings.shape or "rectangle"
  -- Body Type Expected: static, dynamic, kinematic
  settings.body_type = settings.body_type or "static"
  -- Active or Not?
  if type(settings.active) == "nil" then -- Default True
    settings.active = true
  else
    settings.active = settings.active
  end
  -- Angular Damping
  settings.angular_damping = settings.angular_damping or 0.1
  -- Awake or Asleep 
  if type(settings.awake) == "nil" then -- Default True
    settings.awake = true
  else
    settings.awake = settings.awake
  end
  -- Bullet or Not
  settings.bullet = settings.bullet or false
  -- Lock Rotation
  settings.lock_angle = settings.lock_angle or false
  -- Can Sleep?
  if type(settings.can_sleep) == "nil" then -- Default True
    settings.can_sleep = true
  else
    settings.can_sleep = settings.can_sleep
  end
  -- Gravity Scale
  settings.gravity_scale = settings.gravity_scale or 1

  --[[--------------------------------------------
  * Fixture Settings (Simple shapes apply it to all)
  ---------------------------------------------]]--
  -- Between 0.0 (Brick) - 1.0 (Infinite Energy Ball
  settings.restitution = settings.restitution or settings.bounciness
  settings.restitution = settings.restitution or 0.2
  -- What masking catagory do we fall into?
  settings.catagory = settings.catagory or 1
  -- What do we mask? Expected Table or Number
  settings.mask = settings.mask or nil
  -- Group (Default 0)
  settings.group = settings.group or 0
  -- Sensor
  settings.sensor = settings.sensor or false
  -- How dense is this object? kilograms per square meter.
  settings.density = settings.density or 1
  -- How rough is this object's surface 0 - Ice / 1.0 Sandpaper
  settings.friction = settings.friction or 0.5

  --[[--------------------------------------------
  * 'Hidden' Settings
  ---------------------------------------------]]--
  settings.__type = "simple" -- Just for reference 
  settings.__scale = settings.__scale or false -- Scale Image w/ Size of Object // Draw Helper
  settings.__remove = settings.__remove or false -- Remove this object if true // Update Helper
  -- settings.img = draw simple image.

  -- PUT THE PARTS TOGETHER
  -- Step 1 - Make Body 
 -- obj.body = love.physics.newBody(world, settings.x + settings.w/2, settings.y + settings.h/2, settings.body_type)
  obj.body = love.physics.newBody(world, settings.cx, settings.cy, settings.body_type)
  obj.body:setMass(settings.mass)
  obj.body:setAngle(settings.angle)
  obj.body:setAngularDamping(settings.angular_damping)
  obj.body:setActive(settings.active)
  obj.body:setAwake(settings.awake)
  obj.body:setBullet(settings.bullet)
  obj.body:setFixedRotation(settings.lock_angle)
  obj.body:setSleepingAllowed(settings.can_sleep)
  obj.body:setGravityScale(settings.gravity_scale)


  -- Step 2 - Make the shape 
  obj.shape = m.get_shape_table_from_name(settings)


  -- Step 3 - Join the Body to the Shape into a Fixture
  obj.fixture = {}
  for i=1, #obj.shape do
    obj.fixture[#obj.fixture+1] = love.physics.newFixture(obj.body, obj.shape[i])
  end
  
  -- Step 4 - Make a copy of settings in the object, this allows us to store whatever we want during setup.
  for key, value in pairs(settings) do 
    obj.settings[key] = value
  end

  -- Step 5 - Update Fixture with Data
  for i=1, #obj.fixture do
      -- Mask 
    if settings.mask then 
      if type(settings.mask) == "table" then
        obj.fixture[i]:setMask(unpack(settings.mask))
      else
        obj.fixture[i]:setMask(settings.mask)
      end
    end
    -- Catagory
    if settings.catagory == "table" then 
      obj.fixture[i]:setCategory(unpack(settings.catagory))
    else
      obj.fixture[i]:setCategory(settings.catagory)
    end
    -- Group
    obj.fixture[i]:setGroupIndex(settings.group)
    -- Sensor
    obj.fixture[i]:setSensor(settings.sensor)
    -- Bouncyness/restitution
    obj.fixture[i]:setRestitution(settings.restitution)
    -- Density
    obj.fixture[i]:setDensity(settings.density)
    -- Friction
    obj.fixture[i]:setFriction(settings.friction)
  end

  obj.body:resetMassData()

  -- The body holds the user data for the object.
  obj.body:setUserData(obj)

  return obj
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Complex Object??
--------------------------------------------------------------------------------------------------------------------------------------------------]]--

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Joint
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Joint Type Cheater
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.joint_type = {

  distance = love.physics.newDistanceJoint,

  -- Applies Friction To a Body when inside another body?
  friction = love.physics.newFrictionJoint,
  friction2 = love.physics.newFrictionJoint,

  gear = love.physics.newGearJoint,

  motor = love.physics.newMotorJoint,

  mouse = love.physics.newMouseJoint, 

  prismatic = love.physics.newPrismaticJoint,
  prismatic2 = love.physics.newPrismaticJoint,

  pulley = love.physics.newPulleyJoint,

  revolute = love.physics.newRevoluteJoint,
  revolute2 = love.physics.newRevoluteJoint,

  rope = love.physics.newRopeJoint,

  weld = love.physics.newWeldJoint,
  weld2 = love.physics.newWeldJoint,

  wheel = love.physics.newWheelJoint,
  wheel2 = love.physics.newWheelJoint,
}

m.joint_requirements = {
  distance = {"body1", "body2", "x1", "y1", "x2", "y2", "collide_connected"},

  friction = {"body1", "body2", "x", "y", "collide_connected"},
  friction2 = {"body1", "body2", "x1", "y1", "x2", "y2", "collide_connected"},

  gear = {"joint1", "joint2", "ratio", "collide_connected"},

  motor = {"body1", "body2", "correction_factor", "collide_connected"},

  mouse = {"body1", "x", "y"},

  prismatic = {"body1", "body2", "x", "y", "ax", "ay", "collide_connected"},
  prismatic2 = {"body1", "body2", "x1", "y1", "x2", "y2", "ax", "ay", "collide_connected", "reference_angle"},

  pulley = {"body1", "body2", "gx1", "gy1", "gx2", "gy2", "x1", "y1", "x2", "y2", "ratio", "collide_connected"},

  revolute = {"body1", "body2", "x", "y", "collide_connected"},
  revolute2 = {"body1", "body2", "x1", "y1", "x2", "y2", "collide_connected", "reference_angle"},

  rope = {"body1", "body2", "x1", "y1", "x2", "y2", "max_length", "collide_connected"},

  weld = {"body1", "body2", "x", "y", "collide_connected"},
  weld2 = {"body1", "body2", "x1", "y1", "x2", "y2", "collide_connected"},

  wheel = {"body1", "body2", "x", "y", "ax", "ay", "collide_connected"},
  wheel2 = {"body1", "body2", "x1", "y1", "x2", "y2", "ax", "ay", "collide_connected"},
}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Joint - Create
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.create_joint(settings)
  local joint = {}
  local s = settings

  -- Joints require a name
  assert(s.name, "Joints must have a name.")
  joint.name = s.name 

  -- Create the joint w/ arguments
  local joint_args = {}
  for i=1, #m.joint_requirements[s.type] do 
    -- Note to self:
    -- This reads the list of required arguements in order, assignes them in order as a table with the matching settings.
    -- Ex: m.joint_requirements[s.type][i] = body 1, 1 = s.body1
    joint_args[i] = s[m.joint_requirements[s.type][i]]
  end
  
  joint.data = m.joint_type[s.type](unpack(joint_args))
  joint.data:setUserData(joint)

  if s.max_force then joint.data:setMaxForce(s.max_force) end
  return joint
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Joint - Helper - Mouse Joint
  - Creates a Mouse Joint if there is a fixture under it that overlaps with the point.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.create_mouse_joint(settings)
  local created = false
  local s = settings
  s.mx = s.mx or m.mouse[1]()
  s.my = s.my or m.mouse[2]()
  s.fixed_rotation = s.fixed_rotation or false
  s.more_than_one_mouse_joint = s.more_than_one_mouse_joint or false
  s.name = s.name or "mouse"

  m.world:queryBoundingBox(s.mx, s.my, s.mx, s.my, function(found_fixture) 
    -- Clear the found point in fixture
    local found_point_in_fixture = false

    -- Return if we've already got a mouse fixture
    if not s.more_than_one_mouse_joint then 
      for i=#s.joint_pool, 1, -1 do
        if s.joint_pool[i].data:getType() == "mouse" then 
          return false
        end
      end
    end

    -- Do a test to see if the mouse is really on a fixture inside the AABB test
    local fixture_list = found_fixture:getBody():getUserData().fixture
    for i=1, #fixture_list do 
      if fixture_list[i]:testPoint(s.mx, s.my) then 
        found_point_in_fixture = true
      end
    end

    -- If it is inside, create the joint.
    if found_point_in_fixture then 
      s.joint_pool[#s.joint_pool+1] = m.create_joint({
        name = s.name,
        type = "mouse",
        collide_connected = false,
        body1 = found_fixture:getBody(),
        x = s.mx,
        y = s.my,
      })
      -- Confirm we created it
      created = true
      -- Lock the rotation?
      found_fixture:getBody():getUserData().body:setFixedRotation(s.fixed_rotation)
    end

    return not found_point_in_fixture
  end )
  -- We return if we created the joint or not to track the number we created. We can use this for multi-mouse joint push/pop queues
  return created
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Joint - Helper - Mouse Joint
  - Remove the mouse joint if it exists
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.remove_mouse_joint(settings)
  local s = settings
  local removed = false
  local removed_count = 0
  s.remove_one = s.remove_one or false
  s.name = s.name or ""
  -- Scan the pool, check for a mouse type joint
  for i=#s.joint_pool, 1, -1 do
    if s.joint_pool[i].data:getType() == "mouse" and not s.remove_one or s.joint_pool[i].name == s.name then 

      -- Get the bodies and restore the default settings for locked rotation/angle
      local mouse_body = s.joint_pool[i].data:getBodies()
      mouse_body:setFixedRotation(mouse_body:getUserData().settings.lock_angle)
      -- Destory the joint, clear from pool.
      s.joint_pool[i].data:destroy()
      table.remove(s.joint_pool, i)
      removed = true
      removed_count = removed_count + 1

    end
  end
  -- We return if we created the joint or not to track the number we created. We can use this for multi-mouse joint push/pop queues
  -- We return the number removed if we're mixing a push/pop queue with a remove all queue
  return removed, removed_count
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------


  * Helper Functions


--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Remove All Objects
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.remove_all_from_pool(pool)
  for i = #pool, 1, -1 do
    pool[i].__remove = true
  end
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------


  * Debug


--------------------------------------------------------------------------------------------------------------------------------------------------]]--

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw Debug Shapes (oof)
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function draw_shape(shape_type, shape, body)
  -- Polygon Shapes (Tri, Quad) are drawn by world points.
  if shape_type == "polygon" then
    love.graphics.polygon("fill", body:getWorldPoints(shape:getPoints()))
  end
  -- Round Shapes are drawn from center point.
  if shape_type == "circle" then
    local x, y = body:getWorldPoint(shape:getPoint())
    local r = shape:getRadius()
    love.graphics.circle("fill", x, y, r)
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw Filled In Shape Pool + Joints + Names 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.debug_draw_pool(object_pool, joint_pool, names)
  -- Capture Color 
  local cr,cg,cb,ca = love.graphics.getColor()

  -- OBJECT POOL LOOP START
  for item=1, #object_pool do 

    -- Shape Color
    love.graphics.setColor(m.debug_colors.shape)

    -- Create references 
    local selected_physics_item = object_pool[item]
    local p = selected_physics_item.settings
    local b = selected_physics_item.body
    local s = selected_physics_item.shape

    -- Draw each shape in the body
    for current_shape=1, #s do 
      local shape_type = s[current_shape]:getType()
      draw_shape(shape_type, s[current_shape], b)
    end

    -- Name Color
    love.graphics.setColor(m.debug_colors.name)
    if names then 
      love.graphics.print(p.name, b:getX(), b:getY())
    end
  end
  -- OBJECT POOL LOOP END

  -- Joint Color 
  love.graphics.setColor(m.debug_colors.joint)

  -- JOINT POOL LOOP START
  if joint_pool then 
    for jo = 1, #joint_pool do
      local x1, y1, x2, y2 = joint_pool[jo].data:getAnchors( )
      love.graphics.rectangle("fill", x1, y1, 1, 1)
      if x2 then 
        love.graphics.rectangle("fill", x2, y2, 1, 1)
      end
    end
  end
  -- JOINT POOL LOOP END

  -- Reset Color
  love.graphics.setColor(cr,cg,cb,ca)
  -- End Joints 
  -- End Function
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Print World Shapes
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.print_world_items(object_pool, joint_pool)
  print("Object Pool")
  for k,v in pairs(object_pool) do 
    print(k,v,v.body)
  end
  print("Joint Pool")
  for k,v in pairs(joint_pool) do 
    print(k,v,v.data)
  end
  print("World Body List", m.world:getBodyCount())
  for k,v in pairs(m.world:getBodies()) do 
    print(k,v)
  end
  print("World Joint List", m.world:getJointCount())
  for k,v in pairs(m.world:getJoints()) do 
    print(k,v)
  end
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------


  * DATA FUNCTIONS


--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Custom Box2D Shapes from Triangles 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.get_shape_table_from_name(settings)
  if settings.shape == "rectangle" then 
    return {love.physics.newRectangleShape(0, 0, settings.w, settings.h)}
  end

  if settings.shape == "circle" then
    return {love.physics.newCircleShape(0, 0, settings.radius)}
  end

  if settings.shape == "triangle" then
    return {love.physics.newPolygonShape(
      (-6/5) * settings.w/2,   (5/5) * settings.h/2,
      (0/5) * settings.w/2,  (-5/5) * settings.h/2,
      (6/5) * settings.w/2,  (5/5) * settings.h/2
    )}
  end

  if settings.shape == "triangle-right" then
    return {love.physics.newPolygonShape(
      (-5/5) * settings.w/2,   (-5/5) * settings.h/2,
      (-5/5) * settings.w/2,  (5/5) * settings.h/2,
      (5/5) * settings.w/2,  (5/5) * settings.h/2
    )}
  end

  if settings.shape == "hexagon" then
    return {
      love.physics.newPolygonShape(
      (0) * settings.w/2,   (0) * settings.h/2,
      (-3/6) * settings.w/2,  (-5/6) * settings.h/2,
      (3/6) * settings.w/2,  (-5/6) * settings.h/2
    ),
      love.physics.newPolygonShape(
      (0) * settings.w/2,   (0) * settings.h/2,
      (-3/6) * settings.w/2,  (5/6) * settings.h/2,
      (-6/6) * settings.w/2,  (0) * settings.h/2
    ),
      love.physics.newPolygonShape(
      (0) * settings.w/2,   (0) * settings.h/2,
      (-3/6) * settings.w/2,  (-5/6) * settings.h/2,
      (-6/6) * settings.w/2,  (0) * settings.h/2
    ),
      love.physics.newPolygonShape(
      (0) * settings.w/2,   (0) * settings.h/2,
      (-3/6) * settings.w/2,  (5/6) * settings.h/2,
      (3/6) * settings.w/2,  (5/6) * settings.h/2
    ),
      love.physics.newPolygonShape(
      (0) * settings.w/2,   (0) * settings.h/2,
      (6/6) * settings.w/2,  (0) * settings.h/2,
      (3/6) * settings.w/2,  (5/6) * settings.h/2
    ),
      love.physics.newPolygonShape(
      (0) * settings.w/2,   (0) * settings.h/2,
      (6/6) * settings.w/2,  (0) * settings.h/2,
      (3/6) * settings.w/2,  (-5/6) * settings.h/2
    ),
  }
  end

  if settings.shape == "glass" then
    return {
      love.physics.newPolygonShape(
      (-5/5) * settings.w/2,   (-5/5) * settings.h/2,
      (-4/5) * settings.w/2,  (-4/5) * settings.h/2,
      (-3/5) * settings.w/2,  (5/5) * settings.h/2
    ),
      love.physics.newPolygonShape(
      (5/5) * settings.w/2,   (-5/5) * settings.h/2,
      (4/5) * settings.w/2,  (-4/5) * settings.h/2,
      (3/5) * settings.w/2,  (5/5) * settings.h/2
    ),
      love.physics.newPolygonShape(
      (-3/5) * settings.w/2,   (4/5) * settings.h/2,
      (3/5) * settings.w/2,  (4/5) * settings.h/2,
      (-3/5) * settings.w/2,  (5/5) * settings.h/2,
      (3/5) * settings.w/2,  (5/5) * settings.h/2
    ),
  }
  end

  if settings.shape == "wine-glass" then
    return {
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (-5/5) * settings.h/2,
        (-5/5) * settings.w/2,  (1/5) * settings.h/2,
        (-4/5) * settings.w/2,  (1/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (-5/5) * settings.h/2,
        (-4/5) * settings.w/2,  (-5/5) * settings.h/2,
        (-4/5) * settings.w/2,  (1/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (5/5) * settings.w/2,   (-5/5) * settings.h/2,
        (5/5) * settings.w/2,  (1/5) * settings.h/2,
        (4/5) * settings.w/2,  (-5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (4/5) * settings.w/2,   (-5/5) * settings.h/2,
        (4/5) * settings.w/2,  (1/5) * settings.h/2,
        (5/5) * settings.w/2,  (1/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (1/5) * settings.h/2,
        (-4/5) * settings.w/2,  (1/5) * settings.h/2,
        (-3/5) * settings.w/2,  (2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (5/5) * settings.w/2,   (1/5) * settings.h/2,
        (4/5) * settings.w/2,  (1/5) * settings.h/2,
        (3/5) * settings.w/2,  (2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-4/5) * settings.w/2,   (1/5) * settings.h/2,
        (-2/5) * settings.w/2,  (2/5) * settings.h/2,
        (-3/5) * settings.w/2,  (2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (4/5) * settings.w/2,   (1/5) * settings.h/2,
        (2/5) * settings.w/2,  (2/5) * settings.h/2,
        (3/5) * settings.w/2,  (2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-3/5) * settings.w/2,   (2/5) * settings.h/2,
        (3/5) * settings.w/2,  (2/5) * settings.h/2,
        (0/5) * settings.w/2,  (3/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-1/5) * settings.w/2,   (2/5) * settings.h/2,
        (0/5) * settings.w/2,  (5/5) * settings.h/2,
        (1/5) * settings.w/2,  (2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-3/5) * settings.w/2,   (5/5) * settings.h/2,
        (0/5) * settings.w/2,  (4/5) * settings.h/2,
        (3/5) * settings.w/2,  (5/5) * settings.h/2
      ),
      
    }
  end

  if settings.shape == "heart" then
    return {
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (5/5) * settings.h/2,
        (0/5) * settings.w/2,  (0/5) * settings.h/2,
        (-5/5) * settings.w/2,  (0/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (5/5) * settings.h/2,
        (0/5) * settings.w/2,  (0/5) * settings.h/2,
        (5/5) * settings.w/2,  (0/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-4/5) * settings.w/2,   (-5/5) * settings.h/2,
        (-1/5) * settings.w/2,  (-5/5) * settings.h/2,
        (-4/5) * settings.w/2,  (-4/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (4/5) * settings.w/2,   (-5/5) * settings.h/2,
        (1/5) * settings.w/2,  (-5/5) * settings.h/2,
        (4/5) * settings.w/2,  (-4/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-1/5) * settings.w/2,   (-5/5) * settings.h/2,
        (-1/5) * settings.w/2,  (-4/5) * settings.h/2,
        (-4/5) * settings.w/2,  (-4/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (1/5) * settings.w/2,   (-5/5) * settings.h/2,
        (1/5) * settings.w/2,  (-4/5) * settings.h/2,
        (4/5) * settings.w/2,  (-4/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-1/5) * settings.w/2,   (-5/5) * settings.h/2,
        (0/5) * settings.w/2,  (-4/5) * settings.h/2,
        (-1/5) * settings.w/2,  (-4/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (1/5) * settings.w/2,   (-5/5) * settings.h/2,
        (0/5) * settings.w/2,  (-4/5) * settings.h/2,
        (1/5) * settings.w/2,  (-4/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-4/5) * settings.w/2,   (-5/5) * settings.h/2,
        (-5/5) * settings.w/2,  (-3/5) * settings.h/2,
        (-4/5) * settings.w/2,  (-4/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (4/5) * settings.w/2,   (-5/5) * settings.h/2,
        (5/5) * settings.w/2,  (-3/5) * settings.h/2,
        (4/5) * settings.w/2,  (-4/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (-3/5) * settings.h/2,
        (-5/5) * settings.w/2,  (0/5) * settings.h/2,
        (5/5) * settings.w/2,  (0/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (5/5) * settings.w/2,   (-3/5) * settings.h/2,
        (-5/5) * settings.w/2,  (-3/5) * settings.h/2,
        (5/5) * settings.w/2,  (0/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (-3/5) * settings.h/2,
        (0/5) * settings.w/2,  (-3/5) * settings.h/2,
        (0/5) * settings.w/2,  (-4/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (-4/5) * settings.h/2,
        (-5/5) * settings.w/2,  (-3/5) * settings.h/2,
        (-4/5) * settings.w/2,  (-4/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (5/5) * settings.w/2,   (-3/5) * settings.h/2,
        (0/5) * settings.w/2,  (-3/5) * settings.h/2,
        (0/5) * settings.w/2,  (-4/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (-4/5) * settings.h/2,
        (4/5) * settings.w/2,  (-4/5) * settings.h/2,
        (5/5) * settings.w/2,  (-3/5) * settings.h/2
      ),
    }
  end

  if settings.shape == "spade" then
    return {
      love.physics.newPolygonShape(
        (-1/5) * settings.w/2,   (5/5) * settings.h/2,
        (1/5) * settings.w/2,  (5/5) * settings.h/2,
        (0/5) * settings.w/2,  (2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (-5/5) * settings.h/2,
        (-5/5) * settings.w/2,  (0/5) * settings.h/2,
        (5/5) * settings.w/2,  (0/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (2/5) * settings.h/2,
        (1/5) * settings.w/2,  (4/5) * settings.h/2,
        (3/5) * settings.w/2,  (4/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (3/5) * settings.w/2,   (4/5) * settings.h/2,
        (5/5) * settings.w/2,  (2/5) * settings.h/2,
        (0/5) * settings.w/2,  (2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (5/5) * settings.w/2,   (2/5) * settings.h/2,
        (5/5) * settings.w/2,  (0/5) * settings.h/2,
        (-5/5) * settings.w/2,  (0/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (0/5) * settings.h/2,
        (-5/5) * settings.w/2,  (2/5) * settings.h/2,
        (5/5) * settings.w/2,  (2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (2/5) * settings.h/2,
        (-1/5) * settings.w/2,  (4/5) * settings.h/2,
        (-5/5) * settings.w/2,  (2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (2/5) * settings.h/2,
        (-4/5) * settings.w/2,  (4/5) * settings.h/2,
        (-1/5) * settings.w/2,  (4/5) * settings.h/2
      ),
    }
  end

  if settings.shape == "diamond" then
    return {
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (-5/5) * settings.h/2,
        (-3/5) * settings.w/2,  (0/5) * settings.h/2,
        (0/5) * settings.w/2,  (0/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (-5/5) * settings.h/2,
        (3/5) * settings.w/2,  (0/5) * settings.h/2,
        (0/5) * settings.w/2,  (0/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (5/5) * settings.h/2,
        (3/5) * settings.w/2,  (0/5) * settings.h/2,
        (0/5) * settings.w/2,  (0/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (5/5) * settings.h/2,
        (-3/5) * settings.w/2,  (0/5) * settings.h/2,
        (0/5) * settings.w/2,  (0/5) * settings.h/2
      ),
    }
  end

  if settings.shape == "cross" then
    return {
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (-2/5) * settings.h/2,
        (-5/5) * settings.w/2,  (2/5) * settings.h/2,
        (5/5) * settings.w/2,  (-2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (5/5) * settings.w/2,   (-2/5) * settings.h/2,
        (5/5) * settings.w/2,  (2/5) * settings.h/2,
        (-5/5) * settings.w/2,  (2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-2/5) * settings.w/2,   (-5/5) * settings.h/2,
        (-2/5) * settings.w/2,  (5/5) * settings.h/2,
        (2/5) * settings.w/2,  (5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (2/5) * settings.w/2,   (5/5) * settings.h/2,
        (2/5) * settings.w/2,  (-5/5) * settings.h/2,
        (-2/5) * settings.w/2,  (-5/5) * settings.h/2
      ),
    }
  end

  if settings.shape == "star" then
    return {
      love.physics.newPolygonShape(
        (-3/3) * settings.w/2,   (-1/3) * settings.h/2,
        (3/3) * settings.w/2,  (-1/3) * settings.h/2,
        (0/3) * settings.w/2,  (1/3) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/3) * settings.w/2,   (-3/3) * settings.h/2,
        (-2/3) * settings.w/2,  (2/3) * settings.h/2,
        (0/3) * settings.w/2,  (1/3) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/3) * settings.w/2,   (-3/3) * settings.h/2,
        (2/3) * settings.w/2,  (2/3) * settings.h/2,
        (0/3) * settings.w/2,  (1/3) * settings.h/2
      ),
    }
  end

  if settings.shape == "arrow" then
    return {
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (0/5) * settings.h/2,
        (5/5) * settings.w/2,  (0/5) * settings.h/2,
        (0/5) * settings.w/2,  (-5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-2/5) * settings.w/2,   (5/5) * settings.h/2,
        (-2/5) * settings.w/2,  (0/5) * settings.h/2,
        (2/5) * settings.w/2,  (5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (2/5) * settings.w/2,   (5/5) * settings.h/2,
        (2/5) * settings.w/2,  (0/5) * settings.h/2,
        (-2/5) * settings.w/2,  (0/5) * settings.h/2
      ),
    }
  end

  if settings.shape == "moon" then
    return {
      love.physics.newPolygonShape(
        (-2/5) * settings.w/2,   (5/5) * settings.h/2,
        (-2/5) * settings.w/2,  (3/5) * settings.h/2,
        (2/5) * settings.w/2,  (4/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-2/5) * settings.w/2,   (-5/5) * settings.h/2,
        (-2/5) * settings.w/2,  (-3/5) * settings.h/2,
        (2/5) * settings.w/2,  (-4/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (2/5) * settings.w/2,   (5/5) * settings.h/2,
        (2/5) * settings.w/2,  (4/5) * settings.h/2,
        (-2/5) * settings.w/2,  (5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (2/5) * settings.w/2,   (-5/5) * settings.h/2,
        (2/5) * settings.w/2,  (-4/5) * settings.h/2,
        (-2/5) * settings.w/2,  (-5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (2/5) * settings.w/2,   (4/5) * settings.h/2,
        (5/5) * settings.w/2,  (2/5) * settings.h/2,
        (2/5) * settings.w/2,  (5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (2/5) * settings.w/2,   (-4/5) * settings.h/2,
        (5/5) * settings.w/2,  (-2/5) * settings.h/2,
        (2/5) * settings.w/2,  (-5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-2/5) * settings.w/2,   (-5/5) * settings.h/2,
        (-5/5) * settings.w/2,  (-2/5) * settings.h/2,
        (-2/5) * settings.w/2,  (5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (2/5) * settings.h/2,
        (-5/5) * settings.w/2,  (-2/5) * settings.h/2,
        (-2/5) * settings.w/2,  (5/5) * settings.h/2
      ),
    }
  end

  if settings.shape == "pentagon" then
    return {
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (-5/5) * settings.h/2,
        (-5/5) * settings.w/2,  (-1/5) * settings.h/2,
        (5/5) * settings.w/2,  (-1/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (-1/5) * settings.h/2,
        (-3/5) * settings.w/2,  (5/5) * settings.h/2,
        (3/5) * settings.w/2,  (5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (3/5) * settings.w/2,   (5/5) * settings.h/2,
        (5/5) * settings.w/2,  (-1/5) * settings.h/2,
        (-5/5) * settings.w/2,  (-1/5) * settings.h/2
      ),
    }
  end

  if settings.shape == "octogon" then
    return {
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (-2/5) * settings.h/2,
        (-2/5) * settings.w/2,  (-5/5) * settings.h/2,
        (-2/5) * settings.w/2,  (-2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (5/5) * settings.w/2,   (-2/5) * settings.h/2,
        (2/5) * settings.w/2,  (-5/5) * settings.h/2,
        (2/5) * settings.w/2,  (-2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (5/5) * settings.w/2,   (2/5) * settings.h/2,
        (2/5) * settings.w/2,  (5/5) * settings.h/2,
        (2/5) * settings.w/2,  (2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (2/5) * settings.h/2,
        (-2/5) * settings.w/2,  (5/5) * settings.h/2,
        (-2/5) * settings.w/2,  (2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-2/5) * settings.w/2,   (-5/5) * settings.h/2,
        (2/5) * settings.w/2,  (-5/5) * settings.h/2,
        (-2/5) * settings.w/2,  (5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (2/5) * settings.w/2,   (5/5) * settings.h/2,
        (-2/5) * settings.w/2,  (5/5) * settings.h/2,
        (2/5) * settings.w/2,  (-5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (5/5) * settings.w/2,   (-2/5) * settings.h/2,
        (-5/5) * settings.w/2,  (-2/5) * settings.h/2,
        (-5/5) * settings.w/2,  (2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (2/5) * settings.h/2,
        (5/5) * settings.w/2,  (2/5) * settings.h/2,
        (5/5) * settings.w/2,  (-2/5) * settings.h/2
      ),
    }
  end

  if settings.shape == "trapezoid" then
    return {
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (5/5) * settings.h/2,
        (5/5) * settings.w/2,  (5/5) * settings.h/2,
        (-3/5) * settings.w/2,  (-5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (3/5) * settings.w/2,   (-5/5) * settings.h/2,
        (5/5) * settings.w/2,  (5/5) * settings.h/2,
        (-3/5) * settings.w/2,  (-5/5) * settings.h/2
      ),
    }
  end

  if settings.shape == "parallelogram" then
    return {
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (5/5) * settings.h/2,
        (5/5) * settings.w/2,  (5/5) * settings.h/2,
        (-3/5) * settings.w/2,  (-5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (3/5) * settings.w/2,   (-5/5) * settings.h/2,
        (5/5) * settings.w/2,  (5/5) * settings.h/2,
        (-3/5) * settings.w/2,  (-5/5) * settings.h/2
      ),
      
    }
  end

  if settings.shape == "kite" then
    return {
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (-5/5) * settings.h/2,
        (-5/5) * settings.w/2,  (-2/5) * settings.h/2,
        (0/5) * settings.w/2,  (5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (5/5) * settings.h/2,
        (5/5) * settings.w/2,  (-2/5) * settings.h/2,
        (0/5) * settings.w/2,  (-5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (-5/5) * settings.h/2,
        (-5/5) * settings.w/2,  (-2/5) * settings.h/2,
        (0/5) * settings.w/2,  (5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (5/5) * settings.h/2,
        (5/5) * settings.w/2,  (-2/5) * settings.h/2,
        (0/5) * settings.w/2,  (-5/5) * settings.h/2
      ),
    }

  end

  if settings.shape == "club" then
    return {
      love.physics.newPolygonShape(
        (0/6) * settings.w/2,   (-6/6) * settings.h/2,
        (-3/6) * settings.w/2,  (-3/6) * settings.h/2,
        (0/6) * settings.w/2,  (0/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/6) * settings.w/2,   (0/6) * settings.h/2,
        (3/6) * settings.w/2,  (-3/6) * settings.h/2,
        (0/6) * settings.w/2,  (-6/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (3/6) * settings.w/2,   (-2/6) * settings.h/2,
        (0/6) * settings.w/2,  (1/6) * settings.h/2,
        (3/6) * settings.w/2,  (4/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (3/6) * settings.w/2,   (4/6) * settings.h/2,
        (6/6) * settings.w/2,  (1/6) * settings.h/2,
        (3/6) * settings.w/2,  (-2/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/6) * settings.w/2,   (1/6) * settings.h/2,
        (-3/6) * settings.w/2,  (-2/6) * settings.h/2,
        (-6/6) * settings.w/2,  (1/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-6/6) * settings.w/2,   (1/6) * settings.h/2,
        (-3/6) * settings.w/2,  (4/6) * settings.h/2,
        (0/6) * settings.w/2,  (1/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-1/6) * settings.w/2,   (5/6) * settings.h/2,
        (0/6) * settings.w/2,  (1/6) * settings.h/2,
        (1/6) * settings.w/2,  (5/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-3/6) * settings.w/2,   (-2/6) * settings.h/2,
        (-5/6) * settings.w/2,  (-1/6) * settings.h/2,
        (-6/6) * settings.w/2,  (1/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-3/6) * settings.w/2,   (-2/6) * settings.h/2,
        (-1/6) * settings.w/2,  (-1/6) * settings.h/2,
        (0/6) * settings.w/2,  (1/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/6) * settings.w/2,   (1/6) * settings.h/2,
        (-1/6) * settings.w/2,  (3/6) * settings.h/2,
        (-3/6) * settings.w/2,  (4/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-3/6) * settings.w/2,   (4/6) * settings.h/2,
        (-5/6) * settings.w/2,  (3/6) * settings.h/2,
        (-6/6) * settings.w/2,  (1/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/6) * settings.w/2,   (1/6) * settings.h/2,
        (1/6) * settings.w/2,  (3/6) * settings.h/2,
        (3/6) * settings.w/2,  (4/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (3/6) * settings.w/2,   (4/6) * settings.h/2,
        (5/6) * settings.w/2,  (3/6) * settings.h/2,
        (6/6) * settings.w/2,  (1/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (6/6) * settings.w/2,   (1/6) * settings.h/2,
        (5/6) * settings.w/2,  (-1/6) * settings.h/2,
        (3/6) * settings.w/2,  (-2/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (3/6) * settings.w/2,   (-2/6) * settings.h/2,
        (1/6) * settings.w/2,  (-1/6) * settings.h/2,
        (0/6) * settings.w/2,  (1/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/6) * settings.w/2,   (0/6) * settings.h/2,
        (-3/6) * settings.w/2,  (-3/6) * settings.h/2,
        (-2/6) * settings.w/2,  (-1/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/6) * settings.w/2,   (0/6) * settings.h/2,
        (3/6) * settings.w/2,  (-3/6) * settings.h/2,
        (2/6) * settings.w/2,  (-1/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (3/6) * settings.w/2,   (-3/6) * settings.h/2,
        (2/6) * settings.w/2,  (-5/6) * settings.h/2,
        (0/6) * settings.w/2,  (-6/6) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/6) * settings.w/2,   (-6/6) * settings.h/2,
        (-2/6) * settings.w/2,  (-5/6) * settings.h/2,
        (-3/6) * settings.w/2,  (-3/6) * settings.h/2
      ),
    }
  end

  if settings.shape == "tall-gem" then
    return {
      love.physics.newPolygonShape(
        (0/3) * settings.w/2,   (-3/3) * settings.h/2,
        (-2/3) * settings.w/2,  (-2/3) * settings.h/2,
        (2/3) * settings.w/2,  (-2/3) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/3) * settings.w/2,   (3/3) * settings.h/2,
        (-2/3) * settings.w/2,  (2/3) * settings.h/2,
        (2/3) * settings.w/2,  (2/3) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (2/3) * settings.w/2,   (2/3) * settings.h/2,
        (-2/3) * settings.w/2,  (-2/3) * settings.h/2,
        (-2/3) * settings.w/2,  (2/3) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (2/3) * settings.w/2,   (-2/3) * settings.h/2,
        (-2/3) * settings.w/2,  (-2/3) * settings.h/2,
        (2/3) * settings.w/2,  (2/3) * settings.h/2
      ),
      
    }
  end

  if settings.shape == "gem" then
    return {
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (5/5) * settings.h/2,
        (0/5) * settings.w/2,  (0/5) * settings.h/2,
        (-5/5) * settings.w/2,  (0/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (5/5) * settings.h/2,
        (0/5) * settings.w/2,  (0/5) * settings.h/2,
        (5/5) * settings.w/2,  (0/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (-3/5) * settings.h/2,
        (-3/5) * settings.w/2,  (-5/5) * settings.h/2,
        (3/5) * settings.w/2,  (-5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (3/5) * settings.w/2,   (-5/5) * settings.h/2,
        (5/5) * settings.w/2,  (-3/5) * settings.h/2,
        (-5/5) * settings.w/2,  (-3/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (-3/5) * settings.h/2,
        (-5/5) * settings.w/2,  (0/5) * settings.h/2,
        (5/5) * settings.w/2,  (-3/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (5/5) * settings.w/2,   (-3/5) * settings.h/2,
        (5/5) * settings.w/2,  (0/5) * settings.h/2,
        (-5/5) * settings.w/2,  (0/5) * settings.h/2
      ),
      
    }
  end

  if settings.shape == "four-star" then
    return {
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (-5/5) * settings.h/2,
        (-2/5) * settings.w/2,  (-2/5) * settings.h/2,
        (0/5) * settings.w/2,  (-2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (-5/5) * settings.h/2,
        (2/5) * settings.w/2,  (-2/5) * settings.h/2,
        (0/5) * settings.w/2,  (-2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (5/5) * settings.h/2,
        (2/5) * settings.w/2,  (2/5) * settings.h/2,
        (0/5) * settings.w/2,  (2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (5/5) * settings.h/2,
        (-2/5) * settings.w/2,  (2/5) * settings.h/2,
        (0/5) * settings.w/2,  (2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-2/5) * settings.w/2,   (-2/5) * settings.h/2,
        (-5/5) * settings.w/2,  (0/5) * settings.h/2,
        (-2/5) * settings.w/2,  (0/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (2/5) * settings.w/2,   (-2/5) * settings.h/2,
        (5/5) * settings.w/2,  (0/5) * settings.h/2,
        (2/5) * settings.w/2,  (0/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (2/5) * settings.w/2,   (2/5) * settings.h/2,
        (5/5) * settings.w/2,  (0/5) * settings.h/2,
        (2/5) * settings.w/2,  (0/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-2/5) * settings.w/2,   (2/5) * settings.h/2,
        (-5/5) * settings.w/2,  (0/5) * settings.h/2,
        (-2/5) * settings.w/2,  (0/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (2/5) * settings.w/2,   (-2/5) * settings.h/2,
        (-2/5) * settings.w/2,  (2/5) * settings.h/2,
        (2/5) * settings.w/2,  (2/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-2/5) * settings.w/2,   (2/5) * settings.h/2,
        (2/5) * settings.w/2,  (-2/5) * settings.h/2,
        (-2/5) * settings.w/2,  (-2/5) * settings.h/2
      ),
      
    }
  end

  if settings.shape == "stairs" then
    return {
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (5/5) * settings.h/2,
        (-5/5) * settings.w/2,  (3/5) * settings.h/2,
        (5/5) * settings.w/2,  (3/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-3/5) * settings.w/2,   (3/5) * settings.h/2,
        (-3/5) * settings.w/2,  (1/5) * settings.h/2,
        (5/5) * settings.w/2,  (1/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-1/5) * settings.w/2,   (1/5) * settings.h/2,
        (-1/5) * settings.w/2,  (-1/5) * settings.h/2,
        (5/5) * settings.w/2,  (-1/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (1/5) * settings.w/2,   (-1/5) * settings.h/2,
        (1/5) * settings.w/2,  (-3/5) * settings.h/2,
        (5/5) * settings.w/2,  (-3/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (3/5) * settings.w/2,   (-3/5) * settings.h/2,
        (3/5) * settings.w/2,  (-5/5) * settings.h/2,
        (5/5) * settings.w/2,  (-5/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-5/5) * settings.w/2,   (5/5) * settings.h/2,
        (5/5) * settings.w/2,  (5/5) * settings.h/2,
        (5/5) * settings.w/2,  (3/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (5/5) * settings.w/2,   (3/5) * settings.h/2,
        (5/5) * settings.w/2,  (1/5) * settings.h/2,
        (-3/5) * settings.w/2,  (3/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (-1/5) * settings.w/2,   (1/5) * settings.h/2,
        (5/5) * settings.w/2,  (1/5) * settings.h/2,
        (5/5) * settings.w/2,  (-1/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (5/5) * settings.w/2,   (-1/5) * settings.h/2,
        (1/5) * settings.w/2,  (-1/5) * settings.h/2,
        (5/5) * settings.w/2,  (-3/5) * settings.h/2
      ),
      love.physics.newPolygonShape(
        (5/5) * settings.w/2,   (-3/5) * settings.h/2,
        (3/5) * settings.w/2,  (-3/5) * settings.h/2,
        (5/5) * settings.w/2,  (-5/5) * settings.h/2
      ),
    }
  end

  -- error if none found
  if true then 
    error("Wooden Blocks: Shape not found: " .. settings.shape)
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
return m