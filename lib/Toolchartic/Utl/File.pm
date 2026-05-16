package Toolchartic::Utl::File;

# Usual package imports:
use strict;
use warnings;


# Loads an entire file into one Perl string and returns it.
# Returns undef if no filename was provided or if the file
# could not be opened for reading.
sub slurp {
  my $this;
  my $lc_file;  # Pathname of the file to load
  my $lc_ret;   # File contents to be returned
  
  $this = shift(@_);
  
  if ( (scalar @_) < 0.5 ) { return undef; }
  
  $lc_file = $_[0];
  if ( !(-f $lc_file) ) { return undef; }
  if ( !(-r $lc_file) ) { return undef; }
  
  $lc_ret = '';
  open(my $lc_fh,'<',$lc_file) or return undef;
  local $/;
  $lc_ret = <$lc_fh>;
  close($lc_fh);
  
  return($lc_ret);
}

# Slurps in a text file and assures that the text gets
# normalized to Unix-style.
sub slurp_t {
  my $this;
  my $lc_text;
  
  $this = shift(@_);
  
  $lc_text = $this->slurp($_[0]);
  if ( !(defined($lc_text)) ) { return undef; }
  
  # NOW WE NORMALIZE THE TEXT:
  # First, we remove UTF-8 BOM if present.
  $lc_text =~ s/\A\x{FEFF}//;
  # Next, we change Windows line-endings to Unix-style
  $lc_text =~ s/\r\n/\n/g;
  # Finally, we change old-style Mac line-endings
  # to Unix-style
  $lc_text =~ s/\r/\n/g;
  
  # And we are done!
  return $lc_text;
}

# This method slurps in all the files named in its
# arguments, chops then up into individual lines --
# and then returns all those lines, in alphabetical
# order.
sub rliner {
  my $this;
  my @lc_col;
  my $lc_filn;
  my @lc_rev;
  
  $this = shift(@_);
  
  # At start, collected lines are empty.
  @lc_col = ();
  
  # For all the files
  foreach $lc_filn (@_)
  {
    my $lc2_con;
    my @lc2_lin;
    
    $lc2_con = $this->slurp_t($lc_filn);
    if ( defined($lc2_con) )
    {
      @lc2_lin = split(/\n/,$lc2_con);
      push(@lc_col, @lc2_lin);
    }
  }
  
  # It gets returned in reverse
  @lc_rev = reverse(@lc_col);
  return [@lc_rev];
}

1;
