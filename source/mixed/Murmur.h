#pragma once

#include <cstdint>

// fast and random enough hash function
// from https://en.wikipedia.org/wiki/MurmurHash
#define ROT32(x, y) ((x << y) | (x >> (32 - y))) // avoid effort
uint32_t murmur3_32(const char *key, uint32_t len, uint32_t seed);
