package CGI::NeedSSL;

#use strict;
#use warnings;
use vars qw($VERSION @EXPORT_OK @ISA);
$VERSION = '0.06';
use Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(croak_unless_via_SSL cgi_is_via_SSL 
	croak_unless_via_ssl cgi_user_error_msg cgi_error_exit 
	redirect_unless_via_HTTP redirect_unless_via_http 
	redirect_unless_via_SSL redirect_unless_via_ssl);
use CGI::Carp qw(croak);

=head1 NAME

CGI::NeedSSL - module to check SSL status of a CGI call.

=head1 DESCRIPTION

Though some servers are configured with a separate cgi-bin directory for 
SSL-only CGI programs, many allow CGI programs to be called either via a 
http:// or a https:// url.

This module allows SSL-only status of a CGI program running environment to 
be checked and enforced by a perl CGI program.

=head1 SYNOPSIS

use CGI::NeedSSL qw( croak_unless_via_SSL );
croak_unless_via_SSL();

=cut

my $user_msg;
my $https_ahref = 'https://localhost';
my $http_ahref = 'http://localhost';
my $svrname = $ENV{SERVER_NAME};
my $scrname = $ENV{SCRIPT_NAME};
my $qstring = $ENV{QUERY_STRING};
if($svrname and $scrname) {	
	$https_ahref = 	'https://' . $svrname . $scrname;
	$https_ahref .= "?$qstring" if($qstring);
	$http_ahref = $https_ahref;
	$http_ahref =~ s/https/http/;
}

my $header_msg = "Content-Type: text/html; charset=ISO-8859-1\n\n";
my $redirect_msg = "Location: $https_ahref\n\n";
my $redirect_to_http_msg = "Location: $http_ahref\n\n";
my $default_msg = <<HTML_MSG;
<?xml version=\"1.0\" encoding=\"utf-8\"?>
<!DOCTYPE html
        PUBLIC \"-//W3C//DTD XHTML Basic 1.0//EN\"
        \"http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en-US\">
<head><title>Error: Need to use SSL (https:) to access</title></head>
<body>
  <h2>Sorry, this page needs to be accessed via SSL (https:).</h2>
<p>Maybe you meant to try  <a href=\"$https_ahref\"> this URL: $https_ahref\</a\> instead.</p>
</body>
</html>
HTML_MSG

=head1 METHODS

=over 4

item B<cgi_is_via_SSL>

Return 1 if https/SSL in effect, otherwise return undef.

=cut

# are we using https/ssl ?  returns 1 if so, otherwise undef
# Any HTML/SSL compliant web server should manage the HTTPS environment variable
sub cgi_is_via_SSL {
	return 1 if $ENV{HTTPS};
	return;
}

=item B<croak_unless_via_SSL>

Die, via a call CGI::Croak::croak, unless https/SSL is in effect. Prints an 
HTML message suggesting the script be called via https://. This default message 
can be changed with cgi_user_error_msg(). (An alternate spelling for this is 
croak_unless_via_ssl.)

The default croak message is a convenient redirect to the same page via https. 

=cut

# error exit here unless SSL in effect
sub croak_unless_via_SSL {
	cgi_error_exit() unless cgi_is_via_SSL();
	return 0;
}

# added for those who hate capitalization :)
sub croak_unless_via_ssl { croak_unless_via_SSL() }

=item B<redirect_unless_via_SSL> (alternate, redirect_unless_via_ssl)

Print a redirect and exit if not using https/SSL. Optional argument is to the
redirection URL. Defaults to the current URL, but called via https://.

=cut

sub redirect_unless_via_SSL {
	my $msg = shift || $redirect_msg;	
	unless(cgi_is_via_SSL()) { print $msg; exit }
	return 1;
}
sub redirect_unless_via_ssl { redirect_unless_via_SSL(shift) }


=item B<redirect_unless_via_HTTP> (alternate, redirect_unless_via_http)

Print a redirect and exit if not using regular, non-SSL http. 
Optional argument is to the redirection URL. This allows a redirect away 
from the https-only service back to a regular http service if the https 
page is called for a page that is only available via regular http.
Defaults to the current URL, but called via http://.

=cut

sub redirect_unless_via_HTTP {
	my $msg = shift || $redirect_to_http_msg;	
	if(cgi_is_via_SSL()) { print $msg; exit }
	return 1;
}
sub redirect_unless_via_http { redirect_unless_via_http(shift) }


=item B<cgi_user_error_msg>

Set and/or return the current error msg. The error message set by the user 
should be fully HTML, except for the header which the routine prints first--
ie, something like '<HTML><HEAD>NO SSL!</HEAD><BODY>Call us with https://</BODY></HTML>'.

=cut

# set and/or return the current error msg.
# the error message set by the user should be fully HTML, ie 
#  '<HTML><HEAD>NO SSL!</HEAD><BODY>Call us with https://</BODY></HTML>'
sub cgi_user_error_msg {
	my $msg = shift;
	if($msg) { $user_msg = $msg }
	return $user_msg ? $user_msg : $default_msg;
}


=item B<cgi_error_exit>

Prints our error message and exits.


=cut

# print error message to stdout, then croak
sub cgi_error_exit {
	print $header_msg, cgi_user_error_msg();
	croak "Bad call of this CGI: SSL/HTTPS not set--need https.";
}


# included mostly for testing purposes--probably not for use in real life
sub new {
	my ($class) = shift;
	my $self = {};
	bless $self, $class;
	return $self;
};


=back

=head1 AUTHOR

William Herrera (wherrera@skylightview.com).

=head1 SUPPORT

Questions, feature requests and bug reports should go to wherrera@skylightview.com

=head1 COPYRIGHT

=over 4

Copyright (C) 2004, by William Herrera.  
All Rights Reserved. 

=back

This module is free software; you can redistribute it and/or modify it under 
the same terms as Perl itself. 

=cut

1;
