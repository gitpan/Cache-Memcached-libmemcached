# $Id: /mirror/coderepos/lang/perl/Cache-Memcached-LibMemcached/trunk/lib/Cache/Memcached/LibMemcached/Constants.pm 38780 2008-01-14T02:11:15.195880Z daisuke  $
#
# Copyright (c) 2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package Cache::Memcached::LibMemcached::Constants;
use strict;
use warnings;
use Exporter 'import';

1;

__END__

=head1 NAME

Cache::Memcached::LibMemcached::Constants - Constants

=head1 SYNOPSIS

  use Cache::Memcached::LibMemcached::Constants qw(:all);

=head1 CONSTANTS

=head2  MEMCACHED_CLIENT_ERROR

=head2  MEMCACHED_CONNECTION_BIND_FAILURE

=head2  MEMCACHED_CONNECTION_SOCKET_CREATE_FAILURE

=head2  MEMCACHED_DATA_DOES_NOT_EXIST

=head2  MEMCACHED_DATA_EXISTS

=head2  MEMCACHED_DELETED

=head2  MEMCACHED_END

=head2  MEMCACHED_ERRNO

=head2  MEMCACHED_FAILURE

=head2  MEMCACHED_FAIL_UNIX_SOCKET

=head2  MEMCACHED_FETCH_NOTFINISHED

=head2  MEMCACHED_HOST_LOOKUP_FAILURE

=head2  MEMCACHED_MAXIMUM_RETURN

=head2  MEMCACHED_MEMORY_ALLOCATION_FAILURE

=head2  MEMCACHED_NOTFOUND

=head2  MEMCACHED_NOTSTORED

=head2  MEMCACHED_NOT_SUPPORTED

=head2  MEMCACHED_NO_KEY_PROVIDED

=head2  MEMCACHED_NO_SERVERS

=head2  MEMCACHED_PARTIAL_READ

=head2  MEMCACHED_PROTOCOL_ERROR

=head2  MEMCACHED_READ_FAILURE

=head2  MEMCACHED_SERVER_ERROR

=head2  MEMCACHED_SOME_ERRORS

=head2  MEMCACHED_STAT

=head2  MEMCACHED_STORED

=head2  MEMCACHED_SUCCESS

=head2  MEMCACHED_TIMEOUT

=head2  MEMCACHED_UNKNOWN_READ_FAILURE

=head2  MEMCACHED_VALUE

=head2  MEMCACHED_WRITE_FAILURE

=head2  MEMCACHED_DISTRIBUTION_CONSISTENT

=head2  MEMCACHED_DISTRIBUTION_MODULA

=head2  MEMCACHED_HASH_CRC

=head2  MEMCACHED_HASH_DEFAULT

=head2  MEMCACHED_HASH_FNV1A_32

=head2  MEMCACHED_HASH_FNV1A_64

=head2  MEMCACHED_HASH_FNV1_32

=head2  MEMCACHED_HASH_FNV1_64

=head2  MEMCACHED_HASH_HSIEH

=head2  MEMCACHED_HASH_KETAMA

=head2  MEMCACHED_HASH_MD5

=head2 F_STORABLE

For internal use. Indicates the value was serialized via Storable.

=head2 F_COMPRESS

For internal use. Indicates the value was compressed via Compress::Zlib.

=cut
