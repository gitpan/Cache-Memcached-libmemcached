/* $Id$
 *
 * Copyright (c) 2008 Daisuke Maki <daisuke@endeworks.jp>
 * All rights reserved
 */

#ifndef __PERL_LIBMEMCACHED_C__
#define __PERL_LIBMEMCACHED_C__
#include "perl-libmemcached.h"

#define CONSTSUBi(name, x) \
    { \
        SV *sv = newSViv(x); \
        newCONSTSUB(stash, name, sv); \
        av_push(export, sv); \
    }

void
Cache_LibMemcached_bootstrap()
{
    HV *stash;
    AV *export;

    stash = gv_stashpv("Cache::Memcached::LibMemcached::Constants", 1);
    export = get_av("Cache::Memcached::LibMemcached::Constants::EXPORT_OK", 1);

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

/* The next functions (compress, uncompress, freeze, thaw) are implemented
 * as simple static method calls emulating a Perl method calls to
 * Compress::Zlib and Storable, respectively
 */

inline static void
Cache_LibMemcached_uncompress(cache, value, value_len, flags)
        Cache_LibMemcached *cache;
        char **value;
        size_t *value_len;
        uint16_t flags;
{
    if (MEMCACHED_HAVE_ZLIB(cache) && (flags & F_COMPRESS)) {
        SV *sv;
        dSP;

        ENTER;
        SAVETMPS;

        PUSHMARK(SP);
        EXTEND(SP, 1);
        PUSHs(sv_2mortal(newSVpv(*value, *value_len)));
        PUTBACK;

        if (call_pv("Compress::Zlib::memGunzip", G_SCALAR) <= 0) {
            croak("Compress::Zlib::memGunzip did not return a proper value");
        }
        SPAGAIN;

        sv = POPs;
        *value = SvPV(sv, *value_len);

        FREETMPS;
        LEAVE;
    }
}

inline static void
Cache_LibMemcached_thaw(cache, sv, flags)
        Cache_LibMemcached *cache;
        SV *sv;
        uint16_t flags;
{
    if (flags & F_STORABLE) {
        SV *rv;
        dSP;
        ENTER;
        SAVETMPS;

        PUSHMARK(SP);
        EXTEND(SP, 1);
        PUSHs(sv);
        PUTBACK;

        if (call_pv("Storable::thaw", G_SCALAR) <= 0) {
            croak("Storable::thaw did not return a proper value");
        }
        SPAGAIN;

        rv = POPs;
        
        SvSetSV(sv, rv);

        FREETMPS;
        LEAVE;
    }
}

inline static void
Cache_LibMemcached_freeze(cache, sv, flags)
        Cache_LibMemcached *cache;
        SV *sv;
        uint16_t *flags;
{
    if (SvROK(sv)) {
        SV *rv;
        dSP;
        ENTER;
        SAVETMPS;

        PUSHMARK(SP);
        EXTEND(SP, 1);
        PUSHs(sv);
        PUTBACK;

        if (call_pv("Storable::freeze", G_SCALAR) <= 0) {
            croak("Storable::freeze did not return a proper value");
        }
        SPAGAIN;

        rv = POPs;
        
        SvSetSV(sv, rv);

        FREETMPS;
        LEAVE;

        *flags |= F_STORABLE;
    }
}

inline static void
Cache_LibMemcached_compress(cache, sv, flags)
        Cache_LibMemcached *cache;
        SV *sv;
        uint16_t *flags;
{
    size_t compress_threshold;
    bool   compress_enabled;
    size_t sv_length = sv_len(sv);

    compress_threshold = MEMCACHED_COMPRESS_THRESHOLD(cache);
    if (MEMCACHED_HAVE_ZLIB(cache) && 
        MEMCACHED_COMPRESS_ENABLED(cache) &&
        compress_threshold > 0 &&
        sv_length > compress_threshold
    ) {
        SV *rv;
        size_t rv_length;
        dSP;

        ENTER;
        SAVETMPS;

        PUSHMARK(SP);
        EXTEND(SP, 1);
        PUSHs(sv);
        PUTBACK;

        if (call_pv("Compress::Zlib::memGzip", G_SCALAR) <= 0) {
            croak("Compress::Zlib::memGzip did not return a proper value");
        }
        SPAGAIN;

        rv = POPs;
        rv_length = SvCUR(rv);

        /* We won't reset the contents of the original SV unless
         * the savings are actually greater than the savings threshold
         */
        if (rv_length < sv_length * ( 1 - MEMCACHED_COMPRESS_SAVINGS(cache) ) ) {
            SvSetSV(sv, rv);
            *flags |= F_COMPRESS;
        }
        FREETMPS;
        LEAVE;

    }
}

Cache_LibMemcached_rc
Cache_LibMemcached_set(cache, key, value, expires)
        Cache_LibMemcached *cache;
        SV *key;
        SV *value;
        time_t expires;
{
    STRLEN key_len, value_len;
    char *key_char;
    char *value_char;
    uint16_t flags = 0;
    SV *value_copy;

    value_copy = newSVsv(value);

    Cache_LibMemcached_freeze(cache, value_copy, &flags);
    Cache_LibMemcached_compress(cache, value_copy, &flags);

    key_char = SvPVbyte(key, key_len);
    value_char = SvPVbyte(value_copy, value_len);

    return memcached_set(MEMCACHED_CACHE(cache), key_char, key_len, value_char, value_len, expires, flags);
}

Cache_LibMemcached_rc
Cache_LibMemcached_add(cache, key, value, expires)
        Cache_LibMemcached *cache;
        SV *key;
        SV *value;
        time_t expires;
{
    STRLEN key_len, value_len;
    char *key_char;
    char *value_char;
    uint16_t flags = 0;
    SV *value_copy;

    value_copy = newSVsv(value);

    Cache_LibMemcached_freeze(cache, value_copy, &flags);
    Cache_LibMemcached_compress(cache, value_copy, &flags);

    key_char = SvPVbyte(key, key_len);
    value_char = SvPVbyte(value_copy, value_len);

    return memcached_add(MEMCACHED_CACHE(cache), key_char, key_len, value_char, value_len, expires, flags);
}

Cache_LibMemcached_rc
Cache_LibMemcached_replace(cache, key, value, expires)
        Cache_LibMemcached *cache;
        SV *key;
        SV *value;
        time_t expires;
{
    STRLEN key_len, value_len;
    char *key_char;
    char *value_char;
    uint16_t flags = 0;
    SV *value_copy;

    value_copy = newSVsv(value);

    Cache_LibMemcached_freeze(cache, value_copy, &flags);
    Cache_LibMemcached_compress(cache, value_copy, &flags);

    key_char = SvPVbyte(key, key_len);
    value_char = SvPVbyte(value_copy, value_len);

    return memcached_set(MEMCACHED_CACHE(cache), key_char, key_len, value_char, value_len, expires, flags);
}

SV *
Cache_LibMemcached_create(pkg, have_zlib, compress_enabled, compress_threshold, compress_savings)
        char *pkg;
        bool have_zlib;
        bool compress_enabled;
        size_t compress_threshold;
        float compress_savings;
{
    SV *sv;
    Cache_LibMemcached *xs;
    memcached_st *cache;

    Newxz(xs, 1, Cache_LibMemcached);

    MEMCACHED_CACHE(xs)              = memcached_create(NULL);
    MEMCACHED_HAVE_ZLIB(xs)          = have_zlib;
    MEMCACHED_COMPRESS_ENABLED(xs)   = compress_enabled;
    MEMCACHED_COMPRESS_THRESHOLD(xs) = compress_threshold;
    MEMCACHED_COMPRESS_SAVINGS(xs)   = compress_savings;

    XS_STRUCT2OBJ(sv, "Cache::Memcached::LibMemcached", xs);

    return sv;
}

void
Cache_LibMemcached_DESTROY(cache)
        Cache_LibMemcached *cache;
{
    memcached_free(MEMCACHED_CACHE(cache));
}

Cache_LibMemcached_rc
Cache_LibMemcached_server_add(cache, hostname, port)
        Cache_LibMemcached *cache;
        char *hostname;
        unsigned int port;
{
    return memcached_server_add(MEMCACHED_CACHE(cache), hostname, port);
}

Cache_LibMemcached_rc
Cache_LibMemcached_server_add_unix_socket(cache, filename)
        Cache_LibMemcached *cache;
        char *filename;
{
    return memcached_server_add_unix_socket(MEMCACHED_CACHE(cache), filename);
}

unsigned int
Cache_LibMemcached_server_list_count(cache)
        Cache_LibMemcached *cache;
{
    return memcached_server_list_count( MEMCACHED_CACHE(cache)->hosts );
}

void
Cache_LibMemcached_server_list_free(cache)
        Cache_LibMemcached *cache;
{
    memcached_server_list_free( MEMCACHED_CACHE(cache)->hosts );
}

SV *
Cache_LibMemcached_get(cache, key)
        Cache_LibMemcached *cache;
        SV *key;
{
    STRLEN key_len;
    size_t value_len = 0;
    char *key_char, *value;
    Cache_LibMemcached_rc rc;
    uint16_t flags;
    SV *sv;

    key_char = SvPVbyte(key, key_len);
    
    value = memcached_get(MEMCACHED_CACHE(cache), key_char, key_len, &value_len, &flags, &rc);
    if (!value || rc != MEMCACHED_SUCCESS) {
        return &PL_sv_undef;
    }

    Cache_LibMemcached_uncompress( cache, &value, &value_len, flags );
    sv = newSVpv(value, value_len);

    Cache_LibMemcached_thaw( cache, sv, flags );

    return sv;
}

SV *
Cache_LibMemcached_mget(cache, keys, key_len_list, keys_len)
        Cache_LibMemcached *cache;
        char **keys;
        size_t *key_len_list;
        unsigned int keys_len;
{
    Cache_LibMemcached_rc rc;
    HV *hv;
    unsigned int i;

    rc = memcached_mget(MEMCACHED_CACHE(cache), keys, key_len_list, keys_len);
    if (rc != MEMCACHED_SUCCESS) {
        memcached_quit(MEMCACHED_CACHE(cache));
        croak("memcached_mget failed :(");
    }

    hv = newHV();
    while (1) {
        char *value;
        char key[MEMCACHED_MAX_KEY];
        size_t key_length = 0;
        size_t value_length = 0;
        uint16_t flags = 0;
        Cache_LibMemcached_rc rc;
        SV *sv;

        value = memcached_fetch(MEMCACHED_CACHE(cache), key, &key_length, &value_length, &flags, &rc);
        if (value == NULL) {
            break;
        }

        Cache_LibMemcached_uncompress( cache, &value, &value_length, flags );

        sv = newSVpv(value, value_length);

        Cache_LibMemcached_thaw( cache, sv, flags );

        SvREFCNT_inc(sv);
        if (hv_store_ent(hv, newSVpv(key, key_length), sv, 0) == NULL) {
            croak("Failed to insert into hash");
        }
    }

    return newRV_noinc((SV *) hv);
}

SV *
Cache_LibMemcached_delete(cache, key_sv, expiration)
        Cache_LibMemcached *cache;
        SV *key_sv;
        time_t expiration;
{
    char *key;
    size_t key_len;
    Cache_LibMemcached_rc rc;

    key = SvPVbyte(key_sv, key_len);

    rc = memcached_delete(MEMCACHED_CACHE(cache), key, key_len, expiration);
    return (rc == MEMCACHED_SUCCESS) ?
        &PL_sv_yes : &PL_sv_no
    ;
}

SV *
Cache_LibMemcached_incr(cache, key_sv, offset)
        Cache_LibMemcached *cache;
        SV *key_sv;
        unsigned int offset;
{
    char *key;
    size_t key_len;
    uint64_t value;
    Cache_LibMemcached_rc rc;

    key = SvPVbyte(key_sv, key_len);

    rc = memcached_increment(MEMCACHED_CACHE(cache), key, key_len, offset, &value);

    if (rc != MEMCACHED_SUCCESS) {
        return &PL_sv_undef;
    }

    return newSViv(value);
}

SV *
Cache_LibMemcached_decr(cache, key_sv, offset)
        Cache_LibMemcached *cache;
        SV *key_sv;
        unsigned int offset;
{
    char *key;
    size_t key_len;
    uint64_t value;
    Cache_LibMemcached_rc rc;

    key = SvPVbyte(key_sv, key_len);

    rc = memcached_decrement(MEMCACHED_CACHE(cache), key, key_len, offset, &value);

    if (rc != MEMCACHED_SUCCESS) {
        return &PL_sv_undef;
    }

    return newSViv(value);
}

Cache_LibMemcached_rc
Cache_LibMemcached_flush_all(cache, expiration) 
        Cache_LibMemcached *cache;
        time_t expiration;
{
    return memcached_flush( MEMCACHED_CACHE(cache), expiration );
}

#endif /* __PERL_LIBMEMCACHED_C__ */
