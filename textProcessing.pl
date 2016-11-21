  use strict;
  use warnings;
  use File::Find;
  use English;
  
  sub getFiles #Retorna todas as Pastas no diretório passado!
  {
    my $dir = $_[0];
    opendir (DIR, $dir);
    my @files = readdir (DIR);
    my @directories;
    my $i = 0;
    foreach (@files)
    {
      if (!($_ =~ /\./)){ #Se for um diretório
        $directories[$i] = $dir . $_;
        $i++;
      }
    }
    return @directories;
  }
  
  sub getFilesList #Retorna como array todos os arquivos txt dentro da pasta enviada como argumento
  {
    my $dir = $_[0];
    opendir (DIR, $dir);
    my @files = readdir (DIR);
    my @filesTxt; 
    my $i = 0;
    foreach (@files)
    {
      if (/.txt$/) # Se o nome do arquivo termina com .txt
      {
        $filesTxt[$i] = $dir . "\\" . $_;
        $i++;
      }
    }
    return @filesTxt;    
  }
  
  sub openTxtFiles #Printa o que está dentro de um arquivo '.txt'!
  {
    my $dir = $_[0];
    my @files = getFilesList ($dir);
    foreach (@files){
      open (my $fh, '<:encoding(UTF-8)', $_) or die "Could not open file '$_' $!";
      while (my $row = <$fh>){
        chomp $row;
        print "$row\n";
      }
    }
  }
  
  sub findString
   {
	my $bad_str = uc $_[1];
	my $curse_word = uc $_[0];
	
	### index localiza a substring "$curse_word" em "$bad_str" e devolve a localizacao dele na string
	my $loc = index($bad_str, $curse_word);
	if ($loc < 0)
	{
          return 0;
        }
        else
        {
          return 1;
        }
	
  }
  
  sub SPAM_Finder {
	### VOCE ESCOLHE O QUE VC QUER PEGAR COMO ARGUMENTO, SE E O ARQUIVO PARA VC LER O POST TODO DE UMA VEZ
	### OU SE E BASEADO NAQUELE "$row" QUE VAI LENDO DE LINHA EM LINHA
	### DE QQ FORMA, EU VOU ESCREVENDO A FUNCAO MSM ASSIM
	
	### DETECCAO DE TEXTO EM CAIXA ALTA
	my $found_SPAM = 0;
	my $str_post = $_[0];
	if (!($str_post cmp uc($str_post))){ $found_SPAM = 1; }
	return $found_SPAM;
	
	
}
  
  sub chkTxtFilesCurses #Checa se há "Curses" nos arquivos txt do diretório enviado como argumento
  {
    my $dir = $_[0];
    my $curse = $_[1];
    my @files = getFilesList ($dir);
    foreach (@files){
      open (my $fh, '<:encoding(UTF-8)', $_) or die "Could not open file '$_' $!";
      while (my $row = <$fh>){
        chomp $row;
        if (findString ($curse, $row))
        {
          print "Found curse";
        }
      }
    }
  }
  
  sub chkTxtFilesSPAM #Checa se há SPAM nos arquivos txt do diretório enviado argumento
  {
    my $dir = $_[0];
    my @files = getFilesList ($dir);
    my $totalRows = 0;
    my $foundRows = 0;
    foreach (@files){
      open (my $fh, '<:encoding(UTF-8)', $_) or die "Could not open file '$_' $!";
      while (my $row = <$fh>){
        chomp $row;
        $totalRows++;
        if (SPAM_Finder ($row))
        {
          $foundRows++;
        }
      }
      if ($totalRows == $foundRows)
      {
        print "Found SPAM\n";
      }
    }

  }
  
  sub runAllDirectories #Roda todos os diretórios dentro do Root do Programa!
  {
    my $dir = ".\\";
    my @directories = getFiles ($dir);
    foreach (@directories)
    {
      openTxtFiles ($_);
    }
  }
  
  sub getCurses #Retorna um array com todas as palavras de Curses no arquivo Curses.txt no diretório enviado como argumento
  {
    my $dir = $_[0];
    my $cursesPath = $dir . "Curses.txt";
    my @curses;
    my $i = 0;
    open (my $fh, '<:encoding(UTF-8)', $cursesPath) or die "Could not open file '$_' $!";
      while (my $row = <$fh>){
        chomp $row;
        $curses [$i] = $row;
        $i++;
      }
    return @curses;
  }
  
  sub chkAllDirectories #Roda todos os diretórios dentro do Root do Programa e checa por Curses e SPAM!
  {
    my $dir = ".\\";
    my @directories = getFiles ($dir);
    my $curse;
    my @curses = getCurses ($dir);
    foreach $curse (@curses)
    {
      foreach (@directories)
      {
        chkTxtFilesCurses ($_, $curse);
        print "\n";
      }
    }
    foreach (@directories)
    {
      chkTxtFilesSPAM ($_);
      print "\n";
    }
  }
  
  sub searchTopic #Procura por Tópicos (pastas) que contenham a String enviada como argumento
  {
    my $searchString = $_[0];
    my $dir = ".\\";
    my @directories = getFiles ($dir);
    my @foundDirectories;
    my $i = 0;
    foreach (@directories)
    {
      if (findString($searchString,$_))
      {
        $foundDirectories[$i] = $_;
        print $_,"\n";
      }
    }
    return @foundDirectories;
  }
  
  sub validateCPF #Verifica a validade do CPF enviado como argumento
  {
    my $numbersCPF = $_[0];
    
    my @arrayCPF;
    
    for (my $i = 0; $i<11; $i++)
    {
      $arrayCPF[$i] = 0;
    }
    
    my $i = 10;
    while ($numbersCPF > 0)
    {
      $arrayCPF[$i] = $numbersCPF %10;
      $numbersCPF = int ($numbersCPF/10);
      $i--;
    }
    
    if ($i > 1)
    {
      return 0;
    }
    
    my $sum = 0;
    
    for (my $i = 0; $i<9; $i++)
    {
        $sum+= (10 - $i) * $arrayCPF[$i];
    }
    
    
    if (!(11- $sum%11== $arrayCPF[9]) && !($sum%11<2 && $arrayCPF[9] == 0))
    {
      return 0;
    }
    
    $sum = 0;
    for (my $i = 0; $i<10; $i++)
    {
        $sum+= (11-$i) * $arrayCPF[$i];
    }
    
    if (!(11- $sum%11== $arrayCPF[10]) && !($sum%11<2 && $arrayCPF[10] == 0))
    {
      return 0;
    }
    
    return 1;
    
  }
  
  sub CryptPass 
  {
	my $pwd = $_[0];
	my $rand_nbr = int(rand(5));
	my $salt = "rnd";
	
	if ($rand_nbr == 0) { $salt = "meta_security"; }
	elsif ($rand_nbr == 1) { $salt = "blowfish_killer"; }
	elsif ($rand_nbr == 2) { $salt = "L337_Skillz"; }
	elsif ($rand_nbr == 3) { $salt = "FBD_JBA_PLAN"; }
	elsif ($rand_nbr == 4) { $salt = "NTPN_NTPN_NTPN"; }
	
	my $crypt_msg = crypt($pwd, $salt);
	return $crypt_msg;
}

  sub chkName #Verifica se há Nome igual ao enviado como argumento entre os usuários cadastrados na pasta enviada como argumento
  {
    my $dir =  $_[0];
    my $name = $_[1];
    my $userName = "";
    my @users = getFilesList ($dir);
    foreach (@users)
    {
       my $i = 0;
       open (my $fh, '<:encoding(UTF-8)', $_) or die "Could not open file '$_' $!";
       while (my $row = <$fh>){
        chomp $row;
        if ($i == 1) #1 é o número da linha em que o Nome se encontra no .txt
        {
          $userName = $row;
          last; #BREAK
        }
        $i++;
      }
      if (!($name cmp $userName))
      {
        return 0;
      }
    }
    return 1;
  }
  
  sub chkCPF #Verifica se há CPF igual ao enviado como argumento entre os usuários cadastrados na pasta enviada como argumento
  {
    my $dir =  $_[0];
    my $CPF = $_[1];
    my $userCPF = "";
    my @users = getFilesList ($dir);
    foreach (@users)
    {
       my $i = 0;
       open (my $fh, '<:encoding(UTF-8)', $_) or die "Could not open file '$_' $!";
       while (my $row = <$fh>){
        chomp $row;
        if ($i == 3) # 3 é o número da linha em que o CPF se encontra no .txt
        {
          $userCPF = $row;
          last; #BREAK
        }
        $i++;
      }
      if (!($CPF cmp $userCPF))
      {
        return 0;
      }
    }
    return 1;
  }
  
  sub insertUser #insere e valida um usuário na pasta Users do Root utilizando os valores passados como argumento
  {
    my $dir =  ".\\Users\\";
    my $root = ".\\";
    my $userName = $_[0];
    my $unCryptPassword = $_[1];
    my $cryptPassword = CryptPass ($unCryptPassword);
    my $CPF = $_[2];
    $CPF =~ s/\D//g; # TIRA CARACTERES NAO NUMERICOS DA STRING
    
    if (!chkCPF ($dir, $CPF))
    {
      print "Repeated CPF\n";
      return 0;
    }
    
    if (!chkName ($dir, $userName))
    {
      print "Repeated Name\n";
      return 0;
    }
    
    if(!validateCPF ($CPF + 0))
    {
      print "Invalid CPF\n";
      return 0;
    }
    
    my @curses = getCurses ($root);
    foreach (@curses)
    {
      if (findString ($_, $userName) || findString ($_, $unCryptPassword) || findString ($_, $CPF))
      {
        print "Improper Name\n";
        return 0;
      }
    }
    
    my @users = getFilesList ($dir);
    my $i = 0;
    foreach(@users)
    {
      $i++;
    }
    my $userFileName = $dir . $i . ".txt";
    open(my $fh, '>', $userFileName) or die "Could not open file '$userFileName' $!";
    print $fh $i,"\n";
    print $fh $userName,"\n";
    print $fh $cryptPassword,"\n";
    print $fh $CPF,"\n";
    close $fh;    
    
    return 1;        
    
  }  
  
  
   # chkAllDirectories ();
  # searchTopic ("TRANSITO");
   insertUser ("Noc", "Lanzanha", "00000000000000");