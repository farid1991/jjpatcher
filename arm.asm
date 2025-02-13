;array_struct
;{
;	int dataNum;
;	struct data
;	{
;		int virtAddr;
;		char oldByte
;		char newByte
;		char null1;
;		char null2;
;	}
;}

;arm
include "include\x.inc"
include "include\common.inc"
include "target\%target%.inc"


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
	stmfd sp!,{r0-r11,lr}

	mov r7,r0

	mov r2,3
	adr r1,rightspatch
	adr r0,drivername
	bl biosInstall

	adr r0,drivername
	bl biosOpen
        
	;mov r1,fnnumber
	bl bioscall
	mov r6,r0

	adr r0,drivername
	bl biosUninstall


	;saverights r6
	bl intr_off
	mov r8, r0
        savedacr r5
	stmfd sp!,{r5,r6}

;r7 - data array
;insert your code here
	ldr r1, _PCORE_TO_PATCH
	mov r0, 0xE0
	strb r0, [r1]		;skip pool clean
	mov r4, 0		;curent page addr

	ldmia r7!,{r10}		;load size (counter)
.ploop:
	subs r10, r10,1		;decrease counter
	bmi .out

	ldm r7, {r1}
	ldr r3, _PAGE_ALIGN_MASK
	and r2, r1,r3
	cmp r4, r2
	beq .patch		;if page already maped (for consecutive bytes in patch)
	mov r4, r2		;update current page addr

	mov r0, r4
	mov r1, 0x0
	ldr r2, _fs_GetMemMap
	blx r2
	movs r5, r0			;physAddr
	bne .memmap_exists		;if memmap exists


	mov r3, CXC_BASE_ADDR_MASK
	and r2, r4,r3
	mov r3, EMP_START_ADDR
	cmp r2, r3
	ldreq r3, _EMP_END_ADDR
	ldrne r3, _APP_END_ADDR
	cmp r4, r3
	bge .create_page_map
	mov r0, r4
	mov r1, 0x6
	mov r2, r8
	ldr r3, _fs_demand_cache_page
	blx r3
	b .prepatch

.create_page_map:
	ldr r0, _SwappedOutFirst
	mov r1, 0x0
	mov r2, 0x20
	ldr r3, _fs_demand_get_page_i_from_queue
	blx r3
	mov r6, r0			;swap_i
	mov r1, 0xFF
	orr r1, r1,0xFF00
	cmp r0, r1
	bne .i_received
	ldr r0, _SwappedInFirst_p
	mov r1, 0x0
	ldr r2, _NbrOfSwappedInPages
	ldrh r2, [r2]
	ldr r3, _fs_demand_get_page_i_from_queue
	blx r3
	mov r6, r0
	mov r1, r8
	ldr r2, _fs_demand_kick_out_page
	blx r2

.i_received:
	ldr r1, _PagePoolTbl_p
	lsr r0, r6,7
	mov r2, POOL_PAGE_ELEM_SIZE
	mla r9, r2, r0, r1		;pool_p
	ldr r0, [r9,0x8]
	cmp r0, 0x0
	moveq r0, r9
	moveq r1, r8
	ldreq r2, _fs_demand_pagePool_alloc_mem
	blxeq r2
	ldrh r0, [r9,0x4]
	add r0, r0,0x1
	strh r0, [r9,0x4]
	and r0, r6,0x7F
	ldr r1, [r9,0x8]
	add r1, r1, r0,lsl 10
	mov r0, r4
	mov r2, PAGE_SIZE
	mov r3, 0x1B
	ldr r12, _fs_memmap
	blx r12
	ldr r0, _PageCacheTbl_p
	ldr r0, [r0]
	mov r1, PAGE_CACHE_ELEM_SIZE
	mla r2, r6, r1, r0		;page_p
	str r4, [r2,0x0]
	mov r0, r2
	mov r1, 0xFF
	orr r1, r1,0xFF00
	ldr r2, _fs_demand_remove_from_queue
	blx r2
	ldr r1, _NbrOfKickedOutPages
	ldrh r0, [r1,0x0]
	sub r0, r0,1
	strh r0, [r1,0x0]
	ldr r1, _NbrOfLockedInPages
	ldrh r0, [r1,0x0]
	add r0, r0,1
	strh r0, [r1,0x0]
	b .prepatch

.memmap_exists:
	mov r3, CXC_BASE_ADDR_MASK
	and r2, r4,r3
	mov r3, EMP_START_ADDR
	cmp r2, r3
	ldreq r3, _EMP_STATIC_START
	ldreq r2, [r3]
	ldreq r3, _EMP_STATIC_SIZE
	ldreq r3, [r3]
	addeq r3, r3,r2
	ldrne r3, _APP_STATIC_START
	ldrne r2, [r3]
	ldrne r3, _APP_STATIC_SIZE
	ldrne r3, [r3]
	addne r3, r3,r2
	cmp r4, r3
	bmi .patch
	mov r0, r5
	bl get_page_i
	mov r11, r0			;page_i
	ldr r0, _PageCacheTbl_p
	ldr r0, [r0]
	mov r1, PAGE_CACHE_ELEM_SIZE
	mla r2, r11, r1, r0		;page_p
	mov r1, 0xFF
	orr r1, r1,0xFF00
	ldrh r0, [r2,0x4]		;prev_i
	cmp r1, r0
	bne .kick_out_and_cache
	ldrh r0, [r2,0x6]		;next_i
	cmp r1, r0
	beq .prepatch			;page cached and locked

.kick_out_and_cache:
	mov r0, r11
	mov r1, r8
	ldr r2, _fs_demand_kick_out_page
	blx r2
	mov r0, r4
	mov r1, 0x6
	mov r2, r8
	ldr r3, _fs_demand_cache_page
	blx r3	

.prepatch:
	mov r0, 5
	ldr r1, _delay
	blx r1

.patch:
	ldmia r7!,{r1,r2}
	lsr r2, r2,8
	strb r2,[r1]
	b .ploop

.out:
	ldmfd sp!,{r5,r6}
	loaddacr r5
	mov r0, r8
	bl intr_restore
	loadrights r6

;init elfpack
	ldr r0, _PATCH_AUTO_RUN1
	ldr r0, [r0]
	cmp r0, 0x0
	blxne r0

        ldmfd sp!,{r0-r11,pc}


get_page_i:
	stmfd sp!, {r3-r7,lr}

	mov r4, r0			;physAddr
	ldr r0, _fs_PageCacheMaxSize
	ldr r0, [r0]
	lsr r5, r0,7			;max_pool_i
	mov r6, 0			;i

.get_page_i_loop:
	cmp r6, r5
	beq .get_page_i_exit
	ldr r1, _PagePoolTbl_p
	mov r0, POOL_PAGE_ELEM_SIZE
	mla r7, r6, r0, r1		;pool_p
	ldr r1, _PHYS_BASE_ADDR_MASK
	and r0, r4,r1			;physAddr aligned
	ldr r2, [r7,0x8]		;baseAddr
	cmp r2, r0
	beq .get_page_i_success
	mov r1, BLOCK_SIZE
	sub r0, r0,r1
	cmp r2, r0
	beq .get_page_i_success
	add r6, r6,1
	b .get_page_i_loop

.get_page_i_success:
	sub r4, r4,r2
	lsr r4, r4,10
	mov r1, POOL_SIZE
	mla r0, r6,r1,r4

.get_page_i_exit:
	ldmfd sp!, {r3-r7,pc}


setdacr:
        mrc p15, 0, r0, c3, c0, 0 ;save old dacr
        mvn r1,0
        mcr p15, 0, r1, c3, c0, 0 ;set dacr
        bx lr


intr_off:
	mrs r0, CPSR
	orr r12, r0, 0xc0
	msr CPSR_c, r12
	ands r0, r0, 0xc0
	bx lr


intr_restore:
	ands r0, r0, 0xc0
	mrs r12, CPSR
	bic r12, r12, 0xc0
	orr r12, r12, r0
	msr CPSR_c, r12
	bx lr



rightspatch:
            STMFD   SP!, {R1}
            ldr     r0,[sp,4]
            bic     r1, r0, 0x1f
            orr     r1, r1, 0x13
            str     r1,[sp,4]
            LDMFD   SP!, {R1}
            BX      LR            


bioscall:
            STMFD   SP!, {R7,LR}
            MOV     R7, r1
            mov     r12, r0
            SWI     0xFF
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

align 4
_fs_GetMemMap: dw fs_GetMemMap
_fs_demand_cache_page: dw fs_demand_cache_page
_fs_demand_get_page_i_from_queue: dw fs_demand_get_page_i_from_queue
_fs_demand_pagePool_alloc_mem: dw fs_demand_pagePool_alloc_mem
_fs_memmap: dw fs_memmap
_fs_demand_remove_from_queue: dw fs_demand_remove_from_queue
_fs_demand_kick_out_page: dw fs_demand_kick_out_page

_delay: dw delay


_SwappedOutFirst: dw SwappedOutFirst
_SwappedInFirst_p: dw SwappedInFirst_p
_NbrOfSwappedInPages: dw NbrOfSwappedInPages
_NbrOfKickedOutPages: dw NbrOfKickedOutPages
_NbrOfLockedInPages: dw NbrOfLockedInPages
_PagePoolTbl_p: dw PagePoolTbl_p
_PageCacheTbl_p: dw PageCacheTbl_p
_fs_PageCacheMaxSize: dw fs_PageCacheMaxSize
_PAGE_ALIGN_MASK: dw PAGE_ALIGN_MASK
_EMP_END_ADDR: dw EMP_END_ADDR
_APP_END_ADDR: dw APP_END_ADDR
_EMP_STATIC_START: dw EMP_STATIC_START
_EMP_STATIC_SIZE: dw EMP_STATIC_SIZE
_APP_STATIC_START: dw APP_STATIC_START
_APP_STATIC_SIZE: dw APP_STATIC_SIZE

_PHYS_BASE_ADDR_MASK: dw PHYS_BASE_ADDR_MASK

_PATCH_AUTO_RUN1: dw PATCH_AUTO_RUN1

_PCORE_TO_PATCH: dw PCORE_TO_PATCH
