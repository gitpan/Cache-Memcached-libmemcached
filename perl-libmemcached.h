/* $Id$
 *
 * Copyright (c) 2008 Daisuke Maki <daisuke@endeworks.jp>
 * All rights reserved
 */

#ifndef __PERL_LIBMEMCACHED_H__
#define __PERL_LIBMEMCACHED_H__
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#define NEED_newRV_noinc
#define NEED_sv_2pv_nolen
#include "ppport.h"
#include <libmemcached/memcached.h>

#define XS_STATE(type, x) \
    INT2PTR(type, SvROK(x) ? SvIV(SvRV(x)) : SvIV(x))

#define XS_STRUCT2OBJ(sv, class, obj) \
    sv = newSViv(PTR2IV(obj));  \
    sv = newRV_noinc(sv); \
    sv_bless(sv, gv_stashpv(class, 1)); \
    SvREADONLY_on(sv);

#define F_STORABLE 1
#define F_COMPRESS 2

typedef struct Cache_LibMemcached {
    memcached_st *memcached;
    bool          have_zlib;
} Cache_LibMemcached;

#define MEMCACHED_CACHE(x) x->memcached
#define MEMCACHED_HAVE_ZLIB(x) x->have_zlib

typedef memcached_return Cache_LibMemcached_rc;

SV *Cache_LibMemcached_create();
void Cache_LibMemcached_DESTROY(Cache_LibMemcached *cache);
Cache_LibMemcached_rc Cache_LibMemcached_server_add(Cache_LibMemcached *cache, char *hostname, unsigned int port);

Cache_LibMemcached_rc Cache_LibMemcached_set_raw(
    Cache_LibMemcached *cache,
    SV *key,
    SV *value,
    time_t expires,
    unsigned int flags
);

SV * Cache_LibMemcached_get(
    Cache_LibMemcached *cache,
    SV *key
);

SV * Cache_LibMemcached_mget(
    Cache_LibMemcached *cache,
    char **keys,
    size_t *key_len_list,
    unsigned int keys_len
);

SV * Cache_LibMemcached_delete(
    Cache_LibMemcached *cache,
    SV *key,
    time_t expiration
);

SV *
Cache_LibMemcached_incr(
    Cache_LibMemcached *cache,
    SV *key_sv,
    unsigned int offset
);

SV *
Cache_LibMemcached_decr(
    Cache_LibMemcached *cache,
    SV *key_sv,
    unsigned int offset
);

#endif /* __PERL_LIBMEMCACHED_H__ */