sub Unique {
  my @Elements = @_;
  my %Hash = ();
  foreach my $Element (@Elements) {
    ++$Hash{$Element};
  }
  
  my @UniqueElements = keys %Hash;  
  return @UniqueElements;
}

sub RemoveArray (\@@) { # Removes elements of one array from another
                        # Call &RemoveArray(\@Array1,@Array2)
                        # FIXME: Figure out how to do like push, no reference
                        #        on call needed
                        
  my ($Array_ref,@BadElements) = @_;

  my @Array = @{$Array_ref};

  foreach my $BadElement (@BadElements) { # Move this into utility function
    my $Index = 0;
    foreach my $Element (@Array) {
      if ($Element eq $BadElement) {
        splice @Array,$Index,1;
      }
      ++$Index;  
    }
  }
  return @Array;
}

sub URLify { # Adapted from Perl Cookbook, 6.21
  my ($Text) = @_;

  $urls = '(http|telnet|gopher|file|wais|ftp|https)';
  $ltrs = '\w';
  $gunk = '/#~:.?+=&%@!\-';
  $punc = '.:?\-';
  $any  = "${ltrs}${gunk}${punc}";
  $Text =~ s{
              \b                    # start at word boundary
              (                     # begin $1  {
               $urls     :          # need resource and a colon
               [$any] +?            # followed by on or more
                                    #  of any valid character, but
                                    #  be conservative and take only
                                    #  what you need to....
              )                     # end   $1  }
              (?=                   # look-ahead non-consumptive assertion
               [$punc]*             # either 0 or more punctuation
               [^$any]              #   followed by a non-url char
               |                    # or else
               $                    #   then end of the string
              )
             }{<A HREF="$1">$1</A>}igox;
  return $Text;           
}

1;
