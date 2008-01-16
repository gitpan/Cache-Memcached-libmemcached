use strict;
use Test::More;

my @algorithms;
BEGIN
{
    if (! $ENV{ MEMCACHED_SERVER } ) {
        plan(skip_all => "Define MEMCACHED_SERVER (e.g. localhost:11211) to run this test");
    } else {
        plan(tests => 11);
    }
    @algorithms = qw(
        MEMCACHED_HASH_MD5
        MEMCACHED_HASH_CRC
        MEMCACHED_HASH_FNV1_64
        MEMCACHED_HASH_FNV1A_64
        MEMCACHED_HASH_FNV1_32
        MEMCACHED_HASH_FNV1A_32
        MEMCACHED_HASH_KETAMA
        MEMCACHED_HASH_HSIEH
    );
    use_ok("Cache::Memcached::LibMemcached");
    use_ok("Cache::Memcached::LibMemcached::Constants", @algorithms);
}

my $cache = Cache::Memcached::LibMemcached->new( {
    servers => [ $ENV{ MEMCACHED_SERVER } ]
} );
isa_ok($cache, "Cache::Memcached::LibMemcached");

foreach my $algorithm (@algorithms) {
    my $val = do { no strict 'refs'; $algorithm->(); };
    $cache->set_hashing_algorithm($val);
    is($cache->get_hashing_algorithm(), $val);
}
