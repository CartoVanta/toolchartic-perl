use strict;
use warnings;
use ExtUtils::MakeMaker;

sub _adros
{
  my $lc_a;
  my $lc_rg;
  $lc_a = pop(@_);
  foreach $lc_rg (@_)
  {
    if ( $lc_rg ne '' )
    {
      $lc_a->{('lib/'.$lc_rg)} = ('$(INST_LIBDIR)/'.$lc_rg);
    }
  }
}
my $_mapy = {};
_adros(
  'Toolchartic.pm',
  'Toolchartic/Utl.pm',
  'Toolchartic/Os_Spc.pm',
  'Toolchartic/Unix.pm',
  'Toolchartic/Classy.pm',
  'Toolchartic/Shell.pm',
  'Toolchartic/Rsrc.pm',
  'Toolchartic/Rslc.pm',
  'Toolchartic/Resrg.pm',
  'Toolchartic/Utl/File.pm',
  $_mapy
);

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
  PM           => $_mapy,
);
