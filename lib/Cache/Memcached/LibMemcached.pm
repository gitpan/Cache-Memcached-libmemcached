# $Id: /mirror/coderepos/lang/perl/Cache-Memcached-LibMemcached/trunk/lib/Cache/Memcached/LibMemcached.pm 38563 2008-01-13T00:40:10.296281Z daisuke  $
#
# Copyright (c) 2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package Cache::Memcached::LibMemcached;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use Carp 'croak';
use Storable;
use constant HAVE_ZLIB => eval "use Compress::Zlib (); 1;";
use constant COMPRESS_SAVINGS => 0.20;

our ($VERSION, @ISA, %EXPORT_TAGS, @EXPORT_OK);
BEGIN
{
    $VERSION = '0.00002';
    if ($] > 5.006) {
        require XSLoader;
        XSLoader::load(__PACKAGE__, $VERSION);
    } else {
        require DynaLoader;
        @ISA = qw(DynaLoader);
        __PACKAGE__->bootstrap;
    }
}

__PACKAGE__->mk_accessors($_) for qw(
    compress_threshold compress_enable backend
);

sub new
{
    my $class   = shift;
    my $args    = shift || {};
    my $servers = delete $args->{servers};
    my $backend = delete $args->{backend} || 'Cache::Memcached::LibMemcached::Backend';

    my $self    = $class->SUPER::new({ 
        compress_enable => 1,
        %$args,
        backend => $backend->create(HAVE_ZLIB)
    });

    $self->set_servers($servers);
    return $self;
}

sub set_servers
{
    my $self = shift;
    my $servers = shift;
    my $backend = $self->backend;

    foreach my $server (@{ $servers || [] }) {
        if (ref $server) {
            croak "Cache::Memcached::LibMemcached does not support server with weights";
        }
        my ($hostname, $port) = split(/:/, $server);
        if ($port) {
            $backend->server_add( $hostname, $port );
        } else {
            $backend->server_add_unix( $server );
        }
    }

    return $self;
}

sub set
{
    my $self    = shift;
    my $key     = shift;
    my $val     = shift;

    my $expires = 0;
    my $flags   = 0;

    if ( ref $val ) {
        $val = Storable::freeze($val);
        $flags |= Cache::Memcached::LibMemcached::Constants::F_STORABLE;
    }

    use bytes;
    my $len     = length $val;

    if ( HAVE_ZLIB ) {
        my $threshold = $self->compress_threshold;
        if ($threshold && $self->compress_enable && $len >= $threshold) {
            my $c_val = Compress::Zlib::memGzip($val);
            my $c_len = length($c_val);

            # do we want to keep it?
            if ($c_len < $len*(1 - COMPRESS_SAVINGS)) {
                $val = $c_val;
                $len = $c_len;
                $flags |= Cache::Memcached::LibMemcached::Constants::F_COMPRESS;
            }
        }
    }

    $self->backend->set_raw($key, $val, $expires, $flags);
}

sub get { shift->backend->get(@_) }
sub get_multi { shift->backend->get_multi(@_) }
sub delete { shift->backend->delete(@_) }
sub incr { shift->backend->incr(@_) }
sub decr { shift->backend->decr(@_) }
*remove = \&delete;

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

=head1 METHODS

=head2 new

Takes on parameter, a hashref of options.

=head2 set_servers

Sets the server list. Note that currently you should not expect this to
I<replace> the server list that Cache::Memcached::LibMemcached works -- 
instead it ADDS to the list. Normally you shouldn't call this method directly,
because it's called by new(). 

This behavior *may* change in later releases.

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

=head1 AUTHOR

Copyright (c) 2008 Daisuke Maki E<lt>daisuke@endeworks.jpE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
