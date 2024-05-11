local masks = {
   collide_with_nothing = {
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
   }
}

local physics = {}

function physics.init_physics(self, world)
   assert(self.spawn_x and self.spawn_y)
   assert(self.collider_r or
         (self.collider_w and self.collider_h) or
         self.collider_polygon)

   self.body = love.physics.newBody(
      world,
      self.spawn_x,
      self.spawn_y,
      self.collider_type or "dynamic"
   )
   if self.collider_fixed_rotation == true then
      self.body:setFixedRotation(true)
   else
      self.body:setFixedRotation(false)
   end
   self.body:setLinearDamping(self.linear_damping or 0.9)
   self.body:setAngularDamping(self.angular_damping or 0.3)

   if self.collider_polygon then
      self.shape = love.physics.newPolygonShape(
         unpack(self.collider_polygon)
      )
   elseif self.collider_r then
      self.shape  = love.physics.newCircleShape(
         self.collider_r * (self.scale or 1)
      )
      -- NOTE: this might screw some things up with repooling
      self.collider_w = self.collider_r * 2
      self.collider_h = self.collider_r * 2
   elseif self.collider_w and self.collider_h then
      self.shape = love.physics.newRectangleShape(
         self.collider_w * (self.sx or 1),
         self.collider_h * (self.sy or 1)
      )
   end

   if self.collider_gravity_scale then
      self.body:setGravityScale(self.collider_gravity_scale)
   end

   self.fixture = love.physics.newFixture(self.body, self.shape)

   -- NOTE: The shape is cloned when creating a new fixture and that clone is
   -- used by the fixture. So if we want a direct reference to the actual shape
   -- used in-game, we must get it from the fixture
   self.shape = self.fixture:getShape()

   -- Who we are for the physics engine
   if self.collision_categories then
      self.fixture:setCategory(
         self.obj_type, unpack(self.collision_categories))
   elseif self.obj_type then
      self.fixture:setCategory(self.obj_type)
   end

   -- Who we don't collide with
   if self.collision_mask then
      self.fixture:setMask(unpack(self.collision_mask))
   end

   if self.collider_restitution then
      self.fixture:setRestitution(self.collider_restitution)
   else
      self.fixture:setRestitution(0.2)
   end

   self.fixture:setUserData(self)
   self.fixture:setSensor(self.collider_sensor or false)
   if self.collider_mass then
      self.body:setMass(self.collider_mass)
   end
   if self.collider_density then
      self.fixture:setDensity(self.collider_density)
      self.body:resetMassData()
   end
end

function physics.get_rect_bounds(self)
   local x, y = self:get_cc_point()
   return x - self.collider_w/2, y - self.collider_h/2,
          x + self.collider_w/2, y + self.collider_h/2
end

function physics.get_tc_point(self)
   local x, y = self.body:getPosition()
   return x, y - self.collider_h / 2
end

function physics.get_bc_point(self)
   local x, y = self.body:getPosition()
   return x, y + self.collider_h / 2
end

function physics.get_cc_point(self)
   return self.body:getPosition()
end

function physics.get_rotation(self)
   return self.body:getAngle()
end

function physics.set_position(self, x, y)
   self.body:setPosition(
      x or self.body:getX(),
      y or self.body:getY()
   )
end

function physics.set_mock_position(self)
end

function physics.get_mock_tc_point(self)
   return self.spawn_x, self.spawn_y - self.collider_h
end

function physics.get_mock_bc_point(self)
   return self.spawn_x, self.spawn_y + self.collider_h
end

function physics.get_mock_cc_point(self)
   return self.spawn_x, self.spawn_y
end

function physics.get_mock_rect_bounds(self)
   return physics.get_rect_bounds(self)
end

function physics.get_mock_rotation(self)
   return self.r or 0
end

return physics
