# Copyright (c) 2026 - Sophia Elizabeth Shapira
# This library is free software; you may redistribute it and/or modify
# it under the same terms as Perl itself.

package Cartovanta::Classy;

use strict;
use warnings;
use Exporter 'import';

use File::Basename;
use Cwd 'abs_path';

use Cartovanta qw(cr_pk_eval slurp_file);

our @EXPORT_OK = qw(
  cr_loadplf_raw
);

my $_by_fnom = {};
my $_by_pack = {};

# Loads and evaluates a `Cartovanta`-loaded Perl
# file -- but doesn't do any of the extra processing
# for any specific subtypes of `Cartovanta`-loaded
# files, as that's the job for other functions that
# wrap around this one.
#
# If it has previously succeeded in loading and
# evaluating this file, it will not do so again but
# will instead return the result of the previous
# successful attempt.
#
# This function takes one argument -- the name of
# the file that needs to be loaded.
#
# This function returns a hashref with the following
# fields:
#   'package' -- The ad-hoc package-name generated
#         for this resource (by `Cartovanta`'s package
#         name allocator). `undef` if the process
#         failed before even getting a package-name.
#   'evret' -- The result of the `eval` done on the
#         Perl code in the file being loaded. This
#         will be `undef` in the event of failure.
#   'filenom' -- The filename of the resource being
#         loaded. If the process got as far as
#         confirming that it is a readable file and
#         resolving the filename, this will be the
#         canonical absolute pathname for the file.
#         Otherwise, it will be whatever is provided
#         as the argument to this function.
#   'err' -- Upon failure, this will be an error message
#         explaining the error. Upon success, it will
#         be an empty string.
sub cr_loadplf_raw {
  my $lc_ntv_ret;  # Value that will be returned
  my $lc_go_ok;    # An ok-to-proceed variable
  my $lc_fnom;     # Canonical filename of new resource
  my $lc_pkgnom; # Generated ad-hoc package name
  my $lc_file_cont; # Perl contents of new resource
  my $lc_evl_ret;   # Returned from `cr_pk_eval()`
  my $lc_code_ret;  # Returned evaled code.
  
  # Set up initial error code
  $lc_ntv_ret = {
    'package' => undef,
    'evret' => undef,
    'filenom' => $_[0],
  };
  
  # Do we have a valid usable file?
  $lc_go_ok = $_[0];
  if ( $lc_go_ok ) { $lc_go_ok = (!ref($_[0])); }
  if ( $lc_go_ok ) { $lc_go_ok = (-f $_[0]); }
  if ( $lc_go_ok ) { $lc_go_ok = (-r $_[0]); }
  
  # If not, then we have already failed.
  if ( !$lc_go_ok )
  {
    $lc_ntv_ret->{'err'} = ("Not a valid readable file:\n  " . $_[0] . " :\n");
    return($lc_ntv_ret);
  }
  
  # Buf if so, we should know its canonical filename.
  $lc_fnom = abs_path($_[0]);
  $lc_ntv_ret->{'filenom'} = $lc_fnom;
  
  # Of course, let no file be loaded redundantly.
  if ( defined($_by_fnom->{$lc_fnom}) )
  {
    return($_by_fnom->{$lc_fnom});
  }
  
  # Now we need the file's raw contents.
  $lc_file_cont = slurp_file($lc_fnom);
  if(!defined($lc_file_cont))
  {
    $lc_ntv_ret->{'err'} = ("Failed to read contents of file:\n  " . $lc_fnom . " :\n");
    return($lc_ntv_ret);
  }
  
  # And let's evaluate!
  $lc_evl_ret = cr_pk_eval($lc_file_cont);
  $lc_ntv_ret->{'package'} = $lc_evl_ret->{'package'};
  $lc_code_ret = $lc_evl_ret->{'evret'};
  
  # And for our last line of defense against failures:
  if ( !($lc_code_ret) )
  {
    if ( $lc_evl_ret->{'err'} eq '' )
    {
      $lc_ntv_ret->{'err'} = ("Mysterious failure to process file:\n  " . $lc_fnom . " :\n");
    } else {
      $lc_ntv_ret->{'err'} = ($lc_evl_ret->{'err'} . "\n  " . $lc_fnom . " :\n");
    }
    return($lc_ntv_ret);
  }
  
  # Now we fill in the remaining values.
  $lc_ntv_ret->{'evret'} = $lc_code_ret;
  $lc_ntv_ret->{'err'} = '';
  
  # And we register the resource before returning it.
  $lc_pkgnom = $lc_ntv_ret->{'package'};
  $_by_fnom->{$lc_fnom} = $lc_ntv_ret;
  $_by_pack->{$lc_pkgnom} = $lc_ntv_ret;
  return($lc_ntv_ret);
}

1;
