SWAP_DATA_BASE                   EQU 0x48101C00

SwappedOutFirst                  EQU SWAP_DATA_BASE+0x2
NbrOfSwappedInPages              EQU SWAP_DATA_BASE+0x6
NbrOfKickedOutPages              EQU SWAP_DATA_BASE+0xC
NbrOfLockedInPages               EQU SWAP_DATA_BASE+0xE
SwappedInFirst_p                 EQU SWAP_DATA_BASE+0xC4C
PageCacheTbl_p                   EQU SWAP_DATA_BASE+0x10
PagePoolTbl_p                    EQU SWAP_DATA_BASE+0x4C
fs_PageCacheMaxSize              EQU SWAP_DATA_BASE+0x18

EMP_STATIC_START                 EQU SWAP_DATA_BASE+0x28
EMP_STATIC_SIZE                  EQU SWAP_DATA_BASE+0x34
APP_STATIC_START                 EQU SWAP_DATA_BASE+0x2C
APP_STATIC_SIZE                  EQU SWAP_DATA_BASE+0x38

EMP_START_ADDR                   EQU 0x10000000
EMP_SIZE                         EQU 0x9C2000
EMP_END_ADDR                     EQU EMP_START_ADDR+EMP_SIZE

APP_START_ADDR                   EQU 0x14000000
APP_SIZE                         EQU 0x1EB9000
APP_END_ADDR                     EQU APP_START_ADDR+APP_SIZE

fs_memmap                        EQU 0x48014619
fs_GetMemMap                     EQU 0x48014DF5
fs_demand_cache_page             EQU 0x480011E5
fs_demand_pagePool_alloc_mem     EQU 0x48001D65
fs_demand_get_page_i_from_queue  EQU 0x48000CAF
fs_demand_remove_from_queue      EQU 0x480007F1
fs_demand_kick_out_page          EQU 0x48000871

delay                            EQU 0x101A1C54

PATCH_AUTO_RUN1                  EQU 0x158CD924

PCORE_TO_PATCH                   EQU 0x480254A1
