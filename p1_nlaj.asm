title "Proyecto: Snake" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
    .model small    ;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
    .386            ;directiva para indicar version del procesador
    .stack 64       ;Define el tamano del segmento de stack, se mide en bytes
    .data           ;Definicion del segmento de datos
  
;Texto game over
gameOverStr     db      "  G A M E   O V E R  "
    
;Titulo
snakeGiga1      db      " SSSS  N   N   AAA   K  K  EEEEE  "
snakeGiga2      db      " S      NN  N  A   A  K K   E      "
snakeGiga3      db      "  SSS   N N N  AAAAA  KK    EEE    "
snakeGiga4      db      "     S  N  NN  A   A  K K   E      "
snakeGiga5      db      " SSSS  N   N  A   A  K  K  EEEEE  "

;Opciones
opcionJugarStr  db      "[ JUGAR ]", "$"
opcionInstStr   db      "[ INSTRUCCIONES ]", "$"
opcionSalirStr  db      "[ SALIR ]", "$"


;Manual
instMenuTitulo   db      "--- MANUAL: BOTONES DE JUEGO ---", "$"
instFlechas      db      "FLECHAS TECLADO: Mueven a la serpiente (Arriba, Abajo, Izq, Der)", "$"
instBotIniciar   db      "BOTON [ INICIAR ]: Arranca el movimiento de la serpiente", "$"
instBotPausa     db      "BOTON [ PAUSA ]: Congela el juego temporalmente sin perder", "$"
instBotStop      db      "BOTON [ STOP ]: Detiene la partida actual", "$"
instFlechasSpeed db      "FLECHAS [ SPEED ]: Hacen clic en [+] o [-] para graduar el ritmo", "$"
btnVolverStr     db      "[ Volver ]", "$"  ; Bot?n interactivo para el mouse

;Notas musicales que se usaran
NOTE_C4  equ 261
NOTE_D4  equ 293
NOTE_E4  equ 329
NOTE_F4  equ 349
NOTE_G4  equ 392
NOTE_A4  equ 440
NOTE_B4  equ 493
NOTE_C5  equ 523
NOTE_E5  equ 659
NOTE_G5  equ 784


;Musica menu y manual
musica_menu      dw NOTE_C4, 25, NOTE_E4, 25, NOTE_G4, 25, NOTE_C5, 25
                 dw NOTE_G4, 25, NOTE_E4, 25, NOTE_C4, 40, 0


;Musica comer fruta
musica_comer     dw NOTE_G4, 4, NOTE_C5, 8, 0


;Musica game over
musica_gameover  dw NOTE_E4, 40, NOTE_D4, 40, NOTE_C4, 60, 0


;Musica nuevo record
musica_record    dw NOTE_C4, 15, NOTE_C4, 15, NOTE_C4, 15, NOTE_C4, 30
                 dw NOTE_G4, 30, NOTE_A4, 20, NOTE_A4, 20, NOTE_C5, 60, 0


;Color dinamico para la serpiente
serpiente_color_actual  db  0Ah  ; Comienza en verde brillante (0Ah)

;Restriccion de giro
ya_giro         db      0                   ; 0 = Puede girar, 1 = Ya gir? en este turno, bloquea m?s cambios


status          db      0       ; 0 stop-pause, 1 activo
partida_iniciada db     0       ; 0 = A?n no le da START, 1 = Ya inici? el juego


; --- CONFIGURACI?N DE FRUTAS ---
CANT_FRUTAS     equ     3                   ; Controla cu?ntas hay a la vez


; === MODIFICACI?N EXTRA: CONTADOR PARA INCREMENTAR VELOCIDAD ===
frutas_contador db      0                   ; Cuenta de 0 a 5 para el aumento de velocidad


; Estos son los arreglos que guardar?n las posiciones en memoria
frutas_renglon   db      CANT_FRUTAS dup(0)
frutas_columna   db      CANT_FRUTAS dup(0)
frutaIcon       db      "O"


; =========================================================================
;   NUEVO CAT?LOGO DE COLORES Y FIGURAS M?S COLORIDO
; =========================================================================
; Cat?logo de figuras (puedes mantener las que te gusten)
lista_figuras       db      03h, 04h, 05h, 06h, 40h    ; Coraz?n, Diamante, Tr?bol, Espada, @


; Lista con colores muy llamativos en fondo negro:
; 0Ah = Verde brillante, 0Ch = Rojo brillante, 09h = Azul brillante, 
; 0Eh = Amarillo/Naranja, 0Dh = Rosa/Magenta brillante
lista_colores       db      0Ah, 0Ch, 09h, 0Eh, 0Dh    


; Variables de control que ya usas:
fruta_actual_icono  db      03h
fruta_actual_color  db      0Ch                        ; Rojo por defecto


; === VARIABLES PARA GUARDAR EL R?CORD EN DISCO ===
archivo_nombre  db      "record.dat",0      ; Nombre del archivo en disco (debe terminar en 0)
archivo_handle  dw      0                   ; Identificador del archivo abierto
buffer_record   db      3 dup(' '), 2 dup(0) ; B?fer para leer/escribir (3 bytes nombre + 2 bytes score)



;Definici?n de constantes
;Valor ASCII de caracteres para el marco del programa
marcoEsqInfIzq      equ     200d    ;'?'
marcoEsqInfDer      equ     188d    ;'?'
marcoEsqSupDer      equ     187d    ;'?'
marcoEsqSupIzq      equ     201d    ;'?'
marcoCruceVerSup    equ     203d    ;'?'
marcoCruceHorDer    equ     185d    ;'?'
marcoCruceVerInf    equ     202d    ;'?'
marcoCruceHorIzq    equ     204d    ;'?'
marcoCruce          equ     206d    ;'?'
marcoHor            equ     205d    ;'?'
marcoVer            equ     186d    ;'?'
;Atributos de color de BIOS
;Valores de color para car?cter
cNegro          equ     00h
cAzul           equ     01h
cVerde          equ     02h
cCyan           equ     03h
cRojo           equ     04h
cMagenta        equ     05h
cCafe           equ     06h
cGrisClaro      equ     07h
cGrisOscuro     equ     08h
cAzulClaro      equ     09h
cVerdeClaro     equ     0Ah
cCyanClaro      equ     0Bh
cRojoClaro      equ     0Ch
cMagentaClaro   equ     0Dh
cAmarillo       equ     0Eh
cBlanco         equ     0Fh
;Valores de color para fondo de car?cter
bgNegro         equ     00h
bgAzul          equ     10h
bgVerde         equ     20h
bgCyan          equ     30h
bgRojo          equ     40h
bgMagenta       equ     50h
bgCafe          equ     60h
bgGrisClaro     equ     70h
bgGrisOscuro    equ     80h
bgAzulClaro     equ     90h
bgVerdeClaro    equ     0A0h
bgCyanClaro     equ     0B0h
bgRojoClaro     equ     0C0h
bgMagentaClaro  equ     0D0h
bgAmarillo      equ     0E0h
bgBlanco        equ     0F0h


;N?mero de columnas para el area de controles
area_controles_ancho        equ     20d


;Definicion de variables
;T?tulos
nameStr         db      "SNAKE"
recordStr       db      "HI-SCORE"
scoreStr        db      "SCORE"
levelStr        db      "LEVEL"
speedStr        db      "SPEED"


;Variables para nombre en high score
hiScorePlayer   db      "---"
tempPlayer      db      3 dup(' ')
recordNuevoStr  db      "?NUEVO RECORD! INICIALES (3): "


;Variables auxiliares para posicionar cursor al imprimir en pantalla
col_aux         db      0
ren_aux         db      0


conta           db      0       ;contador auxiliar
tick_ms         dw      55      ;55 ms por cada tick del sistema, esta variable se usa para operaci?n de MUL convertir ticks a segundos
mil             dw      1000    ;dato de valor decimal 1000 para operaci?n DIV entre 1000
diez            dw      10      ;dato de valor decimal 10 para operaci?n DIV entre 10
sesenta         db      60      ;dato de valor decimal 60 para operaci?n DIV entre 60


;Variables para el juego
score           dw      0
hi_score        dw      0
speed           db      0


;Variable 'head' de 16 bits. Datos de la cabeza de la serpiente
;Valor inicial: 00 00 0010111 01100b
head            dw      0000001011101100b
;Bits 0-4: Posici?n del rengl?n (0-24d)
;Bits 5-11: Posici?n de la columna (0-79d)
;Bits 12-13: Direcci?n del siguiente movimiento
    ;00: derecha
    ;01: arriba
    ;10: izquierda
    ;11: abajo
;Bits 14-15: No definidos
;Posici?n inicial: rengl?n 12, columna 23, direcci?n derecha


;Datos de la cola de la serpiente
;los primeros dos valores son fijos y se imprimen al inicio del juego
;el resto se deben calcular conforme avanza el juego
;El primer elemento del arreglo 'tail' es el extremo de la cola, el siguiente es el m?s cercano a la cola, y as? sucesivamente.
tail            dw      0000001010101100b,0000001011001100b,1355 dup(0)
tail_conta      dw      2   ;contador para la longitud de la cola


;variables para las coordenadas del objeto actual en pantalla
item_col        db      50      ;columna
item_ren        db      16      ;renglon


;Variables que sirven de parametros para el procedimiento IMPRIME_BOTON
boton_caracter  db      0       ;caracter a imprimir
boton_renglon   db      0       ;renglon de la posicion inicial del boton
boton_columna   db      0       ;columna de la posicion inicial del boton
boton_color     db      0       ;color del caracter a imprimir dentro del boton
boton_bg_color  db      0       ;color del fondo del boton


;Auxiliar para calculo de coordenadas del mouse
ocho            db      8
;Cuando el driver del mouse no esta disponible
no_mouse        db  'No se encuentra driver de mouse. Presione [enter] para salir$'


;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;Macros;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
;clear - Limpia pantalla
clear macro
    mov ax,0003h    ;ah = 00h, selecciona modo video
                    ;al = 03h. Modo texto, 16 colores
    int 10h     ;llama interrupcion 10h con opcion 00h. 
                ;Establece modo de video limpiando pantalla
endm


;posiciona_cursor - Cambia la posici?n del cursor a la especificada con 'renglon' y 'columna' 
posiciona_cursor macro renglon,columna
    mov dh,renglon  ;dh = renglon
    mov dl,columna  ;dl = columna
    mov bx,0
    mov ax,0200h    ;preparar ax para interrupcion, opcion 02h
    int 10h         ;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm 


;inicializa_ds_es - Inicializa el valor del registro DS y ES
inicializa_ds_es    macro
    mov ax,@data
    mov ds,ax
    mov es,ax       ;Este registro se va a usar, junto con BP, para imprimir cadenas utilizando interrupci?n 10h
endm


;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
muestra_cursor_mouse    macro
    mov ax,1        ;opcion 0001h
    int 33h         ;int 33h para manejo del mouse. Opcion AX=0001h
                    ;Habilita la visibilidad del cursor del mouse en el programa
endm


;posiciona_cursor_mouse - Establece la posici?n inicial del cursor del mouse
posiciona_cursor_mouse  macro columna,renglon
    mov dx,renglon
    mov cx,columna
    mov ax,4        ;opcion 0004h
    int 33h         ;int 33h para manejo del mouse. Opcion AX=0001h
                    ;Habilita la visibilidad del cursor del mouse en el programa
endm


;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado
oculta_cursor_teclado   macro
    mov ah,01h      ;Opcion 01h
    mov cx,2607h    ;Parametro necesario para ocultar cursor
    int 10h         ;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm


;apaga_cursor_parpadeo - Deshabilita el parpadeo del cursor cuando se imprimen caracteres con fondo de color
;Habilita 16 colores de fondo
apaga_cursor_parpadeo   macro
    mov ax,1003h        ;Opcion 1003h
    xor bl,bl           ;BL = 0, par?metro para int 10h opci?n 1003h
    int 10h             ;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm


;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
;Los colores disponibles est?n en la lista a continuacion;
; Colores:
; 0h: Negro
; 1h: Azul
; 2h: Verde
; 3h: Cyan
; 4h: Rojo
; 5h: Magenta
; 6h: Cafe
; 7h: Gris Claro
; 8h: Gris Oscuro
; 9h: Azul Claro
; Ah: Verde Claro
; Bh: Cyan Claro
; Ch: Rojo Claro
; Dh: Magenta Claro
; Eh: Amarillo
; Fh: Blanco
; utiliza int 10h opcion 09h
; 'caracter' - caracter que se va a imprimir
; 'color' - color que tomar? el caracter
; 'bg_color' - color de fondo para el car?cter en la celda
; Cuando se define el color del car?cter, ?ste se hace en el registro BL:
; La parte baja de BL (los 4 bits menos significativos) define el color del car?cter
; La parte alta de BL (los 4 bits m?s significativos) define el color de fondo "background" del car?cter
imprime_caracter_color macro caracter,color,bg_color
    mov ah,09h              ;preparar AH para interrupcion, opcion 09h
    mov al,caracter         ;AL = caracter a imprimir
    mov bh,0                ;BH = numero de pagina
    mov bl,color            
    or bl,bg_color          ;BL = color del caracter
                            ;'color' define los 4 bits menos significativos 
                            ;'bg_color' define los 4 bits m?s significativos 
    mov cx,1                ;CX = numero de veces que se imprime el caracter
                            ;CX es un argumento necesario para opcion 09h de int 10h
    int 10h                 ;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm


;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
; utiliza int 10h opcion 09h
; 'cadena' - nombre de la cadena en memoria que se va a imprimir
; 'long_cadena' - longitud (en caracteres) de la cadena a imprimir
; 'color' - color que tomar?n los caracteres de la cadena
; 'bg_color' - color de fondo para los caracteres en la cadena
imprime_cadena_color macro cadena,long_cadena,color,bg_color
    mov ah,13h              ;preparar AH para interrupcion, opcion 13h
    lea bp,cadena           ;BP como apuntador a la cadena a imprimir
    mov bh,0                ;BH = numero de pagina
    mov bl,color            
    or bl,bg_color          ;BL = color del caracter
                            ;'color' define los 4 bits menos significativos 
                            ;'bg_color' define los 4 bits m?s significativos 
    mov cx,long_cadena      ;CX = longitud de la cadena, se tomar?n este n?mero de localidades a partir del apuntador a la cadena
    int 10h                 ;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm


;lee_mouse - Revisa el estado del mouse
;Devuelve:
;;BX - estado de los botones
;;;Si BX = 0000h, ningun boton presionado
;;;Si BX = 0001h, boton izquierdo presionado
;;;Si BX = 0002h, boton derecho presionado
;;;Si BX = 0003h, boton izquierdo y derecho presionados
; (400,120) => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => 50,15
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
lee_mouse   macro
    mov ax,0003h
    int 33h
endm


;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse     macro
    mov ax,0        ;opcion 0
    int 33h         ;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
                    ;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm


; limita_mouse_horizontal - Restringe el movimiento del mouse entre una columna izquierda y una derecha (en p?xeles)
limita_mouse_horizontal macro min_pixel, max_pixel
    mov cx, min_pixel
    mov dx, max_pixel
    mov ax, 0007h
    int 33h
endm


; limita_mouse_vertical - Restringe el movimiento del mouse entre un rengl?n superior y uno inferior (en p?xeles)
limita_mouse_vertical macro min_pixel, max_pixel
    mov cx, min_pixel   ; P?xel del rengl?n superior (M?nimo)
    mov dx, max_pixel   ; P?xel del rengl?n inferior (M?ximo)
    mov ax, 0008h       ; Opci?n 0008h: Bloqueo Vertical
    int 33h
endm




;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;Fin Macros;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;


.code
inicio:                 
    inicializa_ds_es  
    
    call LEER_RECORD_DISCO  
      
    comprueba_mouse     
    xor ax,0FFFFh    
    jz mostrar_menu     ; Si el mouse esta bien, vamos primero al Menu Principal
    lea dx,[no_mouse]
    mov ax,0900h    
    int 21h         
    jmp fin         


;Bucle del men? y su musica
    
mostrar_menu:
    call DIBUJA_MENU_PRINCIPAL
    
    lea si, musica_menu
    call REPRODUCIR_MELODIA


bucle_menu:
    lee_mouse
    test bx,0001h
    jz bucle_menu


;Coordenadas de mouse a modo texto
    mov ax,dx           
    div [ocho]          
    xor ah,ah           
    mov dx,ax
    mov ax,cx           
    div [ocho]          
    xor ah,ah           
    mov cx,ax


;Checa si hizo clic en jugar
    cmp dx,12
    jne revisar_clic_instrucciones
    cmp cx,35
    jl bucle_menu
    cmp cx,43
    jle imprime_ui


revisar_clic_instrucciones:
    ;Checa si hizo clic en instrucciones
    cmp dx,15
    jne revisar_clic_salir
    cmp cx,31
    jl bucle_menu
    cmp cx,47
    jle mostrar_manual


revisar_clic_salir:
    ;Checa si hizo clic en salir
    cmp dx,18
    jne bucle_menu      
    cmp cx,35
    jl bucle_menu
    cmp cx,43
    jg bucle_menu


    ; Cierre del programa
    clear                   
    mov ax,4C00h            
    int 21h


    ;Boton salir
    clear
    mov ax,4C00h
    int 21h  


;Muestra manual
mostrar_manual:
    call DIBUJA_MANUAL


bucle_manual:
    lee_mouse
    test bx,0001h
    jz bucle_manual


    ;Convierte coordenadas del mouse
    mov ax,dx           
    div [ocho]          
    xor ah,ah           
    mov dx,ax           
    mov ax,cx           
    div [ocho]          
    xor ah,ah           
    mov cx,ax 


    ;Checa si hizo clic en volver
    cmp dx,20
    jne bucle_manual
    cmp cx,34
    jl bucle_manual
    cmp cx,44
    jg bucle_manual
    jmp mostrar_menu
    
;Imprime la ui
imprime_ui:
    clear
    oculta_cursor_teclado   
    apaga_cursor_parpadeo   
    
    call DIBUJA_UI
    muestra_cursor_mouse    
    
    ;Bucle para primeras tres frutas
    xor si,si
bucle_frutas_inicio:
    call GENERAR_UNA_FRUTA  
    mov al,[frutas_renglon+si]
    mov dl,[frutas_columna+si]
    posiciona_cursor al,dl
    
    imprime_cadena_color frutaIcon,1,cRojoClaro,bgNegro
    
    
    inc si
    cmp si,CANT_FRUTAS
    jne bucle_frutas_inicio
    
    
    ;Encerrar al mouse en la zona de botones
    limita_mouse_horizontal 0d, 160d 
    limita_mouse_vertical   0d, 192d 
    
    posiciona_cursor_mouse 10d, 0d  


;Bucle de espera
mouse_no_clic:
    lee_mouse
    test bx,0001h
    jnz mouse_no_clic
    
    
    


;Lee el mouse y el teclado
mouse:
    ; 1. CONTROL DEL MOVIMIENTO AUTOM?TICO
    cmp [status],1          ; ?El juego est? activo (se presion? START)?
    jne revisar_teclado     ; Si no est? activo, no se mueve, pasa a revisar controles


    ; Verificar los ticks de la bios
    mov ah,00h
    int 1Ah                 ; Devuelve los ticks actuales
    
    mov al,dl
    sub al,[conta]          
    
    mov bl,6
    sub bl,[speed]          
    cmp bl,1
    jge aplicar_delay
    mov bl,1                
aplicar_delay:
    cmp al,bl
    jb revisar_teclado      ; Si aun no se va a mover checa controles
    mov [conta],dl          


    ; Si ya paso el tiempo mueve la serpiente
    call BORRA_PLAYER
    call MOVER_SNAKE
    call REVISA_COLISION_COLA
    call IMPRIME_PLAYER


; Comprobaciones de colisiones y comida
    call REVISA_COLISION_BORDES
    call REVISA_COMIDA     
    
    mov [ya_giro], 0        ;Si la serpiente se movio un cuadro permite girar
    
    
; 2. REVISAR ENTRADA DE TECLADO (A, S, D, W)
revisar_teclado:
    mov ah,01h              ; Checa si hay teclas en el bufer
    int 16h                 ; Interrupci?n de teclado
    jz revisar_mouse        ; Si no se presionaron teclas checa mouse


    ; Si hay teclas se sacan del bufer
    mov ah,00h              ; Leer caracter
    int 16h                 ; Ascii de la tecla presionada


    ; Para contemplar bloq mayus
    or al,20h               


    ; Cambio de direcci?n de head
    cmp al,'d'              ; D -> Derecha
    je cambiar_derecha
    cmp al,'w'              ; W -> Arriba
    je cambiar_arriba
    cmp al,'a'              ; A -> Izquierda
    je cambiar_izquierda
    cmp al,'s'              ; S -> Abajo
    je cambiar_abajo
    jmp revisar_mouse       ; Si fue otra tecla, la ignora


cambiar_derecha:
    cmp [ya_giro], 1        
    je revisar_mouse        ; Si ya cambio de direccion, entonces ignoramos esta segunda tecla por ahora
    
    mov ax,[head]
    shr ax,12               
    cmp ax,10b              ; Checar si va a la izquierda
    je revisar_mouse        ; Bloqueo de 180 grados
    
    and word ptr [head],0FFFh 
    mov [ya_giro], 1        ; Activa el seguro
    jmp revisar_mouse


cambiar_arriba:
    cmp [ya_giro], 1
    je revisar_mouse
    
    mov ax,[head]
    shr ax,12
    cmp ax,11b              ; Checar si va hacia abajo
    je revisar_mouse        ; Bloqueo de 180 grados
    
    and word ptr [head],0FFFh
    or word ptr [head],1000h  
    mov [ya_giro], 1        ; Activa el seguro
    jmp revisar_mouse


cambiar_izquierda:
    cmp [ya_giro], 1
    je revisar_mouse
    
    mov ax,[head]
    shr ax,12
    cmp ax,00b              ; Checar si va a la derecha
    je revisar_mouse        ; Bloqueo de 180 grados
    
    and word ptr [head],0FFFh
    or word ptr [head],2000h  
    mov [ya_giro], 1        ; Activa el seguro
    jmp revisar_mouse


cambiar_abajo:
    cmp [ya_giro], 1
    je revisar_mouse
    
    mov ax,[head]
    shr ax,12
    cmp ax,01b              ; Checar si va hacia arriba
    je revisar_mouse        ; Bloqueo de 180 grados
    
    and word ptr [head],0FFFh
    or word ptr [head],3000h  
    mov [ya_giro], 1        ; Activa el seguro
    jmp revisar_mouse    
    
; 3. REVISAR ENTRADA DE MOUSE (START, PAUSE, STOP, SPEED)
revisar_mouse:
    lee_mouse
    test bx,0001h           ; Checar si hizo clic izquierdo
    jz mouse                ; Si no hay clic, regresa al ciclo principal


conversion_mouse:
    mov ax,dx           
    div [ocho]          
    xor ah,ah           
    mov dx,ax           ; DX = Renglon


    mov ax,cx           
    div [ocho]          
    xor ah,ah           
    mov cx,ax           ; CX = Columna


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DETECCION DE CLICS EN LOS BOTONES DE LA INTERFAZ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; --- BOTON DE CERRAR [X] --- (Renglon 0, Columnas 17-19)
    cmp dx,0
    jne boton_pause_ui
    cmp cx,17
    jl mouse_no_clic
    cmp cx,19
    jle salir


boton_pause_ui:
    ; --- BOTON DE PAUSE (?) --- (Renglon 19, Columna 3)
    cmp dx,19
    jl boton_stop_ui
    cmp dx,21
    jg boton_stop_ui
    cmp cx,3
    jl boton_stop_ui
    cmp cx,5
    jg boton_stop_ui
    mov [status],0          ; Pausa el juego
    jmp mouse_no_clic


boton_stop_ui:
    ; --- BOTON DE STOP / REINICIAR (?) --- (Renglon 19, Columna 9)
    cmp dx,19
    jl boton_start_ui
    cmp dx,21
    jg boton_start_ui
    cmp cx,9
    jl boton_start_ui
    cmp cx,11
    jg boton_start_ui
    
    ; L?gica de Reinicio Completo:
    mov [status],0          ; Validar pausa
    mov [partida_iniciada],0 ; Liberar el seguro para poder volver a cambiar la velocidad
    call BORRA_PLAYER       ; Borra la posicion vieja de la pantalla
    
    ; Restablecer valores iniciales de la serpiente
    mov [head],0000001011101100b    ; Renglon 12, Columna 23, Direccion Derecha
    mov [tail],0000001010101100b    ; Primer eslabon fijo
    mov [tail+2],0000001011001100b  ; Segundo eslabon fijo
    mov [tail_conta],2              ; Longitud inicial de la cola
    
    ; Limpiar el resto del arreglo de la cola con ceros por si habia crecido
    lea bx,[tail+4]
limpiar_cola_loop:
    mov word ptr [bx],0
    add bx,2
    cmp bx,offset tail_conta        ; Limpiar hasta llegar a la siguiente variable
    jne limpiar_cola_loop


    mov [score],0           ; Reseteamos el puntaje real a 0
    
    ; Re-imprimir datos y UI limpia
    call DATOS_INICIALES    ; Pone Score y Speed en 0 y los vuelve a imprimir
    call IMPRIME_PLAYER     ; Dibuja la serpiente en su lugar de inicio
   
    jmp mouse_no_clic
    
    
   ;Regenerar frutas y stop interno
    push si
    xor si,si
bucle_frutas_stop:
    call GENERAR_UNA_FRUTA  
    mov al,[frutas_renglon+si]
    mov dl,[frutas_columna+si]
    posiciona_cursor al,dl
    imprime_cadena_color frutaIcon,1,cRojoClaro,bgNegro 
    inc si
    cmp si,CANT_FRUTAS
    jne bucle_frutas_stop
    pop si
    
   
   
   
   
   
    jmp mouse_no_clic


boton_start_ui:
    ; --- BOTON DE START (?) --- (Renglon 19, Columna 15)
    cmp dx,19
    jl boton_speed_up
    cmp dx,21
    jg boton_speed_up
    cmp cx,15
    jl boton_speed_up
    cmp cx,17
    jg boton_speed_up
    mov [status],1          ; Reanuda el juego
    mov [partida_iniciada],1 ; Bloquea los cambios de velocidad
    jmp mouse_no_clic


    
    boton_speed_up:
    cmp dx,11
    jl boton_speed_down
    cmp dx,13
    jg boton_speed_down
    cmp cx,16
    jl boton_speed_down
    cmp cx,18
    jg boton_speed_down


    cmp [partida_iniciada], 1
    je mouse_no_clic        ; Si la partida ya arranco una vez se congela la flecha


    cmp [speed], 9d         ; Limite de velocidad
    je mouse_no_clic
    inc [speed]
    call IMPRIME_SPEED
    jmp mouse_no_clic


boton_down:
boton_speed_down:
    cmp dx,11
    jl mouse_no_clic
    cmp dx,13
    jg mouse_no_clic
    cmp cx,12
    jl mouse_no_clic
    cmp cx,14
    jg mouse_no_clic


    cmp [partida_iniciada], 1
    je mouse_no_clic        ; Si la partida ya arranco una vez, se congela la flecha


    cmp [speed],0
    je mouse_no_clic       
    dec [speed]
    call IMPRIME_SPEED
    jmp mouse_no_clic
    
    
fin:
    mov ah,08h
    int 21h         ;opcion 08h int 21h. Lee caracter del teclado sin eco
    cmp al,0Dh      ;compara la entrada de teclado si fue [enter]
    jnz fin         ;Sale del ciclo hasta que presiona la tecla [enter]


salir:              ;inicia etiqueta salir
    clear           ;limpia pantalla
    mov ax,4C00h    ;AH = 4Ch, opcion para terminar programa, AL = 0 Exit Code
    int 21h         ;interrupcion, pasa el control al sistema operativo


    
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;PROCEDIMIENTOS;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;






    DIBUJA_UI proc
    
    
        ;imprimir esquina superior izquierda del marco
        posiciona_cursor 0,0
        imprime_caracter_color marcoEsqSupIzq,cAmarillo,bgNegro
        
        ;imprimir esquina superior derecha del marco
        posiciona_cursor 0,79
        imprime_caracter_color marcoEsqSupDer,cAmarillo,bgNegro
        
        ;imprimir esquina inferior izquierda del marco
        posiciona_cursor 24,0
        imprime_caracter_color marcoEsqInfIzq,cAmarillo,bgNegro
        
        ;imprimir esquina inferior derecha del marco
        posiciona_cursor 24,79
        imprime_caracter_color marcoEsqInfDer,cAmarillo,bgNegro
        
        ;imprimir marcos horizontales, superior e inferior
        mov cx,78       ;CX = 004Eh => CH = 00h, CL = 4Eh 
    marcos_horizontales:
        mov [col_aux],cl
        ;Superior
        posiciona_cursor 0,[col_aux]
        imprime_caracter_color marcoHor,cAmarillo,bgNegro
        ;Inferior
        posiciona_cursor 24,[col_aux]
        imprime_caracter_color marcoHor,cAmarillo,bgNegro
        mov cl,[col_aux]
        loop marcos_horizontales


        ;imprimir marcos verticales, derecho e izquierdo
        mov cx,23       ;CX = 0017h => CH = 00h, CL = 17h 
    marcos_verticales:
        mov [ren_aux],cl
        ;Izquierdo
        posiciona_cursor [ren_aux],0
        imprime_caracter_color marcoVer,cAmarillo,bgNegro
        ;Inferior
        posiciona_cursor [ren_aux],79
        imprime_caracter_color marcoVer,cAmarillo,bgNegro
        ;Interno
        posiciona_cursor [ren_aux],area_controles_ancho
        imprime_caracter_color marcoVer,cAmarillo,bgNegro
        
        mov cl,[ren_aux]
        loop marcos_verticales


        ;imprimir marcos horizontales internos
        mov cx,area_controles_ancho         ;CX = 0014h => CH = 00h, CL = 14h 
    marcos_horizontales_internos:
        mov [col_aux],cl
        ;Interno izquierdo (marcador player 1)
        posiciona_cursor 8,[col_aux]
        imprime_caracter_color marcoHor,cAmarillo,bgNegro


        ;Interno derecho (marcador player 2)
        posiciona_cursor 16,[col_aux]
        imprime_caracter_color marcoHor,cAmarillo,bgNegro


        mov cl,[col_aux]
        loop marcos_horizontales_internos


        ;imprime intersecciones internas    
        posiciona_cursor 0,area_controles_ancho
        imprime_caracter_color marcoCruceVerSup,cAmarillo,bgNegro
        posiciona_cursor 24,area_controles_ancho
        imprime_caracter_color marcoCruceVerInf,cAmarillo,bgNegro


        posiciona_cursor 8,0
        imprime_caracter_color marcoCruceHorIzq,cAmarillo,bgNegro
        posiciona_cursor 8,area_controles_ancho
        imprime_caracter_color marcoCruceHorDer,cAmarillo,bgNegro


        posiciona_cursor 16,0
        imprime_caracter_color marcoCruceHorIzq,cAmarillo,bgNegro
        posiciona_cursor 16,area_controles_ancho
        imprime_caracter_color marcoCruceHorDer,cAmarillo,bgNegro


        ;imprimir [X] para cerrar programa
        posiciona_cursor 0,17
        imprime_caracter_color '[',cAmarillo,bgNegro
        posiciona_cursor 0,18
        imprime_caracter_color 'X',cRojoClaro,bgNegro
        posiciona_cursor 0,19
        imprime_caracter_color ']',cAmarillo,bgNegro


        ;imprimir t?tulo
        posiciona_cursor 0,38
        imprime_cadena_color [nameStr],5,cAmarillo,bgNegro


        call IMPRIME_DATOS_INICIALES
        ret
    endp


    ;Reinicia scores y speed, e imprime
    DATOS_INICIALES proc
        mov [score],0
        mov [speed],0
        mov [frutas_contador],0;
        call IMPRIME_SCORE
        call IMPRIME_HISCORE
        call IMPRIME_SPEED
        ret
    endp


    
    ;Evitar serpientes fantasma
    IMPRIME_DATOS_INICIALES proc
    
        mov al, [fruta_actual_icono]
        mov [frutaIcon], al
    
    ;Imprimir iniciales del record
        posiciona_cursor 2,2
        imprime_cadena_color [hiScorePlayer],3,cAmarillo,bgNegro ; Muestra las iniciales
    
        ;Vaciar marcadores
        call DATOS_INICIALES


        ;Escribir textos fijos en panel de control
        posiciona_cursor 3,2
        imprime_cadena_color recordStr,8,cGrisClaro,bgNegro


        posiciona_cursor 5,2
        imprime_cadena_color scoreStr,5,cGrisClaro,bgNegro


        posiciona_cursor 12,2
        imprime_cadena_color speedStr,5,cGrisClaro,bgNegro


        ;Botones de la interfaz
        ;Boton para bajar velocidad
        mov [boton_caracter],31         
        mov [boton_color],bgAmarillo
        mov [boton_renglon],11
        mov [boton_columna],12
        call IMPRIME_BOTON


        ;Subir velocidad
        mov [boton_caracter],30         
        mov [boton_color],bgAmarillo
        mov [boton_renglon],11
        mov [boton_columna],16
        call IMPRIME_BOTON


        ;Pausa
        mov [boton_caracter],186        
        mov [boton_color],bgAmarillo
        mov [boton_renglon],19
        mov [boton_columna],3
        call IMPRIME_BOTON


        ;Reinicio o stop
        mov [boton_caracter],254d       
        mov [boton_color],bgAmarillo
        mov [boton_renglon],19
        mov [boton_columna],9
        call IMPRIME_BOTON


        ;Arrancar o start
        mov [boton_caracter],16d        
        mov [boton_color],bgAmarillo
        mov [boton_renglon],19
        mov [boton_columna],15
        call IMPRIME_BOTON


        ;Dibujar jugador y manzana
        call IMPRIME_SCORE
        call IMPRIME_HISCORE   
        call IMPRIME_SPEED
        call IMPRIME_PLAYER   
        ret
    endp
   


    ;Procedimiento utilizado para imprimir el score actual
    ;Establece las coordenadas en variables auxiliares en donde comienza a imprimir.
    ;Pone el valor en BX que se imprime con el procedimiento IMPRIME_SCORE_BX
    IMPRIME_SCORE proc
        mov [ren_aux],5
        mov [col_aux],12
        mov bx,[score]
        call IMPRIME_SCORE_BX
        ret
    endp


    ;Procedimiento utilizado para imprimir el score global HI-SCORE
    ;Establece las coordenadas en variables auxiliares en donde comienza a imprimir.
    ;Pone el valor en BX que se imprime con el procedimiento IMPRIME_SCORE_BX
    IMPRIME_HISCORE proc
        mov [ren_aux],3
        mov [col_aux],12
        mov bx,[hi_score]
        call IMPRIME_SCORE_BX
        ret
    endp


    ;Imprime el valor contenido en BX
    ;Se imprime un valor de 5 d?gitos. Si el numero es menor a 10000, se completan los 5 digitos con ceros a la izquierda
    IMPRIME_SCORE_BX proc
        mov ax,bx       ;AX = BX
        mov cx,5        ;CX = 5. Se realizan 5 divisiones entre 10 para obtener los 5 digitos
    ;En el bloque div10, se obtiene los digitos del numero haciendo divisiones entre 10 y se almacenan en la pila
    div10:
        xor dx,dx
        div [diez]
        push dx
        loop div10
        mov cx,5
    ;En el bloque imprime_digito, se recuperan los digitos anteriores calculados para imprimirse en pantalla.
    imprime_digito:
        mov [conta],cl
        posiciona_cursor [ren_aux],[col_aux]
        pop dx
        or dl,30h
        imprime_caracter_color dl,cBlanco,bgNegro
        xor ch,ch
        mov cl,[conta]
        inc [col_aux]
        loop imprime_digito
        ret
    endp


    ;Procedimiento para imprimir el valor de SPEED en pantalla
    ;Se imprime en dos caracteres.
    ;La variable speed es de tipo byte, su valor puede ser hasta 255d, pero solo se requieren dos d?gitos
    ;si speed es mayor a igual a 100d, se limita a establecerse en 99d


    
    IMPRIME_SPEED proc
        mov [ren_aux],12
        mov [col_aux],9
        cmp [speed],100d
        jb continua
        mov [speed],99d
    continua:
        posiciona_cursor [ren_aux],[col_aux]
        
        xor ax,ax       ;Limpieza de ax
        mov al,[speed]  ;Cargar speed en al
        aam             ; AH = Decenas, AL = Unidades (Sin argumentos extras)
        
        push ax         
        mov dl,ah       
        or dl,30h       
        imprime_caracter_color dl,cBlanco,bgNegro
        inc [col_aux]   
        posiciona_cursor [ren_aux],[col_aux]
        pop dx          
        or dl,30h       
        imprime_caracter_color dl,cBlanco,bgNegro
        ret
    endp
    
    


    ;Imprime viborita
    IMPRIME_PLAYER proc
    
    push ax
    push bx
    push cx
    push dx
    push si
    
        call IMPRIME_HEAD 
        call IMPRIME_TAIL
      
    imprime_fruta:
        xor si,si
        mov al,[frutas_renglon+si]
        mov dl,[frutas_columna+si]
        posiciona_cursor al,dl
        
        ;Modificar fruta en la pantalla
        mov al, [fruta_actual_color]    ; Cargar color dinamico en al
        imprime_cadena_color frutaIcon,1,al,bgNegro ; al es atributo de color dinamico
        
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp


    ;Imprime objeto en pantalla
    IMPRIME_ITEM proc
        posiciona_cursor [item_ren],[item_col]
        imprime_caracter_color 3,cVerdeClaro,bgNegro
        ret
    endp


    ;Imprime la cabeza de la serpiente
    IMPRIME_HEAD proc
        mov ax,[head]
        mov dx,ax
        and ax,11111b
        mov [ren_aux],al
        and dx,111111100000b
        shr dx,5
        mov [col_aux],dl
        posiciona_cursor [ren_aux],[col_aux]
        
        mov cl, [serpiente_color_actual]
        imprime_caracter_color 2, cl, bgNegro
        
        ret
    endp


    ;Imprime el cuerpo/cola de la serpiente
    ;Cada valor del arreglo 'tail' iniciando en el primer elemento es un elemento del cuerpo/cola
    ;Los valores establecidos en 0 son espacios reservados para el resto de los elementos.
    ;Se imprimen todos los elementos iniciando en el primero, hasta que se encuentre un 0 
    IMPRIME_TAIL proc
        lea bx,[tail]
    loop_tail:
        push bx
        mov ax,[bx]
        mov dx,ax
        and ax,11111b
        mov [ren_aux],al
        and dx,111111100000b
        shr dx,5
        mov [col_aux],dl
        posiciona_cursor [ren_aux],[col_aux]
        
        mov cl, [serpiente_color_actual]
        imprime_caracter_color 254, cl, bgNegro
        
        pop bx
        add bx,2
        cmp word ptr [bx],0
        jne loop_tail
        ret 
    endp
    
    
;Borra la serpiente para reimprimirla en una posicion actualizada
    BORRA_PLAYER proc
        ;Borrar la cabeza
        mov ax,[head]
        mov dx,ax
        and ax,11111b
        mov [ren_aux],al
        and dx,111111100000b
        shr dx,5
        mov [col_aux],dl
        posiciona_cursor [ren_aux],[col_aux]
        imprime_caracter_color ' ',cNegro,bgNegro


        ;Borrar el cuerpo (recorrer tail)
        lea bx,[tail]
    loop_borra_tail:
        push bx
        mov ax,[bx]
        cmp ax,0            ; Si es 0, ya terminamos
        je fin_borra_tail
        mov dx,ax
        and ax,11111b
        mov [ren_aux],al
        and dx,111111100000b
        shr dx,5
        mov [col_aux],dl
        posiciona_cursor [ren_aux],[col_aux]
        imprime_caracter_color ' ',cNegro,bgNegro
        pop bx
        add bx,2
        jmp loop_borra_tail
    fin_borra_tail:
        pop bx
        ret
    endp
    
    
    
    
    ;Calcular la nueva posicion de la cabeza y desplazar el cuerpo
    MOVER_SNAKE proc
        ;Desplazar los elementos de la cola en el arreglo
        mov cx,[tail_conta]
        shl cx,1            ; Multiplicar por 2 (cada elemento es un word)
        mov si,cx
    desplaza_tail:
        mov ax,[tail + si - 2]
        mov [tail + si],ax
        sub si,2
        jnz desplaza_tail


        ;El primer elemento de la cola ahora es la posicion actual de la cabeza
        mov ax,[head]
        and ax,0FFFh        ; Limpiamos los bits de direcci?n para la cola
        mov [tail],ax


        ;Obtener datos actuales de la cabeza para calcular la siguiente posicion
        mov ax,[head]
        mov dx,ax
        and ax,11111b       ; AX = Renglpn actual
        and dx,111111100000b
        shr dx,5            ; DX = Columna actual
        
        mov bx,[head]
        shr bx,12           ; BX = Direccion


        ;Modificar coordenadas segun la direccion
        cmp bx,00b
        je mover_derecha
        cmp bx,01b
        je mover_arriba
        cmp bx,10b
        je mover_izquierda
        cmp bx,11b
        je mover_abajo
        jmp actualizar_head


    mover_derecha:
        inc dl              ; Avanza 1 columna a la derecha
        jmp actualizar_head
    mover_izquierda:
        dec dl              ; Retrocede 1 columna a la izquierda
        jmp actualizar_head
    mover_arriba:
        dec al              ; Sube 1 renglon
        jmp actualizar_head
    mover_abajo:
        inc al              ; Baja 1 renglon
        jmp actualizar_head


    actualizar_head:
        ; 5. Reconstruir la variable 'head' con las nuevas coordenadas y la misma direccion
        mov cx,bx
        shl cx,12           ; Direcci?n en bits 12-13
        shl dx,5            ; Columna en bits 5-11
        or cx,dx
        xor ah,ah
        or cx,ax            ; Renglon en bits 0-4
        mov [head],cx
        ret
    endp
    
    
    ;Detector de choques
    REVISA_COLISION_BORDES proc
        ; 1. Desarmamos la variable de la cabeza para revisar las coordenadas actuales
        mov ax,[head]
        mov dx,ax
        and ax,11111b       ; AX = Renglon
        and dx,111111100000b
        shr dx,5            ; DX = Columna


        ; 2. Revisamos si toco los limites del tablero
        cmp al,0d           ; ?Techo?
        je secuencia_game_over
        cmp al,24d          ; ?Suelo?
        je secuencia_game_over
        cmp dl,20d          ; ?Pared de los controles?
        je secuencia_game_over
        cmp dl,79d          ; ?Pared derecha?
        je secuencia_game_over
        
        ret                 ; Si no hay choque, el juego sigue normal


   
;Record y nombre
    secuencia_game_over:
        mov [status],0          
        mov ax,33h
        mov ax,2
        int 33h                         ;Oculta cursor de mouse para enfocar el teclado


        posiciona_cursor 12,35
        imprime_cadena_color [gameOverStr],21,cRojoClaro,bgNegro


        ;Checar si supero record
        mov ax,[score]
        cmp ax,[hi_score]
        jbe reiniciar_escenario_directo ; Si no hizo mas puntos entonces se salta la captura


        ;Hubo nuevo record
        lea si, musica_record
        call REPRODUCIR_MELODIA
        jmp continuar_con_nombre
        
     reservar_musica_triste:
        ; === M?SICA TRISTE DE GAME OVER ===
        lea si, musica_gameover
        call REPRODUCIR_MELODIA
        jmp reiniciar_escenario_directo ; Se salta la captura de nombre y va directo al reinicio
        
        
     continuar_con_nombre:
        ;Actualizando el high score
        mov [hi_score],ax  
        call IMPRIME_HISCORE


        ;Mensaje de peticion
        posiciona_cursor 14,28
        imprime_cadena_color [recordNuevoStr],30,cVerdeClaro,bgNegro


        ; Bucle para leer exactamente 3 letras desde teclado
        xor si,si
    bucle_captura_nombre:
        mov ah,00h
        int 16h                         ; Lee pulsacion de tecla sin eco en pantalla


        ; Validar que sea un caracter imprimible estandar
        cmp al,32
        jb bucle_captura_nombre
        cmp al,126
        ja bucle_captura_nombre


        mov [tempPlayer+si],al          ;Bufer temporal
        
        ; Lo imprimimos en tiempo real en la pantalla para que el usuario vea qu? escribe
        mov bl,58
        add bl,cl
        posiciona_cursor 14,bl
        imprime_caracter_color al,cBlanco,bgNegro


        inc si
        cmp si,3
        jne bucle_captura_nombre        ; Repite hasta juntar los 3 caracteres


        ; Pasar las letras del bufer a la variable oficial
        mov al,[tempPlayer]
        mov [hiScorePlayer],al
        mov al,[tempPlayer+1]
        mov [hiScorePlayer+1],al
        mov al,[tempPlayer+2]
        mov [hiScorePlayer+2],al
        
        call GUARDAR_RECORD_DISCO


    reiniciar_escenario_directo:
        ; Espera de retraso para que se pueda apreciar el Game Over (3 segundos)
        mov ah,00h
        int 1Ah                 
        mov bx,dx               
    delay_go:
        mov ah,00h
        int 1Ah                 
        mov cx,dx
        sub cx,bx               
        cmp cx,54d              
        jb delay_go


        ; Restauracion de los valores de la serpiente
        mov [head],0000001011101100b    
        mov [tail],0000001010101100b    
        mov [tail+2],0000001011001100b  
        mov [tail_conta],2              
        
        lea bx,[tail+4]
        
    limpiar_go_nuevo:
        mov word ptr [bx],0
        add bx,2
        cmp bx,offset tail_conta        
        jne limpiar_go_nuevo


        mov [score],0                   ; Limpiamos la puntuacion real
        mov [frutas_contador],0
        mov [partida_iniciada],0        ; Libera la seleccion de velocidad
        mov [serpiente_color_actual], 0Ah  ; Vuelve a ser verde
        
        push si
        xor si,si
    bucle_reset_coordenadas_go:
        call GENERAR_UNA_FRUTA          ; Calcula posicion aleatoria NUEVA en memoria
        inc si
        cmp si,CANT_FRUTAS
        jne bucle_reset_coordenadas_go
        pop si
        
        ; Limpiamos la pantalla visual eliminando los rastros del juego anterior
        clear
        oculta_cursor_teclado
        apaga_cursor_parpadeo


        call DIBUJA_UI                  ; Dibuja el tablero limpio
        mov ax,1
        int 33h                         ; Activa la flecha del mouse


        ; Dibujar las frutas que ya estan en sus nuevas posiciones
        push si
        xor si,si
    bucle_frutas_gameover:
        mov al,[frutas_renglon+si]
        mov dl,[frutas_columna+si]
        posiciona_cursor al,dl
        
        mov al, [fruta_actual_color]    ; Usar el color dinamico actual
        imprime_cadena_color frutaIcon,1,al,bgNegro 
        inc si
        cmp si,CANT_FRUTAS
        jne bucle_frutas_gameover
        pop si


        ret
    endp
        
    REVISA_COLISION_COLA proc
        push ax
        push bx
        push cx
        push dx
        push si


        ;Obtener las coordenadas de la cabeza de forma limpia (igual que en los bordes)
        mov ax,[head]
        and ax,0FFFh            ; Eliminamos los bits de direcci?n, nos quedamos con rengl?n y columna


        ;Preparar el indice para recorrer el arreglo 'tail'
        xor si,si               ; Empezamos desde la primera seccion de la cola


    bucle_revisa_cola:
        mov bx,[tail+si]        ; Cargar la posicion de la seccion de la cola actual
        cmp bx,0                ; ?Esta secci?n est? vac?a (fin de la serpiente)?
        je fin_revisa_cola      ; Si es 0, ya revisamos todo el cuerpo vivo y no chocado


        cmp ax,bx               ; Checar si coincide la posicion y esta parte de la cola
        je choque_con_cuerpo    ; Si choco consigo misma es game over


        add si,2                ; Siguiente posicion del arreglo (cada elemento mide 2 bytes)
        cmp si,2710d            ; Limite de seguridad por si el arreglo es muy grande
        jae fin_revisa_cola
        jmp bucle_revisa_cola


    choque_con_cuerpo:
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        jmp secuencia_game_over ; salto a game over


    fin_revisa_cola:
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp

        
        ;Reiniciar los valores de la cabeza y los bloques iniciales en la memoria
        mov [head],0000001011101100b    
        mov [tail],0000001010101100b    
        mov [tail+2],0000001011001100b  
        mov [tail_conta],2              
        
        ;Vaciar almacen del cuerpo de la partida vieja (ponemos ceros)
        lea bx,[tail+4]
    limpiar_gameover_loop:
        mov word ptr [bx],0
        add bx,2
        cmp bx,offset tail_conta        
        jne limpiar_gameover_loop


        ;Limpiar la pantalla visual por completo
        clear
        oculta_cursor_teclado
        apaga_cursor_parpadeo


        ;Reconstruir todo el mapa y los marcadores desde cero
        call DIBUJA_UI          
        muestra_cursor_mouse    


        
        ;Regenerar frutas tras game over
        push si
        xor si,si
    bucle_frutas_reiniciar:
        call GENERAR_UNA_FRUTA  
        mov al,[frutas_renglon+si]
        mov dl,[frutas_columna+si]
        posiciona_cursor al,dl
        imprime_cadena_color frutaIcon,1,cRojoClaro,bgNegro 
        inc si
        cmp si,CANT_FRUTAS
        jne bucle_frutas_reiniciar
        pop si        
        
        ret
    endp
  
    
      
    ;procedimiento IMPRIME_BOTON
    ;Dibuja un boton que abarca 3 renglones y 5 columnas
    ;con un caracter centrado dentro del boton
    ;en la posici?n que se especifique (esquina superior izquierda)
    ;y de un color especificado
    ;Utiliza paso de parametros por variables globales
    ;Las variables utilizadas son:
    ;boton_caracter: debe contener el caracter que va a mostrar el boton
    ;boton_renglon: contiene la posicion del renglon en donde inicia el boton
    ;boton_columna: contiene la posicion de la columna en donde inicia el boton
    ;boton_color: contiene el color del boton
    IMPRIME_BOTON proc
        ;background de bot?n
        mov ax,0600h        ;AH=06h (scroll up window) AL=00h (borrar)
        mov bh,cRojo        ;Caracteres en color amarillo
        xor bh,[boton_color]
        mov ch,[boton_renglon]
        mov cl,[boton_columna]
        mov dh,ch
        add dh,2
        mov dl,cl
        add dl,2
        int 10h
        mov [col_aux],dl
        mov [ren_aux],dh
        dec [col_aux]
        dec [ren_aux]
        posiciona_cursor [ren_aux],[col_aux]
        imprime_caracter_color [boton_caracter],cRojo,[boton_color]
        ret             ;Regreso de llamada a procedimiento
    endp                ;Indica fin de procedimiento UI para el ensamblador
  
;Dibujar men? principal
DIBUJA_MENU_PRINCIPAL proc
    clear                       ; Limpia la pantalla completa
    oculta_cursor_teclado       ; Esconde el cursor de texto parpadeante
    
    ;Titulo
    posiciona_cursor 3, 22
    imprime_cadena_color snakeGiga1, 35, cVerdeClaro, bgNegro
    posiciona_cursor 4, 22
    imprime_cadena_color snakeGiga2, 35, cVerdeClaro, bgNegro
    posiciona_cursor 5, 22
    imprime_cadena_color snakeGiga3, 35, cVerdeClaro, bgNegro
    posiciona_cursor 6, 22
    imprime_cadena_color snakeGiga4, 35, cVerdeClaro, bgNegro
    posiciona_cursor 7, 22
    imprime_cadena_color snakeGiga5, 35, cVerdeClaro, bgNegro
    
    ;Enmarcar opciones
    ; Opcion 1: JUGAR (Renglon 12, Columna 35)
    posiciona_cursor 12, 35
    imprime_cadena_color opcionJugarStr, 9, cBlanco, bgNegro
    
    ; Opcion 2: INSTRUCCIONES (Renglon 15, Columna 31)
    posiciona_cursor 15, 31
    imprime_cadena_color opcionInstStr, 17, cAmarillo, bgNegro
    
    ; Opcion 3: SALIR (Renglon 18, Columna 35)
    posiciona_cursor 18, 35
    imprime_cadena_color opcionSalirStr, 9, cRojoClaro, bgNegro
    
    muestra_cursor_mouse        ;Muestra la flecha del mouse para que el usuario elija
    ret
DIBUJA_MENU_PRINCIPAL endp



;Dibujar manual
DIBUJA_MANUAL proc
    clear                       ; Limpia el Menu
    
    ;Texto del manual
    posiciona_cursor 3, 24
    imprime_cadena_color instMenuTitulo, 32, cCyanClaro, bgNegro
    
    posiciona_cursor 7, 8
    imprime_cadena_color instFlechas, 63, cBlanco, bgNegro
    
    posiciona_cursor 9, 8
    imprime_cadena_color instBotIniciar, 56, cVerdeClaro, bgNegro
    
    posiciona_cursor 11, 8
    imprime_cadena_color instBotPausa, 58, cAmarillo, bgNegro
    
    posiciona_cursor 13, 8
    imprime_cadena_color instBotStop, 41, cRojoClaro, bgNegro
    
    posiciona_cursor 15, 8
    imprime_cadena_color instFlechasSpeed, 64, cMagentaClaro, bgNegro
    
    ;Boton volver
    posiciona_cursor 20, 34
    imprime_cadena_color btnVolverStr, 10, cGrisClaro, bgNegro
    muestra_cursor_mouse
    ret
DIBUJA_MANUAL endp
   
   
    
    
GENERAR_UNA_FRUTA proc
        push ax
        push cx
        push dx


    generar_renglon:
        mov ah,00h
        int 1Ah         ; Lee el reloj de la BIOS
        mov ax,dx
        xor dx,dx
        mov cx,23d      ; Limita los renglones del 1 al 23
        div cx          
        inc dl          
        mov [frutas_renglon+si],dl


    generar_columna:
        mov ah,00h
        int 1Ah
        mov ax,dx
        xor dx,dx
        mov cx,56d      ; Limita el espacio entre las columnas 21 y 77
        div cx          
        add dl,21d      
        mov [frutas_columna+si],dl


        pop dx
        pop cx
        pop ax
        ret
    endp
    
    
;Checar si serpiente comio fruta
    REVISA_COMIDA proc
        push ax
        push bx
        push cx
        push dx
        push si


        ;EXTRAER COORDENADAS LIMPIAS DE LA CABEZA
        mov ax, [head]
        mov dx, ax
        
        and ax, 11111b       ; AX = Rengl?n real de la cabeza (Bits 0-4)
        mov bh, al           ; Guardamos rengl?n en BH


        and dx, 111111100000b ; Aislamos la columna (Bits 5-11)
        shr dx, 5            ; DL = Columna real de la cabeza
        mov bl, dl           ; Guardamos columna en BL


        ;OBTENER COORDENADAS DE LA FRUTA ACTUAL
        xor si, si          
        mov al, [frutas_renglon+si]   ; AL = Rengl?n real de la fruta
        mov cl, [frutas_columna+si]   ; CL = Columna real de la fruta


        ;COMPROBAR COLISION
        cmp bh, al          ; ?Coincide el rengl?n?
        jne fin_revisar_comida
        cmp bl, cl          ; ?Coincide la columna?
        jne fin_revisar_comida


        ;REVISAR SI COMIO
        add [score], 10
        inc [tail_conta]
        
        ;SONIDO DE COMIDA
        lea si, musica_comer
        call REPRODUCIR_MELODIA
        
        mov al, [fruta_actual_color]
        mov [serpiente_color_actual], al
        
        call IMPRIME_SCORE          


        ;CONTROL DE VELOCIDAD CADA 5 FRUTAS
        inc [frutas_contador]       
        cmp [frutas_contador], 5    
        jne continuar_sin_acelerar  


        mov [frutas_contador], 0    
        cmp [speed], 9d             ; Limite visual de velocidad
        jae continuar_sin_acelerar  
        inc [speed]                 
        call IMPRIME_SPEED          


continuar_sin_acelerar:       
        ; 4. CALCULAMOS NUEVA POSICI?N AL AZAR
        xor si, si                  
        call GENERAR_UNA_FRUTA      
        
        ; === L?GICA DE MUTACI?N DE ASPECTO AL AZAR ===
        mov ah, 00h
        int 1Ah                     ; Lee el reloj del sistema
        mov ax, dx                  
        xor dx, dx                  
        mov cx, 5                   ; 5 opciones en el cat?logo
        div cx                      ; El residuo (0 a 4) queda en DX
        
        mov si, dx                  ; Usamos el residuo como ?ndice
        
        ; Asignamos la nueva figura y color de las listas
        mov al, [lista_figuras+si]
        mov [fruta_actual_icono], al
        
        mov al, [lista_colores+si]
        mov [fruta_actual_color], al
        
        ;Dibujar nueva fruta
        xor si, si                  
        mov al, [frutas_renglon+si]
        mov dl, [frutas_columna+si]
        posiciona_cursor al, dl
        
        mov al, [fruta_actual_icono]
        mov [frutaIcon], al         ; Sincronizamos la variable
        
        mov al, [fruta_actual_color] 
        imprime_cadena_color frutaIcon, 1, al, bgNegro


fin_revisar_comida:
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
    ;Guardado de record
    GUARDAR_RECORD_DISCO proc
        push ax
        push bx
        push cx
        push dx


        ;Preparamos el bufer con los datos actuales
        mov al, [hiScorePlayer]
        mov [buffer_record], al
        mov al, [hiScorePlayer+1]
        mov [buffer_record+1], al
        mov al, [hiScorePlayer+2]
        mov [buffer_record+2], al
        
        mov ax, [hi_score]
        mov word ptr [buffer_record+3], ax  ; Guardamos los 2 bytes del score num?rico


        ;Crear / Abrir archivo para escritura (sobreescribe si ya existe)
        mov ah, 3Ch                         ; Funci?n para crear archivo
        mov cx, 0                           ; Atributos normales
        lea dx, archivo_nombre
        int 21h
        jc fin_guardar                      ; Si hubo un error (Carrier flag set), salimos
        mov [archivo_handle], ax            ; Guardamos el handle asignado por DOS


        ;Escribir los 5 bytes del bufer en el archivo
        mov ah, 40h                         ; Funcion para escribir en archivo
        mov bx, [archivo_handle]
        mov cx, 5                           ; Cantidad de bytes a escribir
        lea dx, buffer_record
        int 21h


        ;Cerrar el archivo de forma segura
        mov ah, 3Eh                         ; Funcion para cerrar archivo
        mov bx, [archivo_handle]
        int 21h


    fin_guardar:
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
    
    
;Lectura de record al abrir el juego
    LEER_RECORD_DISCO proc
        push ax
        push bx
        push cx
        push dx


        ;Intentar abrir el archivo existente en modo lectura
        mov ah, 3Dh                         
        mov al, 0                           ; Modo Solo lectura
        lea dx, archivo_nombre
        int 21h
        jc fin_leer                         ; Si no existe sale 


        mov [archivo_handle], ax            


        ;Leer los 5 bytes y meterlos al bufer temporal
        mov ah, 3Fh                         
        mov bx, [archivo_handle]
        mov cx, 5                           
        lea dx, buffer_record
        int 21h


        ;Pasar los datos leidos a las variables del juego de forma segura
        mov al, [buffer_record]
        mov [hiScorePlayer], al
        mov al, [buffer_record+1]
        mov [hiScorePlayer+1], al
        mov al, [buffer_record+2]
        mov [hiScorePlayer+2], al


        ; Recuperamos el valor numerico de 16 bits (Word)
        mov al, [buffer_record+3]
        mov ah, [buffer_record+4]
        mov [hi_score], ax                  


        ;Cerrar el archivo
        mov ah, 3Eh
        mov bx, [archivo_handle]
        int 21h


    fin_leer:
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    endp
 ;Reproducir melodias
REPRODUCIR_MELODIA proc
    push ax
    push bx
    push cx
    push dx
    push si


bucle_notas:
    mov ax, [si]            ; Lee la frecuencia de la nota
    cmp ax, 0               ; Checar fin de melodia
    je fin_melodia
    
    mov bx, [si+2]          ; Lee la duracion multiplicadora de la nota
    
    ;Encender altavoz y enviar frecuencia
    push ax
    mov al, 10110110b       ; Configura el canal 2 del temporizador
    out 43h, al
    pop ax
    
    ; Conversion: DX:AX = 1,193,180 / Frecuencia
    mov cx, ax
    mov ax, 34DCh
    mov dx, 12h             
    div cx
    
    out 42h, al             ; Envia byte bajo
    mov al, ah
    out 42h, al             ; Envia byte alto
    
    in al, 61h              
    or al, 00000011b        ; Enciende la bocina fisica
    out 61h, al


    ;Control de tiempo en ciclos cpu
    ; Multiplicamos la duracion de la nota por un bucle de retraso pesado
bucle_duracion_externo:
    mov cx, 0FFFh          ; Factor de retraso por nota
bucle_retraso_interno:
    nop                     ; No operation
    loop bucle_retraso_interno
    dec bx
    jnz bucle_duracion_externo


    add si, 4               ; Avanza a la siguiente nota
    jmp bucle_notas


fin_melodia:
    ; --- APAGAR ALTAVOZ AL TERMINAR ---
    in al, 61h
    and al, 11111100b       ; Apaga los bits del altavoz
    out 61h, al


    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
REPRODUCIR_MELODIA endp   
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;FIN PROCEDIMIENTOS;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    end inicio          ;fin de etiqueta inicio, fin de programa