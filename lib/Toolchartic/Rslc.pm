package Toolchartic::Rslc;
use strict;
use warnings;
use Toolchartic::Os_Spc;
use Toolchartic::Utl qw(require_str frcbless);

my $_backpack = Toolchartic::Os_Spc->pick();

# This method prepends directories to the search path
# based on resource-ID strings. In Unicoid systems, the
# array that is prepended will call for searches to be
# done within `~/local` and then in `/usr/local`. On
# any other system, it will follow that system's
# equivalent pattern.
sub p_rsid {
  my $this;
  my $lc_newls;
  my $lc_oblis;
  
  $this = shift(@_);
  
  # Obtain the partial path based on argumentry
  $lc_newls = $_backpack->rsid_path(@_);
  
  # Prepend it to the search path.
  $lc_oblis = $this->{'path'};
  @{$lc_oblis} = (@{$lc_newls},@{$lc_oblis});
  
  # We are done!
  return 1;
}

# This method prepends the directories in the provided
# environment variables to the search path.
sub env_path {
  my $this;
  my $lc_oblis;
  my $lc_evar;  # Any environment variable passed to method
  my @lc_ret;   # Eventually will be prepended
  my @lc_clct;  # Array collected from helper function
  
  $this = shift(@_);
  
  # Initialize return value
  @lc_ret = ();
  
  foreach $lc_evar (@_)
  {
    @lc_clct = $this->_env_path_01($lc_evar);
    push @lc_ret, @lc_clct;
  }
  
  # Prepend it to the search path.
  $lc_oblis = $this->{'path'};
  @{$lc_oblis} = (@lc_ret,@{$lc_oblis});
  
  # We are done!
  return 1;
}

sub _env_path_01 {
  my $this;
  my $lc_rval;
  my @lc_ret;
  my @lc_part;
  my $lc_each;
  
  $this = shift(@_);
  
  # Empty variables return an empty array.
  $lc_rval = $ENV{$_[0]};
  if ( !(defined($lc_rval)) ) { return(); }
  if ( $lc_rval eq '' ) { return(); }
  
  # Get everything in the path variable ...
  @lc_ret = ();
  @lc_part = split(quotemeta(':'),$lc_rval);
  foreach $lc_each (@lc_part)
  {
    # ... but only if there is something there
    if ( (defined($lc_each)) && ( $lc_each ne '' ) )
    {
      push @lc_ret, $lc_each;
    }
  }
  
  # And we are done!
  return(@lc_ret);
}

sub fpth {
  my $this;
  my $lc_ifc;
  my $lc_lns;
  my $lc_eachl;
  
  $this = shift(@_);
  
  # Get lines - in reverse order
  $lc_ifc = require_str('Toolchartic::Utl::File');
  $lc_lns = $lc_ifc->rliner(@_);
  
  # Process each directive line.
  foreach $lc_eachl ( @{$lc_lns} )
  {
    $this->lnpth($lc_eachl);
  }
  
  return 1;
}

# This function processes a single directive line
# of a path file.
sub lnpth {
  my $this;
  my @lc_seg;
  my $lc_cmt;
  
  $this = shift(@_);
  
  # Blast the file into segments and isolate the
  # command name:
  @lc_seg = split(/:/,$_[0],-1);
  shift(@lc_seg);
  pop(@lc_seg);
  $lc_cmt = shift(@lc_seg);
  
  if ( $lc_cmt eq 'env' )
  {
    return $this->env_path(@lc_seg);
  }
  
  if ( $lc_cmt eq 'rsid' )
  {
    return $this->p_rsid(@lc_seg);
  }
  
}


# THE CONSTRUCTOR METHOD

sub new {
  my $this;
  my $lc_ret;
  
  $this = shift(@_);
  
  # First we create the object's starting data:
  $lc_ret = {
    'path' => [],
  };
  
  # Bless & Send
  return frcbless($lc_ret,$this);
}


1;
