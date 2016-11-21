  use strict;
  use warnings;
  use File::Find;
  use English;
  

    # my $directory = ".\\";
    # opendir (DIR, $directory);
    # my @files = readdir (DIR);
    # close (DIR);
    # my @filesTxt; 
    # my $i = 0;
    # foreach (@files)
    # {
      # if (/.txt$/)
      # {
        # $filesTxt[$i] = $_;
        # $i++;
        # # print $_,"\n";
      # }
    # }
    # foreach (@filesTxt){
      # my $filePath = $directory .a "\\" . $_;
      # open (my $fh, '<:encoding(UTF-8)', $filePath) or die "Could not open file '$_' $!";
      # while (my $row = <$fh>){
        # chomp $row;
        # print "$row\n";
      # }
    # }   
     my $filePath =  ".\\PORRA\\TCHAU.txt";
     print $filePath,"\n";
      open (my $fh, '<:encoding(UTF-8)', $filePath) or die "Could not open file '$_' $!";
      while (my $row = <$fh>){
        chomp $row;
        print "$row\n";
      } 