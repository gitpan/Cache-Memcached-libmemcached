/* $Id$
 *
 * Copyright (c) 2008 Daisuke Maki <daisuke@endeworks.jp>
 * All rights reserved
 */

#include "perl-libmemcached.h";

MODULE = Cache::Memcached::LibMemcached    PACKAGE = Cache::Memcached::LibMemcached   PREFIX = Cache_LibMemcached_

PROTOTYPES: DISABLE

BOOT:
    Cache_LibMemcached_bootstrap();

SV *
Cache_LibMemcached__XS_new(pkg, have_zlib, compress_enabled, compress_threshold, compress_savings)
        char *pkg;
        bool have_zlib;
        bool compress_enabled;
        size_t compress_threshold;
        float compress_savings;
    CODE:
        RETVAL = Cache_LibMemcached_create(pkg, have_zlib, compress_enabled, compress_threshold, compress_savings);
    OUTPUT:
        RETVAL

void
Cache_LibMemcached_DESTROY(cache)
        Cache_LibMemcached *cache;

void
Cache_LibMemcached_server_list_free(cache)
        Cache_LibMemcached *cache;

Cache_LibMemcached_rc
Cache_LibMemcached_server_add(cache, hostname, port)
        Cache_LibMemcached *cache;
        char *hostname;
        unsigned int port;

Cache_LibMemcached_rc
Cache_LibMemcached_server_add_unix_socket(cache, filename)
        Cache_LibMemcached *cache;
        char *filename;

Cache_LibMemcached_rc
Cache_LibMemcached_set(cache, key, value, expires = 0)
        Cache_LibMemcached *cache;
        SV *key;
        SV *value;
        time_t expires;

Cache_LibMemcached_rc
Cache_LibMemcached_add(cache, key, value, expires = 0)
        Cache_LibMemcached *cache;
        SV *key;
        SV *value;
        time_t expires;

Cache_LibMemcached_rc
Cache_LibMemcached_replace(cache, key, value, expires = 0)
        Cache_LibMemcached *cache;
        SV *key;
        SV *value;
        time_t expires;

SV *
Cache_LibMemcached_get(cache, key)
        Cache_LibMemcached *cache;
        SV *key;

SV *
Cache_LibMemcached_get_multi(cache, ...)
        Cache_LibMemcached *cache;
    PREINIT:
        char **keys;
        size_t *key_len_list;
        size_t keys_len = items - 1;
        int i;
    CODE:
        Newxz(keys, keys_len, char *);
        Newxz(key_len_list, keys_len, size_t);

        for(i = 0; i < keys_len; i++) {
            keys[i] = SvPV(ST(i + 1), key_len_list[i]);
        }

        RETVAL = Cache_LibMemcached_mget(cache, keys, key_len_list, keys_len);
        Safefree(keys);
        Safefree(key_len_list);
    OUTPUT:
        RETVAL

SV *
Cache_LibMemcached_delete(cache, key, expiration = 0)
        Cache_LibMemcached *cache;
        SV *key;
        time_t expiration;

SV *
Cache_LibMemcached_incr(cache, key, offset = 1)
        Cache_LibMemcached *cache;
        SV *key;
        unsigned int offset;

SV *
Cache_LibMemcached_decr(cache, key, offset = 1)
        Cache_LibMemcached *cache;
        SV *key;
        unsigned int offset;

Cache_LibMemcached_rc
Cache_LibMemcached_flush_all(cache, expiration = 0)
        Cache_LibMemcached *cache;
        time_t expiration;

void
Cache_LibMemcached_set_compress_threshold(cache, value)
        Cache_LibMemcached *cache;
        size_t value;
    CODE:
        MEMCACHED_COMPRESS_THRESHOLD(cache) = value;

IV
Cache_LibMemcached_get_compress_threshold(cache)
        Cache_LibMemcached *cache;
    CODE:
        RETVAL = MEMCACHED_COMPRESS_THRESHOLD(cache);
    OUTPUT:
        RETVAL

void
Cache_LibMemcached_set_compress_enabled(cache, value)
        Cache_LibMemcached *cache;
        bool value;
    CODE:
        MEMCACHED_COMPRESS_ENABLED(cache) = value;

bool
Cache_LibMemcached_get_compress_enabled(cache)
        Cache_LibMemcached *cache;
    CODE:
        RETVAL = MEMCACHED_COMPRESS_ENABLED(cache);
    OUTPUT:
        RETVAL

void
Cache_LibMemcached_set_compress_savings(cache, value)
        Cache_LibMemcached *cache;
        NV value;
    CODE:
        MEMCACHED_COMPRESS_SAVINGS(cache) = value;

NV
Cache_LibMemcached_get_compress_savings(cache)
        Cache_LibMemcached *cache;
    CODE:
        RETVAL = MEMCACHED_COMPRESS_SAVINGS(cache);
    OUTPUT:
        RETVAL

void
Cache_LibMemcached_set_no_block(cache, value)
        Cache_LibMemcached *cache;
        IV value;

IV
Cache_LibMemcached_is_no_block(cache)
        Cache_LibMemcached *cache;

void
Cache_LibMemcached_set_distribution_method(cache, value)
        Cache_LibMemcached *cache;
        IV value;

IV
Cache_LibMemcached_get_distribution_method(cache)
        Cache_LibMemcached *cache;

void
Cache_LibMemcached_set_hashing_algorithm(cache, value)
        Cache_LibMemcached *cache;
        IV value;

IV
Cache_LibMemcached_get_hashing_algorithm(cache)
        Cache_LibMemcached *cache;

SV *
Cache_LibMemcached_stats(cache)
        Cache_LibMemcached *cache;

void
Cache_LibMemcached_disconnect_all(cache)
        Cache_LibMemcached *cache;

