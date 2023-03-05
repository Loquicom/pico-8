pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--sp8ce'em up
--a SPATIAL SHOOT'EM UP
--gameloop

function _init()
	cartdata("sp8ce-em-up")
	init_constant()
	init_ground()
	set_title_mode()
end

--- === Title === ---

function set_title_mode()
	init_title()
	_update = update_title
	_draw = draw_title
end

function init_title()
	init_timer()
	init_menu()
end

function update_title()
	-- Update timer and ground animation
	update_timer()
	update_ground()
	-- Title specific
	update_menu()
end

function draw_title()
	-- Draw timer and ground animation
	cls(1)
	draw_background()
	draw_timer()
	draw_foreground()
	-- Title specific
	draw_menu()
end

--- === Game === ---

function set_game_mode()
	init_game()
	_update = update_game
	_draw = draw_game
end

function init_game()
	init_timer()
	init_rotate()
	init_player()
	init_enemy()
	init_bomb()
	init_collectible()
end

function update_game()
	-- Update timer ground animation
	update_timer()
	update_ground()
	-- Game specific
	update_bomb()
	update_enemy()
	update_collectible()
	update_player()
end

function draw_game()
	-- Draw timer and ground animation
	cls(1)
	draw_background()
	draw_timer()
	-- Game specific
	draw_enemy()
	draw_collectible()
	draw_player()
	draw_foreground()
	draw_bomb()
	draw_ui()
end

--- === End / Game over === ---

function set_end_mode()
	init_end()
	_update = update_end
	_draw = draw_end
end

function init_end()
	endWaiting = timer(30, false)
end

function update_end()
	-- Update timer ground animation
	update_timer()
	update_ground()
	-- End specific
	if (timer_is_end(endWaiting) and btnp(4)) then
		set_title_mode()
	end
	if (timer_is_end(endWaiting) and btnp(5)) then
		set_game_mode()
	end
end

function draw_end()
	-- Draw timer and ground animation
	cls(1)
	draw_background()
	draw_foreground()
	-- End specific
	print("game over",44,44,7)
 	print("your score:"..flr(player.score),34,54,7)
  	print("press ❎ to play again!",18,72,6)
	print("press 🅾️ to return to the menu",5,80,6)
end

-->8
--constant

function init_constant()
	cst_version = "0.30"
	-- Player
	cst_player_life = 3
	cst_player_energy = 5
	cst_player_power = 3
	cst_player_speed_base = 2
	cst_player_speed_max = 3
	cst_player_sprt_base = {1,2,3}
	cst_player_sprt_rota = {7,8,9}
	cst_player_thruster_duration = 8
	cst_player_thruster_sprt_base = {16,17,18,19,32,33,34,35}
	cst_player_thruster_sprt_rota = {20,21,22,23,36,37,38,39}
	cst_player_bullet_timer = 15
	cst_player_bullet_speed = 3
	cst_player_bullet_sprt_base = {48,49,50,51}
	cst_player_bullet_sprt_rota = {52,53,54,55}
	cst_player_animation_rotate_duration = 2
	cst_player_animation_rotate_sprt_fw = {4,5,6}
	cst_player_animation_rotate_sprt_bw = {6,5,4}
	-- Ground
	cst_ground_planet_speed = 0.6
	cst_ground_planet_sprt = {12,14,42,44,46}
	cst_ground_star_min = 4
	cst_ground_star_max = 8
	cst_ground_star_speed = 0.2
	cst_ground_star_sprt = {10,11,26,27}
	cst_ground_light_min = 18
	cst_ground_light_max = 28
	cst_ground_light_speed = 1.2
	-- Enemy
	cst_enemy = {
		{
			sprt = 68,
			speed = 1,
			life = 1
		},
		{
			sprt = 84,
			speed = 0.5,
			life = 2,
			spawn = 8 -- After x enemy of previous type the first enemy of this type spawn
		},
		{
			sprt = 100,
			speed = 1.5,
			life = 3,
			spawn = 4 -- After x enemy of previous type the first enemy of this type spawn
		}
	}
	-- Boss
	cst_boss = {
		{
			sprt_base = 128,
			sprt_rota = 130,
			speed = 1,
			life = 20 
		},
		{
			sprt_base = 132,
			sprt_rota = 134,
			speed = 1,
			life = 20 
		}
	}
	-- Collectible
	cst_collectible_luck = 8 -- More luck => less spawn
	cst_collectible_max = 3 -- Maximum collectible on the screen at the same time
	cst_collectible_speed = 1
	cst_collectible_sprt_life = 40
	cst_collectible_sprt_energy = 41
	cst_collectible_sprt_power = 56
	cst_collectible_sprt_speed = 57
	cst_collectible_sprt_score = 115
	-- Menu
	cst_menu_label = {
		"sCRIPTED MODE",
		"iNFINITE MODE",
		""
	}
	cst_menu_helper = {
		"a STORY MODE WITHOUT STORY 😐",
		"eNDLESS ENEMIES, ENDLESS FUN",
		"exploooosionn !!!!!!!!!!!!!!"
	}
	cst_menu_action = {
		start_scripted_game,
		start_infinite_game,
		nothing
	}
end

-->8
--title

function init_menu()
	menu_cursor = 2
	explosion_counter = 0
end

function update_menu()
 	if (btnp(2) and menu_cursor > 1) then
		menu_cursor -= 1
		explosion_counter = 0
		sfx(0)
	end
	if (btnp(3) and menu_cursor < #cst_menu_label) then
		menu_cursor += 1
		explosion_counter = 0
		sfx(0)
	end
	if (btnp(4) or btnp(5)) then
		cst_menu_action[menu_cursor]()
		sfx(1)
	end
end

function draw_menu()
	-- Score
	print("bEST SCORE:"..dget(menu_cursor), 2, 2, 7)
	-- Logo
	spr(73, 20, 36) -- S
	spr(74, 28, 36) -- P
	spr(75, 36, 36) -- 8
	spr(76, 44, 36) -- C
	spr(77, 52, 36) -- E
	print("'", 60, 36, 7) -- '
	spr(77, 64, 36) -- E
	spr(78, 72, 36) -- M
	spr(79, 88, 36) -- U
	spr(74, 96, 36) -- P
	-- Menu
	local y = 58
	for i=1,#cst_menu_label do
		print(cst_menu_label[i], 38, y, ternaire(i == menu_cursor, 7, 13))
		y += 10
	end
	-- Selector
	spr(0, 28, 58 + 10 * (menu_cursor - 1))
	-- Helper
	print(cst_menu_helper[menu_cursor], 8, 94, 6)
	print("pRESS ❎ TO SELECT", 28, 104, 6)
	-- Credit & version
	spr(112, 48, 119)
	print("bY lOQUICOM", 2, 120, 7)
	print("v:"..cst_version, 104, 120, 7)
end

--- === Functions === ---

function start_scripted_game()
	set_game_mode()
	set_enemy_manager("scripted")
end

function start_infinite_game()
	set_game_mode()
	set_enemy_manager("infinite")
end

function nothing()
	explosion(random(100,20),random(100,20),{radius=3,duration=rnd(120)+120,number=28})
	explosion_counter += 1
	if (dget(3) < explosion_counter) dset(3, explosion_counter)
end

-->8
--player

function init_player()
	player = {
		show = true,
		x = 18,
		y = 60,
		score = 0,
		life = cst_player_life,
		energy = cst_player_energy - 2,
		bomb = false,
		invincible = false,
		sprite = cst_player_sprt_base[1],
		speed = cst_player_speed_base,
		power = 0, -- 0 = simple, 1 = big, 2 = big + simple diag, 3 = big + big diag, 4+ = more speed and less cd ?
		thruster = animate(cst_player_thruster_sprt_base, cst_player_thruster_duration, 12, 64),
		timers = {
			bullet = timer(cst_player_bullet_timer, false)
		},
		bullets = {}
	}
	-- Rotate callback
	on_rotate(function()
		-- Player animation
		player.show = false
		player.thruster.show = false
		animate(ternaire(rotation, cst_player_animation_rotate_sprt_fw, cst_player_animation_rotate_sprt_bw), cst_player_animation_rotate_duration, player.x, player.y, false, _rotate_player_animation)
		-- Change animation sprites
		player.thruster.sprites = ternaire(rotation, cst_player_thruster_sprt_rota, cst_player_thruster_sprt_base)
	end)
end

function update_player()
	end_game()
	move_player()
	action_player()
	update_bullets()
	--Thruster particle
	if (random(64) == 8) then
		local info = rotate_thruster_info()
		particle(player.x+info.offset.x, player.y+info.offset.y, random(8,4), 1, {x=info.x, y=info.y}, 8, nil, cst_player_thruster_duration)
	end
end

function draw_player()
	-- Bullets
	for bullet in all(player.bullets) do
		spr(bullet.sprite, bullet.x, bullet.y, 1, 1, false, bullet.inv)
	end
	-- Player
	if (player.show) spr(player.sprite, player.x, player.y)
end

--- === Functions === ---

function end_game()
	if (player.life != 0) return
	-- Player is dead, stop game
	timer(90, false, _end_game)
	-- Death effect
	explosion(player.x + 4, player.y + 4, {radius=4,duration=rnd(30)+60,number=18})
	shake()
	sfx(6)
	-- Remove player
	player.show = false
	player.thruster.show = false
	player.life = -1
	player.x = 400
	player.y = 400
	-- Save best score
	if (dget(2) < player.score) dset(2, flr(player.score))
end

function move_player()
	-- Can't move if sprite is not show
	if (not player.show) return
	-- Detect pressed button and set values
	local x = 0
	local y = 0
	local info = rotate_player_info()
	if (btn(0)) then
		x -= player.speed -- Left
		info = rotate_player_info(0)
	end
	if (btn(1)) then 
		x += player.speed -- Right
		info = rotate_player_info(1)
	end
	if (btn(2)) then -- Up
		y -= player.speed
		info = rotate_player_info(2)
	end
	if (btn(3)) then -- Down
		y += player.speed
		info = rotate_player_info(3)
	end
	player.sprite = info.sprite
	-- Adapt diagonal speed
	if (x != 0 and y != 0) then
		x /= 2
		y /= 2
	end
	-- Set position
	player.x += x
	player.y += y
	-- Manage out of the map
	local border = rotate_player_border()
	if (player.x < border.left.cond) player.x = border.left.to
	if (player.x > border.right.cond) player.x = border.right.to
	if (player.y > border.down.cond) player.y = border.down.to
	if (player.y < border.up.cond) player.y = border.up.to
	-- Set thruster position
	player.thruster.x = player.x + info.offset.x
	player.thruster.y = player.y + info.offset.y
end

function action_player()
	-- Do nothing if player is hide
	if (not player.show) return
	-- Bomb
	if (player.energy >= cst_player_energy and btn(4) and btn(5)) return blast() -- Return only for stop
	-- Bullets
	if (btn(5) and timer_is_end(player.timers.bullet) and not btn(4)) then
		local info = rotate_bullet_info()
		local bullet = {x=player.x+info.offset.base.x, y=player.y+info.offset.base.y, speed=info.speed.base, sprite=info.sprites[2], inv=false}
		if (player.power == 0) bullet.sprite = info.sprites[1]
		add(player.bullets, bullet)
		if (player.power >= 2) then
			-- Diagonal bullets
			local sprite = info.sprites[3]
			if (player.power > 2) sprite = info.sprites[4]
			add(player.bullets, {x=player.x+info.offset.diag1.x, y=player.y+info.offset.diag1.y, speed=info.speed.diag1, sprite=sprite,inv=true})
			add(player.bullets, {x=player.x+info.offset.diag2.x, y=player.y+info.offset.diag2.y, speed=info.speed.diag2, sprite=sprite,inv=false})
		end
		timer_restart(player.timers.bullet)
		sfx(5)
	end
	-- Rotate
	if (btnp(4)) rotate()
end

function update_bullets()
	for bullet in all(player.bullets) do
		bullet.x += bullet.speed.x
		bullet.y += bullet.speed.y
		collision_player_fire(bullet)
		if (bullet.x < -8 or bullet.x > 128 or bullet.y < -8 or bullet.y > 128) del(player.bullets, bullet)
	end
end

function player_bullet_damage(bullet)
	if (contain({cst_player_bullet_sprt_base[2], cst_player_bullet_sprt_base[4], cst_player_bullet_sprt_rota[2], cst_player_bullet_sprt_rota[4]}, bullet.sprite)) return 2
	return 1
end

--- === Timers === ---

function _delayed_explosion(params)
	explosion(params.x, params.y)
end

function _end_game()
	init_timer()
	init_enemy()
	set_end_mode()
end

-->8
--ennemy

function init_enemy()
	local manager = enemy_manager or manage_enemy_infinite
	enemies = {entities={}, bullets={}, spawn = {0,0,0}, kill = {0,0,0}}
	enemy_manager = manager
	boss = nil
end

function update_enemy()
	-- Enemies
	for enemy in all (enemies.entities) do
		-- Die
		if (enemy.life < 1) then 
			del(enemies.entities, enemy)
			if (enemy.fire != nil) timer_stop(enemy.fire)
			shake(0.6)
			player.score += enemy.type
			enemies.kill[enemy.type] += 1
			explosion(enemy.x+4, enemy.y+4)
			sfx(2)
			timer(5, false, spawn_collectible, {x=enemy.x, y=enemy.y})
			if (enemy.respawn) timer(random(150,30), false, _respawn_enemy, enemy.type)
		end
		-- Move
		_ENV['move_enemy_type'..enemy.type](enemy)
		if (enemy.x < -8 or enemy.y > 130) then
			-- Outside the map
			del(enemies.entities, enemy)
			if (enemy.fire != nil) timer_stop(enemy.fire)
			if (player.life > 0) player.score -= enemy.type*2
			if (player.score < 0) player.score = 0
			timer(random(150,30), false, _respawn_enemy, enemy.type)
		end
		collision_spaceship(enemy)
		-- Shield particle
		if ((enemy.shield.left or enemy.shield.down) and random(64) != 8) then
			local info = ternaire(boss.shield.down, {x=0, y=1, offset={x=random(7),y=11}}, {x=-1, y=0, offset={x=-4,y=random(7)}})
			particle(enemy.x+info.offset.x, enemy.y+info.offset.y, random(2,1), 1, {x=info.x, y=info.y}, 12, nil, 4)
		end
	end
	-- Boss
	if (boss != nil) then
		boss.update()
		if (boss != nil and (boss.shield_vert or boss.shield_hori)) then
			for i=1,3 do
				local info = ternaire(boss.shield_hori, {x=0, y=1, offset={x=random(15),y=18}}, {x=-1, y=0, offset={x=-3,y=random(15)}})
				particle(boss.x+info.offset.x, boss.y+info.offset.y, random(2,1), 1, {x=info.x, y=info.y}, 12, nil, 4)
			end
		end
		collision_player_boss()
	end
	-- Bullets
	for bullet in all(enemies.bullets) do
		bullet.x += bullet.speedX
		bullet.y += bullet.speedY
		collision_enemy_fire(bullet)
	end
	-- Manage spawn
	enemy_manager()
end

function draw_enemy()
	-- Bullets
	for bullet in all(enemies.bullets) do
		spr(bullet.sprite, bullet.x, bullet.y)
	end
	-- Enemies
	for enemy in all (enemies.entities) do
		if (enemy.show) then
			spr(enemy.sprite, enemy.x, enemy.y)
			if (enemy.shield.left) spr(113, enemy.x-8, enemy.y)
			if (enemy.shield.down) spr(114, enemy.x, enemy.y+8)
		end
	end
	-- Boss
	if (boss != nil) then
		local sprt = boss.sprite
		local x = boss.x
		local y = boss.y
		spr(sprt, x, y)
		spr(sprt + 1, x+8, y)
		spr(sprt + 16, x, y+8)
		spr(sprt + 17, x+8, y+8)
	end
end

--- === Functions === ---

function set_enemy_manager(manager)
	if (manager == 1 or manager == "scripted") enemy_manager = manage_enemy_scripted
	if (manager == 2 or manager == "infinite") enemy_manager = manage_enemy_infinite
end

function spawn_enemy(type, x, y, params)
	-- Set params defaut value
	params = params or {}
	if (params.shield_left == nil) params.shield_left = false
	if (params.shield_down == nil) params.shield_down = false
	if (params.shield_random == nil) params.shield_random = true
	if(params.respawn == nil) params.respawn = true
	-- Create enemy
	local enemy = {
		type = type,
		x = x,
		y = y,
		speed = cst_enemy[type].speed,
		life = cst_enemy[type].life,
		sprite = cst_enemy[type].sprt,
		show = true,
		respawn = params.respawn,
		shield = {
			left = params.shield_left,
			down = params.shield_down
		}
	}
	-- Add shield
	if (params.shield_random and (type == 1 or type == 2) and random(100) == 88) then
		if (random(2) == 1) enemy.shield.left = true
		if (not enemy.shield.left) enemy.shield.right = true
	end
	-- Add fire
	if (type == 2) enemy.fire = timer(30, true, _fire_enemy2, enemy)
	if (type == 3) enemy.fire = timer(90, true, _fire_enemy3, enemy)
	add(enemies.entities, enemy)
	return enemy
end

function manage_enemy_scripted()
	if (enemies.spawn[1] == 0) then
		spawn_boss(2)
		enemies.spawn[1] += 1
	end
end

function manage_enemy_infinite()
	-- Spawn first ennemy
	if (enemies.spawn[1] == 0) then
		spawn_enemy(1, 128, random(80,40))
		enemies.spawn[1] += 1
	-- When type3 is killed 5 time decread fire cd
	elseif (enemies.kill[3] != 0 and enemies.kill[3] % 2 == 0) then
		for enemy in all(enemies) do
			if (enemy.type == 3) enemy.fire.duration -= 2
		end
	-- When (5 type2 * number of type2 + number of type2) kill, add new type2
	elseif (enemies.kill[2] != 0 and enemies.kill[2] % ((5*enemies.spawn[2])+enemies.spawn[2]) == 0) then
		local spawn = rotate_enemy_spawn(134, random(120))
		-- Check what type of enemy spawn
		local type = ternaire(enemies.spawn[3] == 0 and enemies.spawn[2] == cst_enemy[3].spawn, 3, 2)
		-- Spawn
		spawn_enemy(type, spawn.x, spawn.y)
		enemies.spawn[type] += 1
	-- When (5 type1 * number of type1 + number of type1) kill, add new type1
	elseif (enemies.kill[1] != 0 and enemies.kill[1] % ((5*enemies.spawn[1])+enemies.spawn[1]) == 0) then
		local spawn = rotate_enemy_spawn(134, random(120))
		-- Check what type of enemy spawn
		local type = ternaire(enemies.spawn[2] == 0 and enemies.spawn[1] == cst_enemy[2].spawn, 2, 1)
		-- Spawn
		spawn_enemy(type, spawn.x, spawn.y)
		enemies.spawn[type] += 1
	end
end

function move_enemy_type1(enemy)
	local info = rotate_enemy1_info(enemy.speed, player.x - enemy.x, player.y - enemy.y)
	enemy.sprite = info.sprite
	enemy.x += info.x
	enemy.y += info.y
end

function move_enemy_type2(enemy)
	local info = rotate_enemy2_info(enemy.speed)
	enemy.x += info.x
	enemy.y += info.y
end

function move_enemy_type3(enemy)
	if (player.life <= 0) return
	local info = rotate_enemy3_info(enemy.speed, enemy.x, enemy.y, player.x - enemy.x, player.y - enemy.y)
	enemy.sprite = info.sprite
	enemy.x += info.x
	enemy.y += info.y
end

--- === Timers === ---

function _fire_enemy2(enemy)
	add(enemies.bullets, {x=enemy.x,y=enemy.y,speedX=1,speedY=1,sprite=98})
	add(enemies.bullets, {x=enemy.x,y=enemy.y,speedX=-1,speedY=1,sprite=96})
	add(enemies.bullets, {x=enemy.x,y=enemy.y,speedX=1,speedY=-1,sprite=96})
	add(enemies.bullets, {x=enemy.x,y=enemy.y,speedX=-1,speedY=-1,sprite=98})
	sfx(4)
end

function _fire_enemy3(enemy)
	if (rotation) then
		add(enemies.bullets, {x=enemy.x,y=enemy.y,speedX=0,speedY=ternaire(player.y < enemy.y, -1, 1),sprite=82})
	else
		add(enemies.bullets, {x=enemy.x,y=enemy.y,speedX=ternaire(player.x < enemy.x, -1, 1),speedY=0,sprite=80})
	end
	sfx(4)
end

function _respawn_enemy(type)
	local spawn = rotate_enemy_spawn(134, random(120))
	spawn_enemy(type, spawn.x, spawn.y)
end

-->8
--boss

function spawn_boss(type)
	local rotate = ternaire(type == 2, not rotation, false)
	local spawn = rotate_enemy_spawn(134, 56, rotate)
	boss = {
		type = type,
		invincible = false,
		phase = 1,
		life = 20,
		x = spawn.x,
		y = spawn.y,
		speed = cst_boss[type].speed + 1,
		move = false,
		rotate = rotate,
		rotate_timer = nil,
		shield_vert = false,
		shield_hori = false,
		sprite = ternaire(rotate, cst_boss[type].sprt_rota, cst_boss[type].sprt_base),
		update = _ENV['update_boss'..type],
		draw = _ENV['draw_boss'..type]
	}
	on_rotate(on_rotate_boss)
	-- Specific type 1
	if (type == 1) then
		boss.rand = 64
		boss.rand_timer = timer(60, true, function() boss.rand = random(20, 108) end)
	end
end

function update_boss1()
	-- Move
	if (boss.move) then
		if (boss.rotate) then
			boss.y += boss.speed
		else
			boss.x -= boss.speed
		end
	else
		if (boss.rotate) then
			if (boss.y < 4) boss.y += boss.speed
			boss.x += limit (boss.rand - boss.x, 1)
		else
			if (boss.x > 108) boss.x -= boss.speed
			boss.y += limit (boss.rand - boss.y, 1)
		end
	end
	-- Out of screen
	if (boss.x < -20 or boss.y > 140) then
		local spawn = rotate_enemy_spawn(134, 56)
		boss.move = false
		boss.rotate = rotation
		boss.sprite = ternaire(rotation, cst_boss[boss.type].sprt_rota, cst_boss[boss.type].sprt_base)
		boss.x = spawn.x
		boss.y = spawn.y
		if (boss.phase == 2) then
			boss.shield_hori = boss.rotate
			boss.shield_vert = not boss.rotate
		end
	end
	-- Fire
end

function change_phase_boss1()
	-- Out of screen
	if (boss.x < -20 or boss.y > 140) then
		boss.phase = 2
		boss.update = update_boss1
	else -- Go outside the screen
		if (boss.rotate) then
			boss.y += boss.speed
		else
			boss.x -= boss.speed
		end
	end
end

function update_boss2()
	if (player.life <= 0) return
	-- Move
	if (boss.move) then
		if (boss.rotate) then
			boss.y -= boss.speed
		else
			boss.x += boss.speed
		end
	else
		if (boss.rotate) then
			if (boss.y < 4) boss.y += boss.speed
			boss.x += limit(player.x - boss.x-4, boss.speed)
		else
			if (boss.x > 108) boss.x -= boss.speed
			boss.y += limit(player.y - boss.y-4, boss.speed)
		end
	end
	-- Out of screen
	if (boss.x > 140 or boss.y < -20) then
		local spawn = rotate_enemy_spawn(134, 56, not rotation)
		boss.move = false
		boss.rotate = not rotation
		boss.sprite = ternaire(not rotation, cst_boss[boss.type].sprt_rota, cst_boss[boss.type].sprt_base)
		boss.x = spawn.x
		boss.y = spawn.y
	end
end

function update_boss2_phase2()
	if (player.life <= 0) return
	if (boss.move) then
		if (boss.rotate) then
			boss.y -= boss.speed
		else
			boss.x += boss.speed
		end
	else
		-- Player behind boss
		if ((boss.rotate == rotation) and ((rotation and player.y-16 > boss.y) or (not rotation and player.x+16 < boss.x))) then 
			on_rotate_boss()
		end
		-- Move
		if (rotation) then
			boss.x += limit(player.x - boss.x-4, boss.speed)
		else
			boss.y += limit(player.y - boss.y-4, boss.speed)
		end
		if (boss.rotate and boss.y > 108) boss.y -= boss.speed
		if (not boss.rotate and boss.x < 4) boss.x += boss.speed
	end
	-- Out of screen
	if (boss.x > 140 or boss.y < -20) then
		local spawn = rotate_enemy_spawn(-20, 56)
		boss.move = false
		boss.rotate = rotation
		boss.sprite = ternaire(rotation, cst_boss[boss.type].sprt_rota, cst_boss[boss.type].sprt_base) + 4
		boss.x = spawn.x
		boss.y = spawn.y
		boss.shield_vert = rotation
		boss.shield_hori = not rotation
	end
end

function change_phase_boss2()
	-- Out of screen
	if (boss.x > 140 or boss.y < -20) then
		local spawn = rotate_enemy_spawn(-20, 56)
		boss.phase = 2
		boss.update = update_boss2_phase2
		boss.rotate = rotation
		boss.sprite = ternaire(rotation, cst_boss[boss.type].sprt_rota, cst_boss[boss.type].sprt_base) + 4
		boss.x = spawn.x
		boss.y = spawn.y
		boss.shield_vert = rotation
		boss.shield_hori = not rotation
		rotate_delete_callback(on_rotate_boss)
	else -- Go outside the screen
		if (boss.rotate) then
			boss.y -= boss.speed
		else
			boss.x += boss.speed
		end
	end
end

function on_rotate_boss()
	if (not timer_is_end(boss.rotate_timer)) return
	boss.rotate_timer = timer(90, false, function(boss) boss.move = true end, boss)
end

-->8
--collectible

function init_collectible()
	collectibles = {}
end

function update_collectible()
	for collectible in all(collectibles) do
		local info = rotate_collectible_info()
		collectible.x += info.x
		collectible.y += info.y
		-- Collision
		collision_collectible(collectible)
		-- Outside the map
		if (collectible.x < -8 or collectible.y > 130) despawn_collectible(collectible)
	end
end

function draw_collectible()
	for collectible in all(collectibles) do
		spr(collectible.sprite, collectible.x, collectible.y)
	end
end

--- === Functions === ---

function spawn_collectible(params)
	if (#collectibles >= cst_collectible_max or random(cst_collectible_luck,1) != cst_collectible_luck) return
	-- Type of collectible
	if (player.life == 1) then
		-- Player is close to the death only health
		if (random(2,1) == 1 ) add(collectibles, {sprite=cst_collectible_sprt_life, x=params.x, y=params.y})
	else
		-- Health, power up and score
		local available = {}
		if (player.life < cst_player_life) add(available, cst_collectible_sprt_life)
		if (player.energy < cst_player_energy) add(available, cst_collectible_sprt_energy)
		if (player.power < cst_player_power) add(available, cst_collectible_sprt_power)
		if (player.speed < cst_player_speed_max) add(available, cst_collectible_sprt_speed)
		if (#available < 3) add(available, cst_collectible_sprt_score)
		add(collectibles, {sprite=rnd(available), x=params.x, y=params.y})
	end
end

function despawn_collectible(collectible)
	if (collectible.sprite == cst_collectible_sprt_life) player.score += cst_player_life - player.life
	if (collectible.sprite == cst_collectible_sprt_energy) player.score += cst_player_energy - player.energy
	if (collectible.sprite == cst_collectible_sprt_power) player.score += cst_player_power - player.power
	if (collectible.sprite == cst_collectible_sprt_speed) player.score += cst_player_speed_max - player.speed
	if (collectible.sprite == cst_collectible_sprt_score) player.score += 1
	del(collectibles, collectible)
end

-->8
--collision

function collision_player_fire(bullet)
	-- Enemy
	for enemy in all(enemies.entities) do
		if (collision_rectangle({{x=bullet.x+1, y=bullet.y+1},{x=bullet.x+4,y=bullet.y+4}}, {{x=enemy.x,y=enemy.y},{x=enemy.x+7,y=enemy.y+7}})) then
			-- Check no shield
			if ((not rotation and not enemy.shield.left) or (rotation and not enemy.shield.down)) then
				-- Do damage
				enemy.life -= player_bullet_damage(bullet)
				timer(4, true, _blink_enemy, {cpt=0,enemy=enemy})
			else
				sfx(8)
			end
			del(player.bullets, bullet)
		end
	end
	-- Boss
	if (boss != nil and not boss.invincible) then
		local boss_coord = ternaire(boss.rotate, {{x=boss.x,y=boss.y+5},{x=boss.x+15,y=boss.y+15}}, {{x=boss.x+5,y=boss.y},{x=boss.x+15,y=boss.y+15}})
		if (collision_rectangle({{x=bullet.x+1, y=bullet.y+1},{x=bullet.x+4,y=bullet.y+4}}, boss_coord)) then
			-- Check no shield
			if ((not rotation and not boss.shield_vert) or (rotation and not boss.shield_hori)) then
				boss.life -= player_bullet_damage(bullet)
				if (boss.phase == 1 and boss.life < cst_boss[boss.type].life / 2) boss.update = _ENV['change_phase_boss'..boss.type]
			else
				sfx(8)
			end
			del(player.bullets, bullet)
		end
	end
end

function collision_enemy_fire(bullet)
	local info = rotate_collision_player_info()
	if (not player.invincible and collision_rectangle({{x=bullet.x+1, y=bullet.y+1},{x=bullet.x+4,y=bullet.y+4}}, {{x=player.x+info[1].x,y=player.y+info[1].y},{x=player.x+info[2].x,y=player.y+info[2].y}})) then
		player.life -= 1
		player.invincible = true
		timer(4, true, _blink_player, {cpt=0,enemy=enemy})
		del(enemies.bullets, bullet)
		if (player.life > 0) sfx(2)
	end
end

function collision_spaceship(enemy)
	local info = rotate_collision_player_info()
	if (not player.invincible and collision_rectangle({{x=enemy.x, y=enemy.y},{x=enemy.x+7,y=enemy.y+7}}, {{x=player.x+info[1].x,y=player.y+info[1].y},{x=player.x+info[2].x,y=player.y+info[2].y}})) then
		player.life -= 1
		player.invincible = true
		timer(4, true, _blink_player, {cpt=0,enemy=enemy})
		enemy.life = 0
	end
end

function collision_collectible(collectible)
	if (collision_rectangle({{x=collectible.x+1, y=collectible.y+1},{x=collectible.x+6,y=collectible.y+6}}, {{x=player.x,y=player.y},{x=player.x+7,y=player.y+7}})) then
		if (player.life < cst_player_life and collectible.sprite == cst_collectible_sprt_life) player.life += 1
		if (collectible.sprite == cst_collectible_sprt_energy) player.energy += 1
		if (collectible.sprite == cst_collectible_sprt_power) player.power += 1
		if (collectible.sprite == cst_collectible_sprt_speed) player.speed += .1
		if (collectible.sprite == cst_collectible_sprt_score) player.score += 8
		del(collectibles, collectible)
		sfx(7)
	end
end

function collision_player_boss()
	if (boss == nil) return
	local info = rotate_collision_player_info()
	local boss_coord = ternaire(boss.rotate, {{x=boss.x,y=boss.y+5},{x=boss.x+15,y=boss.y+15}}, {{x=boss.x+5,y=boss.y},{x=boss.x+15,y=boss.y+15}})
	if (not player.invincible and collision_rectangle(boss_coord, {{x=player.x+info[1].x,y=player.y+info[1].y},{x=player.x+info[2].x,y=player.y+info[2].y}})) then
		player.life = 0
	end
end

function collision_rectangle(obj1, obj2)
	return obj1[1].x <= obj2[2].x and obj2[1].x <= obj1[2].x and obj1[1].y <= obj2[2].y and obj2[1].y <= obj1[2].y
end

function _blink_enemy(params, timer)
	if (params.cpt < 6) then
		params.cpt += 1
		params.enemy.show = not params.enemy.show
	else
		timer_stop(timer)
	end
end

function _blink_player(params, timer)
	if (params.cpt < 6) then
		params.cpt += 1
		player.show = not player.show
		player.thruster.show = not player.thruster.show
	else
		player.invincible = false
		timer_stop(timer)
	end
end

-->8
--ui

function draw_ui()
	-- Life
	local x = 1
	for i=1,cst_player_life do
		spr(ternaire(i > player.life, 25, 24), x, 114)
		x += 9
	end
	-- Energy
	x = 1
	for i=1,cst_player_energy do
		local flip = false
		local sprt = ternaire(i <= player.energy, 67, 65)
		if (i == 1 or i == cst_player_energy) then
			flip = i == cst_player_energy
			sprt = ternaire((i == 1 and player.energy >= 1) or (flip and player.energy >= cst_player_energy), 66, 64)
		end
		spr(sprt, x, 120, 1, 1, flip)
		x+=8
	end
	-- Score
	print("score:"..flr(player.score), 2, 2, 7)
end

-->8
--background & foreground

function init_ground()
	planet = {visible=false,speed=cst_ground_planet_speed}
	stars = {}
	ligths = {}
	for i=0,random(cst_ground_light_max,cst_ground_light_min) do
		add(ligths, {x=-2,speed=cst_ground_light_speed})
	end
	for i=0,random(cst_ground_star_max,cst_ground_star_min) do
		add(stars, {x=-9,speed=cst_ground_star_speed})
	end
end

function update_ground()
	-- Planet
	if (not planet.visible) then
		-- Show the planet, set the properties
		planet.sprite = cst_ground_planet_sprt[random(4) + 1]
		planet.visible = true
		local spawn = rotate_ground_spawn(200, random(111))
		planet.x = spawn.x
		planet.y = spawn.y
	end
	if (planet.visible) then
		if (planet.x < -100 or planet.y > 228) planet.visible = false
		local speed = rotate_ground_speed(planet.speed)
		planet.x += speed.x
		planet.y += speed.y
	end
	-- Stars
	for star in all(stars) do 
		if (star.x < -8 or star.y > 128) then
			star.sprite = cst_ground_star_sprt[random(3) + 1]
			local spawn = rotate_ground_spawn(random(380,130), random(127))
			star.x = spawn.x
			star.y = spawn.y
		end
		local speed = rotate_ground_speed(star.speed)
		star.x += speed.x
		star.y += speed.y
	end
	-- Lights
	for light in all(ligths) do
		if (light.x < -1 or light.y > 128) then
			local spawn = rotate_ground_spawn(random(230,130), random(127))
			light.x = spawn.x
			light.y = spawn.y
			light.color = random(6,5)
		end
		local speed = rotate_ground_speed(light.speed)
		if (light.color == 6) speed = rotate_ground_speed(light.speed+0.2)
		light.x += speed.x
		light.y += speed.y
	end
end

function draw_background()
	-- Stars
	for star in all(stars) do 
		spr(star.sprite, star.x, star.y)
	end
	-- Planet
	if (planet.visible) then
		spr(planet.sprite, planet.x, planet.y)
		spr(planet.sprite+1, planet.x+8, planet.y)
		spr(planet.sprite+16, planet.x, planet.y+8)
		spr(planet.sprite+17, planet.x+8, planet.y+8)
	end
end

function draw_foreground()
	for light in all(ligths) do
		if (light.color == 6) pset(light.x-1, light.y, light.color)
		pset(light.x, light.y, light.color)
	end
end

-->8
--bomb

function init_bomb()
	bomb = {
		active = false,
		back = false,
		radius = 0,
		x = 0,
		y = 0,
		color = 7
	}
end

function update_bomb()
	if (not bomb.active) return
	if (bomb.back) then
		bomb.radius -= 8
		if (bomb.radius < 10) then
			timer_stop(bomb.timer)
			init_bomb()
			player.invincible = false
		end
	else
		bomb.radius += 8
		if (bomb.radius > 140) then
			bomb.back = true
			-- Damage
			for enemy in all(enemies.entities) do
				enemy.life -= 5
			end
		end
	end
end

function draw_bomb()
	circfill(bomb.x, bomb.y, bomb.radius, bomb.color)
end

--- === Functions === ---

function blast()
	bomb.active = true
	bomb.x = player.x + 4
	bomb.y = player.y + 4
	bomb.timer = timer(6, true, _bomb_color)
	player.energy = 0
	player.invincible = true
	sfx(3)
end

function _bomb_color()
	bomb.color = ternaire(bomb.color == 7, 15, 7)
end

-->8
--rotate

function init_rotate()
	rotation = false
	rotate_callback = {}
end

function rotate()
	-- De/Active rotate mode
	rotation = not rotation
	-- Rotate callback
	for callback in all(rotate_callback) do
		callback()
	end
end

function on_rotate(callback)
	add(rotate_callback, callback)
end

function rotate_delete_callback(callback)
	del(rotate_callback, callback)
end

function rotate_player_info(btn)
	if (btn == nil) then
		return ternaire(rotation, {sprite=cst_player_sprt_rota[1], offset={x=0,y=6}}, {sprite=cst_player_sprt_base[1], offset={x=-6,y=0}})
	end
	if (btn == 0) then
		return ternaire(rotation, {sprite=cst_player_sprt_rota[2], offset={x=-1,y=6}}, {sprite=cst_player_sprt_base[1], offset={x=-6,y=0}})
	end
	if (btn == 1) then
		return ternaire(rotation, {sprite=cst_player_sprt_rota[3], offset={x=1,y=6}}, {sprite=cst_player_sprt_base[1], offset={x=-6,y=0}})
	end
	if (btn == 2) then
		return ternaire(rotation, {sprite=cst_player_sprt_rota[1], offset={x=0,y=6}}, {sprite=cst_player_sprt_base[2], offset={x=-6,y=-1}})
	end
	if (btn == 3) then
		return ternaire(rotation, {sprite=cst_player_sprt_rota[1], offset={x=0,y=6}}, {sprite=cst_player_sprt_base[3], offset={x=-6,y=1}})
	end
end

function rotate_player_border()
	return ternaire(
		rotation,
		{left={cond=-7,to=127}, right={cond=127,to=-7}, down={cond=120,to=120}, up={cond=0,to=0}},
		{left={cond=0,to=0}, right={cond=120,to=120}, down={cond=127,to=-7}, up={cond=-7,to=127}}
	)
end

function rotate_bullet_info()
	if (rotation) then 
		return {
			sprites=cst_player_bullet_sprt_rota, 
			speed={
				base={x=0,y=-cst_player_bullet_speed},
				diag1={x=cst_player_bullet_speed/2,y=-cst_player_bullet_speed/2},
				diag2={x=-cst_player_bullet_speed/2,y=-cst_player_bullet_speed/2}
			}, 
			offset={base={x=1,y=2},diag1={x=4,y=0},diag2={x=-1,y=2}}}
	end
	return {
		sprites=cst_player_bullet_sprt_base, 
		speed={
			base={x=cst_player_bullet_speed,y=0},
			diag1={x=cst_player_bullet_speed/2,y=cst_player_bullet_speed/2},
			diag2={x=cst_player_bullet_speed/2,y=-cst_player_bullet_speed/2}
		},
		offset={base={x=2,y=1},diag1={x=0,y=0},diag2={x=0,y=0}}
	}
end

function rotate_thruster_info()
	return ternaire(rotation, {x=0, y=1, offset={x=random(4,3),y=9}}, {x=-1, y=0, offset={x=-2,y=random(4,3)}})
end

function rotate_ground_spawn(baseX, baseY)
	return ternaire(rotation, {x=baseY, y=-baseX+128}, {x=baseX, y=baseY})
end

function rotate_ground_speed(speed)
	return ternaire(rotation, {x=0, y=speed}, {x=-speed, y=0})
end

function rotate_enemy1_info(speed, diffX, diffY)
	local sprite = cst_enemy[1].sprt
	-- Rotation
	if (rotation) then
		if (abs(diffY) < 40) then
			diffX = limit(diffX, speed)
			if (diffX < 0) sprite += 3 
			if (diffX > 0) sprite += 4
		else
			diffX = 0
		end
		return {x=diffX, y=speed, sprite=sprite}
	end
	-- No rotation
	if (abs(diffX) < 40) then
		diffY = limit(diffY, speed)
		if (diffY < 0) sprite += 2
		if (diffY > 0) sprite += 1
	else
		diffY = 0
	end
	return {x=-speed, y=diffY, sprite=sprite}
end

function rotate_enemy2_info(speed)
	return ternaire(rotation, {x=0, y=speed}, {x=-speed, y=0})
end

function rotate_enemy3_info(speed, x, y, diffX, diffY)
	local sprite = cst_enemy[3].sprt
	local move = 0
	if (rotation) then
		if (y < 8) move = speed
		diffX = limit(diffX, speed)
		if (diffX < 0) sprite += 3
		if (diffX > 0) sprite += 4
		return {x=diffX, y=move, sprite=sprite}
	end
	if (x > 112) move = -speed
	diffY = limit(diffY, speed)
	if (diffY < 0) sprite += 2
	if (diffY > 0) sprite += 1
	return {x=move, y=diffY, sprite=sprite}
end

function rotate_enemy_spawn(baseX, baseY, forceRotate)
	if (forceRotate == nil) forceRotate = rotation
	return ternaire(forceRotate, {x=baseY, y=-baseX+128}, {x=baseX, y=baseY})
end

function rotate_collision_player_info()
	return ternaire(rotation, {{x=2,y=0}, {x=5,y=7}}, {{x=0,y=2}, {x=7,y=5}})
end

function rotate_collectible_info()
	return ternaire(rotation, {x=0, y=1}, {x=-1, y=0})
end

function _rotate_player_animation()
	player.show = true
	player.thruster.show = true
end

-->8
--time utils

function init_timer()
	timers = {}
	animations = {}
	particles = {}
end

function update_timer()
	-- Execute timer
	for timer in all(timers) do
		timer.time += 1
		if (timer.time >= timer.duration) then
			if (timer.callback != nil) timer.callback(timer.param, timer)
			if (timer.loop) then
				timer.time = 0
			else
				del(timers, timer)
			end
		end
	end
end

function draw_timer()
	-- Draw animations
	for animation in all(animations) do
		if (animation.show) spr(animation.sprites[animation.index], animation.x, animation.y)
	end
	-- Draw particles
	for particle in all(particles) do
		if particle.radius <= 1 then
			pset(particle.x, particle.y, particle.color)
		else
			circfill(particle.x, particle.y, particle.radius, particle.color)
		end
	end

	
end

--- === Functions === ---

function timer(duration, loop, callback, param)
	local timer = {time=0,duration=duration,loop=loop,callback=callback,param=param}
	add(timers, timer)
	return timer
end

function timer_is_end(timer)
	if (timer == nil) return true
	return not timer.loop and timer.time >= timer.duration
end

function timer_restart(timer)
	timer.time = 0
	add(timers, timer)
end

function timer_stop(timer)
	del(timers, timer)
end

function animate(sprites, duration, x, y, loop, callback)
	if (loop == nil) loop = true
	local animation = {sprites=sprites,index=1,x=x,y=y,loop=loop,callback=callback,show=true}
	animation.timer = timer(duration, true, _animate, animation)
	add(animations, animation)
	return animation
end

function _animate(animation)
	animation.index += 1
	if (animation.index > #animation.sprites) then
		if (animation.loop) then
			animation.index = 1
		else
			-- Animation complete, remove and callback
			if (animation.callback != nil) animation.callback()
			timer_stop(animation.timer)
			del(animations, animation)
		end
	end
end

function shake(intensity)
	intensity = intensity or 1
	timer(1, true, _shake, {intensity=intensity})
end

function _shake(params, timer)
	camera(rnd(params.intensity)-params.intensity/2, rnd(params.intensity)-params.intensity/2)
	params.intensity *= 0.9
	if (params.intensity < .2) then
		camera()
		timer_stop(timer)
	end
end

function particle(x, y, duration, radius, move, colors, physics, refresh)
	-- Default value
	if (type(colors) != "table") colors = {colors}
	physics = physics or {}
	refresh = refresh or 1
	-- Create particle
	local particle = {
		time = 0,
		duration = duration,
		x = x,
		y = y,
		radius = radius,
		move = move,
		physics = physics,
		color = colors[1],
		colors = colors
	}
	add(particles, particle)
	timer(refresh, true, _particle, particle)
end

function _particle(particle, timer)
	-- Particle life
	particle.time += 1
	if (particle.time > particle.duration) then
		timer_stop(timer)
		return del(particles, particle) -- Return to stop
	end

	-- Set color depending on life of the particle
	if (#particle.colors > 1) then
		local divider = particle.duration / #particle.colors
		particle.color = particle.colors[flr(particle.time/divider)+1]
	end

	-- Set physics effect
	if (particle.physics.gravity) particle.move.y += 0.5
	if (particle.physics.grow) particle.radius += 0.1
	if (particle.physics.reduce) particle.radius -= 0.1

	-- Move particle
	particle.x += particle.move.x
	particle.y += particle.move.y
end

function explosion(x, y, params)
	-- Parameter
	params = params or {}
	params.number = params.number or 8
	params.duration = params.duration or rnd(25)+30
	params.radius = params.radius or 2
	-- Add particles for explosion effect
	for i=0,params.number do
		particle(
			x,
			y,
			params.duration,
			params.radius,
			{x=rnd(2)-1, y=rnd(2)-1},
			{10,7,6,6,5},
			{reduce=true}
		)
	end
end

-->8
--utils

function random(max, min)
	-- max include, min include
	min = min or 0
	if (min > max) then
		local tmp = min
		min = max
		max = tmp
	end
	return flr(rnd(max+1-min))+min
end

function limit(number, max)
	if (abs(number) > max) then
		if (number < 0) return -max
		return max
	end
	return number
end

function contain(tab, val)
	for v in all(tab) do
		if (v == val) return true
	end
	return false
end

function ternaire(cond, val1, val2)
	if (cond) return val1
	return val2
end

-->8
--sfx reference

-- 0 = menu cursor mouvement
-- 1 = menu selection
-- 2 = enemy explosion
-- 3 = bomb explosion
-- 4 = enemy fire
-- 5 = player fire
-- 6 = player death
-- 7 = collectible collected
-- 8 = player bullet blocked

__gfx__
00000000000660000006600000000000006600000000000000005500000550000055000000005500000000000000000000000077770000000000009999000000
00670000006d6000665555d00000000000d60d000660d550000d550000d55d000d5d00000000d5d00000000000a0a0000000cccccccc00000000999799990000
06700000665555d000655f550006600006555f550d65f5506655ffd0005ff50005f5000000005f500000000000070000000cccccccccc00000099999a9999000
0777777600655f55006555d5665d600066555f5506555fd06d55550066555566655566000066555600c0c00000a0a00000cccccccbcccc000099999999999900
6777600000655f55665d6000006555d5006555d006655500065555666d5555d66555d600006d555600070000000000000cccccccccccccc009997aa999aa9990
67777000665555d00006600000655f550065550060065660066655d606566560056650000005665000c0c000000000000ccb3cccc333ccc0099999999aa79990
06776000006d600000000000665555d00666d60000066d60060066000060060006006000000600600000000000000000ccc33ccc3333cccc9999999999977999
000000000006600000000000000660000000660000600000000060000060060006006000000600600000000000000000ccc3cc3cb3ccc3cc99aa79997a999999
00000000000000000000000000000000000aa000000aa000000a9000000aa00000000000000000000000000000000000c3c3bcccccccfccc999a99799a999999
00000000000000000000000000000000000a9000000a9000000990000009a00007700770077007700000000000000000ccc33cccffcccccc99999a99999aa999
0000000000000000000000000000000000099000000990000009800000099000788778e77007700700000000000a00000ccc3ccc3fc33fc00999999999997990
000889aa000899aa0008999a0008899a00088000000980000009800000088000788888e7700000070000c00000a7a0000ccccccccbcb3cc00999a997a99a7990
0000899a0000899a00008899000089aa000800000008000000080000000800007888888770000007000c7c00000a000000cccccccccccc000099979799799900
000000000000000000000000000000000000000000000000000000000000000007888870070000700000c00000000000000cccccccccc000000999999aa99000
0000000000000000000000000000000000000000000000000000000000000000007887000070070000000000000000000000cccccccc00000000999999990000
00000000000000000000000000000000000000000000000000000000000000000007700000077000000000000000000000000077770000000000009999000000
00000000000000000000000000000000000aa000000aa0000009a000000aa0000000000000000000000000777700000000000088880008000000002222000000
00000000000000000000000000000000000aa0000009a000000990000009a000006666000066660000007777777700000000888888800008000022222d22ee00
00000000000000000000000000000000000a9000000990000008900000099000066886600666a6600007777776777000000888888800880000022222dd222ee0
00089aaa0000899a000088990008999a0009800000088000000880000009800006888860066aa6600077777677767700008888888000000000222dd2d2222ee0
000089aa000889aa0008899a000089aa0008000000008000000080000008000006888860066aa6600777777777777770088888888000808002222d222222eee0
000000000000000000000000000000000000000000000000000000000000000006688660066a666007767777767777700888888880800880022222222222ee20
0000000000000000000000000000000000000000000000000000000000000000006666000066660077777767777677778888888880008888222d2222d22eee22
000000000000000000000000000000000000000000000000000000000000000000000000000000007777777767777677888888888808888822dd222dd2eee222
00000000000bb000000bb0000000bbb000bb00000bbbb000bb000000bbb000000000000000000000777767777777777788888888888888882dd222d22eee2dd2
0bbb00000bb77b0000b7b000000b77b00b77b000b7777b00b7b00000b77b00000066660000666600777777777767777788888888888888882dd22222eee2dd22
b777b000b7777b000b7b000000b777b00b77b000b7777b000b7b0000b777b000066bb6600666c660076777777777677008888888888888800222222eee2dd220
b777b000b7777b00b7b000000b777b000b77b0000b77b00000b7b0000b777b0006b77b6006cccc6007777677677777700888888888888880022222eee2222220
0bbb00000bb77b00bb000000b777b00000bb00000b77b000000bb00000b777b006b77b6006cccc60007777777777770000888888888888000e22eeee22222200
00000000000bb00000000000b77b00000000000000bb000000000000000b77b0066bb6600666c660000777767767700000088888888880000eeeeeedd2222000
0000000000000000000000000bb000000000000000000000000000000000bb0000666600006666000000777777770000000088888888000000eee2dd22220000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000777700000000000088880000000000002222000000
00000000000000000000000000000000005555000000000000555500005500000000550000777770777770000770770000777000777777707000007070000000
00000000000000000000000000000000056666500000000005666650056650000005665007000000000007007000007007000700000000007700070070000000
0000000000000000000000000000000056d22d650055550056dffd6556dd65000056dd6570000000000000707000007070000070000000007070700070000000
00000000000000000000000000000000562ff2650566665056d22d6556f2650000562f6570000000000000707077070070000000000000007007000070000070
06666666666666660666666666666666562ff26556d22d650566665056f2650000562f6507777000000007000707707070000000777777707000000070000070
65555555555555556aaaaaaaaaaaaaaa56d22d6556dffd650055550056dd65000056dd6500000700777770007000007070000000700000007000000070000070
65555555555555556aaaaaaaaaaaaaaa056666500566665000000000056650000005665000000070700000007000007007000000700000007000000007000700
06666666666666660666666666666666005555000055550000000000005500000000550000077770700000000770770000777000777777707000000000777000
00000000000880000000000008888000005555000000000000555500005500000000550000000000000000000000000000000000000000000000000000000000
00000000088778000008800087777800056666500000000005666650056650000005665000000000000000000000000000000000000000000000000000000000
0088800087777800008778008777780056d44d650055550056dffd6556dd65000056dd6500000000000000000000000000000000000000000000000000000000
08777800877778000087780008778000564ff4650566665056d44d6556f4650000564f6500000000000000000000000000000000000000000000000000000000
08777800088778000087780008778000564ff46556d44d650566665056f4650000564f6500000000000000000000000000000000000000000000000000000000
0088800000088000000880000088000056d44d6556dffd650055550056dd65000056dd6500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000056666500566665000000000056650000005665000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000005555000055550000000000005500000000550000000000000000000000000000000000000000000000000000000000
00088000000088808800000088800000005555000000000000555500005500000000550000000000000000000000000000000000000000000000000000000000
00878000000877808780000087780000056666500000000005666650056650000005665000000000000000000000000000000000000000000000000000000000
0878000000877780087800008777800056deed650055550056dffd6556dd65000056dd6500000000000000000000000000000000000000000000000000000000
8780000008777800008780000877780056effe650566665056deed6556fe65000056ef6500000000000000000000000000000000000000000000000000000000
8800000087778000000880000087778056effe6556deed650566665056fe65000056ef6500000000000000000000000000000000000000000000000000000000
0000000087780000000000000008778056deed6556dffd650055550056dd65000056dd6500000000000000000000000000000000000000000000000000000000
00000000088000000000000000008800056666500566665000000000056650000005665000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000005555000055550000000000005500000000550000000000000000000000000000000000000000000000000000000000
0000000000000c500050050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000c5055d00d5500666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5aaa00000000c6d5cc6666cc06366360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
500aaa000000c60000cccc0006633660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000aaa0000c6000000000006633660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555555550000c6d50000000006366360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000c500000000000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000c500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000056666200555000000005550000000000566660000552000000255000066665000000000000000055000000000000000000000000000000000000000
00000055566666652666550000556662000000555666660000556500005655000066666555000000000000566500000000000000000000000000000000000000
0000000066666565665666dddd66656600000000666665556656665dd56665665556666600000000000000666600000000000000000000000000000000000000
000055065555566566656622226656660000000666665655666566522566566655656666600000000000006ff600000000000000000000000000000000000000
0055665556666650666566dddd66566600000055555566626666565dd5656666266655555500000000000067f600000000000000000000000000000000000000
056666666566665066656652256656660000005666666650666656555565666605666666650000000000006ff600000000000000000000000000000000000000
0566fff6655d2d0056656555555656650566666555555500566656555565666500555555566666500500556ff655005000000000000000000000000000000000
566fffff552d2d000565566556655650566fffff555d2d00056656555565665000d2d555fff7f6650506565ff565605000000000000000000000000000000000
566ff7ff552d2d000506566ff6656050566f7fff555d2d000506565ff565605000d2d555fffff665056656555565665000000000000000000000000000000000
0566fff6655d2d00050056ffff65005005666665555555000500556ff65500500055555556666650566656555565666500000000000000000000000000000000
0566666665666650000566ff7f66500000000056666666500000006ff60000000566666665000000666656555565666600000000000000000000000000000000
0055665556666650000566ffff66500000000055555566620000006f7600000026665555550000006666565dd565666600000000000000000000000000000000
00005506555556650000566ff665000000000006666656550000006ff60000005565666660000000666566522566566600000000000000000000000000000000
000000006666656500005666666500000000000066666555000000666600000055566666000000006656665dd566656600000000000000000000000000000000
00000055566666650000055665500000000000555666660000000056650000000066666555000000005565000056550000000000000000000000000000000000
00000000056666200000000550000000000000000566660000000005500000000066665000000000005520000002550000000000000000000000000000000000
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111661111111111111111511111111
11111111116611111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111151111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a11111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a7a1111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a11111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111115111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a11111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a7a1111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a11111111111111111111
11111111111111111111117777717777711117717711117771117777777117117777777171111171111111117111111177777111111111111111111111111111
11111111111111111111171111111111171171111171171117111111111171111111111177111711111111117111111111111711111111111111111111111111
11111111111111111111711111111111117171111171711111711111111111111111111171717111111111117111111111111171111111111111111111111111
11111111111111111111711111111111117171771711711111111111111111111111111171171111111111117111117111111171111111111111111111111111
11111111111111111111177771111111171117177171711111117777777111117777777171111111111111117111117111111711111111111111111111111111
11111111111111111111111117117777711171111171711111117111111111117111111171111111111111117111117177777111111111111111111111111111
11111111111111111111111111717111111171111171171111117111111111117111111171111111111111111711171171111111111111111111111111111111
11111111111111111111111777717111111117717711117771117777777111117777777171111111111111111177711171111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111151111
111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111511111111a1a11111
1111111111111111111111111111111111111111111111111111111111111111111111111c1c1111111111111111111111111111111111111111111117111111
111111111111111111111111111111111111111111111111111111111111777711111111117111111111111111111111111111111111111111111111a1a11111
1111111111111111111111111111111111111111111111111111111111cccccccc1111111c1c1111111111111111111111111111111111111111111111111111
111111111c11111111111111111111111111111111111111111111111cccccccccc1111111111111111111111111111111111111111111111111111111111111
11111111c7c111111111111111111111111111111111111111111111cccccccbcccc1111111111111111111111111111111111a1a11111111111111111111111
111111111c111111111111111111111111111111111111111111111cccccccccccccc11111111111111111111111111111111117111111111111111111111111
1111111111111111111111111661111111111111111111111111111ccb3cccc333ccc111111111111111111111111111111111a1a11111111111111111111111
111111111111111111111111111111111111111111111111111111ccc33ccc3333cccc1111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111ccc3cc3cb3ccc3cc1111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111c3c3bcccccccfccc1111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111ccc33cccffcccccc1111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111ccc3ccc3fc33fc11111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111ccccccccbcb3cc11111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111cccccccccccc111111111111111111111111111111111111111111111111111111111111
111111511111111111111111111111111111111111111111111111111cccccccccc1111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111cccccccc11111111111111111111111111111111111111111111111111111111111111
11115111111111111111111111111111111111111111111111111111111177771111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111116611111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111a1a111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111171111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111a1a111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111166111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111151111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111661111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a1
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111117
111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a1
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
15111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111511111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111661111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
16611111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a11111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a7a1111111111111111111111
111111111111111111111111111111c1c11111111111111111111111111111111111111111111111111111111111111111111111a11111111111111111111111
11111111111111111111111111111117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111c1c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111511111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11777111111111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1171717171111171111771171171717771177117717771115aaa11111111111111111111c1111111111111111111111111111111111111111111111111111111
117711777111117111717171717171171171117171777111511aaa11111111111111111c7c111111111111111111111111111111111111111111111111111111
11717111711111711171717711717117117111717171711151111aaa1111111111111111c1111111111111111111111111111111111111111111111111111111
11777177111111777177111771177177711771771171711155555555111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

__sfx__
00030000201201b130251200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000260452b035300253000500703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
000200000c363236650935520641063311b6210432116611023210f611013110a6110361104600036000260001600016000460003600026000160001600016000160004600036000260001600016000160001600
00080000386303062025610206101c61019610176101561012610106100f6100d6100b6100a613086130761306613046130361303613006050060500605006050060500605006050060500605006050060500605
000100002b52329543265532555323551215511f5511c5511955118551165511455113541105410d5310b52108521075210551103511025110151102400023000130003400024000140001400024000240001400
000100003b32039320363203472032720307202e7202b720297202672023720235000b20007200062000520003200022000120001200000000000000000000000000000000000000000000000000000000000000
001200001c1631c1531c1431c1331c1231c1130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007000023725287252d3021e105370021c0051330213302133021330213302133021330213302133021330213302133021330213302133021330213302133021320207002070022b0001f0001f0021f0021f002
000800000c32300300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
