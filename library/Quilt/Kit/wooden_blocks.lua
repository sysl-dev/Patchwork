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
-- TODO: Simple object, expose all properties
-- Create Complex Object 
-- Test Area (Rect/Circle)
-- Drawing helpers [Started]
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
  -- Step 1 - Create/Get World 
  -- Check if we're passed a world.
  if type(settings.world) == "userdata" and settings.world.getGravity then 
    -- We were passed a world, we're going to use it.
    m.world = settings.world
  else
    -- Create a new world with the settings.
    settings.world_gravity_x = settings.world_gravity_x or 0
    settings.world_gravity_y = settings.world_gravity_y or 0
    settings.world_allow_sleep = settings.world_allow_sleep or true
    m.world = love.physics.newWorld(settings.world_gravity_x, settings.world_gravity_y, settings.world_allow_sleep)
  end

  -- Step 2 - Apply Callbacks 
  m.world:setCallbacks(m.beginContact, m.endContact, m.preSolve, m.postSolve)

  -- Step 3 - Set 1 Meter = 16 PX
  love.physics.setMeter(settings.meter or 16)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Update the world.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.update(dt, physics_watch_list)
  if m.world then 

    -- We run though things to do pre-update and remove them once done.
    for i=#m.do_before_update, 1, -1 do 
      m.do_before_update[i].fun()
      table.remove(m.do_before_update, i)
    end

    -- For each pool we're asked to monitor we step though and remove items tagged for removal.
    if type(physics_watch_list) == "table" then
      -------------------------------------- 
      -- For each pool we are watching
      for physics_pool = #physics_watch_list, 1, -1 do
        -- Get a pool
        for i=#physics_watch_list[physics_pool], 1, -1 do 
          -- Check if the object is set to remove
          if physics_watch_list[physics_pool][i].remove then 
            -- Destroy Fixtures
            if type(physics_watch_list[physics_pool][i].fixture) == "table" then 
              for x=1, #physics_watch_list[physics_pool][i].fixture do
                physics_watch_list[physics_pool][i].fixture[x]:destroy()
              end
            else
              physics_watch_list[physics_pool][i].fixture:destroy()
            end
           -- Destroy Shapes
            if physics_watch_list[physics_pool][i].shape then 
              if type(physics_watch_list[physics_pool][i].shape) == "table" then 
                for x=1, #physics_watch_list[physics_pool][i].shape do
                  physics_watch_list[physics_pool][i].shape[x]:release()
                end
              else
                physics_watch_list[physics_pool][i].shape:release()
              end
            end
            -- Destory Joints
            if physics_watch_list[physics_pool][i].joint then 
              if type(physics_watch_list[physics_pool][i].joint) == "table" then 
                for x=1, #physics_watch_list[physics_pool][i].joint do
                  physics_watch_list[physics_pool][i].joint[x]:destroy()
                end
              else
                physics_watch_list[physics_pool][i].joint:destroy()
              end
            end
            -- Destory the Body
            physics_watch_list[physics_pool][i].body:destroy()
            -- Remove the object from thr pool.
            table.remove(physics_watch_list[physics_pool],i)
          end
        end
      end
      --------------------------------------
    end
    -- Update the world 
    m.world:update(dt)

  end
  -- End of world only updates
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw Debug Shapes (oof)
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function draw_shape(shape_type, shape, body)
  love.graphics.setColor(1,1,1,1)
  if shape_type == "polygon" then
    love.graphics.polygon("fill", body:getWorldPoints(shape:getPoints()))
  end
  -- Round Shapes
  if shape_type == "circle" then
    local x, y = body:getWorldPoint(shape:getPoint())
    local r = shape:getRadius()
    love.graphics.circle("fill", x, y, r)
  end
  love.graphics.setColor(1,1,1,1)
end

function m.debug_draw_pool(pool)
  -- Draw From Pool
  for i=1, #pool do 
    if pool[i].body then
      if type(pool[i].shape) == "table" then 
        -- Table Stuff
        for x=1, #pool[i].shape do 
          local shape_type = pool[i].shape[x]:getType()
        draw_shape(shape_type, pool[i].shape[x], pool[i].body)
        end
      else 
        -- Check and draw shapes
        local shape_type = pool[i].shape:getType()
        draw_shape(shape_type, pool[i].shape, pool[i].body)
        -- Step out of table check
      end
      -- Step out of body check
    end
    -- Step out of loop
  end
  -- End Function
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw images for things
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.draw(pool_table, settings)
  local img = Texture.zzzzz_test.kit_wooden_block
  if type(pool_table) == "table" then
    for pool=1, #pool_table do 
      for selected_pool=1, #pool_table[pool] do
        -- Shortcut to the current pool.
        local current_pool = pool_table[pool][selected_pool]
        local s = current_pool.fixture[1]:getUserData().settings
        --[[--------------------------------------------
        * Simple Draw
        ---------------------------------------------]]--
        if current_pool.settings.__type == "simple" and s.img then
          local image = img[s.img]
          local image_w = image:getWidth()
          local image_h = image:getHeight()
          local iw = round(s.w/2) + round(img[s.img]:getWidth()/2 - s.w/2)
          local ih = round(s.h/2) + round(img[s.img]:getHeight()/2 - s.h/2)
          local sx = 1
          local sy = 1
          -- Should we scale our image to fit the object?
          if s.__scale then
            sx = ((s.w - image_w)) / image_w
            sx = 1 + 1 * (sx)
            sy = ((s.h - image_h)) / image_h
            sy = 1 + 1 * (sy)
          end
  
          love.graphics.draw(image, round(current_pool.body:getX()), round(current_pool.body:getY()), current_pool.body:getAngle(), sx, sy, iw, ih)
        end
        -- End Simple Draw
      end
    end
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Create Objects

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Simple Shape
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
-- A simple object is an object with only one shape
function m.create_simple_object(settings, world)
  -- Use our world if none was provided.
  world = world or m.world

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

  -- Triangle Scaling Hack
  settings.tri_scale_w = settings.tri_scale_w or 1
  settings.tri_scale_h = settings.tri_scale_h or 1
  -- If we have just radius, set width/height based on it.
  if settings.radius then 
    settings.w = settings.radius * 2
    settings.h = settings.radius * 2
  end

  -- Weight of the object, default is about 12 Pounds. (5 KG)
  settings.mass = settings.mass or settings.weight
  settings.mass = settings.mass or 5
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
  * Convience Settings
  ---------------------------------------------]]--
  settings.__type = "simple"
  settings.__scale = settings.__scale or false
  -- settings.img = draw simple image.

  -- PUT THE PARTS TOGETHER
  -- Step 1 - Make Body 
 -- obj.body = love.physics.newBody(world, settings.x + settings.w/2, settings.y + settings.h/2, settings.body_type)
  obj.body = love.physics.newBody(world, settings.x + settings.w/2, settings.y + settings.h/2, settings.body_type)
  obj.body:setMass(settings.mass)
  obj.body:setAngle(settings.angle)
  obj.body:setAngularDamping(settings.angular_damping)
  obj.body:setActive(settings.active)
  obj.body:setAwake(settings.awake)
  obj.body:setBullet(settings.bullet)
  obj.body:setFixedRotation(settings.lock_angle)
  obj.body:setSleepingAllowed(settings.can_sleep)


  -- Step 2 - Make the shape 
  if settings.shape == "rectangle" then 
    obj.shape = {love.physics.newRectangleShape(0, 0, settings.w, settings.h)}
  end

  if settings.shape == "circle" then
    obj.shape = {love.physics.newCircleShape(0, 0, settings.radius)}
  end

  if settings.shape == "triangle" then
    obj.shape = {love.physics.newPolygonShape(
      (-6/5) * settings.w/2,   (5/5) * settings.h/2,
      (0/5) * settings.w/2,  (-5/5) * settings.h/2,
      (6/5) * settings.w/2,  (5/5) * settings.h/2
    )}
  end

  if settings.shape == "triangle-right" then
    obj.shape = {love.physics.newPolygonShape(
      (-5/5) * settings.w/2,   (-5/5) * settings.h/2,
      (-5/5) * settings.w/2,  (5/5) * settings.h/2,
      (5/5) * settings.w/2,  (5/5) * settings.h/2
    )}
  end

  if settings.shape == "hexagon" then
    obj.shape = {
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
    obj.shape = {
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
    obj.shape = {
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

  if settings.shape == "triforce" then
    obj.shape = {
      love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (-5/5) * settings.h/2,
        (-2/5) * settings.w/2,  (-2/5) * settings.h/2,
        (0/5) * settings.w/2,  (0/5) * settings.h/2
      ),
       love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (-5/5) * settings.h/2,
        (2/5) * settings.w/2,  (-2/5) * settings.h/2,
        (0/5) * settings.w/2,  (0/5) * settings.h/2
      ),
       love.physics.newPolygonShape(
        (-2/5) * settings.w/2,   (-2/5) * settings.h/2,
        (-5/5) * settings.w/2,  (-2/5) * settings.h/2,
        (0/5) * settings.w/2,  (0/5) * settings.h/2
      ),
       love.physics.newPolygonShape(
        (2/5) * settings.w/2,   (-2/5) * settings.h/2,
        (5/5) * settings.w/2,  (-2/5) * settings.h/2,
        (0/5) * settings.w/2,  (0/5) * settings.h/2
      ),
       love.physics.newPolygonShape(
        (-3/5) * settings.w/2,   (-1/5) * settings.h/2,
        (-3/5) * settings.w/2,  (2/5) * settings.h/2,
        (0/5) * settings.w/2,  (0/5) * settings.h/2
      ),
       love.physics.newPolygonShape(
        (0/5) * settings.w/2,   (0/5) * settings.h/2,
        (2/5) * settings.w/2,  (2/5) * settings.h/2,
        (3/5) * settings.w/2,  (-1/5) * settings.h/2
      ),
       
    }
  end


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
    -- Data
    obj.fixture[i]:setUserData(obj)
  
  end

  obj.body:resetMassData()

  return obj
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Remove All Objects

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.remove_all_from_pool(pool)
  for i = #pool, 1, -1 do
    pool[i].remove = true
  end
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
return m