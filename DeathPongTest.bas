   ;This minikernel must be included
   ;include fixed_point_math.asm
   include 6lives.asm
   ;And these kernel options
   set kernel_options pfcolors pfheights
   ;const noscore=1
   scorecolor = $00
   pfheights:
   4
   12
   8
   8
   8
   8
   8
   8
   8
   12
   4
end

   pfcolors:
   $38
   $38
   $2A
   $1E
   $BA
   $8A
   $58
   $38
   $2A
   $1E
   $BA
   $8A
   $58
end

   ; Bits for player, missile direction and movement
   dim _BitOp_01 = y
   dim _BitOp_P0_M0_Dir = g
   dim _BitOp_P1_M1_Dir = h
   dim _Bit0_P0_Dir_Up = g
   dim _Bit1_P0_Dir_Down = g
   dim _Bit2_P0_Dir_Left = g
   dim _Bit3_P0_Dir_Right = g
   dim _Bit4_M0_Dir_Up = g
   dim _Bit5_M0_Dir_Down = g
   dim _Bit6_M0_Dir_Left = g
   dim _Bit7_M0_Dir_Right = g
   dim _Bit0_P1_Dir_Up = h
   dim _Bit1_P1_Dir_Down = h
   dim _Bit2_P1_Dir_Left = h
   dim _Bit3_P1_Dir_Right = h
   dim _Bit4_M1_Dir_Up = h
   dim _Bit5_M1_Dir_Down = h
   dim _Bit6_M1_Dir_Left = h
   dim _Bit7_M1_Dir_Right = h
   dim _Bit5_B_Direction_X = j
   dim _Bit6_B_Direction_Y = j
   dim statusbarcolor = $00
   dim sound_duration = k
   dim _Bit0_Reset_Restrainer = y
   dim _Bit7_M0_Moving = y
   dim _Bit7_M1_Moving = z
   dim _Ball_Velocity = ballx.e
   dim _Ball_Position_y = bally.f
   dim _Ball_Direction = p.q


   ; Extra definitions for the lifebars included in 6lives.asm
   dim lives_centered = 0
   
   ; Boundaries of playfield, player, and missile
   const _P_Edge_Top = 9
   const _P_Edge_Bottom = 88
   const _P_Edge_Left = 1
   const _P_Edge_Right = 153

   const _M_Edge_Top = 2
   const _M_Edge_Bottom = 88
   const _M_Edge_Left = 0
   const _M_Edge_Right = 148

   const _B_Edge_Top = 4
   const _B_Edge_Bottom = 85
   const _B_Edge_Left = 18
   const _B_Edge_Right = 134
   const pfscore = 1
   const lives2 = 3
   ;const scorecolor = $0E
__Start_Restart
   ; Audio channel volumes
   AUDV0 = 1 : AUDV1 = 0

   dim _Bit0_Left_Selection = p
   dim _Bit1_Right_Selection = p
   ; e k p.q
   a = 3 : b = 3 : c = 200 : d = 0 : e = 0 : f = 0 : g = 0 : h = 0 : i = 0
   j = 0 : k = 1 : l = 0 : m = $9E : n = 0 : o = $3e : p = 0 : q = 0 : r = 0
   s = 0 : t = 0 : u = 0 : v = 0 : w = 0 : x = 0 : y = 0 : z = 0



   ;Coordinates of sprites
   player0x = 15: player0y = 60
   player1x = 130: player1y = 60

   ;  Playfield colors
   COLUPF = $80
   COLUBK = $0
   CTRLPF = $21 

   missile0x = 200 : missile0y = 200
   missile1x = 200 : missile1y = 200
   NUSIZ0 = %00000001 : missile0height = 1 : missile1height = 1





; Ball starting direction (only one bit is used)



   ;  This bit fixes it so the reset switch becomes inactive if
   ;  it hasn't been released after being pressed once.
   _Bit0_Reset_Restrainer{0} = 1


; Sprite bitmaps for both players
   player0:
   %00111000
   %00111000
   %00111000
   %00111000
   %00111000
   %00111000
   %00111000
   %00111000
   %00111000
   %00111000
   %00111000
   %00111000
end

   player1:
   %00111000
   %00111000
   %00111000
   %00111000
   %00111000
   %00111000
   %00111000
   %00111000
   %00111000
   %00111000
   %00111000
   %00111000
end

   lives=96

   lives:
   %11111111
   %10000001
   %10111101
   %10100101
   %10100101
   %10111101
   %10000001
   %11111111
end

; Bitmap for playfield
   playfield:
   X.....XXXX.....................X
   X.....X........................X
   X.....XX.......................X
   X.....X........................X
   X.....X........................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
end
__Ball_Spawn_Lag_Loop
   ballheight = 0
   temp6 = _Ball_Velocity
   c = c-1
   if n > 0 then AUDV0 = n : AUDC0 = 8 : AUDF0 = 28 : COLUBK = n : n = n-1 else AUDV0 = 0 : AUDV1 = 0
   drawscreen;
   if c>0 && a>0 then goto __Ball_Spawn_Lag_Loop
   c = 20
   playfield:
   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ................................
   ................................
   ................................
   ................................
   ................................
   ................................
   ................................
   ................................
   ................................
   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
; Set ball size, coordinates, direction, 
   ballx = 80
   bally = 50
   ballheight = 1
   temp5 = (rand & %00100000)
   _Bit5_B_Direction_X = _Bit5_B_Direction_X ^ temp5
   _Bit6_B_Direction_Y{6} = 1

__Main_Loop
   score = l
   dim ball_speed_x = 1
   dim ball_speed_y = 1
   COLUP1 = m
   COLUP0 = o
   lifecolor = $3A

   ;Play sound if any sound duration, k, remains
   if k > 0 then AUDV0 = 10 : AUDC0 = 4 : AUDF0 = 25 : k = k-1 else AUDV0 = 0


   if !joy0up && !joy0down && !joy0left && !joy0right then goto __Skip_Joystick_Precheck
   if !joy1up && !joy1down && !joy1left && !joy1right then goto __Skip_Joystick_Precheck

   ; Clears player0 direction bits since joystick has been moved
   _BitOp_P0_M0_Dir = _BitOp_P0_M0_Dir & %11110000
   _BitOp_P1_M1_Dir = _BitOp_P1_M1_Dir & %11110000

__Skip_Joystick_Precheck
   ;  Joystick directions, direction bits must be turned on
   if joy0up && player0y > _P_Edge_Top then player0y = player0y - 2 : _Bit0_P0_Dir_Up{0} = 1
   if joy0down && player0y < _P_Edge_Bottom then player0y = player0y + 2 : _Bit1_P0_Dir_Down{1} = 1

   if joy1up && player1y > _P_Edge_Top then player1y = player1y - 2 : _Bit0_P0_Dir_Up{0} = 1
   if joy1down && player1y < _P_Edge_Bottom then player1y = player1y + 2 : _Bit1_P0_Dir_Down{1} = 1

   ;  Test for if fire button is pressed
   if !joy0fire then goto __Skip_Fire
   if _Bit7_M0_Moving{7} then goto __Skip_Fire
   _Bit7_M0_Moving{7} = 1
   _Bit4_M0_Dir_Up{4} = _Bit0_P0_Dir_Up{0}
   _Bit5_M0_Dir_Down{5} = _Bit1_P0_Dir_Down{1}
   _Bit6_M0_Dir_Left{6} = _Bit2_P0_Dir_Left{2}
   _Bit7_M0_Dir_Right{7} = _Bit3_P0_Dir_Right{3}
   missile0x = player0x + 6 : missile0y = player0y - 3
__Skip_Fire

   if !_Bit7_M0_Moving{7} then goto __Player_2_Missile

   missile0x = missile0x + 3

   ;  Clears missile0 if it hits the edge of the screen.
   
   if missile0y < _M_Edge_Top then goto __Delete_Missile
   if missile0y > _M_Edge_Bottom then goto __Delete_Missile
   if missile0x < _M_Edge_Left then goto __Delete_Missile
   if missile0x > _M_Edge_Right then goto __Delete_Missile
   if collision(player1,missile0) then goto __Hit_Player1

__Player_2_Missile
   ;Start of player 2 missile generation
   if !joy1fire then goto __Skip_Fire_2
   if _Bit7_M1_Moving{7} then goto __Skip_Fire_2
   _Bit7_M1_Moving{7} = 1
   _Bit4_M1_Dir_Up{4} = _Bit0_P1_Dir_Up{0}
   _Bit5_M1_Dir_Down{5} = _Bit1_P1_Dir_Down{1}
   _Bit6_M1_Dir_Left{6} = _Bit2_P1_Dir_Left{2}
   _Bit7_M1_Dir_Right{7} = _Bit3_P1_Dir_Right{3}
   missile1x = player1x + 6 : missile1y = player1y - 3

__Skip_Fire_2

   if !_Bit7_M1_Moving{7} then goto __Skip_Missile
   missile1x = missile1x - 3

   ;  Clears missile1 if it hits the edge of the screen.
   if missile1y < _M_Edge_Top then goto __Delete_Missile2
   if missile1y > _M_Edge_Bottom then goto __Delete_Missile2
   if missile1x < _M_Edge_Left then goto __Delete_Missile2
   if missile1x > _M_Edge_Right then goto __Delete_Missile2


   if collision(player0,missile1) then goto __Hit_Player2

   if !collision(playfield,missile1) then goto __Skip_Missile
   

   goto __Delete_Missile














__Hit_Player1
   a = a - 1
   if a=2 then m = $98
   if a=1 then m = $92
   if a=0 then player1x = 200 : player1y = 200 
   lives = lives-32

   goto __Delete_Missile
__Hit_Player2
   b = b - 1
   if b=2 then l = $38
   if b=1 then l = $33
   if b=0 then player0x = 200 : player0y = 200
   goto __Delete_Missile2

__Delete_Missile
   _Bit7_M0_Moving{7} = 0 : missile0x = 200 : missile0y = 200
   goto __Skip_Missile

__Delete_Missile2
   _Bit7_M1_Moving{7} = 0 : missile1x = 200 : missile1y = 200

__Skip_Missile
   if collision(player0, ball) then goto __Ball_P1 
   if collision(player1, ball) then goto __Ball_P1
   goto __Skip_Ball_P1

__Ball_P1
   _Bit5_B_Direction_X = _Bit5_B_Direction_X ^ %00100000
   if joy0up || joy1up then _Bit6_B_Direction_Y{6} = 0
   if joy0down || joy1down then _Bit6_B_Direction_Y{6} = 1
   ;Set the counter, k, for the beep sound effect
   k = 3
__Skip_Ball_P1
   ;ball movement
   temp5 = -1 : if _Bit5_B_Direction_X{5} then temp5 = 1 
   if temp5 = -1 then _Ball_Direction = -0.60 else _Ball_Direction = 0.60
   ;;immobilize ball if ball has reached edge boundaries

   if _Ball_Velocity > _B_Edge_Left && _Ball_Velocity < _B_Edge_Right then _Ball_Velocity = _Ball_Direction + _Ball_Velocity else n = 10 : goto __Ball_Spawn_Lag_Loop
   temp6 = -1 : if _Bit6_B_Direction_Y{6} then temp6 = 1
   if temp6 = -1 then _Ball_Direction = -0.60 else _Ball_Direction = 0.60
   _Ball_Position_y = _Ball_Position_y + _Ball_Direction

   ;if ballx < _B_Edge_Left then ballx = 200 : bally = 1 : goto __Ball_Spawn_Lag_Loop
   ;if ballx > _B_Edge_Right then ballx = 200 : bally = 1 : goto __Ball_Spawn_Lag_Loop
   ;if ballx < player0x && ((bally > (player0y - 30)) && (bally < (player0y + 30) )) then _Bit5_B_Direction_X = _Bit5_B_Direction_X ^ %00100000
   if bally < _B_Edge_Top || bally > _B_Edge_Bottom then _Bit6_B_Direction_Y = _Bit6_B_Direction_Y ^ %01000000



   ; draw the screen
   drawscreen


   ; Code for reset switch


   if !switchreset then _Bit0_Reset_Restrainer{0} = 0 : goto __Main_Loop

   if _Bit0_Reset_Restrainer{0} then goto __Main_Loop


   goto __Start_Restart

