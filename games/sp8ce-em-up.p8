pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--gameloop

function _init()
	make_player()
end

function _update()
	move_player()
end

function _draw()
	cls() --clear screen
	draw_player()
end

function make_player()
	px=64
	py=64
	psprite=1
end

function move_player()
	psprite=1
	if (btn(0)) then
	 px-=1 --left
	end
	if (btn(1)) then
	 px+=1 --right
	end
 if (btn(2)) then
	 py-=1 --up
		psprite=2
	end
	if (btn(3)) then 
		py+=1 --down
		psprite=3
	end
end

function draw_player()
	spr(psprite,px,py)
end
__gfx__
00000000000660000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006d6000666d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700665555d0006555d500066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000065515500655155665555d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000655155665555d000655155000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700665555d000066000006555d5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006d600000000000666d6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000660000000000000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
