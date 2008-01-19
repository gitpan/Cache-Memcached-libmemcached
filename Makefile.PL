# $Id: /mirror/coderepos/lang/perl/Cache-Memcached-LibMemcached/trunk/Makefile.PL 39400 2008-01-19T14:57:15.522195Z daisuke  $
#
# Copyright (c) 2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

use strict;
use lib "inc";
use ExtUtils::MakeMaker;
use Devel::CheckLib;

my $libpath = $ENV{LIBPATH} || '';

my $message = <<EOM;
This Makefile.PL will try to detect your installation of libmemcached.
If it can't be found, the script will simply exit without creating a
Makefile.

If you installed libmemcached libraries in a non-standard location,
you should specify it here so we can't find it.

Directory containing your libmemcached installation? [$libpath]
EOM
chomp $message;
$libpath = prompt($message);

check_lib_or_exit( lib => 'memcached',  libpath => $libpath );

print "\nlibmemcached found\n\n";

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
    LICENSE      => 'perl',
    LIBS         => [ '-lmemcached' ],
    NAME         => 'Cache::Memcached::LibMemcached',
    OBJECT       => '$(O_FILES)',
    PREREQ_PM    => {
        'Storable'              => 0,
        'Compress::Zlib'        => 0,
    },
    VERSION_FROM => 'lib/Cache/Memcached/LibMemcached.pm',
    test         => {
        TESTS    => 't/*.t t/*/*.t'
    }
);
$INFO{OPTIMIZE} = '-g' if $debugging;

WriteMakefile(%INFO);