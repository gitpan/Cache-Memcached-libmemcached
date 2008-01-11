/* $Id$
 *
 * Copyright (c) 2008 Daisuke Maki <daisuke@endeworks.jp>
 * All rights reserved
 */

#ifndef __PERL_LIBMEMCACHED_C__
#define __PERL_LIBMEMCACHED_C__
#include "perl-libmemcached.h"

#define CONSTSUBi(name, x) \
    newCONSTSUB(stash, name, newSViv(x));

void
Cache_LibMemcached_bootstrap()
{
    HV *stash;

    stash = gv_stashpv("Cache::Memcached::LibMemcached", 1);

    CONSTSUBi( "F_STORABLE", F_STORABLE );
    CONSTSUBi( "F_COMPRESS", F_COMPRESS );

    /* There has to be an easier way, eh? */
    CONSTSUBi( "MEMCACHED_SUCCESS", MEMCACHED_SUCCESS );
    CONSTSUBi( "MEMCACHED_FAILURE", MEMCACHED_FAILURE );
    CONSTSUBi( "MEMCACHED_HOST_LOOKUP_FAILURE", MEMCACHED_HOST_LOOKUP_FAILURE );
    CONSTSUBi( "MEMCACHED_CONNECTION_BIND_FAILURE", MEMCACHED_CONNECTION_BIND_FAILURE );
    CONSTSUBi( "MEMCACHED_WRITE_FAILURE", MEMCACHED_WRITE_FAILURE );
    CONSTSUBi( "MEMCACHED_READ_FAILURE", MEMCACHED_READ_FAILURE );
    CONSTSUBi( "MEMCACHED_UNKNOWN_READ_FAILURE", MEMCACHED_UNKNOWN_READ_FAILURE );
    CONSTSUBi( "MEMCACHED_PROTOCOL_ERROR", MEMCACHED_PROTOCOL_ERROR );
    CONSTSUBi( "MEMCACHED_CLIENT_ERROR", MEMCACHED_CLIENT_ERROR );
    CONSTSUBi( "MEMCACHED_SERVER_ERROR", MEMCACHED_SERVER_ERROR );
    CONSTSUBi( "MEMCACHED_CONNECTION_SOCKET_CREATE_FAILURE", MEMCACHED_CONNECTION_SOCKET_CREATE_FAILURE );
    CONSTSUBi( "MEMCACHED_DATA_EXISTS", MEMCACHED_DATA_EXISTS );
    CONSTSUBi( "MEMCACHED_DATA_DOES_NOT_EXIST", MEMCACHED_DATA_DOES_NOT_EXIST );
    CONSTSUBi( "MEMCACHED_NOTSTORED", MEMCACHED_NOTSTORED );
    CONSTSUBi( "MEMCACHED_STORED", MEMCACHED_STORED );
    CONSTSUBi( "MEMCACHED_NOTFOUND", MEMCACHED_NOTFOUND );
    CONSTSUBi( "MEMCACHED_MEMORY_ALLOCATION_FAILURE", MEMCACHED_MEMORY_ALLOCATION_FAILURE );
    CONSTSUBi( "MEMCACHED_PARTIAL_READ", MEMCACHED_PARTIAL_READ );
    CONSTSUBi( "MEMCACHED_SOME_ERRORS", MEMCACHED_SOME_ERRORS );
    CONSTSUBi( "MEMCACHED_NO_SERVERS", MEMCACHED_NO_SERVERS );
    CONSTSUBi( "MEMCACHED_END", MEMCACHED_END );
    CONSTSUBi( "MEMCACHED_DELETED", MEMCACHED_DELETED );
    CONSTSUBi( "MEMCACHED_VALUE", MEMCACHED_VALUE );
    CONSTSUBi( "MEMCACHED_STAT", MEMCACHED_STAT );
    CONSTSUBi( "MEMCACHED_ERRNO", MEMCACHED_ERRNO );
    CONSTSUBi( "MEMCACHED_FAIL_UNIX_SOCKET", MEMCACHED_FAIL_UNIX_SOCKET );
    CONSTSUBi( "MEMCACHED_NOT_SUPPORTED", MEMCACHED_NOT_SUPPORTED );
    CONSTSUBi( "MEMCACHED_NO_KEY_PROVIDED", MEMCACHED_NO_KEY_PROVIDED );
    CONSTSUBi( "MEMCACHED_FETCH_NOTFINISHED", MEMCACHED_FETCH_NOTFINISHED );
    CONSTSUBi( "MEMCACHED_TIMEOUT", MEMCACHED_TIMEOUT );
    CONSTSUBi( "MEMCACHED_MAXIMUM_RETURN", MEMCACHED_MAXIMUM_RETURN );
}

SV *
Cache_LibMemcached_create(pkg)
        char *pkg;
{
    SV *sv;
    memcached_st *cache;

    cache = memcached_create(NULL);
    XS_STRUCT2OBJ(sv, "Cache::Memcached::LibMemcached::Backend", cache);

    return sv;
}

void
Cache_LibMemcached_DESTROY(cache)
        Cache_LibMemcached *cache;
{
    memcached_free(cache);
}

memcached_return
Cache_LibMemcached_server_add(cache, hostname, port)
        Cache_LibMemcached *cache;
        char *hostname;
        unsigned int port;
{
    return memcached_server_add(cache, hostname, port);
}

memcached_return
Cache_LibMemcached_server_add_unix_socket(cache, filename)
        Cache_LibMemcached *cache;
        char *filename;
{
}

memcached_return
Cache_LibMemcached_set_raw(cache, key, value, expires, flags)
        Cache_LibMemcached *cache;
        SV *key;
        SV *value;
        time_t expires;
        unsigned int flags;
{
    STRLEN key_len, value_len;
    char *key_char;
    char *value_char;

    key_char = SvPVbyte(key, key_len);
    value_char = SvPVbyte(value, value_len);

    return memcached_set(cache, key_char, key_len, value_char, value_len, expires, flags);
}

SV *
Cache_LibMemcached_get_raw(cache, key, flags)
        Cache_LibMemcached *cache;
        SV *key;
        unsigned int *flags;
{
    STRLEN key_len;
    size_t value_len = 0;
    char *key_char, *value;
    Cache_LibMemcached_rc rc;
    SV *sv;

    key_char = SvPVbyte(key, key_len);
    
    value = memcached_get(cache, key_char, key_len, &value_len, flags, &rc);
    if (!value || rc != MEMCACHED_SUCCESS) {
        return &PL_sv_undef;
    }
    sv = newSVpv(value, value_len);
    return sv;
}

#endif /* __PERL_LIBMEMCACHED_C__ */
