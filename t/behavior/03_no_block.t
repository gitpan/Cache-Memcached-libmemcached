use strict;
use Test::More;

BEGIN
{
    if (! $ENV{ MEMCACHED_SERVER } ) {
        plan(skip_all => "Define MEMCACHED_SERVER (e.g. localhost:11211) to run this test");
    } else {
        plan(tests => 5);
    }
    use_ok("Cache::Memcached::LibMemcached");
}

my $cache = Cache::Memcached::LibMemcached->new( {
    servers => [ $ENV{ MEMCACHED_SERVER } ]
} );
isa_ok($cache, "Cache::Memcached::LibMemcached");

ok(! $cache->is_no_block());
$cache->set_no_block(1);
ok($cache->is_no_block());
$cache->set_no_block(0);
ok(! $cache->is_no_block());