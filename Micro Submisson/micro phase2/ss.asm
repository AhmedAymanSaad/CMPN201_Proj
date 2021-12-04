;====================================MACROS===============================
DrawFilledShape macro XPosition , YPosition , Width , Length , Colour    
 local Draw  
   MOV cx,XPosition
   MOV dx,YPosition
   MOV al,Colour 
   MOV ah,0ch
   Draw: int 10h
   inc cx  
   MOV bx,Width
   add bx,XPosition
   cmp cx,bx
   jng Draw  
   MOV cx,XPosition
   inc dx
   MOV bx,Length
   add bx,YPosition 
   cmp dx,bx   
   jnz Draw 
ENDM DrawFilledShape 

incrementlife macro  playerlife
  inc playerlife
endm

fuelkiller macro  Fuel
  mov Fuel,0
endm

ReadCharacter MACRO Character
    MOV AH, 07H
    INT 21H
    MOV Character, AL
ENDM ReadCharacter

PrintCharacter MACRO Character
    MOV AH, 02H
    MOV DL, Character
    INT 21H
ENDM PrintCharacter

;=========================================================================

.model large
.stack 64
.data
;Data for player 1
Player1X        dw  50        ;X-position of player 
Player1Fuel     db  0      ;Fuel of player max is 100
Player1Laser    dw  00    ;First number says the laser exits or not (1=fired, 0=not fired)
Player1LaserLen dw  00     ;Second number says the length of the laser if it is fired
Player1MoveSpeed    dw  10   ;MUST always be a number that is a factor of 320
player1LaserX   dw 0
player1laserY   dw 0
player1hitObstacle dw 0; zero if no obstacle is hit, 1 if obstacle is hit
player1life     db 3
player1laserlength dw 0
player1Name     db 16 dup('$')
player1drawlengthtemp dw 0; the length of the laser will be saved here temporarily and if an object is hit it will be saved in player2drawlength
player1drawlength dw 0; the length of the fired laser- the laser that is going to be drawn
player1slowspeedseconds db 0; counts the number of seconds for which the player's speed was slowed

;Data for player 2
Player2X        dw  200        ;X-position of player 
Player2Fuel     db  0      ;Fuel of player
Player2Laser    dw  00   ;First number says the laser exists or not (1=fired, 0=not fired)
Player2LaserLen dw  00            ;Second number says the length of the laser if it is fired     
Player2MoveSpeed    dw  10      ;MUST always be a number that is a factor of 320
player2LaserX   dw 0
player2laserY   dw 0
player2hitObstacle dw 0; zero if no obstacle is hit, 1 if obstacle is hit
player2life db 3
player2laserlength dw 0
player2Name     db 16 dup('$')
player2drawlengthtemp dw 0; the length of the laser will be saved here temporarily and if an object is hit it will be saved in player2drawlength
player2drawlength dw 0; the length of the fired laser- the laser that is going to be drawn
player2slowspeedseconds db 0; counts the number of seconds for which the player's speed was slowed
;Data for both players
FuelPerSecond   db  10     ;the amount of fuel that is filled for the player each second

;Data for Obstacles
obstaclewidth equ 15
obstaclelength equ 2
numofobtaclerows equ 3
obstaclesperrow equ 6
ObstacleRow1XPos    dw   0060,0100,0140,0180,0220,0260
ObstacleRow2XPos    dw   0060,0100,0140,0180,0220,0260
ObstacleRow3Xpos    dw   0060,0100,0140,0180,0220,0260
obstacleRow1Ypos equ 100
obstacleRow2Ypos equ 120
obstacleRow3Ypos equ 140
ObstacleRow1Health  dw  1,1,1,1,1,1
ObstacleRow2Health  dw  1,1,1,1,1,1
ObstacleRow3Health  dw  1,1,1,1,1,1
obstaclewidth   equ 15
obstacledirection db 0  ; if it's zero the obsticles move right, if it's equal to one the obsticles move left
ObstacleMoveSpeed   db  1   ;MUST always be a number that is a factor of 320
obstacleSpecialeffect dw 1,2,3,3,2,1
Extralife db 1
slowdown equ 2
normalspeed equ 10
killfuel db 3
row2checked dw 0

;Data variables for timer
oldtime dd 0
newtime dd 0
diff dd 0


;Data names for Static Data
;Scan codes for buttons
Player1Left_SC     equ 1eh       ;A key
Player1Right_SC    equ 20h       ;D key
Player1Fire_SC     equ 11h       ;W key
Player2Left_SC     equ 4bh       ;Arrow Left key
Player2Right_SC    equ 4dh       ;Arrow Right key
Player2Fire_SC     equ 48h       ;Arrow Up key
Escape_SC          equ 01h       ;ESC key

;Y vaules
Player1Y            dw 195
Player2Y           dw 50

;Data for drawing ships
Shape1_Length DW 5
Shape1_width DW 20
Shape2_Length DW 3
Shape2_width DW 6
drawbuffer1 dw 0
drawbuffer2 dw 0

;Data for drawing obstacles
color db ?
startx dw ?
starty dw ? 
endx dw ?
endy dw ?   

;Data for printing
fuel db ' fuel_1:$'
fuel2 db ' fuel_2:$'
lives db ' life_1:$'
lives2 db ' life_2:$'
fuel100 db '100$'

;Variables , Strings and Cnstants
please1                db "Player 1 Please enter your name:","$"
please2                db "Player 2 Please enter your name:","$"
inputname              db  16 dup(?)
lastline               db "Please enter key to continue","$" 
Chat_MSG               db  'To start chatting press F1 $'
GAME_MSG               db  'To start the game press F2 $'
END_MSG                db  'To End the program press ESC $'
GameLevels_MSG         db   "Please choose which level do you want to play  $ "
Level1_MSG             db   "Level1 $"
Level2_MSG             db   "Level2 $"
Play1_MSG              db   "Press F1 to Play $"
Play2_MSG              db   "Press F2 to Play $"

endgamemsg              db  'Game Has Ended Thank You For Playing <3$'

;Debugging data
printdebugmsg   db "moveObstacles proc has been called / $"


.code


;=========================== PROCEDURES ============================

;PROC1: FirstMenu 
;Responsible for making the first menu and getting the players' data
FirstMenu PROC FAR
mov ax,@data
mov ds,ax 

;------------------------------- Player 1  Data ------------------------------------
;Changning to text mode
MOV AH, 00H
MOV AL, 03H
INT 10H

;Printing message (please1) to notify the user to enter his name
mov ah,2      
mov dx,0a1Ah
int 10h 

mov ah,9      
mov dx, offset please1
int 21h 

;Moving the cursor downwards   
mov ah,2      
mov dx,0b1Ah
int 10h           

mov si,0

;Checking the first Letter of player1 (not number or special character)
UserName_Back1 : 
ReadCharacter player1Name[0]
CMP player1Name[0], 'A'
JB  UserName_Back1
CMP player1Name[0], 'Z'
JBE UserName_Return1

CMP player1Name[0], 'a'
JB  UserName_Back1
CMP player1Name[0], 'z'
JA  UserName_Back1

;Printing the name of player1 (Unless not more than 15 characters)
UserName_Return1:
PrintCharacter player1Name[si]
inc si
ReadCharacter player1Name[si]
cmp player1Name[si],0Dh
JE Return1
cmp si,15
JNE UserName_Return1

Return1:
;Printing message to notify the user to press enter to continue
mov ah,2
mov dx, 0c1Ah
int 10h
              
mov ah,9      
mov dx, offset lastline
int 21h 

waitpress1:
;Wait for user press
MOV AH, 00H
INT 16H
cmp al,0DH
jne waitpress1

;--------------------------------- Player 2 Data ---------------------------------
;Changning to text mode
MOV AH, 00H
MOV AL, 03H
INT 10H

;Printing message (please2) to notify the user to enter his name
mov ah,2      
mov dx,0a1Ah
int 10h 

mov ah,9      
mov dx, offset please2
int 21h 

;Moving the cursor downwards   
mov ah,2      
mov dx,0b1Ah
int 10h           
mov si,0

;Checking the first Letter of player2 (not number or special character)
UserName_Back2 : 
ReadCharacter inputname[0]
CMP inputname[0], 'A'
JB  UserName_Back2
CMP inputname[0], 'Z'
JBE UserName_Return2

CMP inputname[0], 'a'
JB  UserName_Back2
CMP inputname[0], 'z'
JA  UserName_Back2

;Printing the name of player2 (Unless not more than 15 characters)
UserName_Return2:
PrintCharacter inputname[si]
inc si
ReadCharacter inputname[si]
cmp inputname[si],0Dh
JE Return2
cmp si,15
JNE UserName_Return2

Return2:
;Printing message to notify the user to press enter to continue
mov ah,2
mov dx, 0c1Ah
int 10h
              
mov ah,9      
mov dx, offset lastline
int 21h 

waitpress2:
;Wait for user press
MOV AH, 00H
INT 16H
cmp al,0DH
jne waitpress2

ret
FirstMenu endp
;------------------------------------------------------
;PROC2: MainMenu 
;Responsible for making the Main menu 
MainMenu PROC FAR
mov ax,@data
mov ds,ax 

;Changning to Graphics mode
MOV AH, 00H
MOV AL, 10H
INT 10H

;Printing Chat message 
mov ah,2
mov dx, 0A19H
int 10h
              
mov ah,9      
mov dx, offset Chat_MSG
int 21h 


;Printing Game message  
mov ah,2
mov dx, 0C19H
int 10h
              
mov ah,9      
mov dx, offset GAME_MSG
int 21h 

;Printing ESCAPE message
mov ah,2
mov dx, 0E19H
int 10h
              
mov ah,9      
mov dx, offset END_MSG
int 21h 

;Drawing Dotted Line 

    MOV CX,0
    MOV dx,300
    MOV al,0fh
    MOV ah,0ch
    First:
    int 10h
    inc CX
    CMP CX,640
    jnz First
    MOV CX,0
    MOV dx,300
    MOV al,00h
    MOV ah,0ch
    Second:
    int 10h
    add CX,5
    CMP CX,640
    jb Second

ret
MainMenu endp
;------------------------------------------------------
;PROC3 : Responsible for getting the players' choice of mode and game level
Modes proc far 
mov ax,@data
mov ds,ax 

;Wait for user press to decide which mode to go to 
T:
MOV AH, 00H
INT 16H
cmp AH,3BH ;F1 is pressed
je ChatMode
cmp AH,3CH ;F2 is pressed
je GameMode
cmp AH,01H ;ESC is pressed
je Escape
cmp AH,86H 
jne T

;------------------------- Chat Mode -------------------------------

ChatMode:
Ret
;Chat Mode code

;------------------------- Game Mode -------------------------------
GameMode:
;Changning to Graphics mode
MOV AH, 00H
MOV AL, 10H
INT 10H

;Printing Message to notify the user to choose the level
mov ah,2
mov dx, 070EH
int 10h

mov ah,9      
mov dx, offset GameLevels_MSG
int 21h 

;Printing which key to press to play level1
mov ah,2
mov dx, 0C06H
int 10h
              
mov ah,9      
mov dx, offset Level1_MSG
int 21h 

mov ah,2
mov dx, 0E06H
int 10h
              
mov ah,9      
mov dx, offset Play1_MSG
int 21h 

;Printing which key to press to play level2
mov ah,2
mov dx, 0C40H
int 10h
              
mov ah,9      
mov dx, offset Level2_MSG
int 21h 

mov ah,2
mov dx, 0E39H
int 10h
              
mov ah,9      
mov dx, offset Play2_MSG
int 21h 

;wait for user press
MOV AH, 00H
INT 16H

cmp AH,3BH ;F1 is pressed
jne Escape
call StartGame


;------------------------- End Game -------------------------------
Escape:
Ret
Modes ENDP
;------------------------------------------------------

printfuel2 proc
   push ax
   push bx
   push cx
   push dx
    MOV Dl,  10
    mov ah,0
    mov al,player2fuel
    cmp al,100
    je print2100
    div dl
    mov dl, al 
    add dl,30h
    mov bl,ah
    MOV AH, 02h
    int 21h
    mov dl, bl 
    add dl,30h
    MOV AH, 02h
    int 21h
    jmp endofprintfuel2
    print2100:
    MOV Dl, offset fuel100  
   MOV AH, 09h
   int 21h

    endofprintfuel2:
   pop dx
   pop cx
   pop bx
   pop ax

   ret
printfuel2 endp

printfuel1 proc
   push ax
   push bx
   push cx
   push dx
    MOV Dl,  10
    mov ah,0
    mov al,player1fuel
    cmp al,100
    je print100
    div dl
    mov dl, al 
    add dl,30h
    mov bl,ah
    MOV AH, 02h
    int 21h
    mov dl, bl 
    add dl,30h
    MOV AH, 02h
    int 21h
    jmp endofprintfuel1
    print100:
    MOV Dl, offset fuel100  
   MOV AH, 9h
   int 21h

    endofprintfuel1:
   pop dx
   pop cx
   pop bx
   pop ax

   ret
printfuel1 endp

printlive proc
   push ax
   push bx
   push cx
   push dx

   MOV Dl,  player1life  
   add dl,30h

   MOV AH, 02h
   int 21h


   pop dx
   pop cx
   pop bx
   pop ax

   ret
printlive endp

printlive2 proc
   push ax
   push bx
   push cx
   push dx

   MOV Dl,  player2life  
    add dl,30h
   MOV AH, 02h
   int 21h


   pop dx
   pop cx
   pop bx
   pop ax

   ret
printlive2 endp


DrawLivesfuels proc
   push dx
   push ax
            
   mov dh, 1 ;row
   mov dl, 1 ;col
   mov ah, 2 
   int 10h

    lea di, player1Name
    loopname:
    mov dl,[di]
    cmp dl,0Dh
    je loopnameend
    mov ah,2
    int 21h
    inc di
    jmp loopname
    loopnameend:


   lea dx,fuel
   mov ah,9
   int 21h 
   call  printfuel1

    lea dx,lives
   mov ah,9
   int 21h 
   call printlive

    mov dh, 2 ;row
   mov dl, 1 ;col
   mov ah, 2 
   int 10h

   lea di, InputName
    loopname2:
    mov dl,[di]
    cmp dl,0Dh
    je loopnameend2
    mov ah,2
    int 21h
    inc di
    jmp loopname2
    loopnameend2:

   lea dx, fuel2
   mov ah, 9
   int 21h
   call  printfuel2

   
   lea dx,lives2
   mov ah,9
   int 21h 
   call printlive2
   pop ax
   pop dx
   ret
DrawLivesfuels endp


DrawSpaceShip proc FAR
    ;Drawing Filled Rectangle
    push ax
    push bx
    DrawFilledShape player1X,Player1Y,Shape1_width, Shape1_Length,01
    DrawFilledShape Player2X,Player2Y,Shape1_width, Shape1_Length,04

    ;Drawing Filled Square
    mov ax,player1X
    add ax,7
    mov bx,Player1Y
    sub bx,3
    mov drawbuffer1,ax
    mov drawbuffer2,bx
    DrawFilledShape drawbuffer1,drawbuffer2,Shape2_width, Shape2_Length,01
    mov ax,player2X
    add ax,7
    mov bx,Player2Y
    add bx,5
    mov drawbuffer1,ax
    mov drawbuffer2,bx
    DrawFilledShape drawbuffer1,drawbuffer2,Shape2_width, Shape2_Length,04
    pop bx
    pop ax
    ret

DrawSpaceShip ENDP

draw proc
    push ax
    push cx
    push dx
     
    mov dx,starty
    mov cx,startx
    mov ah,0ch
    mov al,color
    c:
    inc cx
    int 10h
    cmp cx,endx
    jne c

    mov cx,startx
    inc dx
    cmp dx,endy
    jne c 
    
    pop dx
    pop cx
    pop ax
    ret
draw endp

drawLaser1 proc
    lea di,player1laser
    mov ax,[di]
    cmp ax,1
    jne endplayer1laser
    inc di
    inc di
    mov color,6    
    
    mov ax,player1X
    add ax,10
    mov player1laserx,ax
    
    mov startx,ax
    inc ax
    mov endx,ax
    mov ax,player1Y
    mov endy,ax
    mov ax,player1drawlength
    mov starty,ax
    mov bx,player2Y
    cmp bx,ax
    jl gotodraw
    mov starty,bx
    ;mov bx,200
    ;sub bx,ax
    gotodraw:
    call draw
    endplayer1laser:
    ret
drawlaser1 endp

drawLaser2 proc
    lea di,player2laser
    mov ax,[di]
    cmp ax,1
    jne endplayer2laser
    inc di
    inc di
    mov color,6    
    
    mov ax,player2X
    add ax,10
    mov player2laserx,ax
    
    mov startx,ax
    inc ax
    mov endx,ax
    mov ax,player2Y
    mov starty,ax
    mov ax,player2drawlength
    cmp ax,player1Y
    jng dlj1
    mov ax,player1Y
    dlj1:
    mov endy,ax
    call draw
    endplayer2laser:
    ret
drawlaser2 endp

Addobstcale proc
    push ax 
    mov startx, ax
    mov color, 10  
    mov ax, bx
    mov bx, startx
    
    add bx, obstaclewidth

    
    mov endx,bx
    
    mov starty, ax 
    
    mov bx,starty
                    
    add bx,obstaclelength
    mov endy,bx
     
    call draw
   
    pop ax 
    ret
    Addobstcale endp




Buildobstcale proc
    push ax
    push bx
    push si
    push di
    mov cx, obstaclesperrow
    lea si, ObstacleRow1XPos
    lea di,ObstacleRow1Health
    count:
    mov dl,[di]
    cmp dl,1
    jne dontdraw
    mov ax,[si]
    mov bx, obstacleRow1Ypos
    call Addobstcale
    dontdraw:
    inc si
    inc si
    inc di
    inc di
    loop count
     mov cx, obstaclesperrow
    lea si, obstacleRow1Xpos
    lea di,ObstacleRow2Health
    count1:
    mov dl,[di]
    cmp dl,1
    jne dontdraw1
    mov ax,[si]
    mov bx, obstacleRow2Ypos
    call Addobstcale
    dontdraw1:
    inc si
    inc si
    inc di
    inc di
    loop count1
     mov cx, obstaclesperrow
    lea si, obstacleRow1Xpos
    lea di,ObstacleRow3Health
    count2:
    mov dl,[di]
    cmp dl,1
    jne dontdraw2
    mov ax,[si]
    mov bx, obstacleRow3Ypos
    call Addobstcale
    dontdraw2:
    inc si
    inc si
    inc di
    inc di
    loop count2
    
    pop di
    pop si
    pop bx
    pop ax
    ret
Buildobstcale endp


DrawScreen proc far
;;adding a delay 
MOV     CX, 0
MOV     DX, 40000
MOV     AH, 86H
INT     15H
;;Clear the screen
MOV AX,0600H    ;06 TO SCROLL & 00 FOR FULLJ SCREEN
MOV BH,00H    ;ATTRIBUTE 7 FOR BACKGROUND AND 1 FOR FOREGROUND
MOV CX,0000H    ;STARTING COORDINATES
MOV DX,184FH    ;ENDING COORDINATES
INT 10H        ;FOR VIDEO DISPLAY
;;Draw all the players and lasers (if shot) and obstacles
call DrawSpaceShip
call Buildobstcale
call DrawLivesfuels

ret
DrawScreen endp

Player1Left proc far
    push di
    push ax
    pushf
    lea di,Player1X
    mov ax,0
    cmp [di],ax ;checks if player is already on the left side of the screen
    je endplayer1left ;if true then return
    mov ax,Player1MoveSpeed
    sub [di],ax  ;if false then move to the left
    endplayer1left:
    popf
    pop ax
    pop di
    ret
Player1Left endp

Player1Right proc far
    push di
    push ax
    pushf
    lea di,Player1X
    mov ax,300
    cmp [di],ax ;checks if player is already on the right side of the screen
    je endplayer1right ;if true then return
    mov ax,Player1MoveSpeed
    add [di],ax  ;if false then move to the right
    endplayer1right:
    popf
    pop ax
    pop di
    ret
Player1Right endp

Player2Left proc far
    push di
    push ax
    pushf
    lea di,Player2X
    mov ax,0
    cmp [di],ax ;checks if player is already on the left side of the screen
    je endplayer2left ;if true then return
    mov ax,Player2MoveSpeed
    sub [di],ax  ;if false then move to the left
    endplayer2left:
    popf
    pop ax
    pop di
    ret
Player2Left endp

Player2Right proc far
    push di
    push ax
    pushf
    lea di,Player2X
    mov ax,300
    cmp [di],ax ;checks if player is already on the right side of the screen
    je endplayer2right ;if true then return
    mov ax,Player2MoveSpeed
    add [di],ax  ;if false then move to the right
    endplayer2right:
    popf
    pop ax
    pop di
    ret
Player2Right endp

decrementspeedplayer1 proc  
  push ax
  mov ah,0
  mov al,slowdown
  mov Player1MoveSpeed,ax
  mov player1slowspeedseconds,0
  pop ax
  ret
decrementspeedplayer1 endp

setspeedplayer1 proc  
  mov Player1MoveSpeed,normalspeed
  ret
setspeedplayer1 endp

player2obstacleeffect proc
push si
push bx
mov si,dx
mov bx,[si]
cmp bl,Extralife
jne fueldecrement2 
incrementlife player2life
fueldecrement2:
cmp bl,killfuel
jne slowspeed2
fuelkiller Player1Fuel
slowspeed2:
cmp bl,slowdown
jne endeffect2
call decrementspeedplayer1
endeffect2:
pop bx
pop si
ret
player2obstacleeffect endp


player2hitObstacles proc far
push bx
push si
push ax
push cx
push dx
mov cx,obstaclesperrow
lea si,ObstacleRow1XPos
mov ax,player2Laserlen; save the fuel*2 in ax
add ax,player2y; add the position of player 1 to the fuel*2 from to get the Y-position of end point of laser from the Y=50 to the end of the screen 
mov player2drawlength,ax
mov player2laserlength,ax ; save the value in player1laserlength
push di
lea di,ObstacleRow1Health
cmp ax,obstacleRow1Ypos
jl row2checkp2
mov player2drawlengthtemp,obstacleRow1Ypos
looprow1p2:
mov ax, player2laserx
 cmp [si],ax
 jg row2checkp2
 mov ax,[si]
 add ax,obstaclewidth
 cmp ax,player2laserx
 jg obstaclehitrow1p2
 inc si
 inc si
 inc di
 inc di
 loop looprow1p2
 jmp row2checkp2
obstaclehitrow1p2:
mov bx,[di]
cmp bl,1
jne row2checkp2
mov player2hitObstacle,1
push ax
mov ax,0
mov [di],ax
pop ax
push ax
mov ax,player2drawlengthtemp
mov player2drawlength,ax
pop ax
jmp endhitp2
row2checkp2:
mov cx,obstaclesperrow
lea si,ObstacleRow1XPos
lea dx,obstacleSpecialeffect
lea di,ObstacleRow2Health
mov ax,player2laserlength
cmp row2checked,1;;;;
je endhitp2;;;;;
cmp ax,obstacleRow2Ypos
jl endhitp2
mov player2drawlengthtemp,obstacleRow2Ypos
looprow2p2:
mov ax, player2laserx
 cmp [si],ax
 jg endhitp2
 mov ax,[si]
 add ax,obstaclewidth
 cmp ax,player2laserx
 jg obstaclehitrow2p2
 inc si
 inc si
 inc di
 inc di
 inc dx
 inc dx
 loop looprow2p2
 jmp row3checkp2
obstaclehitrow2p2:
push ax
mov ax , 1
cmp [di],ax
pop ax
jne row3checkp2
mov player2hitObstacle,1
push ax
mov ax , 0
mov [di],ax
pop ax
push ax
mov ax,player2drawlengthtemp
mov player2drawlength,ax
pop ax
call player2obstacleeffect
jmp endhitp2
row3checkp2:
mov row2checked,1
mov cx,obstaclesperrow
lea si,ObstacleRow1XPos
lea di,ObstacleRow3Health
mov ax, player2laserlength
cmp ax,obstacleRow3Ypos
jl endhitp2
mov player2drawlengthtemp,obstacleRow3Ypos
jmp looprow1p2
endhitp2:
mov row2checked,0
pop di
pop dx
pop cx
pop ax
pop si
pop bx
ret
player2hitObstacles endp

HitDetectionPlayer2 proc far
    call player2hitObstacles
    cmp player2hitObstacle,1
    je endofhitdetection2
    mov ax,player2X
    lea di,Player2Laser
    inc di
    inc di
    checkifhitplayer2:
    mov bx,Player1Y
    mov player2laserY,0
    mov cx,[di]
    add cx,player2y
    add player2LaserY,cx
    cmp player2laserY,bx
    jng checkifhitobstacle2
    add ax,10
    mov player2LaserX,ax
    mov ax,player1x
    
    cmp ax,player2laserx
    jnle checkifhitobstacle2
    add ax,Shape1_width
    cmp ax,player2laserx
    jnge checkifhitobstacle2
    dec player1life
    jmp endofhitdetection2

    checkifhitobstacle2:
    endofhitdetection2:
    
    ret
HitDetectionPlayer2 endp

DecrementFuelplayer2 proc far
    mov ax,player2drawlength
    sub ax,50
    ;mov ax,player2laserlen
    mov bl,2
    div bl
    cmp player2hitObstacle,0
    je notadd
    add al,5
    notadd:
    sub player2fuel,al
    
    ret
DecrementFuelplayer2 endp


Player2Fire proc far
    lea di, Player2Laser
    mov ax , 1
    cmp [di],ax              ;if laser is already fired don't fire again
    je endofplayer2fire
    mov [di],ax              ;fire the laser
    inc di
    inc di
    mov ax,0
    mov [di],ax              ;intialize the length of the laser to be zero
    mov al, Player2Fuel
    mov bx, 2
    mul bl                  ;multiply the fuel by 2 to calculate the maximum draw distance
    mov player2Laserlen,ax
    mov [di],al
    mov ax,player2X
    add ax,10
    mov player2LaserX,ax
    call HitDetectionPlayer2
    call DecrementFuelplayer2
    call drawLaser2
    endofplayer2fire:
    mov player2hitObstacle,0
    ret
Player2Fire endp

decrementspeedplayer2 proc  
  push ax
  mov ah,0
  mov al,slowdown
  mov Player2MoveSpeed,ax
  mov player2slowspeedseconds,0
  pop ax
  ret
decrementspeedplayer2 endp

setspeedplayer2 proc  
  mov Player2MoveSpeed,normalspeed

  ret

setspeedplayer2 endp

player1obstacleeffect proc
push si
push bx
mov si,dx
mov bx,[si]
cmp bl,Extralife
jne fueldecrement 
incrementlife player1life
fueldecrement:
cmp bl,killfuel
jne slowspeed
fuelkiller Player2Fuel
slowspeed:
cmp bl,slowdown
jne endeffect
call decrementspeedplayer2
endeffect:
pop bx
pop si
ret
player1obstacleeffect endp



player1hitObstacles proc far
push bx
push si
push ax
push cx
push dx
mov cx,obstaclesperrow
lea si,ObstacleRow1XPos
mov ax,200; Y at the end of the screen

sub ax,player1Laserlen; subtract the fuel*2 from the end of the screen to get the Y-position of laser 
mov player1laserlength,ax ; save the value in player1laserlength
mov player1drawlength,ax
push di
lea di,ObstacleRow3Health
cmp ax,obstacleRow3Ypos
jg row2check
mov player1drawlengthtemp,obstacleRow3Ypos
looprow1:
mov ax, player1laserx
 cmp [si],ax
 jg row2check
 mov ax,[si]
 add ax,obstaclewidth
 cmp ax,player1laserx
 jg obstaclehitrow1
 inc si
 inc si
 inc di
 inc di
 loop looprow1
 jmp row2check
obstaclehitrow1:
mov bx,[di]
cmp bl,1
jne row2check
mov player1hitObstacle,1
push ax
mov ax , 0
mov [di],ax
pop ax
push ax
mov ax,player1drawlengthtemp
mov player1drawlength,ax
pop ax
jmp endhit
row2check:
mov cx,obstaclesperrow
lea si,ObstacleRow1XPos
lea dx,obstacleSpecialeffect
lea di,ObstacleRow2Health
mov ax,player1laserlength
cmp row2checked,1;;;;
je endhit;;;;;
cmp ax,obstacleRow2Ypos
mov player1drawlengthtemp,obstacleRow2Ypos
jg endhit
looprow2:
mov ax, player1laserx
 cmp [si],ax
 jg endhit
 mov ax,[si]
 add ax,obstaclewidth
 cmp ax,player1laserx
 jg obstaclehitrow2
 inc si
 inc si
 inc di
 inc di
 inc dx
 inc dx
 loop looprow2
 jmp row3check
obstaclehitrow2:
push ax
mov ax , 1
cmp [di],ax
pop ax
jne row3check
mov player1hitObstacle,1
push ax
mov ax , 0
mov [di],ax
pop ax
call player1obstacleeffect
push ax
mov ax,player1drawlengthtemp
mov player1drawlength,ax
pop ax
jmp endhit
row3check:
mov row2checked,1
mov cx,obstaclesperrow
lea si,ObstacleRow1XPos
lea di,ObstacleRow1Health
mov ax, player1laserlength
cmp ax,obstacleRow1Ypos
jg endhit
;cmp [di],0
;je endhit
mov player1drawlengthtemp,obstacleRow1Ypos
jmp looprow1
endhit:
mov row2checked,0
pop di
pop dx
pop cx
pop ax
pop si
pop bx
ret
player1hitObstacles endp


HitDetectionPlayer1 proc far

    call player1hitObstacles
    cmp player1hitObstacle,1
    je endofhitdetection
    checkifhitplayer:
    mov ax,player1X
    lea di,Player1Laser
    inc di
    inc di
    mov bx,Player2Y
    mov player1laserY,200
    mov cx,[di]
    sub player1LaserY,cx
    cmp player1laserY,bx
    jnle checkifhitobstacle
    add ax,10
    mov player1LaserX,ax
    mov ax,player2x
    
    cmp ax,player1laserx
    jnle checkifhitobstacle
    add ax,Shape1_width
    cmp ax,player1laserx
    jnge checkifhitobstacle
    dec player2life
    jmp endofhitdetection

    checkifhitobstacle:
    endofhitdetection:
    mov player1hitObstacle,0
    ret
HitDetectionPlayer1 endp

DecrementFuelplayer1 proc far
    mov ax,200
    sub ax,player1drawlength
    mov bl,2
    div bl

    sub player1fuel,al
    ret
DecrementFuelplayer1 endp


Player1Fire proc far
    lea di, Player1Laser
    mov ax,1
    cmp [di],ax              ;if laser is already fired don't fire again
    je endofplayer1fire
    mov [di],ax              ;fire the laser
    inc di
    inc di
    mov ax,0
    mov [di],ax              ;intialize the length of the laser to be zero
    mov al, Player1Fuel
    mov bx, 2
    mul bl 
    mov Player1LaserLen,ax                 ;multiply the fuel by 2 to calculate the maximum draw distance
    mov [di],al
    mov ax,player1X
    add ax,10
    mov player1LaserX,ax
    call HitDetectionPlayer1
    call DecrementFuelplayer1
    call drawLaser1
    endofplayer1fire:
    ret
Player1Fire endp


CheckUserInput proc far

    mov ah,1
    int 16H
    jz buttonNotPressed                 ;if no button is pressed we jump

    ;if button is pressed we execute this code
    mov ah, 0h
    int 16h                             ;Now we store the button that was pressed in ah

    cmp ah,Player1Left_SC
    jne case2                           ;if false skip this code and go to the next check
    call Player1Left                   ;if true do this code then return
    jmp buttonNotPressed                ;then after executing the code we end the procedure
    case2:
    cmp ah,Player1Right_SC
    jne case3 
    call Player1Right
    jmp buttonNotPressed
    case3:
    cmp ah,Player1Fire_SC
    jne case4
    call Player1Fire
    jmp buttonNotPressed
    case4: 
    cmp ah,Player2Left_SC
    jne case5 
    call Player2Left 
    jmp buttonNotPressed
    case5:
    cmp ah,Player2Right_SC
    jne case6 
    call Player2Right
    jmp buttonNotPressed
    case6:
    cmp ah,Player2Fire_SC
    jne case7
    call Player2Fire
    jmp buttonNotPressed
    case7:                  ;button is not one of the registered buttons


    buttonNotPressed:
    ret

CheckUserInput endp

MoveObstacles proc far
    push si ; pushes all the registers used
    push cx
    push ax
    push dx
    mov dx,1
    lea si,ObstacleRow1XPos ; si points at the array that contains the X-coordinates of the obstacles
    mov cx,ObstaclesPerRow ; cx will act as a counter and contains the number of obstacles in each row
    cmp obstacledirection,0 
    je increment ; if the direction is set to right we will increment the X-coordinate
    cmp obstacledirection,1
    je decrement ; if the direction is set to left we will decrement the X-coordinate

    increment:
    add [si],dx ; increment the X-coordinate
    inc si ; go the the X-coordiate of second obstacle
    inc si
    loop increment ; decrement cx and jump to increment
    dec si ; decrement Si to go to the X-coordinate of the last object
    dec si
    mov ax,[si] ; save the X-coordinate of the last object in ax
    add ax,obstaclewidth ; add the width of the object to it's X-coordinate and saves it in ax
    cmp ax,320 ; checks whether the object reached the end of the screen or not
    je setdirection
    jne endyy
    setdirection:
    mov obstacledirection,1 ; change the obstacles direction
    jmp endyy

    decrement:
    sub [si],dx ;decrement the X-coordinate
    mov ax,[si] ;; save the X-coordinate of the obstacle in ax
    cmp ax,0 ; checks whether the object has reached the end of the screen where x=0
    je reversedirection
    jne continue
    reversedirection:
    mov obstacledirection,0 ;; change the obstacles direction
    continue:
    inc si
    inc si
    loop decrement

    endyy:
    pop dx
    pop ax 
    pop cx
    pop si ; we pop the registers that we used to get their original values
    ret
MoveObstacles endp



IncrementFuel proc far
    push ax
    mov al,FuelPerSecond    ;Every second this code runs to replenish the fuel of the ships by 10
    cmp Player1Fuel,100     ;Check if fuel is full
    jge maxfuelplayer1     ;if full jump to next player
    add Player1Fuel,al      ;if not fill the fuel
    fillplayer2fuel:
    cmp Player2Fuel,100
    jge maxfuel
   
    add Player2Fuel,al
    jmp endofIncrementFuel
    maxfuelplayer1:
    mov Player1Fuel,100
    jmp fillplayer2fuel
    maxfuel:
    mov Player2Fuel,100
    endofIncrementFuel:
    
    pop ax
    ret
IncrementFuel endp

playersSpeed proc
    push ax
    inc player1slowspeedseconds
    inc player2slowspeedseconds
    mov al,player1slowspeedseconds
    cmp al,5
    je setplayer1speed
    checkplayer2speed:
    mov al,player2slowspeedseconds
    cmp al,5
    je setplayer2speed
    jmp endspeed
    setplayer1speed:
    call setspeedplayer1
    jmp checkplayer2speed
    setplayer2speed:
    call setspeedplayer2
    endspeed:
    pop ax
    ret
playersSpeed endp

CheckTimeFunctions proc far

    mov ah,00
    int 1ah
    mov word ptr newtime,dx
    mov word ptr newtime+2,cx   ;get the current time
    mov ax, word ptr newtime
    mov bx, word ptr oldtime
    sub ax,bx                   ;subtract current time from the oldtime
    mov word ptr diff,ax
    mov ax, word ptr newtime+2
    mov bx, word ptr oldtime+2
    sbb ax,bx
    mov word ptr diff+2,ax
    mov dx,word ptr diff
    cmp dx,18       ;if the difference between newtime-oldtime is greater than 1 second (18 ticks) dont jump
    jng TimerNotDone        ;jmp if 1 second has not passed
    mov ax,word ptr newtime ;intialize the clock again
    mov word ptr oldtime,ax
    mov ax,word ptr newtime+2
    mov word ptr oldtime+2,ax
   ;now call the functions that are executed every one second
   ;call MoveObstacles
   call IncrementFuel
   mov player1laser,0
   mov player2laser,0
   call playersSpeed



    TimerNotDone:

    ret
CheckTimeFunctions endp

EndGame proc 
    MOV AX,0600H    ;06 TO SCROLL & 00 FOR FULLJ SCREEN
    MOV BH,00H    ;ATTRIBUTE 7 FOR BACKGROUND AND 1 FOR FOREGROUND
    MOV CX,0000H    ;STARTING COORDINATES
    MOV DX,184FH    ;ENDING COORDINATES
    INT 10H        ;FOR VIDEO DISPLAY
    call DrawLivesfuels
    mov dh, 3 ;row
   mov dl, 1 ;col
   mov ah, 2 
   int 10h
   lea dx,endgamemsg
   mov ah,9
   int 21h 

EndGame endp

MainGameLoop proc far
    call CheckUserInput
    call CheckTimeFunctions
    call MoveObstacles
    cmp player1life,0
    jne next1
    call endgame
    next1:
    cmp player2life,0
    jne next2
    call endgame
    next2:
    ret
MainGameLoop endp

StartGame proc near
pushf

;;Switch to video mode
mov ah,0
mov al,13h
int 10h

GameLoop:
call DrawScreen
call MainGameLoop
jmp GameLoop

popf
ret
StartGame endp

;============================== MAIN CODE ================================
main proc far 
mov ax,@data
mov ds,ax 
mov es, ax

;;call main menu proc

;Intializing the timer
mov ah,00
int 1ah
mov word ptr oldtime,dx
mov word ptr oldtime+2,cx
;=====================
call FirstMenu
call MainMenu
call Modes

hlt
main endp
end main

