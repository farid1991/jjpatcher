;arm
include "%fasminc%\x.inc"

macro call ad
{
  if global_codesize = 32
    if ad and 3 = 1
      blx (ad and 0xFFFFFFFE)
    else
      bl (ad and 0xFFFFFFFE)
    end if
  else
    if ad and 3 = 1
      bl (ad and 0xFFFFFFFE)
    else
      blx (ad and 0xFFFFFFFE)
    end if
  end if
}


macro savedacr reg
{
  call setdacr
  if reg eq r0
  else
    mov reg,r0
  end if
}
macro loaddacr reg
{
  mcr p15, 0, reg, c3, c0 ;restore dacr
}
macro saverights reg
{
  mov r12,swinum ;set supervisor
  swi swinum
  if reg eq r0
  else
    mov reg,r0
  end if
}
macro loadrights reg
{
  msr cpsr_cxsf, reg ;restore rights
}



code32
        stmfd sp!,{r1-r7,lr}

        mov r7,r0


        mov r2,3
        adr r1,rightspatch
        adr r0,drivername
        bl biosInstall

        adr r0,drivername
        bl biosOpen
        
        ;mov r1,fnnumber
        bl callbios
        mov r6,r0

        adr r0,drivername
        bl biosUninstall


;        saverights r6
        savedacr r5

        ;r7 - data array
        ;insert your code here


        ldmia r7!,{r0}
.ploop:
        subs r0,r0,1
        bmi .out

        ldmia r7!,{r1,r2}
        mov r2,r2,lsr 8
        strb r2,[r1]
        b .ploop

.out:

        loaddacr r5
        loadrights r6


        ldmfd sp!,{r1-r7,pc}


setdacr:
        mrc p15, 0, r0, c3, c0 ;save old dacr
        stmfd sp!,{r0}
        mvn r0,0
        mcr p15, 0, r0, c3, c0 ;set dacr
        ldmfd sp!,{r0}
        bx lr




rightspatch:
            STMFD   SP!, {R1}
            ldr     r0,[sp,4]
            bic     r1, r0, 0x1f
            orr     r1, r1, 0x13
            str     r1,[sp,4]
            LDMFD   SP!, {R1}
            BX      LR            


callbios:
            STMFD   SP!, {R7,LR}
            MOV     R7, r1
            mov     r12, r0
            SWI     0xFE
            LDMFD   SP!, {R7,LR}
            BX      LR


biosUninstall:
            MOV     R12, 3
            b driverfn_common
biosOpen:
            MOV     R12, 2
            b driverfn_common
biosInstall:
            MOV     R12, 1
driverfn_common:  
            MOV     R3, SP
            STR     LR, [SP,-8]!
            SWI     0xFF
            LDR     LR, [SP],8
            BX      LR

drivername: db "rightspatch",0
