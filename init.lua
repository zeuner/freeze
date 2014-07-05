-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
-- Copyright (c) 2014 PenguinDad
_ = {}
-- Entity definition
local entity = {
	physical = false,
	collisionbox = {0, 0, 0, 0, 0, 0},
	is_visible = false,
}
function entity:on_activate(staticdata)
	self.object:set_armor_groups({immortal=1})
end
-- Register the entity
minetest.register_entity("freeze:sticky", entity)
minetest.register_chatcommand("freeze", {
	params = "<name>",
	description = "Freeze player <name>",
	privs = {privs=true},
	func = function(name, param)
		local player = minetest.get_player_by_name(param)
		if player ~= nil and player:is_player() then
			-- Add empty table for player related info
			_[param] = {}
			-- Add entity and attach player to it
			_[param].entity = minetest.add_entity(player:getpos(), "freeze:sticky")
			player:set_attach(_[param].entity, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
			-- Revoke interact from player
			_[param].privs = minetest.get_player_privs(param)
			local c = function(p) return p end
			local tmp = c(_[param].privs)
			tmp.interact = false
			minetest.set_player_privs(param, tmp)
			minetest.auth_reload()
			tmp = nil
			if minetest.setting_getbool("enable_damage") then
				player:set_hp(1)
			end
			minetest.chat_send_all(param .. " was frozen by " .. name .. ".")
		end
	end,
})
minetest.register_chatcommand("unfreeze", {
	params = "<name>",
	description = "Unfreeze player <name>",
	privs = {privs=true},
	func = function(name, param)
		local player = minetest.get_player_by_name(param)
		if player ~= nil and player:is_player() then
			if _[param] ~= nil then
				-- Regrant interact
				minetest.set_player_privs(param, _[param].privs)
				minetest.auth_reload()
				-- Detach player
				player:set_detach()
				_[param].entity:remove()
				minetest.chat_send_player(param, "You aren't frozen anymore.")
				-- Clear the player info in the table
				_[param] = nil
			end
		end
	end,
})
