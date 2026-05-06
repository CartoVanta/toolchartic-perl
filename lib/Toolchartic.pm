# Copyright (c) 2026 - Sophia Elizabeth Shapira
# This library is free software; you may redistribute it and/or modify
# it under the same terms as Perl itself.

package Toolchartic;

our $VERSION = '0.00_1';


# Usual package imports:
use strict;
use warnings;
use Exporter 'import';


# BEGIN LOADING BACKEND
sub _backend_package {
  if ( $^O eq 'MSWin32' ) { return('Toolchartic::Win32'); }
  return('Toolchartic::Unix');
}
sub _load_backend {
  my $lc_pkg;
  $lc_pkg = _backend_package();
  if ( !(eval "require $lc_pkg; 1;") )
  {
    die "\nCould not load Toolchartic backend $lc_pkg.\n$@\n";
  }
  return($lc_pkg);
}
_load_backend();
# FINISH LOADING BACKEND


our @EXPORT_OK = qw(
  cr_alloc_get
  cr_alloc_init
  cr_alloc_ready
  cr_home_refresh
  cr_pk_eval
  cr_settings
  shell_captr
  slurp_file
  slurp_t_file
);

# DECLARE THE HELPER VARIABLES:
my $_alloc_nspace = undef; # Namespace for ad-hoc package names
my $_alloc_numid = 0; # ID-number of last allocated ad-hoc package name



# Get value for `$_homedir`
cr_home_refresh();
sub cr_home_refresh {
  return( _backend_package()->cr_home_refresh(@_) );
}



# Loads an entire file into one Perl string and returns it.
# Returns undef if no filename was provided or if the file
# could not be opened for reading.
sub slurp_file {
  require Toolchartic::Utl::File;
  return Toolchartic::Utl::File->slurp(@_);
}

# Slurps in a text file and assures that the text gets
# normalized to Unix-style.
sub slurp_t_file {
  require Toolchartic::Utl::File;
  return Toolchartic::Utl::File->slurp_t(@_);
}


sub shell_captr {
  my $lc_comd;
  my $lc_ret;
  $lc_comd = shell_qt(@_);
  $lc_ret = `$lc_comd`;
  chomp($lc_ret);
  return $lc_ret;
}

sub cr_settings {
  
  # The argument must be a hashref.
  if ( ref($_[0]) ne 'HASH' ) { return 0; }
  
  return( _backend_package()->cr_settings(@_) );
}

# Initialize the Ad-Hoc Package Namespace Allocator
sub cr_alloc_init {
  my $lc_nspace; # Temporary storage for considered namespace
  
  # Only valid initializations are allowed 
  $lc_nspace = $_[0];
  if ( !defined($lc_nspace) ) { return 0; }
  if ( ref($lc_nspace) ) { return 0; }
  if ( !($lc_nspace =~ /^[a-zA-Z_]\w*(?:::[a-zA-Z_]\w*)*$/) )
  {
    return 0;
  }
  
  # First initialization wins. However, additional
  # attempts (as long as they pass the tests that come
  # up to this point) still are identified as "success".
  if ( defined($_alloc_nspace) ) { return 1; }
  
  # Looks like we have a winner.
  $_alloc_nspace = $lc_nspace;
  return 1;
}

# This function allocates one ad-hoc package name.
sub cr_alloc_get {
  # This will only work if the allocator has been
  # initiated.
  if ( !defined($_alloc_nspace) ) { return undef; }
  
  # Let us assemble the new allocee.
  $_alloc_numid = int($_alloc_numid + 1.2);
  return($_alloc_nspace . '::X' . $_alloc_numid . 'z');
}

# Queries to see if the allocator has been initiated.
# Returns `1` for yes and `0` for no.
sub cr_alloc_ready {
  return ( defined($_alloc_nspace) ? 1 : 0 );
}

# Does an `eval` on code after slapping on an ad-hoc
# package name. Returns hashref with the following fields:
# 'package' -- The ad-hoc package name (`undef` if the
#     allocator hasn't been initiated, which causes this
#     function without even calling `eval`)
# 'evret' -- Return value of `eval`
# 'err' -- The error message (empty-string upon success)
sub cr_pk_eval {
  my $lc_ret; # The in-progress return value
  my $lc_code; # The code that will get `eval`ed
  my $lc_infrec; # Informational record for newly added resource
  
  # Construct initial value
  $lc_ret = {
    'package' => undef,
    'evret' => undef,
    'err' => "Namespace allocator uninitiated.\n",
  };
  
  # And that's what we return if the allocator hasn't
  # been initiated.
  if ( !cr_alloc_ready() ) { return $lc_ret; }
  
  # Now we allocate a namespace and prep code
  $lc_ret->{'package'} = cr_alloc_get();
  $lc_code = 'package ' . $lc_ret->{'package'} . '; ' . $_[0];
  
  # Here we set up the informational record
  $lc_infrec = {};
  if ( (defined($_[1])) && (ref($_[1]) eq 'HASH') )
  {
    $lc_infrec = { %{$_[1]} };
  }
  $lc_infrec->{'package'} = $lc_ret->{'package'};
  
  # Now we need to insert this record where the
  # package can see it.
  {
    my $lc2_vnom;
    $lc2_vnom = $lc_ret->{'package'};
    $lc2_vnom .= '::pkginf';
    no strict 'refs';
    ${$lc2_vnom} = $lc_infrec;
  }
  
  # And finally, the evaluation.
  $lc_ret->{'evret'} = eval($lc_code);
  $lc_ret->{'err'} = $@;
  
  # And we're done!
  return $lc_ret;
}



1;
