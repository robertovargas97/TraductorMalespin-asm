;Traductor de Malespin


.model small
.386
.stack 100h

.data
msgOp            db    10,13,10,13,'OPCION INCORRECTA$',10,13
msgIntrucciones  db    10,13,10,13,'INFORMACION',10,13,'SE TRABAJA CON LETRAS MINUSCULAS',10,13,'LOS CAMBIOS QUE REALIZA LA TRADUCCION DE ESPANOL A MALESPIN O VICEVERSA SON :',10,13,10,13,'a por e y viceversa',10,13,'i por o y viceversa',10,13,'b por t y viceversa',10,13,'f por g y viceversa',10,13,'p por m y viceversa',10,13,'s por c y viceversa$',10,13
msgExt           db    10,13,10,13,'HAS PRESIONADO ESC , SALISTE DEL PROGRAMA$'
msgSeguir        db    10,13,10,13,'SI DESEA SALIR PRESIONE ESC SINO PRESIONE CUALQUIER TECLA PARA TRADUCIR ' ,10,13,'UNA PALABRA$',10,13
msgError         db        10,13,'Has sobrepasado el limite de 50 caracteres en la frase',10,13,'Presiona una tecla para continuar...$',10,13
msgInicio        db        10,13,,10,13,'Ingrese la frase o palabra que desea traducir',10,13,'Presione ENTER al terminar de digitar la frase o palabra...$',10,13
msgIntroductorio db    10,13,'Bienvenido al traductor de Malespin a Espanol$',10,13
msgEleccion      db        10,13,10,13,'Digite 1 para traducir una frase de Malespin a Espanol ',10,13,'Digite 2 para traducir una frase de Espanol a Malespin: $',10,13
fraseMalespin    db        10,13,10,13,'Malespin: $',10,13
fraseEspa?ol     db        10,13,10,13,'Espanol: $',10,13
frase            db        80 Dup('$')
cont             dw        0

.code

main proc



 mov ax,@data
 mov ds,ax
 
 call mensajeIntro
 call fraseInstru
 
inicio: 
 call mensajeEl
 cmp al,49
 je uno
 cmp al,50
 je dos
 cmp al,1bh
 je salida
 call errorOp
 jg repetir
 
uno:
 call mensajeInicial
 call fraseMal
 call leerFrase
 cmp al,1bh
 je salida
 call fraseEsp
 call traducirFrase
 call imprimirFrase
 jmp  repetir
 
dos:
 call mensajeInicial
 call fraseEsp
 call leerFrase
 cmp al,1bh
 je salida
 call fraseMal
 call traducirFrase
 call imprimirFrase
 
repetir:   
   mov ah,9             ;Carga servicio 9 para leer cadenas
   lea dx,msgSeguir     ;Se carga el MSJ para seguir
   int 21h              ;Imprimimos el mensaje 
   mov ah,8             ;Servicio 8 lee un caracter sin eco(no se imprime en pantalla), crea el efecto de presiona una tecla para continuar...
   int 21h
   cmp al,1bh
   je salida
   cmp al,1bh
   je salida
   call limpiarFrase
   jmp inicio
   
salida:

 mov ah,9           ;Carga servicio 9 para leer cadenas
 lea dx,msgExt      ;Se carga el mensaje de no digitos ingresados
 int 21h 
 
finalizar:                    ;FIN DEL PROGRAMA
  mov ah,4ch
  int 21h 
 
main endp
;------------------------------------------------------------------------------------------------------------------------------------------

;-----------------------------------------------Lectura de Frase---------------------------------------------------------------------------
leerFrase proc near
    mov si,0     ;Contara la cantidad de veces que el usuario ingresa un caracter para la frase
    
leer: 
    mov ah,1            ;Servicio uno para pedir caracter
    cmp si,80           ;Si se llego al maximo permitido
    jge errorMax
    int 21h 
    cmp al,0Dh          ;Si la persona pulsa enter
    je fin
    cmp al,1bh
    je fin    
   
    mov frase[si],al    ;Llena el vector del numerador1
    inc si
    inc cont
    jmp leer 
    
errorFrase:
    call errorMax
      
fin:

    RET
leerFrase endp
;--------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------Mensaje de error----------------------------------------------------------------------------
errorMax proc near
 mov ah,9           ;Carga servicio 9 para leer cadenas
 lea dx,msgError    ;Se carga el mensaje de no digitos ingresados
 int 21h
 mov ah,8           ;Servicio 8 lee un caracter sin eco(no se imprime en pantalla), crea el efecto de presiona una tecla para continuar...
 int 21h

RET 
errorMax endp
;-------------------------------------------------------------------------------------------------------------------------------------------

errorOp proc near
 mov ah,9           ;Carga servicio 9 para leer cadenas
 lea dx,msgOp       ;Se carga el mensaje de opcion
 int 21h
RET 
errorOp endp
;------------------------------------------------Mensaje de  Intro----------------------------------------------------------------------------
mensajeIntro proc near
 mov ah,9                   ;Carga servicio 9 para leer cadenas
 lea dx,msgIntroductorio    ;Se carga el mensaje de Intro
 int 21h
 
 RET 
mensajeIntro endp

mensajeEl proc near
 mov ah,9                   ;Carga servicio 9 para leer cadenas
 lea dx, msgEleccion       ;Se carga el mensaje de Eleccion de 
 int 21h

 mov ah,1            ;Servicio uno para pedir caracter
 int 21h 
 
RET 
mensajeEl endp
;-------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------Mensaje de info----------------------------------------------------------------------------
mensajeInicial proc near
 mov ah,9            ;Carga servicio 9 para leer cadenas
 lea dx,msgInicio    ;Se carga el mensaje de no digitos ingresados
 int 21h
 
RET 
mensajeInicial endp
;-------------------------------------------------------------------------------------------------------------------------------------------- 
fraseMal proc near
 mov ah,9 
 lea dx,fraseMalespin    ;Se carga el mensaje de frase en malespin
 int 21h
 
 RET
 fraseMal endp

;-------------------------------------------------------------------------------------------------------------------------------------------
fraseInstru proc near
     mov ah,9              ;Carga servicio 9 para leer cadenas
     lea dx,msgIntrucciones   ;Se carga el mensaje de traduccion
     int 21h
RET 
fraseInstru endp


fraseEsp proc near
     mov ah,9              ;Carga servicio 9 para leer cadenas
     lea dx,fraseEspa?ol   ;Se carga el mensaje de traduccion
     int 21h
RET 
fraseEsp endp

;---------------------------------------------Impresion de la frase-------------------------------------------------------------------------
imprimirFrase proc near
     xor si,si             ;Limpio SI
     mov si,0              ;Inicializo SI
    
imprime:
     cmp frase[si],'$'  ;Como el vector se inicializa con $ al llegar a este caracter quiere decir que se acabo la frase ingresada
     je salir
     mov ah,2           ;Servicio 2 para mostrar caracter     
     mov dl,frase [si]  ;Se mueve a dl el caracter del vector en la posicion SI para mostrarlo      
     int 21h            ;Se muestra en pantalla
     inc si
     jmp imprime
     
salir:

  RET
imprimirFrase endp

;---------------------------------------------Limpiar frase-------------------------------------------------------------------------
limpiarFrase proc near
     xor si,si             ;Limpio SI
     mov si,0              ;Inicializo SI
    
limpia:
    cmp si,cont
    jge exit   
    mov frase [si],'$'  ;Se mueve a dl el caracter del vector en la posicion SI para mostrarlo      
    inc si
    jmp limpia
  
exit:
  RET
limpiarFrase endp

;-----------------------------------Desencriptacion de malespint a espa?ol--------------------------------------------------------------------

traducirFrase proc near
    mov si,0
    
traducir:
     cmp frase[si],'$'  ;Como el vector se inicializa con $ al llegar a este caracter quiere decir que se acabo la frase ingresada
     je salir
     
     cmp frase[si],'a'
     je cambiea
     
     cmp frase[si],'e'
     je cambiee
     
     cmp frase[si],'i'
     je cambiei
     
     cmp frase[si],'o'
     je cambieo
     
     cmp frase[si],'b'
     je cambieb
     
     cmp frase[si],'t'
     je cambiet
     
     cmp frase[si],'f'
     je cambief
     
     cmp frase[si],'g'
     je cambieg
     
     cmp frase[si],'p'
     je cambiep
     
     cmp frase[si],'m'
     je cambiem
     
     cmp frase[si],'c'
     je cambiec
     
     cmp frase[si],'s'
     je cambies
    
     jmp siga
     
cambiea:
   mov frase[si],'e'
   jmp siga 

cambiee:
   mov frase[si],'a'
   jmp siga 
   
cambiei:
   mov frase[si],'o'
   jmp siga 
   
cambieo:
   mov frase[si],'i'
   jmp siga 
   
cambieb:
   mov frase[si],'t'
   jmp siga 
   
cambiet:
   mov frase[si],'b'
   jmp siga
   
cambief:
   mov frase[si],'g'
   jmp siga
   
cambieg:
   mov frase[si],'f'
   jmp siga
   
cambiep:
   mov frase[si],'m'
   jmp siga
   
cambiem:
   mov frase[si],'p'
   jmp siga
   
cambiec:
   mov frase[si],'s'
   jmp siga
   
cambies:
   mov frase[si],'c'
   jmp siga
     
siga: 
    inc si
    jmp traducir

slr:

  RET
traducirFrase endp

;---------------------------------------------------------------------------------------------------------------------------------------------
colocar_cursor proc
    mov ah,2
    mov bh,0
    int 10h
    
RET

colocar_cursor endp
;---------------------------------------------------------------------------------------------------------------------------------
colocar_posicion proc
    mov dl,0        ;Columna
    mov dh,0           ;Fila
RET

colocar_posicion endp

end main


