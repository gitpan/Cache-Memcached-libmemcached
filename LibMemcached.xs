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
Cache_LibMemcached_create(pkg)
        char *pkg;

void
Cache_LibMemcached_DESTROY(cache)
        Cache_LibMemcached *cache;

Cache_LibMemcached_rc
Cache_LibMemcached_server_add(cache, hostname, port)
        Cache_LibMemcached *cache;
        char *hostname;
        unsigned int port;

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

void
Cache_LibMemcached_get_raw(cache, key)
        Cache_LibMemcached *cache;
        SV *key;
    PREINIT:
        unsigned int flags;
        SV *value;
    PPCODE:
        value = Cache_LibMemcached_get_raw(cache, key, &flags);
        EXTEND( SP, 2 );
        PUSHs( value );
        PUSHs( newSViv(flags) );
