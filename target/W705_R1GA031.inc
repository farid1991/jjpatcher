SWAP_DATA_BASE                   EQU 0x480C2C00

SwappedOutFirst                  EQU SWAP_DATA_BASE+0x2
NbrOfSwappedInPages              EQU SWAP_DATA_BASE+0x6
NbrOfKickedOutPages              EQU SWAP_DATA_BASE+0xC
NbrOfLockedInPages               EQU SWAP_DATA_BASE+0xE
SwappedInFirst_p                 EQU SWAP_DATA_BASE+0x10
PageCacheTbl_p                   EQU SWAP_DATA_BASE+0x50
PagePoolTbl_p                    EQU SWAP_DATA_BASE+0x60
fs_PageCacheMaxSize              EQU SWAP_DATA_BASE+0x58

EMP_STATIC_START                 EQU SWAP_DATA_BASE+0xCA8
APP_STATIC_START                 EQU SWAP_DATA_BASE+0xCAC
EMP_STATIC_SIZE                  EQU SWAP_DATA_BASE+0xCB4
APP_STATIC_SIZE                  EQU SWAP_DATA_BASE+0xCB8

EMP_START_ADDR                   EQU 0x10000000
EMP_SIZE                         EQU 0x818000
EMP_END_ADDR                     EQU EMP_START_ADDR+EMP_SIZE

APP_START_ADDR                   EQU 0x14000000
APP_SIZE                         EQU 0x1CE3000
APP_END_ADDR                     EQU APP_START_ADDR+APP_SIZE

fs_memmap                        EQU 0x48027B1D
fs_GetMemMap                     EQU 0x4802842D
fs_demand_cache_page             EQU 0x48011759
fs_demand_pagePool_alloc_mem     EQU 0x480119BD
fs_demand_get_page_i_from_queue  EQU 0x480114A5
fs_demand_remove_from_queue      EQU 0x48011139
fs_demand_kick_out_page          EQU 0x480111D5

delay                            EQU 0x101CEB38

PATCH_AUTO_RUN1                  EQU 0x15BCE778

PCORE_TO_PATCH                   EQU 0x4803A9CB
