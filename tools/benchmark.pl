use strict;
use Benchmark qw(cmpthese);
use Cache::Memcached;
use Cache::Memcached::Fast;
use Cache::Memcached::LibMemcached;

my %args = (
    servers => [ qw(localhost:11211) ],
    compess_threshold => 1_000,
);

my $data;

my $memd = Cache::Memcached->new(\%args);
my $memd_fast = Cache::Memcached::Fast->new(\%args);
my $libmemd = Cache::Memcached::LibMemcached->new(\%args);
my $libmemd_no_block = 
    Cache::Memcached::LibMemcached->new(\%args);
$libmemd_no_block->set_no_block(1);

{
    print qq|==== Benchmark "Simple get() (scalar)" ====\n|;
    $data = '0123456789' x 10;
    $libmemd->set( 'foo', $data );
    cmpthese(50_000, {
        perl_memcahed => sub {
            ($memd->get('foo') eq $data) or die;
        },
        memcached_fast => sub {
            ($memd_fast->get('foo') eq $data) or die;
        },
        libmemcached  => sub {
            ($libmemd->get('foo') eq $data) or die;
        },
    });
}

{
    print qq|==== Benchmark "Simple get() (w/serialize)" ====\n|;
    $data = { foo => [ qw(1 2 3) ] };
    $libmemd->set( 'foo', $data );
    cmpthese(50_000, {
        perl_memcahed => sub {
            (ref $memd->get('foo')->{foo} eq 'ARRAY') or die;
        },
        memcached_fast => sub {
            (ref $memd_fast->get('foo')->{foo} eq 'ARRAY') or die;
        },
        libmemcached  => sub {
            (ref $libmemd->get('foo')->{foo} eq 'ARRAY') or die;
        },
    });
}

{
    print qq|==== Benchmark "Simple get() (w/compression)" ====\n|;
    $data = '0123456789' x 500;
    $libmemd->set( 'foo', $data );
    cmpthese(50_000, {
        perl_memcahed => sub {
            ($memd->get('foo') eq $data) or die;
        },
        memcached_fast => sub {
            ($memd_fast->get('foo') eq $data) or die;
        },
        libmemcached  => sub {
            ($libmemd->get('foo') eq $data) or die;
        },
        libmemcached  => sub {
            ($libmemd->get('foo') eq $data) or die;
        },
    });
}

{
    print qq|==== Benchmark "Simple set() (scalar)" ====\n|;
    $data = '0123456789' x 10;
    cmpthese(400_000, {
        perl_memcahed => sub {
            $memd->set( 'foo', $data );
        },
        memcached_fast => sub {
            $memd_fast->set( 'foo', $data );
        },
        libmemcached  => sub {
            $libmemd->set( 'foo', $data );
        },
        libmemcached_no_block  => sub {
            $libmemd_no_block->set( 'foo', $data );
        },
    });
}

{
    print qq|==== Benchmark "Simple set() (w/serialize)" ====\n|;
    $data = { foo => [ qw(1 2 3) ] };
    cmpthese(100_000, {
        perl_memcahed => sub {
            $memd->set( 'foo', $data );
        },
        memcached_fast => sub {
            $memd_fast->set( 'foo', $data );
        },
        libmemcached  => sub {
            $libmemd->set( 'foo', $data );
        },
        libmemcached_no_block  => sub {
            $libmemd_no_block->set( 'foo', $data );
        },
    });
}

{
    print qq|==== Benchmark "Simple set() (w/compress)" ====\n|;
    $data = '0123456789' x 500;
    cmpthese(100_000, {
        perl_memcahed => sub {
            $memd->set( 'foo', $data );
        },
        memcached_fast => sub {
            $memd_fast->set( 'foo', $data );
        },
        libmemcached  => sub {
            $libmemd->set( 'foo', $data );
        },
        libmemcached_no_block  => sub {
            $libmemd_no_block->set( 'foo', $data );
        },
    });
}



