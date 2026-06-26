// This code could be used as a template for your utf8.c, but it's not required.

#include <stdint.h>
#include <stdio.h>
#include "utf8.h"

void decode_utf8(const char* s) {
    size_t i = 0;
    while (s[i] != '\0') {
        unsigned char first = (unsigned char)s[i];

        if ((first & 0x80) == 0x00) {
            // 1-byte character (0xxxxxxx)
            uint32_t codepoint = first;

            report_character(codepoint, 1);
            i += 1;

        } else if ((first & 0xE0) == 0xC0) {
            // 2-byte character (110xxxxx 10xxxxxx)
            unsigned char second = (unsigned char)s[i + 1];
            uint32_t codepoint = ((first & 0x1F) << 6) | (second & 0x3F);

            report_character(codepoint, 2);
            i += 2;

        } else if ((first & 0xF0) == 0xE0) {
            // 3-byte character (1110xxxx 10xxxxxx 10xxxxxx)
            unsigned char second = (unsigned char)s[i + 1];
            unsigned char third = (unsigned char)s[i + 2];
            uint32_t codepoint = ((first & 0x0F) << 12) | ((second & 0x3F) << 6) | (third & 0x3F);

            report_character(codepoint, 3);
            i += 3;
            
        } else if ((first & 0xF8) == 0xF0) {
            // 4-byte character (11110xxx 10xxxxxx 10xxxxxx 10xxxxxx)
            unsigned char second = (unsigned char)s[i + 1];
            unsigned char third = (unsigned char)s[i + 2];
            unsigned char fourth = (unsigned char)s[i + 3];
            uint32_t codepoint = ((first & 0x07) << 18) | ((second & 0x3F) << 12) | ((third & 0x3F) << 6) | (fourth & 0x3F);

            report_character(codepoint, 4);
            i += 4;

        } else {
            printf("<li>Unknown byte, 0x%02hhx</li>\n", s[i]);
            i++;
        }
    }
}
