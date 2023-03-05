pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--Sp8ce'em Up
--By Loquicom
--gameloop

function _init()
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
	-- Update timer ground animation
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
	draw_credit()
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
end

function update_game()
	-- Update timer ground animation
	update_timer()
	update_ground()
	-- Game specific
	update_bomb()
	update_enemy()
	update_player()
end

function draw_game()
	-- Draw timer and ground animation
	cls(1)
	draw_background()
	draw_timer()
	-- Game specific
	draw_enemy()
	draw_player()
	draw_foreground()
	draw_bomb()
	draw_ui()
end

--- === End / Game over === ---

function set_end_mode()
	_update = update_end
	_draw = draw_end
end

function update_end()
	-- Update timer ground animation
	update_timer()
	update_ground()
	-- End specific
	if (btnp(5)) then
		init_game()
		_update = update_game
		_draw = draw_game
	end
end

function draw_end()
	-- Draw timer and ground animation
	cls(1)
	draw_background()
	draw_foreground()
	-- End specific
	print("game over",44,44,7)
 	print("your score:"..player.score,34,54,7)
  	print("press ❎ to play again!",18,72,6)
end

-->8
--constant

function init_constant()
	cst = {
		version = "0.16.0",
		player = {
			speed = 2,
			life = 3,
			energy = 5,
			sprt = {
				base = {1,2,3},
				rota = {7,8,9}
			},
			thruster = {
				sprt = {
					base = {16,17,18,19,32,33,34,35},
					rota = {20,21,22,23,36,37,38,39}
				},
				duration = 8
			},
			bullet = {
				timer = 15,
				speed = 3,
				sprt = {
					base = {48,49,50,51},
					rota = {52,53,54,55}
				}
			},
			rotate = {
				sprt = {
					fw = {4,5,6},
					bw = {6,5,4}
				},
				duration = 2 
			}
		},
		ground = {
			planet = {
				speed = 0.6,
				sprt = {12,14,42,44,46}
			},
			star = {
				min = 4,
				max = 8,
				speed = 0.2,
				sprt = {10,11,26,27}
			},
			light = {
				min = 18,
				max = 28,
				speed = 1.2
			}
		},
		enemy = {
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
	}
end

-->8
--title & end

function init_menu()
	menu = {
		cursor = 1,
		label = {
			"iFINITE MODE",
			"nOT AVAILABLE"
		},
		helper = {
			"tRY TO BEAT YOUR SCORE",
			"mAYBE AVAILABLE ONE DAY"
		},
		action = {
			start_infinite_game,
			nothing
		}
	}
end

function update_menu()
 	if (btnp(2) and menu.cursor > 1)menu.cursor -= 1
	if (btnp(3) and menu.cursor < #menu.label) menu.cursor += 1
	if (btnp(4) or btnp(5)) menu.action[menu.cursor]()
end

function draw_menu()
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
	local y = 64
	for i=1,#menu.label do
		local color = 13
		if (i == menu.cursor) color = 7
		print(menu.label[i], 38, y, color)
		y += 10
	end
	-- Selector
	spr(0, 28, 64 + 10 * (menu.cursor - 1))
	-- Helper
	print(menu.helper[menu.cursor], 20, 98, 6)
	print("pRESS ❎ TO SELECT", 28, 108, 6)
end

function draw_credit()
	print("bY lOQUICOM", 2, 120, 7)
	print("v:"..cst.version, 96, 120, 7)
end

--- === Functions === ---

function start_infinite_game()
	set_game_mode()
end

function nothing()
	explosion(64,64,{radius=3,duration=rnd(120)+120,number=28})
end

-->8
--player

function init_player()
	player = {
		show = true,
		x = 18,
		y = 64,
		score = 0,
		life = cst.player.life,
		energy = 5,
		bomb = false,
		invincible = false,
		sprite = cst.player.sprt.base[1],
		speed = cst.player.speed,
		power = 0, -- 0 = simple, 1 = big, 2 = big + simple diag, 3 = big + big diag, 4+ = more speed and less cd ?
		thruster = {
			animation = animate(cst.player.thruster.sprt.base, cst.player.thruster.duration, 12, 64),
			particles = {}
		},
		timers = {
			bullet = timer(cst.player.bullet.timer, false),
			thruster = timer(cst.player.thruster.duration, true, _thruster_timer)
		},
		bullets = {}
	}
end

function update_player()
	end_game()
	move_player()
	action_player()
	update_bullets()
end

function draw_player()
	-- Bullets
	for bullet in all(player.bullets) do
		spr(bullet.sprite, bullet.x, bullet.y, 1, 1, false, bullet.inv)
	end
	-- Thruster particle
	for particle in all(player.thruster.particles) do
		pset(particle.x, particle.y, 8)
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
	-- Remove player
	player.show = false
	player.thruster.animation.show = false
	player.thruster.particles = {}
	timer_stop(player.timers.thruster)
	player.life = -1
	player.x = 400
	player.y = 400
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
	player.thruster.animation.x = player.x + info.offset.x
	player.thruster.animation.y = player.y + info.offset.y
end

function action_player()
	-- Do nothing if player is hide
	if (not player.show) return
	-- Bomb
	if (player.energy == cst.player.energy and btn(4) and btn(5)) return blast() -- Return only for stop
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
	end
	-- Rotate
	if (btnp(4)) rotate()
end

function update_bullets()
	for bullet in all(player.bullets) do
		bullet.x += bullet.speed.x
		bullet.y += bullet.speed.y
		collison_player_fire(bullet)
		if (bullet.x < -8 or bullet.x > 128 or bullet.y < -8 or bullet.y > 128) del(player.bullets, bullet)
	end
end

function player_bullet_damage(bullet)
	if (contain({cst.player.bullet.sprt.base[2], cst.player.bullet.sprt.base[4], cst.player.bullet.sprt.rota[2], cst.player.bullet.sprt.rota[4]}, bullet.sprite)) return 2
	return 1
end

--- === Timers === ---

function _thruster_timer()
	local info = rotate_thruster_info()
	for particle in all(player.thruster.particles) do
		particle.x += info.x
		particle.y += info.y
		particle.time += 1
		if (particle.time >= particle.duration) del(player.thruster.particles, particle)
	end
	if (random(8) == 8) add(player.thruster.particles, {x=player.x+info.offset.x, y=player.y+info.offset.y, duration=random(8,4), time=0})
end

function _delayed_explosion(params)
	explosion(params.x, params.y)
end

function _end_game()
	_update = update_end
	_draw = draw_end
end

-->8
--ennemy

function init_enemy()
	enemies = {entities={}, bullets={}, spawn = {0,0,0}, kill = {0,0,0}}
end

function update_enemy()
	for enemy in all (enemies.entities) do
		-- Die
		if (enemy.life < 1) then 
			del(enemies.entities, enemy)
			if (enemy.fire != nil) timer_stop(enemy.fire)
			shake(0.6)
			player.score += enemy.type
			enemies.kill[enemy.type] += 1
			explosion(enemy.x+4, enemy.y+4)
			timer(random(150,30), false, _respawn_enemy, enemy.type)
		end
		-- Move
		if (enemy.type == 1) move_enemy_type1(enemy)
		if (enemy.type == 2) move_enemy_type2(enemy)
		if (enemy.type == 3) move_enemy_type3(enemy)
		if (enemy.x < -8 or enemy.y > 130) then
			-- Outside the map
			del(enemies.entities, enemy)
			if (enemy.fire != nil) timer_stop(enemy.fire)
			player.score -= enemy.type*2
			if (player.score < 0) player.score = 0
			timer(random(150,30), false, _respawn_enemy, enemy.type)
		end
		collision_spaceship(enemy)
	end
	-- Bullets
	for bullet in all(enemies.bullets) do
		bullet.x += bullet.speedX
		bullet.y += bullet.speedY
		collison_enemy_fire(bullet)
	end
	-- Manage spawn
	manage_enemy()
end

function draw_enemy()
	for bullet in all(enemies.bullets) do
		spr(bullet.sprite, bullet.x, bullet.y)
	end
	for enemy in all (enemies.entities) do
		if (enemy.show) spr(enemy.sprite, enemy.x, enemy.y)
	end
end

--- === Functions === ---

function spawn_enemy(type, x, y)
	local enemy = {
		type = type,
		x = x,
		y = y,
		speed = cst.enemy[type].speed,
		life = cst.enemy[type].life,
		sprite = cst.enemy[type].sprt,
		show = true
	}
	if (type == 2) enemy.fire = timer(30, true, _fire_enemy2, enemy)
	if (type == 3) enemy.fire = timer(90, true, _fire_enemy3, enemy)
	add(enemies.entities, enemy)
end

function manage_enemy()
	-- Spawn first ennemy
	if (enemies.spawn[1] == 0) then
		local spawn = rotate_enemy_spawn(134, random(120))
		spawn_enemy(1, spawn.x, spawn.y)
		enemies.spawn[1] += 1
	-- When type3 is killed 5 time decread fire cd
	elseif (enemies.kill[3] != 0 and enemies.kill[3] % 2 == 0) then
		for enemy in all(enemies) do
			if (enemy.type == 3) enemy.fire.duration -= 2
		end
	-- When (5 type2 * number of type2 + number of type2) kill, add new type2
	elseif (enemies.kill[2] != 0 and enemies.kill[2] % ((5*enemies.spawn[2])+enemies.spawn[2]) == 0) then
		local spawn = rotate_enemy_spawn(134, random(120))
		local type = 2
		-- Check what type of enemy spawn
		if (enemies.spawn[3] == 0 and enemies.spawn[2] == cst.enemy[3].spawn) then
			type = 3
		end
		-- Spawn
		spawn_enemy(type, spawn.x, spawn.y)
		enemies.spawn[type] += 1
	-- When (5 type1 * number of type1 + number of type1) kill, add new type1
	elseif (enemies.kill[1] != 0 and enemies.kill[1] % ((5*enemies.spawn[1])+enemies.spawn[1]) == 0) then
		local spawn = rotate_enemy_spawn(134, random(120))
		local type = 1
		-- Check what type of enemy spawn
		if (enemies.spawn[2] == 0 and enemies.spawn[1] == cst.enemy[2].spawn) then
			type = 2
		end
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
end

function _fire_enemy3(enemy)
	if (rotation) then
		local y = 1
		if (player.y < enemy.y) y = -1 
		add(enemies.bullets, {x=enemy.x,y=enemy.y,speedX=0,speedY=y,sprite=82})
	else
		local x = 1
		if (player.x < enemy.x) x = -1 
		add(enemies.bullets, {x=enemy.x,y=enemy.y,speedX=x,speedY=0,sprite=80})
	end
end

function _respawn_enemy(type)
	local spawn = rotate_enemy_spawn(134, random(120))
	spawn_enemy(type, spawn.x, spawn.y)
end

-->8
--collectible

-->8
--collison

function collison_player_fire(bullet)
	for enemy in all(enemies.entities) do
		if (collison_rectangle({{x=bullet.x+1, y=bullet.y+1},{x=bullet.x+4,y=bullet.y+4}}, {{x=enemy.x,y=enemy.y},{x=enemy.x+7,y=enemy.y+7}})) then
			enemy.life -= player_bullet_damage(bullet)
			timer(4, true, _blink_enemy, {cpt=0,enemy=enemy})
			del(player.bullets, bullet)
		end
	end
end

function collison_enemy_fire(bullet)
	local info = rotate_collison_player_info()
	if (not player.invincible and collison_rectangle({{x=bullet.x+1, y=bullet.y+1},{x=bullet.x+4,y=bullet.y+4}}, {{x=player.x+info[1].x,y=player.y+info[1].y},{x=player.x+info[2].x,y=player.y+info[2].y}})) then
		player.life -= 1
		player.invincible = true
		timer(4, true, _blink_player, {cpt=0,enemy=enemy})
		del(enemies.bullets, bullet)
	end
end

function collision_spaceship(enemy)
	local info = rotate_collison_player_info()
	if (not player.invincible and collison_rectangle({{x=enemy.x, y=enemy.y},{x=enemy.x+7,y=enemy.y+7}}, {{x=player.x+info[1].x,y=player.y+info[1].y},{x=player.x+info[2].x,y=player.y+info[2].y}})) then
		player.life -= 1
		player.invincible = true
		timer(4, true, _blink_player, {cpt=0,enemy=enemy})
		enemy.life = 0
	end
end

function collison_collectible()

end

function collison_rectangle(obj1, obj2)
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
		player.thruster.animation.show = not player.thruster.animation.show
	else
		player.invincible = false
		timer_stop(timer)
	end
end

-->8
--ui

function draw_ui()
	local sprt = 0
	-- Life
	local x = 1
	for i=1,cst.player.life do
		sprt = 24
		if (i > player.life) sprt = 25
		spr(sprt, x, 114)
		x += 9
	end
	-- Energy
	x = 1
	for i=1,cst.player.energy do
		local flip = false
		if (i == 1 or i == cst.player.energy) then
			flip = i == cst.player.energy
			sprt = 64
			if ((i == 1 and player.energy >= 1) or (flip and player.energy >= cst.player.energy)) sprt = 66
		else
			sprt = 65
			if (i <= player.energy) sprt = 67
		end
		spr(sprt, x, 120, 1, 1, flip)
		x+=8
	end
	-- Score
	print("score:"..player.score, 2, 2, 7)
end

-->8
--background & foreground

function init_ground()
	planet = {visible=false,speed=cst.ground.planet.speed}
	stars = {}
	ligths = {}
	for i=0,random(cst.ground.light.max,cst.ground.light.min) do
		add(ligths, {x=-2,speed=cst.ground.light.speed})
	end
	for i=0,random(cst.ground.star.max,cst.ground.star.min) do
		add(stars, {x=-9,speed=cst.ground.star.speed})
	end
end

function update_ground()
	-- Planet
	if (not planet.visible) then
		-- Show the planet, set the properties
		planet.sprite = cst.ground.planet.sprt[random(4) + 1]
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
			star.sprite = cst.ground.star.sprt[random(3) + 1]
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
end

function _bomb_color()
	if (bomb.color == 7) then
		bomb.color = 15
	else
		bomb.color = 7
	end
end

-->8
--rotate

function init_rotate()
	rotation = false
end

function rotate()
	-- De/Active rotate mode
	rotation = not rotation
	-- Player animation
	player.show = false
	player.thruster.animation.show = false
	local sprites = cst.player.rotate.sprt.fw
	if (not rotation) sprites = cst.player.rotate.sprt.bw
	animate(sprites, cst.player.rotate.duration, player.x, player.y, false, _rotate_player_animation)
	-- Change animation sprites
	player.thruster.animation.sprites = cst.player.thruster.sprt.base
	if (rotation) player.thruster.animation.sprites = cst.player.thruster.sprt.rota
end

function rotate_player_info(btn)
	if (btn == nil) then
		if (rotation) return {sprite=cst.player.sprt.rota[1], offset={x=0,y=6}}
		return {sprite=cst.player.sprt.base[1], offset={x=-6,y=0}}
	end
	if (btn == 0) then
		if (rotation) return {sprite=cst.player.sprt.rota[2], offset={x=-1,y=6}}
		return {sprite=cst.player.sprt.base[1], offset={x=-6,y=0}}
	end
	if (btn == 1) then
		if (rotation) return {sprite=cst.player.sprt.rota[3], offset={x=1,y=6}}
		return {sprite=cst.player.sprt.base[1], offset={x=-6,y=0}}
	end
	if (btn == 2) then
		if (rotation) return {sprite=cst.player.sprt.rota[1], offset={x=0,y=6}}
		return {sprite=cst.player.sprt.base[2], offset={x=-6,y=-1}}
	end
	if (btn == 3) then
		if (rotation) return {sprite=cst.player.sprt.rota[1], offset={x=0,y=6}}
		return {sprite=cst.player.sprt.base[3], offset={x=-6,y=1}}
	end
end

function rotate_player_border()
	if (rotation) return {left={cond=-7,to=127}, right={cond=127,to=-7}, down={cond=120,to=120}, up={cond=0,to=0}}
	return {left={cond=0,to=0}, right={cond=120,to=120}, down={cond=127,to=-7}, up={cond=-7,to=127}}
end

function rotate_bullet_info()
	if (rotation) then 
		return {
			sprites=cst.player.bullet.sprt.rota, 
			speed={
				base={x=0,y=-cst.player.bullet.speed},
				diag1={x=cst.player.bullet.speed/2,y=-cst.player.bullet.speed/2},
				diag2={x=-cst.player.bullet.speed/2,y=-cst.player.bullet.speed/2}
			}, 
			offset={base={x=1,y=2},diag1={x=4,y=0},diag2={x=-1,y=2}}}
	end
	return {
		sprites=cst.player.bullet.sprt.base, 
		speed={
			base={x=cst.player.bullet.speed,y=0},
			diag1={x=cst.player.bullet.speed/2,y=cst.player.bullet.speed/2},
			diag2={x=cst.player.bullet.speed/2,y=-cst.player.bullet.speed/2}
		},
		offset={base={x=2,y=1},diag1={x=0,y=0},diag2={x=0,y=0}}
	}
end

function rotate_thruster_info()
	if (rotation) return {x=0, y=1, offset={x=random(4,3),y=9}}
	return {x=-1, y=0, offset={x=-2,y=random(4,3)}}
end

function rotate_ground_spawn(baseX, baseY)
	if (rotation) return {x=baseY, y=-baseX+128}
	return {x=baseX, y=baseY}
end

function rotate_ground_speed(speed)
	if (rotation) return {x=0, y=speed}
	return {x=-speed, y=0}
end

function rotate_enemy1_info(speed, diffX, diffY)
	local sprite = cst.enemy[1].sprt
	-- Rotation
	if (rotation) then
		if (abs(diffY) < 40) then
			diffX = limit(diffX, speed)
			if (diffX < 0) sprite = cst.enemy[1].sprt + 3
			if (diffX > 0) sprite = cst.enemy[1].sprt + 4
		else
			diffX = 0
		end
		return {x=diffX, y=speed, sprite=sprite}
	end
	-- No rotation
	if (abs(diffX) < 40) then
		diffY = limit(diffY, speed)
		if (diffY < 0) sprite = cst.enemy[1].sprt + 2
		if (diffY > 0) sprite = cst.enemy[1].sprt + 1
	else
		diffY = 0
	end
	return {x=-speed, y=diffY, sprite=sprite}
end

function rotate_enemy2_info(speed)
	if (rotation) return {x=0, y=speed}
	return {x=-speed, y=0}
end

function rotate_enemy3_info(speed, x, y, diffX, diffY)
	local sprite = cst.enemy[3].sprt
	local move = 0
	if (rotation) then
		if (y < 8) move = speed
		diffx = limit(diffX, speed)
		if (diffX < 0) sprite = cst.enemy[3].sprt + 3
		if (diffX > 0) sprite = cst.enemy[3].sprt + 4
		return {x=diffX, y=move, sprite=sprite}
	end
	if (x > 112) move = -speed
	diffY = limit(diffY, speed)
	if (diffY < 0) sprite = cst.enemy[3].sprt + 2
	if (diffY > 0) sprite = cst.enemy[3].sprt + 1
	return {x=move, y=diffY, sprite=sprite}
end

function rotate_enemy_spawn(baseX, baseY)
	if (rotation) return {x=baseY, y=-baseX+128}
	return {x=baseX, y=baseY}
end

function rotate_collison_player_info()
	if (rotation) return {{x=2,y=0}, {x=5,y=7}}
	return {{x=0,y=2}, {x=7,y=5}}
end

function _rotate_player_animation()
	player.show = true
	player.thruster.animation.show = true
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
	if (intensity == nil) intensity = 1
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

function particle(x, y, duration, radius, move, physics, colors)
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
	timer(1, true, _particle, particle)
end

function _particle(particle, timer)
	-- Particle life
	particle.time += 1
	if (particle.time > particle.duration) then
		timer_stop(timer)
		return del(particles, particle) -- Return to stop
	end

	-- Set color depending on life of the particle
	local divider = particle.duration / #particle.colors
	particle.color = particle.colors[flr(particle.time/divider)+1]

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
	if (params == nil) params = {}
	if (params.number == nil) params.number = 8
	if (params.duration == nil) params.duration = rnd(25)+30
	if (params.radius == nil) params.radius = 2
	-- Add particles for explosion effect
	for i=0,params.number do
		particle(
			x,
			y,
			params.duration,
			params.radius,
			{x=rnd(2)-1, y=rnd(2)-1},
			{reduce=true},
			{10,7,6,6,5}
		)
	end
end

-->8
--utils

function random(max, min)
	-- max include, min include
	if (min == nil) min = 0
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
06666660066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65566556655555560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66755766677667760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66777766677667760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65777756677557760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67766776677777760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56666665566666650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555550055555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111511111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111bb11111111111111511111111111111111111111111111111
111111111111111111111111111111111111111111111111111111111111111111111111111111b7b11111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111b7b111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111b7b1111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111bb11111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111151111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111151111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111111bb111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111b7b111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111b7b1111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111b7b11111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111bb111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111116611111111111111111111111111111111111111111111111
11111111115111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111511111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111777711111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111cccccccc111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111cccccccccc11111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111cccccccbcccc1111111111111111111111111111111111111111111111111c11111111111111111
1111111111111111111111111111111111bb111111111111cccccccccccccc11111111111111111111111111111111111111111111111c7c1111111111111111
111111111111111111111111111111111b7b111111111111ccbbccccbbbccc111111111111111111111111111111111111111111111111c11111111111111111
11111111111111111111111111111111b7b111111111111cccbbcccbbbbcccc11111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111b7b1111111111111cccbccbcbbcccbcc11111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111bb11111111111111cbcbbcccccccbccc11111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111cccbbcccbbcccccc11111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111cccbcccbbcbbbc111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111ccccccccbcbbcc111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111cccccccccccc1111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111cccccccccc11111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111cccccccc111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111777711111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111166111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111116d6111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111665555d11111111111111111111111bb1111111111111111111111111111111111111111111bb111111111111111111111111111111111
1111111111111118999a655f5511111111111111111111bb77b1111111111111111111111111111111111111111bb77b11111111111111111111111111111111
111111111111111189aa655f551111111111111111111b7777b111111111111111111111111111111111111111b7777b11111111111111111111111111111111
111111111111111111665555d111111115111111111111bb77b1111111111111111111111111111111111111111bb77b11111111111111111111111111111111
111111111111111111116d61111111111111111111111111bb1111111111111111111111111111111111111111111bb111111111111111111111111111111111
11111111111111111111166111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111166111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111661111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111bb11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111b7b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111b7b111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111b7b11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111bb11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a11111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a7a1111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a11111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111511151111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111166111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111661111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111bb111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111b7b11111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111b7b1111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111b7b111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111111bb111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111166111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111511111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111511111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111bb11111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111b7b1111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111b7b111111111111111111111111111111111111111111111111

