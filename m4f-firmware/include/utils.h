/*
 * Utility function declarations for M4F firmware
 */

#ifndef UTILS_H
#define UTILS_H

#include <stdint.h>
#include <stdarg.h>

/* String and memory functions */
int snprintf(char *buf, int size, const char *fmt, ...);
void *memcpy(void *dest, const void *src, uint32_t n);
void *memset(void *s, int c, uint32_t n);
int strcmp(const char *s1, const char *s2);
int strncmp(const char *s1, const char *s2, uint32_t n);
uint32_t strlen(const char *s);

#endif /* UTILS_H */
