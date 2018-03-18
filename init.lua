
-- display entity shown when loader node is punched
minetest.register_entity("simple_anchor:display", {
	physical = false,
	collisionbox = {0, 0, 0, 0, 0, 0},
	visual = "wielditem",
	-- wielditem seems to be scaled to 1.5 times original node size
	visual_size = {x = 1.0 / 1.5, y = 1.0 / 1.5},
	textures = {"simple_anchor:display_node"},
	timer = 0,
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		-- remove after 8 seconds
		if self.timer > 8 then
			self.object:remove()
		end
	end,
})


-- Display-zone node, Do NOT place the display as a node,
-- it is made to be used as an entity (see above)
local x = 8
minetest.register_node("simple_anchor:display_node", {
	tiles = {"loader_display.png"},
	use_texture_alpha = true,
	walkable = false,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			-- sides
			{-(x+.55), -(x+.55), -(x+.55), -(x+.45), (x+.55), (x+.55)},
			{-(x+.55), -(x+.55), (x+.45), (x+.55), (x+.55), (x+.55)},
			{(x+.45), -(x+.55), -(x+.55), (x+.55), (x+.55), (x+.55)},
			{-(x+.55), -(x+.55), -(x+.55), (x+.55), (x+.55), -(x+.45)},
			-- top
			{-(x+.55), (x+.45), -(x+.55), (x+.55), (x+.55), (x+.55)},
			-- bottom
			{-(x+.55), -(x+.55), -(x+.55), (x+.55), -(x+.45), (x+.55)},
		},
	},
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	drop = "",
})


minetest.register_node("simple_anchor:loader_block", {
	description = "forceload anchor",
	tiles = {"loader_block.png"},
	groups = {dig_immediate=2},
	light_source = 4,
	on_construct = function (pos)
		if minetest.forceload_block(pos) then
			minetest.debug("forceload block ".. minetest.pos_to_string(pos))
			local meta = minetest.get_meta(pos)
			local vm = minetest.get_voxel_manip(pos, pos)
			local pmin, pmax = vm:get_emerged_area()
			local epos = vector.divide(vector.add(pmin,pmax),2)
			meta:set_string("epos",minetest.pos_to_string(epos))
    else
      minetest.debug("failed forceload block ".. minetest.pos_to_string(pos))
    end
	end,
	on_destruct = function (pos)
		minetest.forceload_free_block(pos)
		minetest.debug("unforceloaded block ".. minetest.pos_to_string(pos))
	end,
	on_punch = function (pos, node, puncher, pointed_thing)
		local meta = minetest.get_meta(pos)
		local epos = minetest.string_to_pos(meta:get_string("epos"))
		minetest.add_entity(epos, "simple_anchor:display")	
	end,
});
