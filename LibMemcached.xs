/* $Id$
 *
 * Copyright (c) 2008 Daisuke Maki <daisuke@endeworks.jp>
 * All rights reserved
 */

#include "perl-libmemcached.h";

MODULE = Cache::Memcached::LibMemcached    PACKAGE = Cache::Memcached::LibMemcached::Backend   PREFIX = Cache_LibMemcached_

PROTOTYPES: DISABLE

BOOT:
    Cache_LibMemcached_bootstrap();

SV *
Cache_LibMemcached_create(pkg, have_zlib)
        char *pkg;
        bool have_zlib;

void
Cache_LibMemcached_DESTROY(cache)
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
Cache_LibMemcached_set_raw(cache, key, value, expires, flags)
        Cache_LibMemcached *cache;
        SV *key;
        SV *value;
        time_t expires;
        unsigned int flags;
    CODE:
        RETVAL = Cache_LibMemcached_set_raw(cache, key, value, expires, flags);
    OUTPUT:
        RETVAL

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

