use strict;
use Test::More;

BEGIN
{
    if (! $ENV{ MEMCACHED_SERVER } ) {
        plan(skip_all => "Define MEMCACHED_SERVER (e.g. localhost:11211) to run this test");
    } else {
        plan(tests => 6);
    }
    use_ok("Cache::Memcached::LibMemcached");
    use_ok("Cache::Memcached::LibMemcached::Constants", qw(MEMCACHED_DISTRIBUTION_MODULA MEMCACHED_DISTRIBUTION_CONSISTENT));
}

my $cache = Cache::Memcached::LibMemcached->new( {
    servers => [ $ENV{ MEMCACHED_SERVER } ]
} );
isa_ok($cache, "Cache::Memcached::LibMemcached");

ok(!!$cache->get_distribution_method() == 0);
$cache->set_distribution_method(MEMCACHED_DISTRIBUTION_CONSISTENT);
is($cache->get_distribution_method(), MEMCACHED_DISTRIBUTION_CONSISTENT);
$cache->set_distribution_method(MEMCACHED_DISTRIBUTION_MODULA);
is($cache->get_distribution_method(), MEMCACHED_DISTRIBUTION_MODULA);

