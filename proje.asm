.model small
.stack 100h

.data
    kalan_atis   db 5
    puan          db 0      
    top_x         db 40     
    top_y         db 23     
    top_karakter db 'O'    
    pin_kar      db 'I'
    vurulan_pin  db 0
    guc          db 1
    
    pin_konumlar db 10, 25, 40, 55, 70 

    mesaj         db 'Oklar: Yon | BOSLUK: Guc | Kalan: ', '$'
    puan_mesaj   db ' | Puan: ', '$'
    guc_mesaj    db 'GUC (1-9): ', '$'
    bitti_mesaj  db 'OYUN BITTI! Toplam Puaniniz: ', '$'
    tebrik_mesaj db 'TEBRIKLER! HEPSINI VURDUNUZ! Puan: ', '$'

.code
ana_program proc
    mov ax, @data
    mov ds, ax
    
    mov ah, 00h
    mov al, 03h
    int 10h
    
    call ekrani_temizle

yeni_tur:
    cmp vurulan_pin, 5
    je oyun_kazanildi
    cmp kalan_atis, 0
    je oyun_bitti      

    call klavye_temizle
    call pinleri_yer_degistir 

    mov top_x, 40
    mov top_y, 23
    
    call ekrani_temizle
    call ust_bilgi_yazdir
    call pinleri_ciz

oyun_dongusu:
    call topu_ciz
    mov ah, 01h      
    int 16h
    jz oyun_dongusu  
    
    mov ah, 00h      
    int 16h
    
    cmp al, 27       
    je cikis
    cmp ah, 4Bh      
    je sola_git
    cmp ah, 4Dh      
    je saga_git
    cmp al, 32       
    je guc_baslat
    
    jmp oyun_dongusu

sola_git:
    cmp top_x, 0
    je oyun_dongusu
    call topu_sil
    dec top_x
    jmp oyun_dongusu

saga_git:
    cmp top_x, 79
    je oyun_dongusu
    call topu_sil
    inc top_x
    jmp oyun_dongusu

guc_baslat:
    call klavye_temizle
guc_dongusu:
    mov ah, 86h
    mov cx, 0002h
    mov dx, 49F0h
    int 15h

    inc guc
    cmp guc, 10
    jne guc_ekrana_yaz
    mov guc, 1
guc_ekrana_yaz:
    mov ah, 02h
    mov dh, 1
    mov dl, 0
    int 10h
    lea dx, guc_mesaj
    mov ah, 09h
    int 21h
    mov dl, guc
    add dl, '0'
    mov ah, 02h
    int 21h
    
    mov ah, 01h
    int 16h
    jz guc_dongusu
    
    mov ah, 00h      
    int 16h
    jmp atis_firlat

atis_firlat:
firlatma_dongusu:
    call topu_sil
    dec top_y
    
    cmp top_y, 5
    jne top_ilerle
    
    mov si, 0
carp_kontrol:
    mov al, pin_konumlar[si]
    cmp al, 0
    je siradaki_pin   
    
    cmp top_x, al
    jne siradaki_pin
    
    mov pin_konumlar[si], 0  
    inc vurulan_pin          
    
    mov al, guc
    shl al, 1       
    add puan, al    
    
    call bip_sesi_cikar
    
siradaki_pin:
    inc si
    cmp si, 5
    jne carp_kontrol
    
top_ilerle:
    call topu_ciz
    call pinleri_ciz
    
    mov al, 10
    sub al, guc      
    mov ah, 0
    mov cx, ax       
hiz_gercek_zaman:
    push cx
    mov ah, 86h
    mov cx, 0000h
    mov dx, 61A8h
    int 15h
    pop cx
    loop hiz_gercek_zaman
    
    cmp top_y, 0
    jg firlatma_dongusu
    
    dec kalan_atis
    jmp yeni_tur

oyun_kazanildi:
    call ekrani_temizle
    mov ah, 02h
    mov dh, 12       
    mov dl, 15       
    mov bh, 0
    int 10h
    lea dx, tebrik_mesaj
    mov ah, 09h
    int 21h
    jmp puan_yaz

oyun_bitti:
    call ekrani_temizle
    mov ah, 02h
    mov dh, 12       
    mov dl, 20       
    mov bh, 0
    int 10h
    lea dx, bitti_mesaj
    mov ah, 09h
    int 21h

puan_yaz:
    mov al, puan
    mov ah, 0
    mov bl, 10
    div bl           
    mov cl, ah       
    mov dl, al
    add dl, '0'
    mov ah, 02h
    int 21h
    mov dl, cl       
    add dl, '0'
    int 21h
    
    call klavye_temizle
    mov ah, 00h
    int 16h
    jmp cikis

cikis:
    mov ah, 4Ch
    int 21h
ana_program endp

ekrani_temizle proc
    mov ah, 06h      
    mov al, 0        
    mov bh, 07h      
    mov cx, 0000h    
    mov dx, 184Fh    
    int 10h
    ret
ekrani_temizle endp

klavye_temizle proc
temizle_dongu:
    mov ah, 01h      
    int 16h
    jz temiz_bitti   
    mov ah, 00h      
    int 16h
    jmp temizle_dongu 
temiz_bitti:
    ret
klavye_temizle endp

ust_bilgi_yazdir proc
    mov ah, 02h
    mov dh, 0
    mov dl, 0
    mov bh, 0
    int 10h
    
    mov ah, 09h
    mov al, ' '      
    mov bl, 0Ah      
    mov cx, 80       
    int 10h
    
    lea dx, mesaj
    mov ah, 09h
    int 21h
    
    mov dl, kalan_atis
    add dl, '0'
    mov ah, 02h
    int 21h
    
    lea dx, puan_mesaj
    mov ah, 09h
    int 21h
    
    mov al, puan
    mov ah, 0
    mov bl, 10
    div bl
    mov cl, ah       
    mov dl, al
    add dl, '0'
    mov ah, 02h
    int 21h
    mov dl, cl       
    add dl, '0'
    int 21h
    
    ret
ust_bilgi_yazdir endp

pinleri_yer_degistir proc
    mov ah, 00h
    int 1Ah 

    cmp pin_konumlar[0], 0
    je atla0            
    mov bl, dl
    add bl, guc         
    and bl, 0Fh         
    add bl, 1           
    mov pin_konumlar[0], bl
atla0:

    cmp pin_konumlar[1], 0
    je atla1
    mov bl, dh
    xor bl, dl          
    and bl, 0Fh         
    add bl, 17          
    mov pin_konumlar[1], bl
atla1:

    cmp pin_konumlar[2], 0
    je atla2
    mov bl, cl          
    add bl, guc
    and bl, 0Fh         
    add bl, 33          
    mov pin_konumlar[2], bl
atla2:

    cmp pin_konumlar[3], 0
    je atla3
    mov bl, ch
    xor bl, dl          
    and bl, 0Fh         
    add bl, 49          
    mov pin_konumlar[3], bl
atla3:

    cmp pin_konumlar[4], 0
    je atla4
    mov bl, dl
    add bl, dh
    add bl, cl          
    and bl, 0Fh         
    add bl, 64          
    mov pin_konumlar[4], bl
atla4:

    ret
pinleri_yer_degistir endp

pinleri_ciz proc
    mov si, 0
p_ciz:
    mov al, pin_konumlar[si]
    cmp al, 0        
    je p_gec         
    
    mov ah, 02h
    mov dh, 5
    mov dl, al
    mov bh, 0
    int 10h
    
    mov ah, 09h
    mov al, pin_kar
    mov bl, 0Eh      
    mov cx, 1        
    int 10h
p_gec:
    inc si
    cmp si, 5
    jne p_ciz
    ret
pinleri_ciz endp

topu_ciz proc
    mov ah, 02h
    mov dh, top_y
    mov dl, top_x
    mov bh, 0
    int 10h
    
    mov ah, 09h
    mov al, top_karakter
    mov bl, 0Bh      
    mov cx, 1
    int 10h
    ret
topu_ciz endp

topu_sil proc
    mov ah, 02h
    mov dh, top_y
    mov dl, top_x
    mov bh, 0
    int 10h
    
    mov ah, 09h
    mov al, ' '
    mov bl, 07h      
    mov cx, 1
    int 10h
    ret
topu_sil endp   

bip_sesi_cikar proc
    mov al, 0B6h     
    out 43h, al
    mov al, 0A9h     
    out 42h, al
    mov al, 04h      
    out 42h, al

    in al, 61h       
    or al, 03h       
    out 61h, al      

    mov ah, 86h
    mov cx, 0000h
    mov dx, 8000h    
    int 15h

    in al, 61h       
    and al, 0FCh     
    out 61h, al      
    
    ret
bip_sesi_cikar endp

end ana_program
