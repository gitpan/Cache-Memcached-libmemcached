use strict;
use Test::More;

BEGIN
{
    if (! $ENV{ MEMCACHED_SERVER } ) {
        plan(skip_all => "Define MEMCACHED_SERVER (e.g. localhost:11211) to run this test");
    } else {
        plan(tests => 13);
    }
    use_ok("Cache::Memcached::LibMemcached");
}

my $cache = Cache::Memcached::LibMemcached->new( {
    servers => [ $ENV{ MEMCACHED_SERVER } ]
} );
isa_ok($cache, "Cache::Memcached::LibMemcached");

{
    $cache->set("num", 0);

    for my $i (1..10) {
        my $num = $cache->incr("num");
        is($num, $i);
    }
}

{
    $cache->remove("num");
    ok( ! $cache->incr("num") );
}