/*
 * Resource table for M4F RemoteProc
 * Defines memory regions and vring buffers for RPMsg
 */

#include <stdint.h>
#include <stddef.h>

/* Resource table structure */
struct resource_table {
    uint32_t ver;
    uint32_t num;
    uint32_t reserved[2];
    uint32_t offset[1];
} __attribute__((packed));

/* Carveout entry for memory regions */
struct fw_rsc_carveout {
    uint32_t type;
    uint32_t da;
    uint32_t pa;
    uint32_t len;
    uint32_t flags;
    uint32_t reserved;
    char name[32];
} __attribute__((packed));

/* Resource types */
#define RSC_CARVEOUT    0
#define RSC_DEVMEM      1
#define RSC_TRACE       2
#define RSC_VDEV        3

/* Define the complete structure type first */
struct ti_ipc_resource_table {
    struct resource_table base;
    struct fw_rsc_carveout code_data;
};

/* The resource table */
__attribute__((section(".resource_table"), used))
struct ti_ipc_resource_table ti_ipc_remoteproc_ResourceTable = {
    .base = {
        .ver = 1,
        .num = 1,
        .reserved = {0, 0},
        .offset = {offsetof(struct ti_ipc_resource_table, code_data)},
    },
    .code_data = {
        .type = RSC_CARVEOUT,
        .da = 0x05000000,     /* Device address - M4F IRAM base */
        .pa = 0x00000000,     /* Physical address (filled by RemoteProc) */
        .len = 0x50000,       /* 320KB - covers IRAM (192K) + DRAM (64K) + gap */
        .flags = 0,
        .reserved = 0,
        .name = "M4F_CODE_DATA",
    },
};
