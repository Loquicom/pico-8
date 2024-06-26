pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--sp8ce'em up
--a SPATIAL SHOOT'EM UP by Loquicom
--gameloop

function _init()
	cartdata("sp8ce-em-up")
	init_constant()
	init_ground()
	set_title_mode()
	background_color = cst_ground_color
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
	cls(background_color)
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
	-- Music
	if (selectedMode == "scripted") change_music(6)
	if (selectedMode == "infinite") change_music(12)
end

function update_game()
	-- Update timer ground animation
	update_timer()
	update_ground()
	-- Game specific
	update_bomb()
	if (player.life > 0) update_enemy()
	update_collectible()
	update_player()
end

function draw_game()
	-- Draw timer and ground animation
	cls(background_color)
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

function set_end_mode(message)
	init_end(message)
	_update = update_end
	_draw = draw_end
end

function init_end(message)
	init_timer()
	change_music(17)
	end_waiting = timer(20, false)
	end_message = message or "game over"
end

function update_end()
	-- Update timer ground animation
	update_timer()
	update_ground()
	-- End specific
	if (timer_is_end(end_waiting) and btnp(4)) then
		set_title_mode()
	end
	if (timer_is_end(end_waiting) and btnp(5)) then
		set_game_mode()
	end
end

function draw_end()
	-- Draw timer and ground animation
	cls(background_color)
	draw_background()
	draw_foreground()
	-- End specific
	print(end_message,44,44,7)
 	print("your score:"..flr(player.score),34,54,7)
  	print("press ❎ to play again!",18,72,6)
	print("press 🅾️ to return to the menu",5,80,6)
end

-->8
--constant

function init_constant()
	cst_version = "1.00"
	-- Player
	cst_player_life = 5 -- Max 14
	cst_player_energy = 5
	cst_player_power = 3
	cst_player_speed_base = 2
	cst_player_speed_max = 3.6
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
	cst_ground_color = 1
	cst_ground_color_change = -1
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
		},
		{
			sprt = 116,
			speed = 1,
			life = 1
		}
	}
	-- Boss
	cst_boss = {
		{
			sprt_base = 128,
			sprt_rota = 130,
			speed = 1,
			life = 40,
			fire = 20 -- Time between two bullets
		},
		{
			sprt_base = 132,
			sprt_rota = 134,
			speed = 2,
			life = 50,
			fire = 18 -- Time between two bullets
		}
	}
	cst_boss_sprt_fire = 89
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
	menu_cursor = ternaire(dget(0) != 0, dget(0), 1)
	cst_player_life = ternaire(dget(4) != 0, dget(4), cst_player_life)
	explosion_counter = 0
	gamemode = 0
	change_music(0)
end

function update_menu()
	-- Mode selector
 	if (btnp(2) and menu_cursor > 1) then
		menu_cursor -= 1
		explosion_counter = 0
		dset(0, menu_cursor)
		sfx(0)
	elseif (btnp(3) and menu_cursor < #cst_menu_label) then
		menu_cursor += 1
		explosion_counter = 0
		dset(0, menu_cursor)
		sfx(0)
	-- Life selector
	elseif (btnp(0) and cst_player_life > 1) then 
		cst_player_life -= 1
		dset(4, cst_player_life)
		sfx(0)
	elseif (btnp(1) and cst_player_life < 14) then
		cst_player_life += 1
		dset(4, cst_player_life)
		sfx(0)
	-- Launch
	elseif (btnp(4) or btnp(5)) then
		gamemode = menu_cursor
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
	-- Life number
	print(cst_player_life, 120, 4, 7)
	spr(24, 110, 2)
end

--- === Functions === ---

function start_scripted_game()
	set_enemy_manager("scripted")
	set_game_mode()
end

function start_infinite_game()
	set_enemy_manager("infinite")
	set_game_mode()
end

function nothing()
	explosion(random(100,20),random(100,20),{radius=3,duration=rnd(120)+120,number=28})
	explosion_counter += 1
	if (dget(3) < explosion_counter) dset(3, explosion_counter)
	if (explosion_counter > 21) background_color = (background_color + cst_ground_color_change) % 16
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
		energy = cst_player_energy,
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
	timer(90, false, set_end_mode)
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
	-- Reset enemies
	init_enemy()
	-- Save best score
	if (dget(gamemode) < player.score) dset(gamemode, flr(player.score))
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

-->8
--ennemy

function init_enemy()
	local manager = enemy_manager or manage_enemy_infinite
	enemies = {entities={}, bullets={}, spawn = {0,0,0,0}, kill = {0,0,0,0}}
	enemy_manager = manager
	num_wave = 0
	kill_boss()
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
			if (enemy.respawn) timer(random(150,30), false, _respawn_enemy, enemy.type)
		end
		collision_spaceship(enemy)
		-- Shield particle
		if ((enemy.shield.left or enemy.shield.down) and random(64) != 8) then
			local info = ternaire(enemy.shield.down, {x=0, y=1, offset={x=random(7),y=11}}, {x=-1, y=0, offset={x=-4,y=random(7)}})
			particle(enemy.x+info.offset.x, enemy.y+info.offset.y, random(2,1), 1, {x=info.x, y=info.y}, 12, nil, 4)
		end
	end
	-- Boss
	if (boss != nil) then
		boss.update()
		if ((boss.shield_left or boss.shield_down)) then
			for i=1,3 do
				local info = ternaire(boss.shield_down, {x=0, y=1, offset={x=random(15),y=18}}, {x=-1, y=0, offset={x=-3,y=random(15)}})
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
	if (manager == "scripted") enemy_manager = manage_enemy_scripted
	if (manager == "infinite") enemy_manager = manage_enemy_infinite
	selectedMode = manager
end

function spawn_enemy(type, x, y, params)
	-- Set params defaut value
	params = params or {}
	if (params.shield_left == nil) params.shield_left = false
	if (params.shield_down == nil) params.shield_down = false
	if (params.shield_random == nil) params.shield_random = true
	if(params.respawn == nil) params.respawn = true
	-- Create enemy
	local spawn = rotate_enemy_spawn(x, y, ternaire(type == 4, not rotation, rotation))
	local enemy = {
		type = type,
		x = spawn.x,
		y = spawn.y,
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
	if (type == 3) enemy.fire = timer(60, true, _fire_enemy3, enemy)
	if (type == 4) enemy.vert = rotation
	add(enemies.entities, enemy)
	return enemy
end

function manage_enemy_scripted()
	-- enemies.spawn[1] ==> wave number
	-- enemies.spawn[2] ==> Nb of enemies left to spawn in the wave
	if (enemies.spawn[1] == 0) then 
		next_wave()
	elseif (timer_is_end(wave_timer) and enemies.spawn[2] == 0 and count(enemies.entities) == 0 and boss == nil) then -- Wave end
		if (enemies.spawn[1] == count(wave)) then -- Last wave
			-- Save best score
			if (dget(1) < player.score) dset(1, flr(player.score))
			timer(60, false, set_end_mode, "you win")
		else -- Next wave
			wave_timer = timer(60, false, next_wave)
		end
	end
end

function manage_enemy_infinite()
	local spawn1 = enemies.spawn[1]
	local spawn2 = enemies.spawn[2]
	local spawn3 = enemies.spawn[3]
	local kill1 = enemies.kill[1]
	local kill2 = enemies.kill[2]
	local kill3 = enemies.kill[3]
	-- Spawn first ennemy
	if (enemies.spawn[1] == 0) then
		spawn_enemy(1, 128, random(80,40))
		enemies.spawn[1] += 1
	-- When type3 is killed 5 time decrease fire cd
	elseif (kill3 != 0 and kill3 % 2 == 0) then
		for enemy in all(enemies) do
			if (enemy.type == 3) enemy.fire.duration -= 2
		end
	-- When (5 type2 * number of type2 + number of type2) kill, add new type2
	elseif (kill2 != 0 and kill2 % ((5*spawn2)+spawn2) == 0) then
		-- Check what type of enemy spawn
		local type = ternaire(spawn3 == 0 and spawn2 == cst_enemy[3].spawn, 3, 2)
		-- Spawn
		spawn_enemy(type, 134, random(120))
		enemies.spawn[type] += 1
	-- When (5 type1 * number of type1 + number of type1) kill, add new type1
	elseif (kill1 != 0 and kill1 % ((5*spawn1)+spawn1) == 0) then
		-- Check what type of enemy spawn
		local type = ternaire(spawn2 == 0 and spawn1 == cst_enemy[2].spawn, 2, 1)
		-- Spawn
		spawn_enemy(type, 134, random(120))
		enemies.spawn[type] += 1
	end
	-- Chance of spanw type4 increase for each enemies spawned
	if spawn1 > 2 and random(1800) <= spawn1 + spawn2 + spawn3 then
		spawn_enemy(4, 134, random(120), {respawn = false})
		enemies.spawn[4] += 1
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

function move_enemy_type4(enemy)
	local sprite = cst_enemy[4].sprt
	local speed = enemy.speed
	if (enemy.vert) then
		local diffY = player.y - enemy.y
		if (diffY != 0) enemy.y += limit(diffY, speed)
		if (diffY < 0) sprite += 1
		if (diffY > 0) sprite += 2
		enemy.x += -speed
	else
		local diffX = player.x - enemy.x
		if (diffX < 0) sprite += 3 
		if (diffX > 0) sprite += 4
		if (diffX != 0) enemy.x += limit(diffX, speed)
		enemy.y += speed
	end
	enemy.sprite = sprite
end

--- === Timers === ---

function _fire_enemy2(enemy)
	if (enemy.x > 128 or enemy.y < 0) return -- Don't fire if ennemy is outside the screen
	add(enemies.bullets, {x=enemy.x,y=enemy.y,speedX=1,speedY=1,sprite=98})
	add(enemies.bullets, {x=enemy.x,y=enemy.y,speedX=-1,speedY=1,sprite=96})
	add(enemies.bullets, {x=enemy.x,y=enemy.y,speedX=1,speedY=-1,sprite=96})
	add(enemies.bullets, {x=enemy.x,y=enemy.y,speedX=-1,speedY=-1,sprite=98})
	sfx(4)
end

function _fire_enemy3(enemy)
	if (enemy.x > 128 or enemy.y < 0) return -- Don't fire if ennemy is outside the screen
	if (rotation) then
		add(enemies.bullets, {x=enemy.x,y=enemy.y,speedX=0,speedY=ternaire(player.y < enemy.y, -2, 2),sprite=82})
	else
		add(enemies.bullets, {x=enemy.x,y=enemy.y,speedX=ternaire(player.x < enemy.x, -2, 2),speedY=0,sprite=80})
	end
	sfx(4)
end

function _respawn_enemy(type)
	spawn_enemy(type, 134, random(120))
end

-->8
--boss

function spawn_boss(type)
	local rotate = ternaire(type == 2, not rotation, rotation)
	local spawn = rotate_enemy_spawn(134, 56, rotate)
	boss = {
		type = type,
		invincible = false,
		phase = 1,
		life = cst_boss[type].life,
		x = spawn.x,
		y = spawn.y,
		speed = cst_boss[type].speed,
		move = false,
		rotate = rotate,
		rotate_timer = nil,
		fire_timer = timer(cst_boss[type].fire, true, _ENV['_fire_boss'..type]),
		shield_left = false,
		shield_down = false,
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
	change_music(21)
end

function kill_boss()
	if (boss == nil) return
	-- Remove boss
	timer_stop(boss.rotate_timer)
	timer_stop(boss.fire_timer)
	if (boss.rand_timer) timer_stop(boss.rand_timer)
	rotate_delete_callback(on_rotate_boss)
	change_music(6)
	boss = nil
end

function update_boss1()
	-- Move
	if (boss.move) then
		if (boss.rotate) then
			boss.y += boss.speed * 3
		else
			boss.x -= boss.speed * 3
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
			boss.shield_down = boss.rotate
			boss.shield_left = not boss.rotate
		end
	end
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
		boss.shield_left = rotation
		boss.shield_down = not rotation
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
		boss.shield_left = rotation
		boss.shield_down = not rotation
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

function _fire_boss1()
	if (boss.move) return
	local info = ternaire(boss.rotate, {offset={x=4,y=12},speed={{x=0,y=1},{x=-1,y=1},{x=1,y=1}}}, {offset={x=0,y=4},speed={{x=-1,y=0},{x=-1,y=1},{x=-1,y=-1}}})
	add(enemies.bullets, {x=boss.x+info.offset.x,y=boss.y+info.offset.y,speedX=info.speed[1].x,speedY=info.speed[1].y,sprite=cst_boss_sprt_fire})
	add(enemies.bullets, {x=boss.x+info.offset.x,y=boss.y+info.offset.y,speedX=info.speed[2].x,speedY=info.speed[2].y,sprite=cst_boss_sprt_fire})
	add(enemies.bullets, {x=boss.x+info.offset.x,y=boss.y+info.offset.y,speedX=info.speed[3].x,speedY=info.speed[3].y,sprite=cst_boss_sprt_fire})
	sfx(4)
end

function _fire_boss2()
	local info = ternaire(boss.rotate, {offset={x=4,y=12},speed={x=0,y=1}}, {offset={x=0,y=4},speed={x=-1,y=0}})
	add(enemies.bullets, {x=boss.x+info.offset.x,y=boss.y+info.offset.y,speedX=info.speed.x,speedY=info.speed.y,sprite=cst_boss_sprt_fire})
	if (boss.phase == 2) add(enemies.bullets, {x=boss.x+info.offset.x,y=boss.y+info.offset.y,speedX=-info.speed.x,speedY=-info.speed.y,sprite=cst_boss_sprt_fire})
	sfx(4)
end

-->8
--wave

function init_wave()
	wave_timer = nil
	-- type,time,y[number,r(random)],shield left[t(true),f(false),r(rotate)] (optional, f default),shield down[t(true),f(false),r(rotate)] (optional, f default)
	wave = {
		"1,0,60", -- 1: Show enemy type 1
		"1,0,60|1,50,20|1,50,100|1,100,20|1,100,60|1,100,100", -- 2
		"1,0,r|1,0,r|1,50,r|1,50,r|1,50,r|1,50,r|1,100,r|1,100,r|1,100,r", -- 3: Random
		"1,0,60|1,0,r|1,0,r|1,50,20|1,50,100|1,50,r|1,100,20|1,100,60|1,100,100|1,100,r|1,100,r|1,150,20|1,150,r|1,150,r|1,200,100|1,200,r|1,200,r|1,250,60|1,250,r|1,250,r", -- 4: Fixe + Random
		"2,0,60|1,100,20|1,100,100", -- 5: Show enemy type 2
		"2,0,20|2,0,100|1,50,60|2,150,40|2,150,80|1,200,20|1,200,100", -- 6
		"2,0,60|1,30,20|2,50,20|2,50,100|1,80,60|1,80,100", -- 7
		"2,0,60|2,20,20|2,20,100|1,30,20|1,30,60|1,30,100|2,50,40|2,50,80|1,60,40|1,60,80", -- 8
		"2,0,20|2,0,40|2,0,60|2,0,80|2,0,100|2,200,40|2,200,80|2,220,40|2,220,80|1,230,r|1,240,r|1,250,r", -- 9
		"1,0,60,f,t|1,100,20,t|1,200,60,r,r|1,300,20,t|1,300,100,f,t|1,400,20,t", -- 10: Show shield
		"1,0,60,t|1,50,60,f,t|1,100,60,t|1,150,60,f,t|1,200,6,t|1,250,60,f,t|1,300,6,t|1,350,60,f,t|1,400,60,t", -- 11
		"1,0,40,f,t|1,0,80,t|1,50,40,t|1,50,80,f,t|1,100,40,f,t|1,100,80,t|1,150,40,t|1,150,80,f,t|1,200,60,t", -- 12
		"1,0,60,r,r|1,80,60,r,r|1,160,60,r,r|1,240,60,r,r|1,320,60,r,r|1,400,60,r,r", -- 13: Rotate shield
		"1,0,r,r,r|1,80,r,r,r|1,160,r,r,r|1,240,r,r,r|1,320,r,r,r|1,400,r,r,r|1,480,r,r,r", -- 14: Random + rotate
		"2,0,60,t|1,50,40|1,50,80|2,150,60,f,t|1,200,40|1,200,80", -- 15: Type 2 shield
		"2,0,40,t|2,0,80,f,t|1,50,20|1,50,100|2,150,60|1,150,40,f,t|1,150,80,t|2,200,60,r,r", -- 16
		"1,0,20|1,0,40|1,0,60|1,0,80|1,0,100|2,0,30|2,0,90|1,100,70|1,100,50", -- 17
		"1,0,0,r,r|1,0,10,r,r|1,0,20,r,r|1,0,30,r,r|1,0,40,r,r|1,0,50,r,r|1,0,60,r,r|1,0,70,r,r|2,20,40|1,50,100", -- 18: The wall
		"1,0,r|1,40,r,r,r|1,80,r|2,120,r,r,r|1,160,r|1,200,r,r,r|2,200,r,r,r|1,240,r|2,280,r|1,320,r,r,r|2,360,r|1,400,r,r,r", -- 19
		"5", -- 20: Boss 1
		"1,0,60|2,50,20,f,t|2,50,100,f,t", -- 21: Pause
		"3,0,60", -- 22: Show enemy type 3
		"1,0,40|1,0,60|1,0,80|3,40,r|1,80,20|1,80,100", -- 23
		"1,0,40|2,0,60|1,0,80|3,40,r|2,80,20|2,80,100", -- 24
		"3,0,60,r,r|1,50,20|1,50,100|1,100,r|1,100,r|1,100,r", -- 25: Show type 3 with shield
		"1,0,40|1,0,80|2,0,60,r,r|3,50,60,r,r|1,150,20|1,150,100|2,200,60,r,r", -- 26
		"3,0,r,r,r|1,0,r|1,20,r|1,40,r|1,60,r|1,80,r|1,100,r|2,100,r,r,r|1,120,r|1,140,r|1,160,r|1,180,r|1,200,r", -- 27
		"2,0,20|2,0,40|2,0,60|2,0,80|2,0,100|1,20,30|1,20,50|1,20,70|1,20,90|3,40,r", -- 28: The wall 2
		"3,0,60,r,r|1,50,20|1,50,60|1,50,100|1,80,r|1,80,r|2,100,r,t|2,100,r,f,t|1,150,20|1,150,60|1,150,100|1,180,r|1,180,r", -- 29
		"3,0,60,r,r|4,50,20|4,50,60|4,50,100|4,80,r|4,80,r", -- 30: Show enemy type 4
		"1,0,r|4,20,r|1,50,r|4,70,r|1,100,r|4,120,r|1,150,r|4,170,r|1,200,r|4,220,r", -- 31
		"1,0,r|4,20,r,r,r|1,50,r|4,70,r,r,r|1,100,r|4,120,r,r,r|1,150,r|4,170,r,r,r|1,200,r|4,220,r,r,r", -- 32
		"2,0,40|2,0,80|4,20,60|2,100,20,r,r|2,100,100,r,r|4,120,r|4,120,r|4,150,r,r,r|1,150,r,r,r", -- 33
		"2,0,40,r,r|2,0,80,r,r|4,20,60|4,20,r|4,20,r|3,100,r,r,r|4,120,60|4,120,r|4,120,r", -- 34
		"2,0,20|2,0,100|3,0,60|3,10,60|3,20,60|4,50,r|4,50,r", -- 35: Show stacked type 3
		"2,0,20|2,0,100|3,0,60,r,r|3,10,60,r,r|3,20,60,r,r|4,50,r|1,50,r", -- 36
		"3,0,r|1,0,r|4,0,r|2,50,r|3,100,r,r,r|1,100,r|4,100,r|2,150,r,r,r|3,200,r|1,200,r,r,r|4,200,r,r,r", -- 37
		"2,0,20|2,0,100|3,0,60|3,10,60|3,20,60|3,30,60|3,40,60|3,50,60|3,60,60|4,100,r|4,100,r|1,100,r|1,100,r", -- 38: Maxi stack
		"2,0,r,t|2,0,r,f,t|1,50,r|4,50,r,r,r|3,100,r,r,r|1,150,r,r,r|4,150,r|2,200,60", -- 39
		"6", -- 40: Boss 2
		"1,100,r,r,r", -- 41: Awake
		"4,0,60,t,t|4,20,20,t,t|4,20,100,t,t|4,420,r", -- 42: Evade
	}
end

function next_wave()
	enemies.spawn[1] += 1
	num_wave = enemies.spawn[1]
	if (num_wave == 1) init_wave()
	instanciate_wave(wave[num_wave])
end

function instanciate_wave(wave)
	local data = split(wave, "|")
	enemies.spawn[2] = count(data)
	for enemy in all(data) do
		local info = split(enemy, ",")
		if (info[1] > 4) then -- Enemie type > 4 == Boss (5 -> Boss 1 and 6 -> Boss 2)
			spawn_boss(info[1]-4)
			enemies.spawn[2] -= 1
		else
			timer(info[2], false, function()
				local y = ternaire(info[3] == 'r', random(120,8), info[3])
				local shield_left = ternaire(info[4] == 'r', not rotation, info[4] == 't')
				local shield_down = ternaire(info[5] == 'r', rotation, info[5] == 't')
				spawn_enemy(info[1], 134, y, {shield_left=shield_left, shield_down=shield_down,shield_random=false,respawn=false})
				enemies.spawn[2] -= 1
			end)
		end
	end
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
		local boss1 = {sprite=boss.sprite+1, x=boss.x+8, y=boss.y}
		local boss2 = {sprite=boss.sprite+16, x=boss.x, y=boss.y+8}
		local boss3 = {sprite=boss.sprite+17, x=boss.x+8, y=boss.y+8}
		if (collision_pixel(bullet, boss) or collision_pixel(bullet, boss1) or collision_pixel(bullet, boss2) or collision_pixel(bullet, boss3)) then
			-- Check no shield
			if ((not rotation and not boss.shield_left) or (rotation and not boss.shield_down)) then
				boss.life -= player_bullet_damage(bullet)
				if (boss.phase == 1 and boss.life <= cst_boss[boss.type].life / 2) boss.update = _ENV['change_phase_boss'..boss.type]
				if (boss.life <= 0) then
					player.score += 42
					explosion(boss.x + 8, boss.y + 8, {radius=4,duration=rnd(30)+60,number=18})
					add(collectibles, {sprite=cst_collectible_sprt_life, x=boss.x+8, y=boss.y+8})
					shake()
					sfx(9)
					kill_boss()
				else
					explosion(bullet.x+4, bullet.y+4)
					shake(.6)
					sfx(2)
				end
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
		if (collectible.sprite == cst_collectible_sprt_speed) player.speed += .2
		if (collectible.sprite == cst_collectible_sprt_score) player.score += 8
		del(collectibles, collectible)
		sfx(7)
	end
end

function collision_player_boss()
	local info = rotate_collision_player_info()
	local boss_coord = ternaire(boss.rotate, {{x=boss.x,y=boss.y+5},{x=boss.x+15,y=boss.y+15}}, {{x=boss.x+5,y=boss.y},{x=boss.x+15,y=boss.y+15}})
	if (not player.invincible and collision_rectangle(boss_coord, {{x=player.x+info[1].x,y=player.y+info[1].y},{x=player.x+info[2].x,y=player.y+info[2].y}})) then
		player.life = 0
	end
end

function collision_rectangle(obj1, obj2)
	return obj1[1].x <= obj2[2].x and obj2[1].x <= obj1[2].x and obj1[1].y <= obj2[2].y and obj2[1].y <= obj1[2].y
end

function collision_pixel(obj1, obj2)
    -- check if objects collide
    if (obj1.x > obj2.x+7 or obj2.x > obj1.x+7 or obj1.y > obj2.y+7 or obj2.y > obj1.y+7) return false
    -- sprite 1 pos in spritesheet
    local line = flr(obj1.sprite / 16)
    local obj1SprtX = (obj1.sprite - (line * 16)) * 8
    local obj1SprtY = line * 8
    -- sprite 2 pos in spritesheet
    line = flr(obj2.sprite / 16)
    local obj2SprtX = (obj2.sprite - (line * 16)) * 8
    local obj2SprtY = line * 8
    -- check if the pixel who collide is not empty
    for i=0,7 do
        for j=0,7 do
            local x = obj1.x+i - obj2.x
            local y = obj1.y+j - obj2.y
            if (x >= 0 and x < 8 and y >= 0 and y < 8 and sget(obj1SprtX+i, obj1SprtY+j) != 0 and sget(obj2SprtX+x, obj2SprtY+y) != 0) return true
        end
    end
    return false
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
	-- Boss life (1 heart = 10 LP)
	x = 118
	if (boss != nil) then
		local max_boss_life = cst_boss[boss.type].life
		for i=1,flr(max_boss_life/10) do
			spr(ternaire((i*10-9) > boss.life, 25, 105), x, 106)
			x -= 9
		end
	end
	-- Wave in scripted mode
	if (gamemode == 1) print("wAVE: "..num_wave,96,2,7)
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
			if (boss != nil) then 
				boss.life -= 10
				explosion(boss.x + 8, boss.y + 8, {radius=4,duration=rnd(30)+60,number=18})
				shake()
			end
			-- Remove bullets
			enemies.bullets = {}
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

function change_music(num)
	if (music_num != num) music(num, 120)
	music_num = num
end

-->8
--sfx reference
-- sfx from https://www.lexaloffle.com/bbs/?tid=34367
-- music from https://www.lexaloffle.com/bbs/?pid=38442 and https://www.lexaloffle.com/bbs/?tid=2619

-- 0 = menu cursor mouvement
-- 1 = menu selection
-- 2 = enemy explosion
-- 3 = bomb explosion
-- 4 = enemy fire
-- 5 = player fire
-- 6 = player death
-- 7 = collectible collected
-- 8 = player bullet blocked
-- 9 = boss death
-- 10 -> 14 = Music menu (0)
-- 15 -> 23 = Music scripted (06)
-- 24 -> 28 = Music infinite (12)
-- 29 -> 36 = Music death (17)
-- 37 -> 43 = Music boss (21)

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
00000000088778000008800087777800056666500000000005666650056650000005665000088000000000000000000000000000000000000000000000000000
0088800087777800008778008777780056d44d650055550056dffd6556dd65000056dd6500877800000880000000000000000000000000000000000000000000
08777800877778000087780008778000564ff4650566665056d44d6556f4650000564f6508777780008778000000000000000000000000000000000000000000
08777800088778000087780008778000564ff46556d44d650566665056f4650000564f6508777780008778000000000000000000000000000000000000000000
0088800000088000000880000088000056d44d6556dffd650055550056dd65000056dd6500877800000880000000000000000000000000000000000000000000
00000000000000000000000000000000056666500566665000000000056650000005665000088000000000000000000000000000000000000000000000000000
00000000000000000000000000000000005555000055550000000000005500000000550000000000000000000000000000000000000000000000000000000000
00088000000088808800000088800000005555000000000000555500005500000000550000000000000000000000000000000000000000000000000000000000
00878000000877808780000087780000056666500000000005666650056650000005665007700770000000000000000000000000000000000000000000000000
0878000000877780087800008777800056deed650055550056dffd6556dd65000056dd6575577567000000000000000000000000000000000000000000000000
8780000008777800008780000877780056effe650566665056deed6556fe65000056ef6575555567000000000000000000000000000000000000000000000000
8800000087778000000880000087778056effe6556deed650566665056fe65000056ef6575555557000000000000000000000000000000000000000000000000
0000000087780000000000000008778056deed6556dffd650055550056dd65000056dd6507555570000000000000000000000000000000000000000000000000
00000000088000000000000000008800056666500566665000000000056650000005665000755700000000000000000000000000000000000000000000000000
00000000000000000000000000000000005555000055550000000000005500000000550000077000000000000000000000000000000000000000000000000000
0000000000000c500050050000000000005555000000000000555500005500000000550000000000000000000000000000000000000000000000000000000000
0000000000000c5055d00d5500666600056666500000000005666650056650000005665000000000000000000000000000000000000000000000000000000000
5aaa00000000c6d5cc6666cc0696696056d33d650055550056dffd6556dd65000056dd6500000000000000000000000000000000000000000000000000000000
500aaa000000c60000cccc00066aa660563ff3650566665056d33d6556f3650000563f6500000000000000000000000000000000000000000000000000000000
50000aaa0000c60000000000066aa660563ff36556d33d650566665056f3650000563f6500000000000000000000000000000000000000000000000000000000
555555550000c6d5000000000696696056d33d6556dffd650055550056dd65000056dd6500000000000000000000000000000000000000000000000000000000
0000000000000c500000000000666600056666500566665000000000056650000005665000000000000000000000000000000000000000000000000000000000
0000000000000c500000000000000000005555000055550000000000005500000000550000000000000000000000000000000000000000000000000000000000
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
11111111111111111111111111111111111111111111111111111111111115511111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111156651111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111166661111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111116ff61111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111167f61111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111116ff61111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111511556ff65511511111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111516565ff56561511111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111115665655556566511111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111156665655556566651111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111166665655556566661111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111116666565dd56566661111111111111111166111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111166656652256656661111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111116656665dd566656611111111111111111111111111111111111111111111111111111111a1
11111111111111111111111111111111111111111111111111111111556511115655111111111111111111111111111111111111111111111111111111111117
111111111111111111111111111111111111111111111111111111115521111112551111111111111111111111111111111111111111111111111111111111a1
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
15111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111166111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111661111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111661111111111111111111111111111111111111111111111111
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
000400003f643232333a64121231346411e2312f641172312a63112221246310d2211e63109221186310522111621032110c62101211086250121504625002150261500615006000060500600006000060000600
001400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
001400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
001400002c7252c0152c7152a0252a7152a0152a7152f0152c7252c0152c7152801525725250152a7252a0152072520715207151e7251e7151e7151e715217152072520715207151e7251e7151e7151e7151e715
001400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0014000020725200152071520015217252101521715210152c7252c0152c7152c0152a7252a0152a7152a015257252501525715250152672526015267153401532725310152d715280152672525015217151c015
001400181862500000000001862518625186251862500000186051862018625000001862500000000001862500000000001862518605186251862518605186250000000000000000000000000000000000000000
000f00200c0730000018605000000c0730000000000000000c0730000000000000000c0730000000000000000c0730000000000000000c0730000000000000000c0730000000000000000c073000000000000000
003c0020025500255004550055500455004550055500755005550055500755007550045500455000550005500255002550045500555004550045500555007550055500555007550095500a550095500755009550
003c00201a54526305155451a5451c545000001a5451c5451d5451c5451a545185451a5450000000000000001a5452100521545180051c5450000018545000001a545000001c545000001a545000000000000000
001e00200557005575025650000002565050050557005575025650000002565000000457004570045750000005570055750256500000025650000005570055750256500000025650000007570075700757500000
003c00200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003c00201d1151a1151a1151d1151a1151a1151c1201c1251d1151a1151a1151d1151a1151a1151f1201f1251d1151a1151a1151d1151a1151a1151c1201c1251d1151a1151a1151d1151a1151a1151f1201f125
003c00202150624506285060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001e0020091351500009135000050920515000091350000009145000000920500000071400714007145000000913500000091350000009205000000913500000091450000009205000000c2000c2050020000000
001e00200c505155351853517535135051553518535175350050015535185351a5350050515535185351a53500505155351c5351a53500505155351c5351a53500505155351a5351853500505155351a53518535
000f0020001630020000143002000f655002000020000163001630010000163002000f655001000010000163001630010000163002000f655002000010000163001630f65500163002000f655002000f60300163
003c002000000090750b0750c075090750c0750b0750b0050b0050c0750e075100750e0750c0750b0750000000000090750b0750c0750e0750c0751007510005000000e0751007511075100750c0751007510005
003c00200921409214092140921409214092140421404214022140221402214022140221402214042140421409214092140921409214092140921404214042140221402214022140221402214022140421404214
003c00200521405214052140521404214042140721407214092140921409214092140b2140b214072140721405214052140521405214042140421407214072140921409214092140921409214092140921409214
005000200706007060050600506003060030600506005060030600306005060050600206002060030600306007060070600506005060030600306005060050600306003060050600506007060070600706007060
00280020131251a1251f1251a12511125181251d125181250f125161251b125161250e125151251a125151250f125161251b1251612511125181251d125181250e125151251a125151251f1251a125131250e125
00280020227302273521730227301f7301f7301f7301f7352473024735227302273521730217351d7301d7351f7301f7352173022730217302173522730247302673026730267302673500000000000000000000
002800202773027735267302473524730247302473024735267302673524730267352273022730227302273524730247352273021735217302173021730217351f7301f7301f7301f7301f7301f7301f7301f735
005000200f0600f0600e0600e060070600706005060050600c0600c060060600606007060090600a0600e0650f0600f0600e0600e060070600706005060050600c0600a060090600206007060070600706007065
002800200f125161251b125161250e125151251a12515125131251a1251f1251a12511125181251d125181250f125161251b125161250e125151251a12515125131251a1251f1251a125131251a1251f1251a125
002800201a5201a525185201a525135101351013510135151b5201b5251a5201a525185201852515520155251652016525185201a52518520185251a5201b520155201552015520155251f5001f5001f5001f505
002800201f5201f5251d5201b525155101551015510155151d5201d5251b5201d5251a5101a5101a5101a5151b5201b5251a5201a52518520185201552015525165201652016520165251a5001a5001a5001a505
000c00000c5370f0370c5270f0270f537120370f527120271e537230371e527230272f537260372f52726027165371903716527190271c537190371c527210271c536210362452612026120360b0260551601016
000c0020102451c0071c007102351c0071c007102251c007000001022510005000001021500000000001021013245000001320013235000001320013225000001320013225000001320013215000001320013215
000c00200c133000000061500615176550000000615006150c133000000061500615176550000000615006150c133000000061500615176550000000615006150c13300000006150061517655000000061500615
0018002002070020700207002070040700407004070040700c0700c0700c0700c0700a0700a0700a0700a0700e0700e0700e0700e0700d0700d0700d0700d070100701007010070100700e0700e0700e0700e075
001800200000015540155401554015545115401154011540115451354013540135401354510540105401054010545115401154011540115451054010540105401054513540135401354013545095400954009545
0018002009070090700907009070070700707007070070700907009070090700907002070020700207002070030700307003070030700a0700a0700a0700a0700707007070070700707007070070700707007075
00180020000001054010540105401054511540115401154011545105401054010540105450e5400e5400e5400e545075400754007540075450e5400e5400e5400e54505540055400554005540055400554005545
__music__
00 0b424344
01 0b0a4344
00 0b0a4344
00 0b0c4344
00 0d0c4344
02 0d0e4344
01 110f4344
00 110f4312
00 110f4312
00 140f1310
00 150f1310
02 160f1744
01 1a424319
00 1a184319
00 1a181b19
00 1c424319
02 1b1a4319
01 1d1e1f44
00 21222044
00 1d1e1f23
02 21222024
00 25422744
01 28652744
00 28422744
00 28292744
00 28292744
00 2a422744
00 2a422744
00 2a2b2744
00 2a2b2744
00 2a262744
02 2a262744

