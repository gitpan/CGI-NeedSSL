use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'CGI::NeedSSL',
    VERSION_FROM => 'lib/CGI/NeedSSL.pm', # finds $VERSION
    AUTHOR       => 'William Herrera (wherrera@skylightview.com)',
    ABSTRACT     => '',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                    },
);
