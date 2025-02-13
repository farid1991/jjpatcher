if ~ defined MAINARMLIB
  MAINARMLIB equ 1

macro pad val
{
  db ( (($+val-1)and(0xFFFFFFFF-val+1))-$ )dup 0
}

macro bxd ad,dr
{
local _ad
  if dr eq
    ldr  r4,_ad
    bx r4
  else
    ldr  dr,_ad
    bx dr
  end if
  align 4
_ad dw (ad+1)
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
macro code16
{
  global_codesize equ 16
  code16
}
macro code32
{
  global_codesize equ 32
  code32
}
code16

macro parseregnum reg
{
  registernum=0xFF
  if reg eq r0
    registernum=0
  else if reg eq r1
    registernum=1
  else if reg eq r2
    registernum=2
  else if reg eq r3
    registernum=3
  else if reg eq r4
    registernum=4
  else if reg eq r5
    registernum=5
  else if reg eq r6
    registernum=6
  else if reg eq r7
    registernum=7
  else if reg eq r8
    registernum=8
  else if reg eq r9
    registernum=9
  else if reg eq r10
    registernum=10
  else if reg eq r11
    registernum=11
  else if reg eq r12
    registernum=12
  else if reg eq r13
    registernum=13
  else if reg eq r14
    registernum=14
  else if reg eq r15
    registernum=15
  else if reg eq pc
    registernum=15
  end if
}

macro adr reg,offs
{
  if global_codesize = 32
    add reg,pc,(offs-($ and 0xFFFFFFFC)-8)
  else
    add reg,pc,(offs-($ and 0xFFFFFFFC)-4)
  end if
}

macro ldr rg, p1*,p2,p3
{
  local fl
  fl equ
    if fl eq
      match =[ a =]=,b  , p1,p2
      \{
        ldr rg,[a],b
        fl equ 1
      \}
    end if
    if fl eq
      match =[ a =] , p1,p2,p3
      \{
        ldr rg,[a]
        fl equ 1
      \}
    end if
    if fl eq
      match =[ a =] , p1,p2
      \{
        ldr rg,[a]
        fl equ 1
      \}
    end if
    if fl eq
      match =[ a =] , p1
      \{
        ldr rg,[a]
        fl equ 1
      \}
    end if


  if fl eq
    if global_codesize = 32
      ldr rg , [pc,(p1-($ and 0xFFFFFFFC)-8)]
    else
      ldr rg , [pc,(p1-($ and 0xFFFFFFFC)-4)]
    end if
  end if
}


macro ldreq rg, p1*,p2,p3
{
  local fl
  fl equ
    if fl eq
      match =[ a =] , p1
      \{
        ldreq rg,[a]
        fl equ 1
      \}
    end if

  if fl eq
    if global_codesize = 32
      ldreq rg , [pc,(p1-($ and 0xFFFFFFFC)-8)]
    end if
  end if
}


macro ldrne rg, p1*,p2,p3
{
  local fl
  fl equ
    if fl eq
      match =[ a =] , p1
      \{
        ldrne rg,[a]
        fl equ 1
      \}
    end if

  if fl eq
    if global_codesize = 32
      ldrne rg , [pc,(p1-($ and 0xFFFFFFFC)-8)]
    end if
  end if
}


macro org off
{
  db 'justdase'
  dw off
  org off
}

macro movl r,v
{
  if v<256
    mov r,(v)
  else if v<511
    mov r,255
    add r,(v-255)
  else
    num=0x00FFFFFF
    sdv=24
    rept 23
    \{
      if (v and num)=0
        mov r,(v shr sdv)
        lsl r,r,sdv
        num = 0xFFFFFFFF
      end if
      num = (num shr 1) + 0x80000000
      sdv = sdv-1
    \}
    if ~ num = 0xFFFFFFFF
      bad value
    end if
  end if
}

LDR fix ldr
DCD fix dw
DCB fix db
CODE16 fix code16
CODE32 fix code32
MOVL fix movl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end if
