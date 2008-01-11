# $Id$
#
# Copyright (c) 2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

use strict;
use ExtUtils::MakeMaker;

my $debugging = 0;
for(my $i = 0; $i < @ARGV; $i++) {
    if ($ARGV[$i] =~ /^--debugging$/) {
        splice(@ARGV, $i, 1);
        $debugging = 1;
        $i--;
    }
}

my %INFO = (
    ABSTRACT     => 'Perl Interface to libmemcached',
    AUTHOR       => 'Daisuke Maki <daisuke@endeworks.jp>',
    DISTNAME     => 'Cache-Memcached-LibMemcached',
    INSTALLDIRS  => 'site',
    LIBS         => [ '-lmemcached' ],
    NAME         => 'Cache::Memcached::LibMemcached',
    OBJECT       => '$(O_FILES)',
    PREREQ_PM    => {
        'Class::Accessor::Fast' => 0,
        'Storable'              => 0,
    },
    VERSION_FROM => 'lib/Cache/Memcached/LibMemcached.pm',
    test         => {
        TESTS    => 't/*.t t/*/*.t'
    }
);
$INFO{OPTIMIZE} = '-g' if $debugging;

WriteMakefile(%INFO);