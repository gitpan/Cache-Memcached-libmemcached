use strict;
use Benchmark qw(cmpthese);
use Cache::Memcached;
use Cache::Memcached::LibMemcached;

my %args = (
    servers => [ qw(localhost:11211) ],
    compess_threshold => 1_000,
);

my $data = '0123456789' x 10;

my $memd = Cache::Memcached->new(\%args);
my $libmemd = Cache::Memcached::LibMemcached->new(\%args);
$libmemd->set( 'foo', $data );

cmpthese(50_000, {
    perl_memcahed => sub {
        ($memd->get('foo') eq $data) or die;
    },
    libmemcached  => sub {
        ($libmemd->get('foo') eq $data) or die;
    },
});