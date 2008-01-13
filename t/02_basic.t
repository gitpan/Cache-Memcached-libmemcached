use strict;
use Test::More;

BEGIN
{
    if (! $ENV{ MEMCACHED_SERVER } ) {
        plan(skip_all => "Define MEMCACHED_SERVER (e.g. localhost:11211) to run this test");
    } else {
        plan(tests => 8);
    }
    use_ok("Cache::Memcached::LibMemcached");
}

my $cache = Cache::Memcached::LibMemcached->new( {
    servers => [ $ENV{ MEMCACHED_SERVER } ]
} );
isa_ok($cache, "Cache::Memcached::LibMemcached");

{
    $cache->set("foo", "bar", 300);
    my $val = $cache->get("foo");
    is($val, "bar", "simple value");
}

{
    $cache->set("foo", { bar => 1 }, 300);
    my $val = $cache->get("foo");
    is_deeply($val, { bar => 1 }, "got complex values");
}

{
    ok( $cache->get("foo"),  "before delete returns ok");
    ok( $cache->delete("foo") );
    ok( ! $cache->get("foo"),  "delete works");
    ok( ! $cache->delete("foo") );
}