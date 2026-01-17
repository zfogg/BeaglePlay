/*
 * Utility functions for M4F firmware
 * Simple implementations for string formatting and helpers
 */

#include <stdint.h>
#include <stdarg.h>

/* Simple integer to string conversion */
static int itoa_simple(int value, char *buf, int base) {
    char temp[32];
    int i = 0;
    int is_negative = 0;

    if (value < 0 && base == 10) {
        is_negative = 1;
        value = -value;
    }

    if (value == 0) {
        temp[i++] = '0';
    } else {
        while (value > 0) {
            int digit = value % base;
            temp[i++] = (digit < 10) ? ('0' + digit) : ('a' + digit - 10);
            value /= base;
        }
    }

    if (is_negative) {
        temp[i++] = '-';
    }

    /* Reverse the string */
    int len = i;
    for (int j = 0; j < len; j++) {
        buf[j] = temp[len - 1 - j];
    }
    buf[len] = '\0';

    return len;
}

/* Simple snprintf implementation */
int snprintf(char *buf, int size, const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);

    int written = 0;
    const char *p = fmt;

    while (*p && written < size - 1) {
        if (*p == '%') {
            p++;
            if (*p == 's') {
                /* String */
                const char *s = va_arg(args, const char *);
                while (*s && written < size - 1) {
                    buf[written++] = *s++;
                }
            } else if (*p == 'd') {
                /* Signed decimal */
                int val = va_arg(args, int);
                char temp[32];
                int len = itoa_simple(val, temp, 10);
                for (int i = 0; i < len && written < size - 1; i++) {
                    buf[written++] = temp[i];
                }
            } else if (*p == 'u' || *p == 'l') {
                /* Unsigned decimal / long */
                uint32_t val = va_arg(args, uint32_t);
                char temp[32];
                int len = itoa_simple((int)val, temp, 10);
                for (int i = 0; i < len && written < size - 1; i++) {
                    buf[written++] = temp[i];
                }
            } else if (*p == 'x') {
                /* Hexadecimal */
                uint32_t val = va_arg(args, uint32_t);
                char temp[32];
                int len = itoa_simple((int)val, temp, 16);
                for (int i = 0; i < len && written < size - 1; i++) {
                    buf[written++] = temp[i];
                }
            } else if (*p == '%') {
                buf[written++] = '%';
            }
            p++;
        } else {
            buf[written++] = *p++;
        }
    }

    buf[written] = '\0';
    va_end(args);

    return written;
}

/* memcpy implementation */
void *memcpy(void *dest, const void *src, uint32_t n) {
    char *d = (char *)dest;
    const char *s = (const char *)src;

    while (n--) {
        *d++ = *s++;
    }

    return dest;
}

/* memset implementation */
void *memset(void *s, int c, uint32_t n) {
    unsigned char *p = (unsigned char *)s;

    while (n--) {
        *p++ = (unsigned char)c;
    }

    return s;
}

/* strcmp implementation */
int strcmp(const char *s1, const char *s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }

    return *(unsigned char *)s1 - *(unsigned char *)s2;
}

/* strncmp implementation */
int strncmp(const char *s1, const char *s2, uint32_t n) {
    while (n && *s1 && (*s1 == *s2)) {
        s1++;
        s2++;
        n--;
    }

    if (n == 0) {
        return 0;
    }

    return *(unsigned char *)s1 - *(unsigned char *)s2;
}

/* strlen implementation */
uint32_t strlen(const char *s) {
    uint32_t len = 0;

    while (*s++) {
        len++;
    }

    return len;
}
