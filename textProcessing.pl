  use strict;
  use warnings;
  use File::Find;
  use English;
  use List::Util qw(min);
  
  sub levenshtein #APAGAR COMENTARIO. levenshtein distance. Nao sei exatamente como funciona, mas calcula a diferença entre duas palavras.
  { 
    my ($str1, $str2) = @_;
    my @ar1 = split //, $str1;
    my @ar2 = split //, $str2;

    my @dist;
    $dist[$_][0] = $_ foreach (0 .. @ar1);
    $dist[0][$_] = $_ foreach (0 .. @ar2);

    foreach my $i (1 .. @ar1){
        foreach my $j (1 .. @ar2){
            my $cost = $ar1[$i - 1] eq $ar2[$j - 1] ? 0 : 1;
            $dist[$i][$j] = min(
                        $dist[$i - 1][$j] + 1, 
                        $dist[$i][$j - 1] + 1, 
                        $dist[$i - 1][$j - 1] + $cost );
        }
    }

    return $dist[@ar1][@ar2];
}
  
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
        if (levenshtein ($curse, $row) <= 2)
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
  
  sub splitWords #limpa todos as pontuações e palavras recorrentes separa as palavras num array
  {
     my $splitString = $_[0];
     my @splitWords = split / |,|_|-|'|.\\/, $splitString; # elimina as pontuações dentro do '/  /' 
     my @newSplitWords;
     
     my %stop_hash;
     my @stop_words = qw/i in a to the it have haven't was but is be from a ou e pra para com como até ate esta ta este por pelo pela/; # hash com palavras recorrentes que não serão pesquisadas
     foreach (@stop_words)
     {
       $stop_hash{$_}++ ;
     }
    
     my $i = 0;
     foreach (@splitWords)
     {
       if ((! (exists $stop_hash {$_ })) && ($_ cmp "")) #limpa todas as palavras dentro do hash do array
       {
         $newSplitWords[$i] = $_;
         $i++;
       }
     }
     
     return @newSplitWords;
  }
  
  sub calculateDistance # verifica a proximidade entre duas strings para a pesquisa
  {
    my $i;
    
    my $searchString = uc $_[0];
    my $topicName = uc $_[1];
    
    chomp $searchString;
    chomp $topicName;
    
    my @newSearchWords = splitWords ($searchString);
    my @newTopicWords = splitWords ($topicName);    
    
    my $sWord;
    my $tWord;
    
    
    my @distances;
    $i = 0;

    foreach $sWord (@newSearchWords)
    {
      foreach $tWord (@newTopicWords)
      {
        $distances[$i] = 0;
        if ((levenshtein($sWord, $tWord) < 3 && length $sWord >2) || !($sWord cmp $tWord))
        {
          $distances[$i] = 1;
        }
        $i++;
      }
    }

    $i = 0;
    my $maximumDistance = 5;
    my $totalPoints = 0;
    
    foreach (@distances)
    {
      if ($_)
      {
        my $actualDistance = 0;
        my $tempPoints = 1;
        for (my $j = $i+1; $j< scalar @distances; $j++)
        {
          $actualDistance++;
          if ($distances[$j])
          {
            $tempPoints++;
            $actualDistance = 0;
          }
          if ($actualDistance == $maximumDistance)
          {
            last; # BREAK;
          }
        }
        if ($tempPoints > $totalPoints)
        {
          $totalPoints = $tempPoints;
        }
      }
      $i++;
    }
    
    
    if (scalar @newTopicWords * scalar @newSearchWords < 5)
    {
      $totalPoints *=2;
    }

    return $totalPoints;
    
  }
  
  sub searchTopic #Procura por Tópicos (pastas) que contenham a String enviada como argumento
  {
    my $searchString = $_[0];
    my @distances;
    my $dir = ".\\";
    my @directories = getFiles ($dir);
    my @foundDirectories;
    my $directory;
    my $i = 0;
    foreach $directory (@directories)
    {
      if (calculateDistance($searchString,$directory) >= 2)
      {
        $foundDirectories[$i] = $_;
        print $directory,"\n";
        print "points: ", calculateDistance($searchString, $directory),"\n";
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
    my $userIndex = 1; 
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
        return $userIndex;
      }
      $userIndex++;
    }
    return 0;
  }
  
  sub chkCPF #Verifica se há CPF igual ao enviado como argumento entre os usuários cadastrados na pasta enviada como argumento
  {
    my $dir =  $_[0];
    my $CPF = $_[1];
    my $userCPF = "";
    my $userIndex = 1;
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
        return $userIndex;
      }
      $userIndex++;
    }
    return 0;
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
    
    if (chkCPF ($dir, $CPF))
    {
      print "Repeated CPF\n";
      return 0;
    }
    
    if (chkName ($dir, $userName))
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
    my $i = 1; #número do primeiro user na lista!!
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
  
  sub deleteUser #deleta o usuario com o nome informado
  {
    my $dir = ".\\Users\\";
    my $userName = $_[0];
    my $userIndex;
    if (!($userIndex = chkName($dir, $userName)))
    {
      print "User not found!\n";
      return 0;
    }

    my $userFileName = $dir . $userIndex . ".txt";
    unlink $userFileName;
    
    return 1;
  }
  
  sub chkPass # retorna uma lista com a senha encriptada em com todos os salts possiveis
  {
    my $pwd = $_[0];
    my $salt = "";
    my @passwords;
    
    for (my $nbr =0; $nbr < 5; $nbr++)
    {
      if ($nbr == 0) { $salt = "meta_security"; }
      elsif ($nbr == 1) { $salt = "blowfish_killer"; }
      elsif ($nbr == 2) { $salt = "L337_Skillz"; }
      elsif ($nbr == 3) { $salt = "FBD_JBA_PLAN"; }
      elsif ($nbr == 4) { $salt = "NTPN_NTPN_NTPN"; }
          
      $passwords[$nbr] = crypt($pwd, $salt);
    }
    
    return @passwords;
  }
  
  sub validateLogin #valida do login de um usuário. Recebe como argumento o nome do usuário e a senha
  {
    my $dir = ".\\Users\\";
    my $userName = $_[0];
    my $userPassword = $_[1];
    my $userActualPassword;
    my $userIndex;
    if (!($userIndex = chkName ($dir, $userName)))
    {
      print "User not found!\n";
      return 0;
    }
    my @passwords = chkPass($userPassword);
    
    my $userFileName = $dir . $userIndex . ".txt";
    
    my $i = 0;
    open (my $fh, '<:encoding(UTF-8)', $userFileName) or die "Could not open file '$userFileName' $!";
    while (my $row = <$fh>)
    {
      chomp $row;
      if ($i == 2) # 3 é o número da linha em que o CPF se encontra no .txt
      {
        $userActualPassword = $row;
        last; #BREAK
      }
      $i++;
    }
    
    foreach (@passwords)
    {
      if ( $_ eq $userActualPassword)
      {
        print "Login Succefull!\n";
        return 0;
      }
    }
    
    print "Wrong Password!\n";
    return 1;
    
  }
  
  sub createPost #Cria um post. Recebe como argumento o Autor do post, qual post foi respondido (0 quer dizer que não foi resposta), A mensagem do post e o topico no qual o post será feito
  {
    my $dir = ".\\";
    my $author = $_[0];
    my $response = $_[1];
    my $message = $_[2];
    my $topic = $_[3];
    my @files = getFiles ($dir);
    my $topicPath = "";
    
    foreach (@files)
    {
      $_ =~ s/[\.\\\/]+//g;
      if ($topic eq $_)
      {
        $topicPath = $_;
      }
    }
    
    if ($topicPath eq "")
    {
      print "No Topic Found!\n";
      return 0;
    }
    
    $topicPath = $dir . "\\" . $topicPath;
    my @txts = getFilesList ($topicPath);
    
    my $i = 1;
    foreach (@txts)
    {
      $i++;
    }
    
    my $topicFileName = $topicPath . "\\" . $i . ".txt";
    
    open(my $fh, '>', $topicFileName) or die "Could not open file '$topicFileName' $!";
    print $fh $author,"\n";
    print $fh $response,"\n";
    print $fh $message,"\n";
    close $fh;    
    
    return 1;    
    
  }  
  
  # chkAllDirectories ();
  searchTopic ("TOPI B Z X Y C D E F G H A");
  # insertUser ("Bruno", "Lanzanha", "00000000000");
  # deleteUser ("Noc");
  # validateLogin ("Bruno", "Lanzanhaaa");
  # createPost ("Diogo", "0", "Oi, tchau\naté", "Topico_A");