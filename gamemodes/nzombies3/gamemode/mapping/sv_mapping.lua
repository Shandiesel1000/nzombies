//

function nz.Mapping.Functions.ZedSpawn(pos, link, respawnable, ply)

	local ent = ents.Create("zed_spawns") 
	pos.z = pos.z - ent:OBBMaxs().z
	ent:SetPos( pos )
	ent:Spawn()
	ent.link = tonumber(link)
	//For the link displayer
	if link != nil then
		ent:SetLink(link)	
	end
	ent.respawnable = respawnable or 1 //Default to always be respawnable if not set
	
	if tobool(ent.respawnable) then
		table.insert(nz.Enemies.Data.RespawnableSpawnpoints, ent)
	elseif table.HasValue(nz.Enemies.Data.RespawnableSpawnpoints, ent) then
		table.RemoveByValue(nz.Enemies.Data.RespawnableSpawnpoints, ent)
	end
 	
	if ply then
		undo.Create( "Zombie Spawnpoint" )
			undo.SetPlayer( ply )
			undo.AddEntity( ent )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return ent
end

function nz.Mapping.Functions.PlayerSpawn(pos, ply)

	local ent = ents.Create("player_spawns") 
	pos.z = pos.z - ent:OBBMaxs().z
	ent:SetPos( pos )
	ent:Spawn()
	
	if ply then
		undo.Create( "Player Spawnpoint" )
			undo.SetPlayer( ply )
			undo.AddEntity( ent )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return ent
	
end

function nz.Mapping.Functions.EasterEgg(pos, ang, model, ply)
	local egg = ents.Create( "easter_egg" )
	egg:SetModel( model )
	egg:SetPos( pos )
	egg:SetAngles( ang )
	egg:Spawn()

	local phys = egg:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
	
	if ply then
		undo.Create( "Easter Egg" )
			undo.SetPlayer( ply )
			undo.AddEntity( egg )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return egg
end

function nz.Mapping.Functions.WallBuy(pos, gun, price, angle, oldent, ply)

	if weapons.Get(gun) != nil then
		
		if IsValid(oldent) then oldent:Remove() end
	
		local ent = ents.Create("wall_buys") 
		ent:SetAngles(angle)
		pos.z = pos.z - ent:OBBMaxs().z
		ent:SetWeapon(gun, price)
		ent:SetPos( pos )
		ent:Spawn()
		ent:PhysicsInit( SOLID_VPHYSICS )
		
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
		end
		
		if ply then
			undo.Create( "Wall Gun" )
				undo.SetPlayer( ply )
				undo.AddEntity( ent )
			undo.Finish( "Effect (" .. tostring( model ) .. ")" )
		end
		return ent
	else
		print("SKIPPED: " .. gun .. ". Are you sure you have it installed?")
	end
	
end

function nz.Mapping.Functions.RBoxHandler(pos, guns, angle, keep, ply)

	if not guns then
		print("No guns were supplied for the RBoxHandler ... did you use a save where it isn't defined?")
	return end
	PrintTable(guns)

	if keep then
		local ent = ents.FindByClass("random_box_handler")[1]
		ent:ClearWeapons()
	else
		if !IsValid( ent ) then ent = ents.Create("random_box_handler") end
		ent:SetAngles(angle)
		ent:SetPos( pos )
		ent:Spawn()
		ent:PhysicsInit( SOLID_VPHYSICS )
		ent:SetColor( Color(0, 255, 255) )
		
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
		end
		//Just to be sure
		ent:ClearWeapons()
	end
		
	for k,v in pairs(guns) do
		if weapons.Get(v) != nil then
			ent:AddWeapon(v)
		else
			print("SKIPPED: " .. v .. ". Are you sure you have it installed?")
		end
	end
	
	if ply then
		undo.Create( "Random Box Handler" )
			undo.SetPlayer( ply )
			undo.AddEntity( ent )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return ent
	
end

function nz.Mapping.Functions.PlayerHandler(pos, angle, startwep, startpoints, numweps, eeurl, keep, ply)

	local ent
	
	if keep then
		ent = ents.FindByClass("player_handler")[1]
	else
		for k,v in pairs(ents.FindByClass("player_handler")) do
			//WE CAN ONLY HAVE 1!
			v:Remove()
		end
		ent = ents.Create("player_handler")
		ent:SetAngles(angle)
		ent:SetPos( pos )
		ent:Spawn()
		ent:PhysicsInit( SOLID_VPHYSICS )
		ent:SetColor( Color(0, 255, 255) )
		
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
		end
	end
		
	ent:SetData(startpoints, startwep, numweps, eeurl)
	
	if ply then
		undo.Create( "Player Handler" )
			undo.SetPlayer( ply )
			undo.AddEntity( ent )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return ent
	
end

function nz.Mapping.Functions.PropBuy(pos,ang,model,flags,ply)
	local prop = ents.Create( "prop_buys" )
	prop:SetModel( model )
	prop:SetPos( pos )
	prop:SetAngles( ang )
	prop:Spawn()
	prop:PhysicsInit( SOLID_VPHYSICS )
	
	//REMINDER APPY FLAGS
	if flags != nil then
		Doors:CreateLink( prop, flags )
	end
	
	local phys = prop:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
	
	if ply then
		undo.Create( "Prop" )
			undo.SetPlayer( ply )
			undo.AddEntity( prop )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return prop
end

function nz.Mapping.Functions.Electric(pos,ang,model,ply)
	//THERE CAN ONLY BE ONE TRUE HERO
	local prevs = ents.FindByClass("power_box")
	if prevs[1] != nil then
		prevs[1]:Remove()
	end
	
	local ent = ents.Create( "power_box" )
	ent:SetPos( pos )
	ent:SetAngles( ang )
	ent:Spawn()
	ent:PhysicsInit( SOLID_VPHYSICS )
		
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
	
	if ply then
		undo.Create( "Power Switch" )
			undo.SetPlayer( ply )
			undo.AddEntity( ent )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return ent
end

function nz.Mapping.Functions.BlockSpawn(pos,ang,model,ply)
	local block = ents.Create( "wall_block" )
	block:SetModel( model )
	block:SetPos( pos )
	block:SetAngles( ang )
	block:Spawn()
	block:PhysicsInit( SOLID_VPHYSICS )
	
	local phys = block:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
	
	if ply then
		undo.Create( "Invisible Block" )
			undo.SetPlayer( ply )
			undo.AddEntity( block )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return block
end

function nz.Mapping.Functions.BoxSpawn(pos,ang, ply)
	local box = ents.Create( "random_box_spawns" )
	box:SetPos( pos )
	box:SetAngles( ang )
	box:Spawn()
	box:PhysicsInit( SOLID_VPHYSICS )
	
	if ply then
		undo.Create( "Random Box Spawnpoint" )
			undo.SetPlayer( ply )
			undo.AddEntity( box )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return box
end

function nz.Mapping.Functions.PerkMachine(pos, ang, id, ply)
	local perkData = nz.Perks.Functions.Get(id)
	
	local perk = ents.Create("perk_machine")
	perk:SetPerkID(id)
	perk:TurnOff()
	perk:SetPos(pos)
	perk:SetAngles(ang)
	perk:Spawn()
	perk:Activate()
	perk:PhysicsInit( SOLID_VPHYSICS )
	
	local phys = perk:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
	
	if ply then
		undo.Create( "Perk Machine" )
			undo.SetPlayer( ply )
			undo.AddEntity( perk )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return perk
end

function nz.Mapping.Functions.BreakEntry(pos,ang,ply)
	local entry = ents.Create( "breakable_entry" )
	entry:SetPos( pos )
	entry:SetAngles( ang )
	entry:Spawn()
	entry:PhysicsInit( SOLID_VPHYSICS )
	
	local phys = entry:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
	
	if ply then
		undo.Create( "Barricade" )
			undo.SetPlayer( ply )
			undo.AddEntity( entry )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return entry
end

function nz.Mapping.Functions.SpawnEffect( pos, ang, model, ply )

	local e = ents.Create("nz_prop_effect")
	e:SetModel(model)
	e:SetPos(pos)
	e:SetAngles( ang )
	e:Spawn()
	e:Activate()
	if ( !IsValid( e ) ) then return end

	if ply then
		undo.Create( "Effect" )
			undo.SetPlayer( ply )
			undo.AddEntity( e )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return e

end

function nz.Mapping.Functions.SpawnEntity(pos, ang, ent, ply)
	local entity = ents.Create( ent )
	entity:SetPos( pos )
	entity:SetAngles( ang )
	entity:Spawn()
	entity:PhysicsInit( SOLID_VPHYSICS )
	
	table.insert(nz.QMenu.Data.SpawnedEntities, entity)
	
	if ply then
		undo.Create( "Entity" )
			undo.SetPlayer( ply )
			undo.AddEntity( entity )
		undo.Finish( "Effect (" .. tostring( model ) .. ")" )
	end
	return entity
end

//Physgun Hooks
function nz.Mapping.Functions.OnPhysgunPickup( ply, ent )
	local class = ent:GetClass()
	if ( class == "prop_buys" or class == "wall_block" or class == "breakable_entry" ) then 
		//Ghost the entity so we can put them in walls.
		local phys = ent:GetPhysicsObject()
		phys:EnableCollisions(false)
	end
	
end

function nz.Mapping.Functions.OnPhysgunDrop( ply, ent )
	local class = ent:GetClass()
	if ( class == "prop_buys" or class == "wall_block" or class == "breakable_entry" ) then 
		//Unghost the entity so we can put them in walls.
		local phys = ent:GetPhysicsObject()
		phys:EnableCollisions(true)
	end
	
end

hook.Add( "PhysgunPickup", "nz.OnPhysPick", nz.Mapping.Functions.OnPhysgunPickup )
hook.Add( "PhysgunDrop", "nz.OnDrop", nz.Mapping.Functions.OnPhysgunDrop )