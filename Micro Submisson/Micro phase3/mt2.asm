EXTRN player1Name:BYTE
EXTRN InputName:BYTE
PUBLIC ChatModule

.model small
.stack
.386
.data
CHATend			DB		'TO EXIT CHAT PRESS esc $'


valuesent db 's'
valuereceived db 'R'
p1cursorx db 0
p1cursory db 2
p2cursorx db 0
p2cursory db 15
postionplayer1 equ 1
postionplayer2 equ 2

;https://www.coursehero.com/file/43809748/scrollasm/

.code      

ChatModule proc far    
	mov ax,@data
	mov ds,ax
	
    call drawchat
	call portinitialization
	
	
	Again:	
		call sending
		call Receiving
		jmp Again

Finish:	
mov ah,4Ch
int 21h
ret
ChatModule endp
portinitialization proc
		
		mov dx,3fbh 			; Line Control Register
		mov al,10000000b		;Set Divisor Latch Access Bit
		out dx,al	
		
		mov dx,3f8h				;set lsb of baud rate divisor
		mov al,0ch			
		out dx,al
		
		mov dx,3f9h				;set msb of baud rate divisor
		mov al,00h
		out dx,al
		
		mov dx,3fbh
		mov al,00011011b   ;can change 
		out dx,al

		ret
portinitialization endp

drawchat proc
		
		MOV AH,0						;CHANGE TO GRAPHICS MODE
		MOV AL,0EH						
		INT 10H	
		
		mov bh,00
		mov AH,0CH						;draw pixel int condition
		mov al,0Bh          			;set the  colour
		mov dx,99    
		
		line1: ; drawing separte line
			mov cx,04
			line2:
				int 10h
				inc cx
				cmp cx,636  
			jne line2
			inc dx
			cmp dx,100
		jne line1
		
		mov ah,2                		;move cursor 
	                        ; x,y cordinate of name 
		mov dx,0003h                     ; x,y cordinate of name 
		int 10h
		
		mov ah,09
		mov dx,offset player1name 
		int 21h
		
		mov ah,2                		;move cursor 
		
		mov dx,0003h             
		add dl,player1name+1	       ;shift after name 
		int 10h
		
		
		
		mov ah,2             		    ;move cursor 
		mov dx,0D03h         		    ; x,y cordinate of name2
		int 10h
		
		mov ah,09
		mov dx,offset InputName  ;display name2
		int 21h
		
		mov ah,2               		    ;move cursor 
	    mov dx,0D53h            		
		add dl,InputName+1			;add playername length to shift
		int 10h
		
		
		
		mov ah,2             		    ;move cursor 
		mov bh,0
		mov dx,181Eh         		    
		int 10h
		
		mov ah,09
		mov dx,offset chatend          ; display endchat 
		int 21h
		
		mov bh,00
		mov AH,0CH						
		mov al,0Ah          			;set olour
		mov dx,190    
		
		
		
		
		ret
drawchat endp
write proc
	
		
	    cmp bl,postionplayer1  ; prrint up
        JNE secondhalf		
		
		
		cmp p1cursorx,80   ;max x
		 je nextpostion1
		
		mov dl,p1cursorx
		mov dh,p1cursory
		inc p1cursorx
		JMP Cursor_move
		
	nextpostion1:
        inc p1cursory   ;=next line
		cmp p1cursory,12 ;fullscreen
		jne DonotScrollUp
		
		 mov dh,p1cursory
        mov dl,p1cursorx
     mov ah,6       ; function 6
		mov al,1        ; scroll by 1 line    
		mov bh,0       ; normal video attribute         
		mov ch,1       ; upper left Y
		mov cl,0        ; upper left X
		mov dh,11     ; lower right Y
		mov dl,79   ; lower right X 
		int 10h 
		mov dh,p1cursory
        mov dl,p1cursorx
		mov dh,11
       
		mov p1cursory,dh
        mov p1cursorx,dl
		
		
	DonotScrollUp:	
		MOV p1cursorx,0 
		mov dl,p1cursorx
		mov dh,p1cursory
		
		inc p1cursorx
		JMP Cursor_move
		
	secondhalf:
		cmp p2cursorx,80;  max x 
		je nextpostion2
		
		mov dl,p2cursorx
		mov dh,p2cursory 
		inc p2cursorx
		jmp Cursor_move
	nextpostion2:
		inc p2cursory
		cmp p2cursory,25
		jne DonotScrollDown
		
		mov dh,p2cursory
        mov dl,p2cursorx
     mov ah,6       ; function 6
		mov al,1        ; scroll by 1 line    
		mov bh,0       ; normal video attribute         
		mov ch,1       ; upper left Y
		mov cl,0        ; upper left X
		mov dh,22    ; lower right Y
		mov dl,79    ; lower right X 
		int 10h 
		mov dh,p2cursory
        mov dl,p2cursorx
		mov dh,22
       
		mov p2cursory,dh
        mov p2cursorx,dl
	DonotScrollDown:
		MOV p2cursorx,0	
	    mov dl,p2cursorx
		mov dh,p2cursory
		inc p2cursorx
		
		Cursor_move:
		mov ah,2 
		mov bh,0
		int 10h   
		
	
	    cmp bl,postionplayer1  
        JNE Down1
		mov dl,valuesent
		jmp PrintLabel	
		
	Down1:	
		mov dl,valuereceived
		
	PrintLabel:	
		mov ah, 2
        int 21h 

	

ret
write endp
Sending proc
	
	    
	   
		mov ah,1
		int 16h
		jz RetrunSend 
		;; if keypress then send it and print it
		mov ah,0
		int 16h
		mov valuesent,al
		
	Againchecking:	
		;;checking transmitter holding register
		mov dx , 3FDH  ; Line Status Register
		In al , dx    ;Read Line Status
		and al , 00100000b
		JZ  Againchecking        ;Not empty 
        
       
		
		
		;put the VALUE in Transmit data register
		mov dx , 3F8H  ; Transmit data register
		mov  al,valuesent
		out dx , al 
		
		cmp al,27        ;check esc
		je Finish        ;end
		
		
		cmp ah, 1ch ;check enter
		jne noscroll
		mov p1cursorx, -1	
		inc p1cursory

		cmp p1cursory,12    ;if fullscren
		jne noscroll
        mov dh,p1cursory
        mov dl,p1cursorx
     mov ah,6       ; function 6
		mov al,1        ; scroll by 1 line    
		mov bh,0       ; normal video attribute         
		mov ch,1       ; upper left Y
		mov cl,0        ; upper left X
		mov dh,11     ; lower right Y
		mov dl,79    ; lower right X 
		int 10h 
		mov dh,p1cursory
        mov dl,p1cursorx
		mov dh,11
       
		mov p1cursory,dh
        mov p1cursorx,dl
		
		
		
       


		jmp dummy001
		noscroll:

		
		cmp ah, 0eh 	;delete check
		jne dummy001
		cmp p1cursorx, 0
		jne xnotequal0
		
		cmp p1cursory, 0
		jne ynotequal0
		;x=0,y=0
		ret
		ynotequal0:
		;in x = 0 but y != 0
		mov p1cursorx, 79
		dec p1cursory
		mov ah, 2
		mov dl, p1cursorx
		mov dh, p1cursory
		int 10h
		
		mov ah, 2
		mov dl, 20h
		int 21h
		ret
		xnotequal0:
		dec p1cursorx
		mov ah, 2
		mov dl, p1cursorx
		mov dh, p1cursory
		int 10h
		mov ah, 2
		mov dl, 20h
		int 21h
		
		ret
		dummy001:

	
        
		mov bl,postionplayer1
		call write  ;display
	
RetrunSend:
ret
Sending endp

Receiving proc
	
		
		mov dx , 3FDH  ; Line Status Register
		in al , dx     ; check ready
		and al , 1
		JZ norecive            ;Not Ready 
		
		 ;put valuereceived in Receive data register
		 mov dx , 03F8H     
		 in al , dx      
		 mov valuereceived , al 
		
		 
		 cmp al,27 ; check esc
		 je Finish ;end 
	 
	 	
		cmp al, 0Dh ; check enter key 
		jne noscroll2
		mov p2cursorx, -1	;
		inc p2cursory

		cmp p2cursory, 25 ; fullscreen
		jne noscroll2
		
		   mov dh,p2cursory
        mov dl,p2cursorx
     mov ah,6       ; function 6
		mov al,1        ; scroll by 1 line    
		mov bh,0       ; normal video attribute         
		mov ch,14      ; upper left Y
		mov cl,0        ; upper left X
		mov dh,22    ; lower right Y
		mov dl,79    ; lower right X 
		int 10h 
		mov dh,p2cursory
        mov dl,p2cursorx
		mov dh,22
       
		mov p2cursory,dh
        mov p2cursorx,dl

		jmp Deletedum
		noscroll2:

		
		cmp al, 08h 	;delete checck
		jne Deletedum
		cmp p2cursorx, 0
		jne xnotequal00
		
		cmp p2cursory, 0
		jne ynotequal00
		
		ret
		ynotequal00:
		;x,y=0
		mov p2cursorx, 79
		dec p2cursory
		mov ah, 2
		mov dl, p2cursorx
		mov dh, p2cursory
		int 10h
		
		mov ah, 2
		mov dl, 20h
		int 21h
		ret
		xnotequal00:
		dec p2cursorx
		mov ah, 2
		mov dl, p2cursorx
		mov dh, p2cursory
		int 10h
		
		mov ah, 2
		mov dl, 20h
		int 21h
		
		ret
		Deletedum:

		 mov bl,postionplayer2
		 call write
		
	
norecive:
ret
Receiving endp






Torecieve Proc

        ;is Ready
		mov dx , 3FDH  ; Line Status Register
		in al , dx  
		test al , 1
		JZ noreciving           ;Not Ready 
		
		 ;ready so put VALUE in Receive data register
		 mov dx , 03F8H     
		 in al , dx      
		 mov valuereceived , al 
		
        noreciving:
Torecieve Endp

Tosend Proc

 ;check_buffer
		mov ah,1
		int 16h
		jz RetrunSend	
		mov ah,0
		int 16h
		mov valueSent,al
		
	CheckAgain:	
		;Check that Transmitter Holding Register is Empty
		mov dx , 3FDH  ; Line Status Register
		In al , dx    ;Read Line Status
		test al , 00100000b
		JZ  CheckAgain        ;Not empty 
		
		
		;If empty put the VALUE in Transmit data register
		mov dx , 3F8H  ; Transmit data register
		mov  al,valueSent
		out dx , al 
Tosend Endp


end