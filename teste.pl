  use strict;
  use warnings;
  use File::Find;
  
  
  my $dir = ".\\";
    opendir (DIR, $dir);
    my @files = readdir (DIR);
    my @filesTxt; 
    my $i = 0;
    foreach (@files)
    {
      if (/.txt$/)
      {
        $filesTxt[$i] = $dir . $_;
        $i++;
        print $_,"\n";
      }
    }
    
# my $dirOpen = @filesTxt;
    my @filesOpen = @filesTxt;
    foreach (@filesOpen){
      my $filePath = $dir . "\\" . $_;
      open (my $fh, '<:encoding(UTF-8)', $filePath) or die "Could not open file '$_' $!";
      while (my $row = <$fh>){
        chomp $row;
        print "$row\n";
      }
    }