/*
 * BeaglePlay M4F Sample Firmware
 * Demonstrates RPMsg communication with Linux host
 *
 * This firmware runs on the ARM Cortex-M4F core in the AM62x SoC
 * and communicates with the Linux host via RPMsg (Remote Processor Messaging)
 */

#include <stdint.h>
#include <stdbool.h>
#include "../include/utils.h"

/* Hardware register definitions for AM62x M4F */
#define UART_BASE       0x04A00000  /* MCU UART0 base address */
#define MAILBOX_BASE    0x29000000  /* Mailbox for IPC */

/* RPMsg configuration */
#define RPMSG_BUF_SIZE  512
#define VRING0_ID       0
#define VRING1_ID       1

/* Message buffer */
static char rx_buffer[RPMSG_BUF_SIZE];
static char tx_buffer[RPMSG_BUF_SIZE];

/* Counter for demonstration */
static volatile uint32_t tick_counter = 0;

/* Simple UART functions for debugging */
static void uart_init(void) {
    /* UART initialization would go here */
    /* For now, we'll rely on bootloader setup */
}

static void uart_putc(char c) {
    volatile uint32_t *uart_thr = (volatile uint32_t *)(UART_BASE + 0x00);
    volatile uint32_t *uart_lsr = (volatile uint32_t *)(UART_BASE + 0x14);

    /* Wait for TX FIFO to be ready */
    while ((*uart_lsr & 0x20) == 0);
    *uart_thr = c;
}

static void uart_puts(const char *str) {
    while (*str) {
        if (*str == '\n') uart_putc('\r');
        uart_putc(*str++);
    }
}

/* Simple delay function */
static void delay(uint32_t count) {
    volatile uint32_t i;
    for (i = 0; i < count; i++) {
        __asm__ __volatile__("nop");
    }
}

/* Forward declaration */
static int rpmsg_send(const char *msg, uint32_t len);

/* RPMsg callback - called when message received from Linux */
static void rpmsg_receive_callback(void *data, uint32_t len) {
    if (len >= RPMSG_BUF_SIZE) {
        len = RPMSG_BUF_SIZE - 1;
    }

    memcpy(rx_buffer, data, len);
    rx_buffer[len] = '\0';

    uart_puts("[M4F] Received: ");
    uart_puts(rx_buffer);
    uart_puts("\n");

    /* Process commands */
    if (strcmp(rx_buffer, "ping") == 0) {
        snprintf(tx_buffer, RPMSG_BUF_SIZE, "pong from M4F! Counter: %u", (unsigned int)tick_counter);
        /* Send response back to Linux */
        rpmsg_send(tx_buffer, strlen(tx_buffer));
    }
    else if (strcmp(rx_buffer, "status") == 0) {
        snprintf(tx_buffer, RPMSG_BUF_SIZE,
                 "M4F Status:\n"
                 "  Uptime ticks: %u\n"
                 "  Core: Cortex-M4F @ 400MHz\n"
                 "  Status: Running",
                 (unsigned int)tick_counter);
        rpmsg_send(tx_buffer, strlen(tx_buffer));
    }
    else if (strncmp(rx_buffer, "echo ", 5) == 0) {
        snprintf(tx_buffer, RPMSG_BUF_SIZE, "M4F Echo: %s", rx_buffer + 5);
        rpmsg_send(tx_buffer, strlen(tx_buffer));
    }
    else {
        snprintf(tx_buffer, RPMSG_BUF_SIZE,
                 "M4F: Unknown command '%s'. Try: ping, status, echo <msg>",
                 rx_buffer);
        rpmsg_send(tx_buffer, strlen(tx_buffer));
    }
}

/* Stub for RPMsg send - actual implementation depends on TI IPC library */
static int rpmsg_send(const char *msg, uint32_t len) {
    uart_puts("[M4F] Sending: ");
    uart_puts(msg);
    uart_puts("\n");

    /* Actual RPMsg send would use mailbox and shared memory */
    /* This is a placeholder for the real implementation */
    return 0;
}

/* Main M4F firmware entry point */
int main(void) {
    uart_init();
    uart_puts("\n\n");
    uart_puts("========================================\n");
    uart_puts("BeaglePlay M4F Firmware Starting\n");
    uart_puts("========================================\n");
    uart_puts("Core: ARM Cortex-M4F\n");
    uart_puts("Communication: RPMsg via shared memory\n");
    uart_puts("Ready to receive commands from Linux!\n");
    uart_puts("========================================\n\n");

    /* Initialize RPMsg communication */
    /* In real implementation, this would:
     * 1. Initialize mailbox interrupts
     * 2. Setup shared memory regions (vrings)
     * 3. Register RPMsg endpoints
     * 4. Signal Linux that M4F is ready
     */

    uart_puts("[M4F] RPMsg initialized\n");
    uart_puts("[M4F] Waiting for messages from Linux host...\n\n");

    /* Main loop */
    while (1) {
        tick_counter++;

        /* Check for incoming RPMsg messages */
        /* This would normally be interrupt-driven */

        /* Send periodic heartbeat every ~1 second */
        if ((tick_counter % 1000000) == 0) {
            snprintf(tx_buffer, RPMSG_BUF_SIZE,
                     "[M4F Heartbeat] Tick: %u", (unsigned int)tick_counter);
            uart_puts(tx_buffer);
            uart_puts("\n");

            /* Optionally send to Linux too */
            // rpmsg_send(tx_buffer, strlen(tx_buffer));
        }

        /* Small delay to prevent busy-waiting */
        delay(100);
    }

    return 0;
}

/* Interrupt handlers */
void MailboxIRQHandler(void) {
    /* Handle mailbox interrupt from Linux */
    /* Read message from vring and call rpmsg_receive_callback */
}
