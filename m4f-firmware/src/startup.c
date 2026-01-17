/*
 * Startup code for AM62x Cortex-M4F
 * Handles initialization and vector table setup
 */

#include <stdint.h>

/* External symbols from linker script */
extern uint32_t _stack_top;
extern uint32_t _data_start;
extern uint32_t _data_end;
extern uint32_t _data_load;
extern uint32_t _bss_start;
extern uint32_t _bss_end;

/* Main function prototype */
extern int main(void);

/* Default handler for interrupts */
static void Default_Handler(void) {
    while (1) {
        /* Hang if unhandled interrupt occurs */
    }
}

/* Weak aliases for interrupt handlers */
void Reset_Handler(void);
void NMI_Handler(void) __attribute__((weak, alias("Default_Handler")));
void HardFault_Handler(void) __attribute__((weak, alias("Default_Handler")));
void MemManage_Handler(void) __attribute__((weak, alias("Default_Handler")));
void BusFault_Handler(void) __attribute__((weak, alias("Default_Handler")));
void UsageFault_Handler(void) __attribute__((weak, alias("Default_Handler")));
void SVC_Handler(void) __attribute__((weak, alias("Default_Handler")));
void DebugMon_Handler(void) __attribute__((weak, alias("Default_Handler")));
void PendSV_Handler(void) __attribute__((weak, alias("Default_Handler")));
void SysTick_Handler(void) __attribute__((weak, alias("Default_Handler")));
void MailboxIRQHandler(void) __attribute__((weak, alias("Default_Handler")));

/* Vector table */
__attribute__((section(".vector_table")))
void (* const vector_table[])(void) = {
    (void (*)(void))(&_stack_top),     /* Initial Stack Pointer */
    Reset_Handler,                      /* Reset Handler */
    NMI_Handler,                        /* NMI Handler */
    HardFault_Handler,                  /* Hard Fault Handler */
    MemManage_Handler,                  /* MPU Fault Handler */
    BusFault_Handler,                   /* Bus Fault Handler */
    UsageFault_Handler,                 /* Usage Fault Handler */
    0,                                  /* Reserved */
    0,                                  /* Reserved */
    0,                                  /* Reserved */
    0,                                  /* Reserved */
    SVC_Handler,                        /* SVCall Handler */
    DebugMon_Handler,                   /* Debug Monitor Handler */
    0,                                  /* Reserved */
    PendSV_Handler,                     /* PendSV Handler */
    SysTick_Handler,                    /* SysTick Handler */
    /* External Interrupts */
    MailboxIRQHandler,                  /* Mailbox IRQ */
};

/* Reset Handler - called at startup */
void Reset_Handler(void) {
    uint32_t *src, *dest;

    /* Copy data section from flash to RAM */
    src = &_data_load;
    dest = &_data_start;
    while (dest < &_data_end) {
        *dest++ = *src++;
    }

    /* Zero out BSS section */
    dest = &_bss_start;
    while (dest < &_bss_end) {
        *dest++ = 0;
    }

    /* Enable FPU (Floating Point Unit) for Cortex-M4F */
    /* CPACR: Coprocessor Access Control Register */
    volatile uint32_t *cpacr = (volatile uint32_t *)0xE000ED88;
    *cpacr |= (0xF << 20);  /* Enable CP10 and CP11 (FPU) */

    /* Call main */
    main();

    /* If main returns, hang */
    while (1);
}
