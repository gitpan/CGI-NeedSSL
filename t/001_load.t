# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'CGI::NeedSSL' ); }

my $object = new CGI::NeedSSL;
isa_ok ($object, 'CGI::NeedSSL');
