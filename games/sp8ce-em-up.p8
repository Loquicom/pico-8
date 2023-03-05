pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--gameloop

function _init()
	init_constant()
	init_timer()
	init_rotate()
	init_ground()
	make_player()
end

function _update()
	update_timer()
	update_ground()
	update_player()
end

function _draw()
	cls(1) --clear screen
	draw_background()
	draw_timer()
	draw_player()
	draw_foreground()
end

-->8
-- constant

function init_constant()
	cst = {
		player = {
			speed = 2,
			sprt = {
				base = {1,2,3},
				rota = {7,8,9}
			},
			thruster = {
				sprt = {
					base = {16,17,18,19,32,33,34,35},
					rota = {20,21,22,23,36,37,38,39}
				}
			}
		}
	}
end

-->8
--player

function make_player()
	player = {}
	player.show = true
	player.sprite = 1
	player.x = 18
	player.y = 64
	player.speed = 2
	player.thruster = animate({16,17,18,19,32,33,34,35}, 8, player.x-6, player.y)
	player.bullets = {}
	player.power = 0
	player.timers = {bullet=timer(15, false)}
end

function update_player()
	move_player()
	action_player()
	update_bullets()
end

function move_player()
	-- Can't move if sprite is not show
	if (not player.show) return
	-- Detect pressed button set speed end sprite
	local x = 0
	local y = 0
	local info = rotate_player_info()
	local thrusterOffset = info.offset
	player.sprite = info.sprite
	if (btn(0)) then
		x -= player.speed -- Left
		info = rotate_player_info(0)
		player.sprite = info.sprite
		thrusterOffset = info.offset
	end
	if (btn(1)) then 
		x += player.speed -- Right
		info = rotate_player_info(1)
		player.sprite = info.sprite
		thrusterOffset = info.offset
	end
	if (btn(2)) then -- Up
		y -= player.speed
		info = rotate_player_info(2)
		player.sprite = info.sprite
		thrusterOffset = info.offset
	end
	if (btn(3)) then -- Down
		y += player.speed
		info = rotate_player_info(3)
		player.sprite = info.sprite
		thrusterOffset = info.offset
	end
	-- Adapt diagonal speed
	if (x != 0 and y != 0) then
		x /= 2
		y /= 2
	end
	-- Set position
	player.x += x
	player.y += y
	-- Manage out of the map
	if (player.x < 0) player.x = 0
	if (player.x > 120) player.x = 120
	if (player.y > 127) player.y = -7
	if (player.y < -7) player.y = 127
	-- Set thruster position
	if (rotation) then
		thrusterOffset.y = 6
	else
		thrusterOffset.x = -6
	end
	player.thruster.x = player.x + thrusterOffset.x
	player.thruster.y = player.y + thrusterOffset.y
end

function action_player()
	-- Do nothing if player is hide
	if (not player.show) return
	-- Bullets
	local info = rotate_bullet_info()
	if (btn(4) and timer_is_end(player.timers.bullet)) then
		local bullet = {x=player.x,y=player.y,speed=info.speed.base,sprite=info.sprites[2]}
		if (player.power == 0) bullet.sprite = info.sprites[1]
		-- Offset to align
		if (rotation) then
			bullet.x += 2
		else
			bullet.y += 2
		end
		add(player.bullets, bullet)
		if (player.power >= 2) then
			-- Diagonal bullets
			local sprite = info.sprites[3]
			if (player.power > 2) sprite = info.sprites[4]
			add(player.bullets, {x=player.x,y=player.y,speed=info.speed.diag1,sprite=sprite})
			add(player.bullets, {x=player.x,y=player.y,speed=info.speed.diag2,sprite=sprite})
		end
		
		timer_restart(player.timers.bullet)
	end
	-- Rotate
	if (btnp(5)) rotate()
end

function update_bullets()
	for bullet in all(player.bullets) do
		bullet.x += bullet.speed.x
		bullet.y += bullet.speed.y
		if (bullet.x < -8 or bullet.x > 128 or bullet.y < -8 or bullet.y > 128) del(player.bullets, bullet)
	end
end

function draw_player()
	-- Bullets
	for bullet in all(player.bullets) do
		spr(bullet.sprite, bullet.x, bullet.y, 1, 1, false, (bullet.diag and bullet.speed > 0))
	end
	-- Player
	if (player.show) spr(player.sprite, player.x, player.y)
end

-->8
--background & foreground

function init_ground()
	planet = {visible=false,speed=0.6}
	stars = {}
	ligths = {}
	for i=0,flr(rnd(10)+18) do
		add(ligths, {x=-2,speed=1.2})
	end
	for i=0,flr(rnd(4)+4) do
		add(stars, {x=-9,speed=0.2})
	end
end

function update_ground()
	-- Planet
	if (not planet.visible) then
		-- Show the planet, set the properties
		local type = flr(rnd(4)+0.1)
		if (type == 0) planet.sprite = 12
		if (type == 1) planet.sprite = 14
		if (type == 2) planet.sprite = 42
		if (type == 3) planet.sprite = 44
		if (type == 4) planet.sprite = 46
		planet.visible = true
		planet.x = 200
		planet.y = flr(rnd(111))
	end
	if (planet.visible) then
		if (planet.x < -100) planet.visible = false
		planet.x -= planet.speed
	end
	-- Stars
	for star in all(stars) do 
		if (star.x < -8) then
			local type = flr(rnd(3)+0.1)
			if (type == 0) star.sprite = 10
			if (type == 1) star.sprite = 11
			if (type == 2) star.sprite = 26
			if (type == 3) star.sprite = 27
			star.x = flr(rnd(250))+130
			star.y = flr(rnd(127))
		end
		star.x -= star.speed
	end
	-- Lights
	for light in all(ligths) do
		if (light.x < -1) then
			light.x = flr(rnd(100))+130
			light.y = flr(rnd(127))
			light.color = flr(rnd(2)+5)
		end
		light.x -= light.speed
		if (light.color == 6) light.x -= 0.2
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
-- rotate

function init_rotate()
	rotation = false
end

function rotate()
	-- De/Active rotate mode
	rotation = not rotation
	-- Player animation
	player.show = false
	player.thruster.show = false
	local sprites = {4,5,6}
	if (not rotation) sprites = {6,5,4}
	animate(sprites, 2, player.x, player.y, false, _rotate_player_animation)
	-- Change animation sprites
	player.thruster.sprites = cst.player.thruster.sprt.base
	if (rotation) player.thruster.sprites = cst.player.thruster.sprt.rota
end

function rotate_player_info(btn)
	if (btn == nil) then
		if (rotation) return {sprite=cst.player.sprt.rota[1],offset={x=0,y=6}}
		return {sprite=cst.player.sprt.base[1],offset={x=-6,y=0}}
	end
	if (btn == 0) then
		if (rotation) return {sprite=cst.player.sprt.rota[2],offset={x=-1,y=6}}
		return {sprite=cst.player.sprt.base[1],offset={x=-6,y=0}}
	end
	if (btn == 1) then
		if (rotation) return {sprite=cst.player.sprt.rota[3],offset={x=1,y=6}}
		return {sprite=cst.player.sprt.base[1],offset={x=-6,y=0}}
	end
	if (btn == 2) then
		if (rotation) return {sprite=cst.player.sprt.rota[1],offset={x=0,y=6}}
		return {sprite=cst.player.sprt.base[2],offset={x=-6,y=-1}}
	end
	if (btn == 3) then
		if (rotation) return {sprite=cst.player.sprt.rota[1],offset={x=0,y=6}}
		return {sprite=cst.player.sprt.base[3],offset={x=-6,y=1}}
	end
end

function rotate_bullet_info()
	if (rotation) return {sprites={52,53,54,55}, speed={base={x=0,y=-3},diag1={x=1.5,y=-1.5},diag2={x=-1.5,y=-1.5}}}
	return {sprites={48,49,50,51}, speed={base={x=3,y=0},diag1={x=1.5,y=1.5},diag2={x=1.5,y=-1.5}}}
end

function _rotate_player_animation()
	player.show = true
	player.thruster.show = true
end

-->8
-- time utils

function init_timer()
	timers = {}
	animations = {}
end

function update_timer()
	-- Execute timer
	for timer in all(timers) do
		timer.time += 1
		if (timer.time >= timer.duration) then
			if (timer.callback != nil) timer.callback(timer.param)
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
end

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

__gfx__
00000000000660000006600000000000006600000000000000005500000550000055000000005500000000000000000000000077770000000000009999000000
00670000006d6000665555d00000000000d60d000660d550000d550000d55d000d5d00000000d5d00000000000a0a0000000cccccccc00000000999799990000
06700000665555d000655f550006600006555f550d65f5506655ffd0005ff50005f5000000005f500000000000070000000cccccccccc00000099999a9999000
0777777600655f55006555d5665d600066555f5506555fd06d55550066555566655566000066555600c0c00000a0a00000cccccccbcccc000099999999999900
6777600000655f55665d6000006555d5006555d006655500065555666d5555d66555d600006d555600070000000000000cccccccccccccc009997aa999aa9990
67777000665555d00006600000655f550065550060065660066655d606566560056650000005665000c0c000000000000ccbbccccbbbccc0099999999aa79990
06776000006d600000000000665555d00666d60000066d60060066000060060006006000000600600000000000000000cccbbcccbbbbcccc9999999999977999
000000000006600000000000000660000000660000600000000060000060060006006000000600600000000000000000cccbccbcbbcccbcc99aa79997a999999
00000000000000000000000000000000000aa000000aa000000a9000000aa00000000000000000000000000000000000cbcbbcccccccbccc999a99799a999999
00000000000000000000000000000000000a9000000a9000000990000009a00000000000000000000000000000000000cccbbcccbbcccccc99999a99999aa999
0000000000000000000000000000000000099000000990000009800000099000000000000000000000000000000a00000cccbcccbbcbbbc00999999999997990
000889aa000899aa0008999a0008899a0008800000098000000980000008800000000000000000000000c00000a7a0000ccccccccbcbbcc00999a997a99a7990
0000899a0000899a00008899000089aa000800000008000000080000000800000000000000000000000c7c00000a000000cccccccccccc000099979799799900
000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000000000cccccccccc000000999999aa99000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc00000000999999990000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077770000000000009999000000
00000000000000000000000000000000000aa000000aa0000009a000000aa0000000000000000000000000777700000000000088880008000000002222000000
00000000000000000000000000000000000aa0000009a000000990000009a000000000000000000000007777777700000000888888800008000022222d22ee00
00000000000000000000000000000000000a900000099000000890000009900000000000000000000007777776777000000888888800880000022222dd222ee0
00089aaa0000899a000088990008999a0009800000088000000880000009800000000000000000000077777677767700008888888000000000222dd2d2222ee0
000089aa000889aa0008899a000089aa0008000000008000000080000008000000000000000000000777777777777770088888888000808002222d222222eee0
0000000000000000000000000000000000000000000000000000000000000000000000000000000007767777767777700888888880800880022222222222ee20
0000000000000000000000000000000000000000000000000000000000000000000000000000000077777767777677778888888880008888222d2222d22eee22
000000000000000000000000000000000000000000000000000000000000000000000000000000007777777767777677888888888808888822dd222dd2eee222
0bbb0000000bb000000bb0000000bbb0000000000000000000000000000000000000000000000000777767777777777788888888888888882dd222d22eee2dd2
b777b0000bb77b0000b7b000000b77b0000000000000000000000000bbb000000000000000000000777777777767777788888888888888882dd22222eee2dd22
b777b000b7777b000b7b000000b777b0000000000bbb000000000000b77b00000000000000000000076777777777677008888888888888800222222eee2dd220
0bbb00000bb77b00b7b000000b777b000bb00000b777b000bb000000b777b000000000000000000007777677677777700888888888888880022222eee2222220
00000000000bb000bb000000b777b000b77b0000b777b000b7b000000b777b000000000000000000007777777777770000888888888888000e22eeee22222200
000000000000000000000000b77b0000b77b00000b7b00000b7b000000b777b00000000000000000000777767767700000088888888880000eeeeeedd2222000
0000000000000000000000000bb00000b77b00000b7b000000b7b000000b77b000000000000000000000777777770000000088888888000000eee2dd22220000
000000000000000000000000000000000bb0000000b00000000bb0000000bb000000000000000000000000777700000000000088880000000000002222000000
