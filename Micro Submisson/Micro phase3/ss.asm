EXTRN ChatModule:FAR
public player1Name, InputName


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
player1FreezeSeconds db 0; counts the number of seconds for which the player is frozen and can't move but can fire
player1InfiniteFuelseconds db 0; counts the number of seconds for which the player's fuel is infinite
player1IsFrozen db 0; zero if not frozen, 1 if frozen
player1InfiniteFuel db 0; zero if not infinite, 1 if infiite
player1msg db 40 dup('$')
player2msg db 40 dup('$')



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
player2FreezeSeconds db 0; counts the number of seconds for which the player is frozen and can't move but can fire
player2InfiniteFuelseconds db 0; counts the number of seconds for which the player's fuel is infinite
player2IsFrozen db 0; zero if not frozen, 1 if frozen
player2InfiniteFuel db 0; zero if not infinite, 1 if infiite

;Data for both players
FuelPerSecond   db  10     ;the amount of fuel that is filled for the player each second
Level                  db   1 ; 1 for level 1 and 2 for level 2
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
obstacledirection db 0  ; for level 1 it's zero the obsticles move right, if it's equal to one the obsticles move left
obstacledirectionLevel2 dW 0,1,0  ; for level 2 if it's zero the obsticles move right, if it's equal to one the obsticles move left, each number is for a certain row
ObstacleMoveSpeed   db  1   ;MUST always be a number that is a factor of 320
obstacleSpecialeffect dw 1,2,3,4,5,1
Extralife db 1
slowdown equ 2
normalspeed equ 10
killfuel db 3
infiniteFuel db 4
freeze equ 5
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
Enterkey_SC        equ 1ch       ;Enter key

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
;Data for printing
fuel db ' fuel_1:$'
fuel2 db ' fuel_2:$'
lives db ' life_1:$'
lives2 db ' life_2:$'
fuel100 db '100$'

;Data for drawing obstacles
color db ?
startx dw ?
starty dw ? 
endx dw ?
endy dw ?   



;Variables , Strings and Cnstants
please1                db "Player 1 Please enter your name:","$"
please2                db "Player 2 Please enter your name:","$"
inputname              db  16 dup('$')
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
connectedtoplayer       db  'Connected to Player: $'
chatinviterecmsg           db  'Received Chat Invitation: press F1 to accept$'
chatinvitesent          db  'Chat Invitation Sent $'
gameinviterecmsg           db  'Received Game Invitation: press F2 to accept$'
gameinvitesent       db  'Game Invitation Sent $'

;Defined data for send and receive codes
chatinvitation         dw  101
chataccepted            dw  111
gameinvitation          dw  102
gameaccepted            dw  112
ReceiveData             dw 0
chatinviterec           dw  0
gameinviterec           dw  0
gamelevel2              dw  0
isplayer1               dw  0
player1leftcode dw  211
player1rightcode dw 212
player1firecode dw 213
player2leftcode dw 221
player2rightcode dw 222
player2firecode dw 223
playertyping dw 230

;Debugging data
printdebugmsg   db "moveObstacles proc has been called / $"
dbg1            db "opening chat mode $"


.code


;=========================== PROCEDURES ============================

SendName proc
;;Send Data=================================================
;Check that Transmitter Holding Register is Empty
mov dx , 3FDH ; Line Status Register
AGAIN: In al , dx ;Read Line Status
test al , 00100000b
JZ AGAIN ;Not empty
;If empty put the VALUE in Transmit data register
mov dx , 3F8H ; Transmit data register
mov al,[si]
out dx , al
ret
SendName endp

ReceiveName proc
;;Receiving Data===========================================
;Check that Data is Ready
mov dx , 3FDH ; Line Status Register
CHK: in al , dx
test al , 1
JZ CHK ;Not Ready
;If Ready read the VALUE in Receive data register
mov dx , 03F8H
in al , dx
mov [di] , al
ret
ReceiveName endp

CheckReceive proc
mov dx , 3FDH ; Line Status Register
in al , dx
test al , 1
JZ CHK1 ;Not Ready'
lea di,ReceiveData
call ReceiveName
CHK1:
ret
CheckReceive endp

; chatModule proc far
; MOV AX,0600H
; MOV BH,00
; MOV CX,0
; MOV DX,184FH    ;CLEARING SCREEN
; INT 10H
; mov ah,2      
; mov dx,0a1Ah
; int 10h 

; mov ah,9      
; mov dx, offset please1
; int 21h 
; ret
; chatModule endp

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
;mov player1Name[si],'$'
mov cx,15
lea si,player1Name
lea di,InputName
SendingName:
call SendName
call ReceiveName
inc di
inc si
loop SendingName
;Printing message to notify the user to press enter to continue
mov ah,2
mov dx, 0c1Ah
int 10h
mov ah,9      
mov dx, offset connectedtoplayer
int 21h

mov ah,9      
mov dx, offset inputname
int 21h

mov ah,2
mov dx, 0d1Ah
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
mov ReceiveData,0
call CheckReceive
cmp ReceiveData,0
jne CheckReceivedData
MOV AH, 1
INT 16H
jz T

MOV AH, 0
INT 16H
cmp AH,3BH ;F1 is pressed
je ChatMode
cmp AH,3CH ;F2 is pressed
je GameMode1
cmp AH,01H ;ESC is pressed
je Escapeproc
cmp AH,86H 
jne T
jmp T

Escapeproc:
hlt

CheckReceivedData:
cmp ReceiveData,101
jne checknext1
mov ah,2
mov dx,1800h
int 10h
mov ah,9
mov dx, offset chatinviterecmsg
int 21h
mov chatinviterec,1
jmp T
checknext1:
cmp ReceiveData,111
jne checknext2
call chatModule
jmp T
GameMode1:
jmp GameMode
checknext2:
cmp ReceiveData,102
jne checknext3
mov ah,2
mov dx,1700h
int 10h
mov ah,9
mov dx, offset gameinviterecmsg
int 21h
mov gameinviterec,1
jmp T
checknext3:
cmp ReceiveData,112
jne checknext4
jmp SelectLevel
jmp T
checknext4:
jmp T

;------------------------- Chat Mode -------------------------------

ChatMode:
cmp chatinviterec,1
je acceptchatinvite
lea si,chatinvitation
call SendName
mov ah,2
mov dx,1800h
int 10h
mov ah, 9
mov dx, offset chatinvitesent
int 21h
jmp T

acceptchatinvite:
lea si,chataccepted
call SendName
call chatModule

Ret
;Chat Mode code

;------------------------- Game Mode -------------------------------
GameMode:
cmp gameinviterec,1
je acceptgameinvite
lea si,gameinvitation
call SendName
mov ah,2
mov dx,1700h
int 10h
mov ah, 9
mov dx, offset gameinvitesent
int 21h
jmp T

acceptgameinvite:
lea si,gameaccepted
call SendName
lea di,gamelevel2
call ReceiveName
cmp gamelevel2,0
je startgamelevel1
mov Level,2
startgamelevel1:
mov isplayer1,0
call StartGame

SelectLevel:
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
jne level2
mov level,1
lea si,gamelevel2
call SendName
mov isplayer1,1
call StartGame

level2:
cmp AH,3CH ;F2 is pressed
jne Escape;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; add your code
mov gamelevel2,1
lea si,gamelevel2
call SendName
mov isplayer1,1
mov level,2
call StartGame

;------------------------- End Game -------------------------------
Escape:
Ret
Modes ENDP
;------------------------------------------------------


initializeComponents proc
push si
push cx
mov player1life,3
mov player2life,3
mov cx,ObstaclesPerRow
lea si,ObstacleRow1Health
loophealth:
push ax
mov ax,1
mov [si],ax
pop ax
loop loophealth
mov cx,ObstaclesPerRow
lea si,ObstacleRow2Health
loophealth2:
push ax
mov ax,1
mov [si],ax
pop ax
loop loophealth2
mov cx,ObstaclesPerRow
lea si,ObstacleRow3Health
loophealth3:
push ax
mov ax,1
mov [si],ax
pop ax
loop loophealth3
pop cx
pop si

ret
initializeComponents endp

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
   lea di, player1msg
    loopmsg:
    mov dl,[di]
    cmp dl,0Dh
    je loopmsgend
    cmp dl,'$'
    je loopmsgend
    mov ah,2
    int 21h
    inc di
    jmp loopmsg
    loopmsgend:

    mov dh, 3 ;row
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

    mov dh, 4 ;row
   mov dl, 1 ;col
   mov ah, 2 
   int 10h
   lea di, player2msg
    loopmsg2:
    mov dl,[di]
    cmp dl,0Dh
    je loopmsg2end
    cmp dl,'$'
    je loopmsg2end
    mov ah,2
    int 21h
    inc di
    jmp loopmsg2
    loopmsg2end:

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
    push dx
    mov dh,level
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
    cmp dh,2
    je level2row2
    lea si, obstacleRow1Xpos
    jmp continuedrawing2
    level2row2:
    lea si, obstacleRow2Xpos
    continuedrawing2:

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
    cmp dh,2
    je level2row3
    lea si, obstacleRow1Xpos
    jmp continuedrawing3
    level2row3:
    lea si, obstacleRow3Xpos
    continuedrawing3:
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
    pop dx
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

FreezePlayer1 proc
  mov player1IsFrozen,1
  mov Player1MoveSpeed,0
  mov player1FreezeSeconds,0
ret
FreezePlayer1 endp

InfiniteFuelPlayer2 proc 
mov player2InfiniteFuel,1
ret
InfiniteFuelPlayer2 endp


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
jne FreezeP2
call decrementspeedplayer1

FreezeP2:
cmp bl,Freeze
jne InfiniteFuelp2
call FreezePlayer1

InfiniteFuelp2:
cmp bl,infiniteFuel
jne endeffect2
call InfiniteFuelPlayer2
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

player2hitObstacleslevel2 proc far
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
jl row2checkp2l2
mov player2drawlengthtemp,obstacleRow1Ypos
looprow1p2l2:
mov ax, player2laserx
 cmp [si],ax
 jg row2checkp2l2
 mov ax,[si]
 add ax,obstaclewidth
 cmp ax,player2laserx
 jg obstaclehitrow1p2l2
 inc si
 inc si
 inc di
 inc di
 loop looprow1p2l2
 jmp row2checkp2l2
obstaclehitrow1p2l2:
mov bx,[di]
cmp bl,1
jne row2checkp2l2
mov player2hitObstacle,1
push AX
mov ax,0
mov [di],ax
pop ax
push ax
mov ax,player2drawlengthtemp
mov player2drawlength,ax
pop ax
jmp endhitp2l2
row2checkp2l2:
mov bx,player2drawlengthtemp;;;;;;;;;;;;;;;;;;;;;;;; add
cmp bx, obstacleRow3Ypos;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; add
je endhitp2l2ex;;;;;;;;;;;;;;;;;;;;;;;; add
;cmp row2checked,1;;;;
;je endhitp2l2;;;;;
mov cx,obstaclesperrow
lea si,ObstacleRow2XPos
lea dx,obstacleSpecialeffect
lea di,ObstacleRow2Health
mov ax,player2laserlength
cmp ax,obstacleRow2Ypos
jl endhitp2l2
mov player2drawlengthtemp,obstacleRow2Ypos
looprow2p2l2:
mov ax, player2laserx
 cmp [si],ax
 jg row3checkp2l2
 mov ax,[si]
 add ax,obstaclewidth
 cmp ax,player2laserx
 jg obstaclehitrow2p2l2
 inc si
 inc si
 inc di
 inc di
 inc dx
 inc dx
 loop looprow2p2l2
 jmp row3checkp2l2
obstaclehitrow2p2l2:
push ax
mov ax,1
cmp [di],ax
pop ax
jne row3checkp2l2
mov player2hitObstacle,1
push ax
mov ax,0
mov [di],ax
pop ax
push ax
mov ax,player2drawlengthtemp
mov player2drawlength,ax
pop ax
call player2obstacleeffect
jmp endhitp2l2
endhitp2l2ex:
jmp endhitp2l2
row3checkp2l2:
mov row2checked,1
mov cx,obstaclesperrow
lea si,ObstacleRow3XPos
lea di,ObstacleRow3Health
mov ax, player2laserlength
cmp ax,obstacleRow3Ypos
jl endhitp2l2
mov player2drawlengthtemp,obstacleRow3Ypos
jmp looprow1p2l2
endhitp2l2:
mov row2checked,0
pop di
pop dx
pop cx
pop ax
pop si
pop bx
ret
player2hitObstacleslevel2 endp


HitDetectionPlayer2 proc far
    
    push dx
    mov dl,level
    cmp dl,2
    jne level1HitObtaclesPlayer2
    call player2hitObstacleslevel2
    jmp ContinueHitDetectionPlayer2
    level1HitObtaclesPlayer2:    
    call player2hitObstacles
    ContinueHitDetectionPlayer2:
    pop dx
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
     push bx
    mov bh, player2InfiniteFuel
    cmp bh,1
    je enddec2
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
    enddec2:
    pop bx
    ret
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

FreezePlayer2 proc
mov player2IsFrozen,1
mov Player2MoveSpeed,0
mov player2FreezeSeconds,0
ret
FreezePlayer2 endp

InfiniteFuelPlayer1 proc 
mov player1InfiniteFuel,1
ret
InfiniteFuelPlayer1 endp


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
jne FreezeP1
call decrementspeedplayer2

FreezeP1:
cmp bl,Freeze
jne InfiniteFuelp1
call FreezePlayer2

InfiniteFuelp1:
cmp bl,infiniteFuel
jne endeffect
call InfiniteFuelPlayer1
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

player1hitObstacleslevel2 proc far
push bx
push si
push ax
push cx
push dx
mov cx,obstaclesperrow
lea si,ObstacleRow3XPos
mov ax,200; Y at the end of the screen

sub ax,player1Laserlen; subtract the fuel*2 from the end of the screen to get the Y-position of laser 
mov player1laserlength,ax ; save the value in player1laserlength
mov player1drawlength,ax
push di
lea di,ObstacleRow3Health
cmp ax,obstacleRow3Ypos
jg row2checkl2
mov player1drawlengthtemp,obstacleRow3Ypos
looprow1l2:
mov ax, player1laserx
 cmp [si],ax
 jg row2checkl2
 mov ax,[si]
 add ax,obstaclewidth
 cmp ax,player1laserx
 jg obstaclehitrow1l2
 inc si
 inc si
 inc di
 inc di
 loop looprow1l2
 jmp row2checkl2
obstaclehitrow1l2:
mov bx,[di]
cmp bl,1
jne row2checkl2
mov player1hitObstacle,1
push ax
mov ax,0
mov [di],ax
pop ax
push ax
mov ax,player1drawlengthtemp
mov player1drawlength,ax
pop ax
jmp endhitl2
row2checkl2:
mov bx,player1drawlengthtemp;;;;;;;;;;;; add
cmp bx, obstacleRow1Ypos;;;;;;;;;;;;;;;;;;;;;; add
je endhit;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; add
;cmp row2checked,1;;;;
;je endhitl2;;;;;
mov cx,obstaclesperrow
lea si,ObstacleRow2XPos
lea dx,obstacleSpecialeffect
lea di,ObstacleRow2Health
mov ax,player1laserlength
cmp ax,obstacleRow2Ypos
jg endhitl2
mov player1drawlengthtemp,obstacleRow2Ypos

looprow2l2:
mov ax, player1laserx
 cmp [si],ax
 jg row3checkl2
 mov ax,[si]
 add ax,obstaclewidth
 cmp ax,player1laserx
 jg obstaclehitrow2l2
 inc si
 inc si
 inc di
 inc di
 inc dx
 inc dx
 loop looprow2l2
 jmp row3checkl2
obstaclehitrow2l2:
push ax
mov ax,1
cmp [di],ax
pop ax
jne row3checkl2
mov player1hitObstacle,1
push AX
mov ax,0
mov [di],ax
pop ax
call player1obstacleeffect
push ax
mov ax,player1drawlengthtemp
mov player1drawlength,ax
pop ax
jmp endhitl2
row3checkl2:
mov row2checked,1
mov cx,obstaclesperrow
lea si,ObstacleRow1XPos
lea di,ObstacleRow1Health
mov ax, player1laserlength
cmp ax,obstacleRow1Ypos
jg endhitl2
mov player1drawlengthtemp,obstacleRow1Ypos
jmp looprow1l2
endhitl2:
mov row2checked,0
pop di
pop dx
pop cx
pop ax
pop si
pop bx
ret
player1hitObstacleslevel2 endp



HitDetectionPlayer1 proc far

    push dx
    mov dl,level
    cmp dl,2
    jne level1HitObtacles
    call player1hitObstacleslevel2
    jmp ContinueHitDetectionPlayer1
    level1HitObtacles:    
    call player1hitObstacles
    ContinueHitDetectionPlayer1:
    pop dx
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
    push bx
    mov bh, player1InfiniteFuel
    cmp bh,1
    je enddec1
    mov ax,200
    sub ax,player1drawlength
    mov bl,2
    div bl

    sub player1fuel,al
    enddec1:
    pop bx
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

InGameChatRec proc far
    push cx
    push ax
    push bx
    mov cx,0
    mov dh, 4 ;row
    mov dl, 1 ;col
    mov ah, 2 
    int 10h
    lea bx,player2msg
    lea di,player2msg
    cmp isplayer1,0
    jne isp1
    mov dh, 2 ;row
    mov dl, 1 ;col
    mov ah, 2 
    int 10h
    lea bx,player1msg
    lea di,player1msg
    isp1:
    call ReceiveName
    MOV AH, 02H
    MOV DL, [di]
    mov [bx],dl
    INT 21H
    cmp cx,39
    je endofmsg
    mov ah,0dh
    cmp [di],ah
    je endofmsg
    jmp isp1
    inc di
    inc bx
    inc cx
    endofmsg:
    pop bx
    pop ax
    pop cx
    ret
InGameChatRec endp

InGameChat proc far
    push cx
    push ax
    push dx
    mov dh, 2 ;row
    mov dl, 1 ;col
    mov ah, 2 
    int 10h
    mov cx,0
    lea si,player1msg
    cmp isplayer1,0
    jne isp1e
    mov dh, 4 ;row
    mov dl, 1 ;col
    mov ah, 2 
    int 10h
    lea si,player2msg
    isp1e:
    mov ah,07
    int 21h
    mov [si],al
    MOV AH, 02H
    MOV DL, [si]
    INT 21H
    call SendName
    cmp cx,39
    je endofmsg2
    mov ah,0dh
    cmp [si],ah
    je endofmsg2
    inc si
    inc cx
    jmp isp1e
    endofmsg2:
    pop dx
    pop ax
    pop cx
    ret
InGameChat endp

CheckReceivedInput proc
cmp ReceiveData,211
jne checknextreceive1
call Player1Left
jmp endofreceiveinput
checknextreceive1:
cmp ReceiveData,212
jne checknextreceive2
call Player1Right
jmp endofreceiveinput
checknextreceive2:
cmp ReceiveData,213
jne checknextreceive3
call Player1Fire
jmp endofreceiveinput
checknextreceive3:
cmp ReceiveData,221
jne checknextreceive4
call Player2Left
jmp endofreceiveinput
checknextreceive4:
cmp ReceiveData,222
jne checknextreceive5
call Player2Right
jmp endofreceiveinput
checknextreceive5:
cmp ReceiveData,223
jne checknextreceive6
call Player2Fire
jmp endofreceiveinput
checknextreceive6:
cmp ReceiveData,230
jne checknextreceive7
call InGameChatRec
jmp endofreceiveinput
checknextreceive7:

endofreceiveinput:
ret
CheckReceivedInput endp


CheckUserInput proc far

    mov ReceiveData,0
    call CheckReceive
    cmp ReceiveData,0
    je checkbuttons
    call CheckReceivedInput
    checkbuttons:

    mov ah,1
    int 16H
    jz buttonNotPressed1                 ;if no button is pressed we jump

    ;if button is pressed we execute this code
    mov ah, 0h
    int 16h                             ;Now we store the button that was pressed in ah

    cmp isplayer1,0
    je case4

    cmp ah,Player1Left_SC
    jne case2                           ;if false skip this code and go to the next check
    call Player1Left                   ;if true do this code then return
    lea si,player1leftcode
    call SendName
    jmp buttonNotPressed                ;then after executing the code we end the procedure
    case2:
    cmp ah,Player1Right_SC
    jne case3 
    call Player1Right
    lea si,player1rightcode
    call SendName
    jmp buttonNotPressed
    case3:
    cmp ah,Player1Fire_SC
    jne case7
    call Player1Fire
    lea si,player1firecode
    call SendName
    jmp case7
    buttonNotPressed1:
    jmp buttonNotPressed
    case4: 
    cmp ah,Player1Left_SC
    jne case5 
    call Player2Left 
    lea si,player2leftcode
    call SendName
    jmp buttonNotPressed
    case5:
    cmp ah,Player1Right_SC
    jne case6 
    call Player2Right
    lea si,player2rightcode
    call SendName
    jmp buttonNotPressed
    case6:
    cmp ah,Player1Fire_SC
    jne case7
    call Player2Fire
    lea si,player2firecode
    call SendName
    jmp buttonNotPressed
    case7:                  
    cmp ah,Enterkey_SC
    jne case8
    lea si,playertyping
    call SendName
    call InGameChat
    jmp buttonNotPressed
    case8:


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

MoveObstaclesLevel2 proc far
    push si ; pushes all the registers used
    push cx
    push ax
    push dx
    push di
    lea di, obstacledirectionLevel2
    mov dx,1
    lea si,ObstacleRow1XPos ; si points at the array that contains the X-coordinates of the obstacles
    mov cx,ObstaclesPerRow ; cx will act as a counter and contains the number of obstacles in each row
    push ax
    mov ax,0
    cmp [di],ax
    pop ax 
    je increment2 ; if the direction is set to right we will increment the X-coordinate
    push ax
    mov ax,1
    cmp [di],ax 
    pop ax
    je decrement2 ; if the direction is set to left we will decrement the X-coordinate

    increment2:
    add [si],dx ; increment the X-coordinate
    inc si ; go the the X-coordiate of second obstacle
    inc si
    loop increment2 ; decrement cx and jump to increment
    dec si ; decrement Si to go to the X-coordinate of the last object
    dec si
    mov ax,[si] ; save the X-coordinate of the last object in ax
    add ax,obstaclewidth ; add the width of the object to it's X-coordinate and saves it in ax
    cmp ax,320 ; checks whether the object reached the end of the screen or not
    je setdirection2
    jne row2
    setdirection2:
    push ax
    mov ax,1
    mov [di],ax ; change the obstacles direction
    pop ax
    jmp row2

    decrement2:
    sub [si],dx ;decrement the X-coordinate
    mov ax,[si] ;; save the X-coordinate of the obstacle in ax
    cmp ax,0 ; checks whether the object has reached the end of the screen where x=0
    je reversedirection2
    jne continue2
    reversedirection2:
    push ax
    mov ax,0
    mov [di],ax ;; change the obstacles direction
    pop ax
    continue2:
    inc si
    inc si
    loop decrement2
    row2:

    inc di
    inc di
    lea si,ObstacleRow2XPos ; si points at the array that contains the X-coordinates of the obstacles
    mov cx,ObstaclesPerRow ; cx will act as a counter and contains the number of obstacles in each row
    push ax
    mov ax,0
    cmp [di],ax 
    pop ax
    je increment22 ; if the direction is set to right we will increment the X-coordinate
    push ax
    mov ax,1
    cmp [di],ax
    pop ax
    je decrement22 ; if the direction is set to left we will decrement the X-coordinate

    increment22:
    add [si],dx ; increment the X-coordinate
    inc si ; go the the X-coordiate of second obstacle
    inc si
    loop increment22 ; decrement cx and jump to increment
    dec si ; decrement Si to go to the X-coordinate of the last object
    dec si
    mov ax,[si] ; save the X-coordinate of the last object in ax
    add ax,obstaclewidth ; add the width of the object to it's X-coordinate and saves it in ax
    cmp ax,320 ; checks whether the object reached the end of the screen or not
    je setdirection22
    jne row3
    setdirection22:
    push ax
    mov ax,1
    mov [di],ax ; change the obstacles direction
    pop ax
    jmp row3
    decrement22:
    sub [si],dx ;decrement the X-coordinate
    mov ax,[si] ;; save the X-coordinate of the obstacle in ax
    cmp ax,0 ; checks whether the object has reached the end of the screen where x=0
    je reversedirection22
    jne continue22
    reversedirection22:
    push ax
    mov ax,0
    mov [di],ax ;; change the obstacles direction
    pop ax
    continue22:
    inc si
    inc si
    loop decrement22

    row3:

    inc di
    inc di
    lea si,ObstacleRow3XPos ; si points at the array that contains the X-coordinates of the obstacles
    mov cx,ObstaclesPerRow ; cx will act as a counter and contains the number of obstacles in each row
    push ax
    mov ax,0
    cmp [di],ax
    pop ax 
    je increment23 ; if the direction is set to right we will increment the X-coordinate
    push ax
    mov ax,1
    cmp [di],ax
    pop ax
    je decrement23 ; if the direction is set to left we will decrement the X-coordinate

    increment23:
    add [si],dx ; increment the X-coordinate
    inc si ; go the the X-coordiate of second obstacle
    inc si
    loop increment23 ; decrement cx and jump to increment
    dec si ; decrement Si to go to the X-coordinate of the last object
    dec si
    mov ax,[si] ; save the X-coordinate of the last object in ax
    add ax,obstaclewidth ; add the width of the object to it's X-coordinate and saves it in ax
    cmp ax,320 ; checks whether the object reached the end of the screen or not
    je setdirection23
    jne endyy2
    setdirection23:
    push ax
    mov ax,1
    mov [di],ax ; change the obstacles direction
    pop ax
    jmp endyy2

    decrement23:
    sub [si],dx ;decrement the X-coordinate
    mov ax,[si] ;; save the X-coordinate of the obstacle in ax
    cmp ax,0 ; checks whether the object has reached the end of the screen where x=0
    je reversedirection23
    jne continue23
    reversedirection23:
    push ax
    mov ax,0
    mov [di],ax ;; change the obstacles direction
    pop ax
    continue23:
    inc si
    inc si
    loop decrement23

    endyy2:
    pop di
    pop dx
    pop ax 
    pop cx
    pop si ; we pop the registers that we used to get their original values
    ret
MoveObstaclesLevel2 endp


IncrementFuel proc far
    push ax
    push bx
    mov ah,player1InfiniteFuel
    cmp ah,1
    je countfivesecondsPlayer1
    mov al,FuelPerSecond    ;Every second this code runs to replenish the fuel of the ships by 10
    cmp Player1Fuel,100     ;Check if fuel is full
    jge maxfuelplayer1     ;if full jump to next player
    add Player1Fuel,al      ;if not fill the fuel
    fillplayer2fuel:
    mov ah,player2InfiniteFuel
    cmp ah,1
    je countfivesecondsPlayer2
    cmp Player2Fuel,100
    jge maxfuel
   
    add Player2Fuel,al
    jmp endofIncrementFuel
    maxfuelplayer1:
    mov Player1Fuel,100
    jmp fillplayer2fuel
    maxfuel:
    mov Player2Fuel,100
    jmp endofIncrementFuel

    countfivesecondsPlayer1:
    mov bl,player1InfiniteFuelseconds
    inc player1InfiniteFuelseconds
    cmp bl,5
    jl maxfuelplayer1
    mov player1InfiniteFuel,0
    mov player1InfiniteFuelseconds,0
    mov player1fuel,50
    jmp fillplayer2fuel


    countfivesecondsPlayer2:
    mov bl,player2InfiniteFuelseconds
    inc player2InfiniteFuelseconds
    cmp bl,5
    jl maxfuel
    mov player2InfiniteFuel,0
    mov player2InfiniteFuelseconds,0
    mov player2fuel,50

    
    endofIncrementFuel:

    pop bx
    pop ax
    ret
IncrementFuel endp

playersSpeed proc
    push ax
    inc player1slowspeedseconds
    inc player2slowspeedseconds
    inc player1FreezeSeconds
    inc player2FreezeSeconds
    mov al,player1slowspeedseconds
    cmp al,5
    je setplayer1speed
    mov al, player1FreezeSeconds
    cmp al,5
    je setplayer1speed
    checkplayer2speed:
    mov al,player2slowspeedseconds
    cmp al,5
    je setplayer2speed
    mov al, player2FreezeSeconds
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
    push ax
    call CheckUserInput
    call CheckTimeFunctions
    mov al,level
    cmp al,2
    je level2MoveObstacles
    call MoveObstacles
    jmp ContinueGameLoop
    level2MoveObstacles:
    call MoveObstaclesLevel2
    ContinueGameLoop:
    cmp player1life,0
    jne next1
    call endgame
    next1:
    cmp player2life,0
    jne next2
    call endgame
    next2:
    pop ax
    ret
MainGameLoop endp

StartGame proc near
pushf

;;Switch to video mode
mov ah,0
mov al,13h
int 10h
cmp isplayer1,0
jne GameLoop
mov cx,15
lea di,player1Name
lea si,player2Name
swtichname1:
mov ax,[di]
mov [si],ax
inc di
inc si
loop swtichname1
mov cx,15
lea di,InputName
lea si,player1Name
swtichname2:
mov ax,[di]
mov [si],ax
inc di
inc si
loop swtichname2
mov cx,15
lea di,Player2Name
lea si,InputName
swtichname3:
mov ax,[di]
mov [si],ax
inc di
inc si
loop swtichname3
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

;;Intializing Serial Conneciton
;;Configure the Connection
mov dx,3fbh 			; Line Control Register
mov al,10000000b		;Set Divisor Latch Access Bit
out dx,al			;Out it

mov dx,3f8h	   ;set lsb byte of the baud rate devisor latch register	
mov al,0ch			
out dx,al

mov dx,3f9h    ;set msb byte of the baud rate devisor latch register
mov al,00h     ;to ensure no garbage in msb it should be setted
out dx,al

mov dx,3fbh ;used for send and receive
mov al,00011011b
out dx,al
;----------------


;=====================
call FirstMenu
call MainMenu
call Modes

hlt
main endp
end main

