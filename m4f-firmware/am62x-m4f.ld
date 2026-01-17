/*
 * Linker script for AM62x Cortex-M4F
 * Defines memory layout and section placement
 */

/* Entry point */
ENTRY(Reset_Handler)

/* Memory layout for AM62x M4F */
MEMORY
{
    /* AM62x M4F actual memory regions from device tree:
     * reg = <0x00 0x5000000 0x00 0x30000 0x00 0x5040000 0x00 0x10000>;
     * reg-names = "iram", "dram";
     */
    IRAM (rwx)  : ORIGIN = 0x05000000, LENGTH = 192K  /* 0x30000 - Instruction RAM */
    DRAM (rwx)  : ORIGIN = 0x05040000, LENGTH = 64K   /* 0x10000 - Data RAM */
}

/* Stack size */
_stack_size = 4K;

SECTIONS
{
    /* Vector table must be at the beginning */
    .vector_table :
    {
        KEEP(*(.vector_table))
    } > IRAM

    /* Resource table for RemoteProc */
    .resource_table :
    {
        KEEP(*(.resource_table))
    } > IRAM

    /* Code section */
    .text :
    {
        . = ALIGN(4);
        *(.text)
        *(.text*)
        *(.rodata)
        *(.rodata*)
        . = ALIGN(4);
        _etext = .;
    } > IRAM

    /* Data section - initialized data */
    .data :
    {
        . = ALIGN(4);
        _data_start = .;
        *(.data)
        *(.data*)
        . = ALIGN(4);
        _data_end = .;
    } > DRAM AT> IRAM

    _data_load = LOADADDR(.data);

    /* BSS section - zero-initialized data */
    .bss :
    {
        . = ALIGN(4);
        _bss_start = .;
        *(.bss)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _bss_end = .;
    } > DRAM

    /* Stack */
    .stack (NOLOAD) :
    {
        . = ALIGN(8);
        . = . + _stack_size;
        . = ALIGN(8);
        _stack_top = .;
    } > DRAM

    /* Heap (if needed) */
    .heap (NOLOAD) :
    {
        . = ALIGN(4);
        _heap_start = .;
        /* Heap grows to end of DRAM */
        . = ORIGIN(DRAM) + LENGTH(DRAM);
        _heap_end = .;
    } > DRAM

    /* Debug sections */
    .comment 0 : { *(.comment) }
    .debug_info 0 : { *(.debug_info) }
    .debug_abbrev 0 : { *(.debug_abbrev) }
    .debug_line 0 : { *(.debug_line) }
    .debug_str 0 : { *(.debug_str) }
}
