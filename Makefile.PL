use strict;
use warnings;
use ExtUtils::MakeMaker;

if ( $^O eq 'MSWin32' )
{
  os_unsupported();
}

WriteMakefile(
  NAME         => 'Toolchartic',
  DISTNAME     => 'Toolchartic-Perl',
  VERSION_FROM => 'lib/Toolchartic.pm',
  ABSTRACT     => 'Perl resource-access infrastructure for Toolchartic toolchains.',
  AUTHOR       => 'Sophia Elizabeth Shapira',
  LICENSE      => 'perl',
  PM           => {
    'lib/Toolchartic.pm'      => '$(INST_LIBDIR)/Toolchartic.pm',
    'lib/Toolchartic/Utl.pm' => '$(INST_LIBDIR)/Toolchartic/Utl.pm',
    'lib/Toolchartic/Os_Spc.pm' => '$(INST_LIBDIR)/Toolchartic/Os_Spc.pm',
    'lib/Toolchartic/Unix.pm' => '$(INST_LIBDIR)/Toolchartic/Unix.pm',
    'lib/Toolchartic/Classy.pm' => '$(INST_LIBDIR)/Toolchartic/Classy.pm',
    'lib/Toolchartic/Shell.pm' => '$(INST_LIBDIR)/Toolchartic/Shell.pm',
    'lib/Toolchartic/Rsrc.pm' => '$(INST_LIBDIR)/Toolchartic/Rsrc.pm',
    'lib/Toolchartic/Rslc.pm' => '$(INST_LIBDIR)/Toolchartic/Rslc.pm',
    'lib/Toolchartic/R_Cvperlc.pm' => '$(INST_LIBDIR)/Toolchartic/R_Cvperlc.pm',
    'lib/Toolchartic/R_Cvperli.pm' => '$(INST_LIBDIR)/Toolchartic/R_Cvperli.pm',
  },
);
