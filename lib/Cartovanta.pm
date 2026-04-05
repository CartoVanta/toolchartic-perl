# Copyright (c) 2026 - Sophia Elizabeth Shapira
# This library is free software; you may redistribute it and/or modify
# it under the same terms as Perl itself.

package Cartovanta;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(
  infile
  rgval
  onelzy
  shell_captr
  shell_qt
  shell_quote
);

# Loads the contents of a file into a PERL string.
sub infile {
  my $lc_a;
  my $lc_b;
  if ( !@_ ) { return undef; }
  $lc_a = '';
  if ( open($lc_b,'<',$_[0]) )
  {
    local $/ = undef;
    $lc_a = <$lc_b>;
    close($lc_b);
  }
  return $lc_a;
}

# Takes as its first argument a PERL string to be `eval`ed.
# Any additional arguments are passed to the code-reference
# returned by that `eval`.
# If the `eval` fails to return a code-reference, `undef` is
# returned.
# Otherwise, the return value is whatever is returned by the
# generated code-reference.
sub rgval {
  my $lc_code;
  my $lc_bld;
  if ( !@_ ) { return undef; }
  $lc_code = shift(@_);
  $lc_bld = eval($lc_code);
  if ( ref($lc_bld) ne 'CODE' ) { return undef; }
  return($lc_bld->(@_));
}

# Takes as its first argument the pathname of a file whose
# contents are to be loaded as a PERL string and `eval`ed.
# Any additional arguments are passed to the code-reference
# returned by that `eval`.
# If the file cannot be loaded, or if the `eval` fails to
# return a code-reference, `undef` is returned.
# Otherwise, the return value is whatever is returned by the
# generated code-reference.
sub onelzy {
  my $lc_file;
  my $lc_code;
  if ( !@_ ) { return undef; }
  $lc_file = shift(@_);
  $lc_code = infile($lc_file);
  return(rgval($lc_code,@_));
}


sub shell_captr {
  my $lc_comd;
  my $lc_ret;
  $lc_comd = shell_qt(@_);
  $lc_ret = `$lc_comd`;
  chomp($lc_ret);
  return $lc_ret;
}
sub shell_qt {
  my $lc_ret;
  my $lc_ech;
  $lc_ret = ' ';
  foreach $lc_ech (@_)
  {
    $lc_ret .= ( shell_quote($lc_ech) . ' ' );
  }
  return $lc_ret;
}
sub shell_quote {
  my $lc_strg;
  ($lc_strg) = @_;
  return "''" if !defined($lc_strg) || $lc_strg eq '';
  $lc_strg =~ s/'/'"'"'/g;
  return "'$lc_strg'";
}



1;
