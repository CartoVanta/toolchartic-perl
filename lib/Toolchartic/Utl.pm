package Toolchartic::Utl;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(
  require_str
  blessing
  frcbless
);

# Designed to behave as much as possible like the
# `require` keyword, except that it takes a string
# rather than a bare literal.
sub require_str{
  my $lc_pkg;
  
  $lc_pkg = $_[0];
  if ( !($lc_pkg) )
  {
    die("\n" . '`require_str()` needs a valid package-name to load.' . "\n\n");
  }
  if ( ref($lc_pkg) )
  {
    die("\n" . 'You must specify a string of a package name to `require_str()`.' . "\n\n");
  }
  
  if ( !(eval "require $lc_pkg; 1;") )
  {
    die "\nCould not load module $lc_pkg.\n$@\n";
  }
  
  return $lc_pkg;
}


# This function takes as its one argument either a string with a
# valid-for-blessing package-name for a class (the blessing) or a
# reference that has been blessed with such a blessing. It returns
# the blessing string itself.
sub blessing {
  my $lc_rfv;
  $lc_rfv = ref($_[0]);
  if ( $lc_rfv ) { return $lc_rfv; }
  return $_[0];
}

# This function is meant to act similarly to the `bless` operation
# except that it can (instead of a package-name) take as its
# second argument an already-blessed object.
sub frcbless {
  bless $_[0], require_str(blessing($_[1]));
  return $_[0];
}



1;
