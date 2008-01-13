# $Id: /mirror/coderepos/lang/perl/Cache-Memcached-LibMemcached/trunk/lib/Cache/Memcached/LibMemcached.pm 38592 2008-01-13T14:59:20.030194Z daisuke  $
#
# Copyright (c) 2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package Cache::Memcached::LibMemcached;
use strict;
use warnings;
use Carp 'croak';
use Storable;
use constant HAVE_ZLIB => eval "use Compress::Zlib (); 1;";
use constant COMPRESS_SAVINGS => 0.20;

our ($VERSION, @ISA, %EXPORT_TAGS, @EXPORT_OK);
BEGIN
{
    $VERSION = '0.00004';
    if ($] > 5.006) {
        require XSLoader;
        XSLoader::load(__PACKAGE__, $VERSION);
    } else {
        require DynaLoader;
        @ISA = qw(DynaLoader);
        __PACKAGE__->bootstrap;
    }
}

sub new
{
    my $class   = shift;
    my $args    = shift || {};
    my $servers = delete $args->{servers};

    my $self    = $class->_XS_new(
        HAVE_ZLIB,
        exists $args->{compress_enable} ? $args->{compress_enable} : 1,
        $args->{compress_threshold} || 0,
        COMPRESS_SAVINGS,
    );

    $self->set_servers($servers);
    return $self;
}

sub set_servers
{
    my $self = shift;
    my $servers = shift;

    # Setting the servers requires us to discard the current server list
    # as well.
    $self->server_list_free();

    foreach my $server (@{ $servers || [] }) {
        if (ref $server) {
            croak "Cache::Memcached::LibMemcached does not support server with weights";
        }
        my ($hostname, $port) = split(/:/, $server);
        if ($port) {
            $self->server_add( $hostname, $port );
        } else {
            $self->server_add_unix( $server );
        }
    }

    return $self;
}

*remove = \&delete;
*enable_compress = \&set_compress_enabled;

1;

__END__

=head1 NAME

Cache::Memcached::LibMemcached - Perl Interface to libmemcached

=head1 SYNOPSIS

  use Cache::Memcached::LibMemcached;
  my $memd = Cache::Memcached::LibMemcached->new({
    serves => [ "10.0.0.15:11211", "10.0.0.15:11212", "/var/sock/memcached" ],
    compress_threshold => 10_000
  });

  $memd->set("my_key", "Some value");
  $memd->set("object_key", { 'complex' => [ "object", 2, 4 ]});

  $val = $memd->get("my_key");
  $val = $memd->get("object_key");
  if ($val) { print $val->{complex}->[2] }

  $memd->incr("key");
  $memd->decr("key");
  $memd->incr("key", 2);

  $memd->delete("key");
  $memd->remove("key"); # Alias to delete

  my $hashref = $memd->get_multi(@keys);

=head1 DESCRIPTION

This is the Perl Interface to libmemcached, a C library to interface with
memcached.

There's also a Memcached::libmemcached available on googlecode, but the
intent of Cache::Memcached::LibMemcached is to provide users with consistent
API as Cache::Memcached.

=head1 Cache::Memcached COMPATIBLE METHODS

Except for the minor incompatiblities, below methods are generally compatible 
with Cache::Memcached.

=head2 new

Takes on parameter, a hashref of options.

=head2 set_servers

  $memd->set_servers( [ qw(serv1:port1 serv2:port2 ...) ]);

Sets the server list. 

As of 0.00003, this method works like Cache::Memcached and I<replaces> the
current server list with the new one 

=head2 get

  my $val = $memd->get($key);

Retrieves a key from the memcached. Returns the value (automatically thawed
with Storable, if necessary) or undef.

Currently the arrayref form of $key is NOT supported. Perhaps in the future.

=head2 get_multi

  my $hashref = $memd->get_multi(@keys);

Retrieves multiple keys from the memcache doing just one query.
Returns a hashref of key/value pairs that were available.

=head2 set

  $memd->set($key, $value[, $expires]);

Unconditionally sets a key to a given value in the memcache. Returns true if 
it was stored successfully.

Currently the arrayref form of $key is NOT supported. Perhaps in the future.

=head2 add

  $memd->add($key, $value[, $expires]);

Like set(), but only stores in memcache if they key doesn't already exist.

=head2 replace

  $memd->replace($key, $value[, $expires]);

Like set(), but only stores in memcache if they key already exist.

=head2 incr

=head2 decr

  my $newval = $memd->incr($key);
  my $newval = $memd->decr($key);
  my $newval = $memd->incr($key, $offset);
  my $newval = $memd->decr($key, $offset);

Atomically increments or decrements the specified the integer value specified 
by $key. Returns undef if the key doesn't exist on the server.

=head2 delete

=head2 remove

  $memd->delete($key);

Deletes a key.

XXX - The behavior when second argument is specified may differ from
Cache::Memcached -- this hasn't been very well tested. Patches welcome!

=head2 flush_all

  $memd->fush_all;

Runs the memcached "flush_all" command on all configured hosts, emptying all 
their caches. 

=head2 set_compress_threshold

  $memd->set_compress_threshold($threshold);

Set the compress threshold.

=head2 enable_compress

  $memd->enable_compress($bool);

This is actually an alias to set_compress_enabled(). The original version
from Cache::Memcached is, despite its naming, a setter as well.

=head1 Cache::Memcached::LibMemcached SPECIFIC METHODS

These methods are libmemcached-specific.

=head2 server_add

Adds a memcached server.

=head2 server_add_unix_socket

Adds a memcached server, connecting via unix socket.

=head2 server_list_free

Frees the memcached server list.

=head1 UTILITY METHODS

WARNING: Please do not consider the existance for these methods to be final.
They may disappear from future releases.

=head2 get_compress_threshold

Return the current value of compress_threshold

=head2 set_compress_enabled

Set the value of compress_enabled

=head2 get_compress_enabled

Return the current value of compress_enabled

=head2 set_compress_savings

Set the value of compress_savings

=head2 get_compress_savings

Return the current value of compress_savings

=head1 VARIOUS MEMCACHED MODULES

Below are the various memcached modules available on CPAN. 

Please check tool/benchmark.pl for a live comparison of these modules.
(except for Cache::Memcached::XS, which I wasn't able to compile under my
main dev environment)

=head2 Cache::Memcached

This is the "main" module. It's mostly written in Perl.

=head2 Cache::Memcached::LibMemcached

Cache::Memcached::LibMemcached, which is the module for which your reading
the document of, is a perl binding for libmemcached (http://tangent.org/552/libmemcached.html). Not to be confused with libmemcache (see below).

=head2 Cache::Memcached::XS

Cache::Memcached::XS is a binding for libmemcache (http://people.freebsd.org/~seanc/libmemcache/).
The main memcached site at http://danga.com/memcached/apis.bml seems to 
indicate that the underlying libmemcache is no longer in active development.

=head2 Cache::Memcached::Fast

Cache::Memcached::Fast is a memcached client written in XS from scratch.

=head1 AUTHOR

Copyright (c) 2008 Daisuke Maki E<lt>daisuke@endeworks.jpE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
