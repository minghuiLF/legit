#!/usr/bin/perl -w
#use Switch;
use File::Copy "cp";
sub print_help {
print <<"EOF";
Usage: legit.pl <command> [<args>]

These are the legit commands:
   init       Create an empty legit repository
   add        Add file contents to the index
   commit     Record changes to the repository
   log        Show commit log
   show       Show file at particular state
   rm         Remove files from the current directory and from the index
   status     Show the status of files in the current directory, index, and repository
   branch     list, create or delete a branch
   checkout   Switch branches or restore current directory files
   merge      Join two development histories together

EOF

exit(1);
}

sub if_already_init {
  if (-e ".legit/") {
    return 1;
  }
  return 0;
}

sub copy_two_dir {
  # copy one dir to another
  #
  $dir1=shift @_;
  $dir2=shift @_;

  foreach my $x (glob "$dir1/*") {

    cp($x,$dir2);
  }

}

sub if_somefile_intrack {
  # if a file in the tracklist
  # return 1 if it is  0 otherwise
  $x=shift @_;
  my @tracked_file=get_track_file_list();

  if (grep {$_ eq $x} @tracked_file) {
    return 1;
  }
  return 0;
}

sub get_track_file_list {
  # open index get the  filename in staged
  # stored in @tracked_file

  my @tracked_file;
  open(FH, '<', $IND) or die $!;
    foreach $file(<FH>) {
      chomp ($file);
      if ($file) {
        push @tracked_file, $file;
      }


    }

  close(FH);
  return @tracked_file;
}

sub creat_branch {
  $branch_name=shift @_;
  # creat branch dir
  mkdir ".legit/".$branch_name;

  # creat log
  my $log=".legit/".$branch_name."/log";

  open(FH, '>', $log) or die $!;
  close(FH);
  return 1;
}

sub check_file_change {
  $file1_path=shift @_;
  $file2_path=shift @_;


  open my $ain, '<', $file1_path or die "Cannot open $file1_path: $!";
  @alines=<$ain>;
  close $ain;

  open my $bin, '<', $file2_path or die "Cannot open $file2_path: $!";

  @blines=<$bin>;
  close $bin;

  if ($#alines!=$#blines) {

    return 1;
  }


  $c=0;
  while  ($c<=$#alines) {
    if ($alines[$c] ne $blines[$c]) {

      return 1;
    }
    $c++;

  }
  return 0;



}

sub if_file_need_staged{
  $x=shift @_;
  $now_version= shift @_;


  ## check if something change

  my $version_store_dir=".legit/".$NOW_BRANCH."/.$now_version";

  ## get version dir's filenames
  opendir ( DIR, $version_store_dir ) || die "Error in opening dir $version_store_dir\n";
  @master_filenames = grep(/^[^\.]/,readdir(DIR));
  closedir(DIR);

  if (grep {$_ eq $x} @master_filenames) {##  if this file in the version

    my $file_path=$version_store_dir."/$x";
    ## some changed
    if (check_file_change($x,$file_path)) {
      return 1;
    }else{
      return 0
    }



  }else{##  new file
    return 1;
  }

}

sub get_now_vertion {
  open(FH, '<', $BRANCH_VER) or die $!;
    @FH=<FH>;
    my $now_version=$FH[0];
  close(FH);
  return $now_version;
}

sub if_exist_storedir {
  my $ver=shift @_;
  my $version_store_dir=".legit/".$NOW_BRANCH."/.$ver";
  unless (-e $version_store_dir) {
    return 0;
  }
  return $version_store_dir ;

}

sub print_file {
  $file=shift @_;
  open(HF, '<', $file) or die "legit.pl: can't open $file\n";
    foreach  $line(<HF>) {
      print($line);
    }

  close HF;
}



## init -----------------------------------------------------------------------
sub init {
    unless(mkdir ".legit") {
        die "legit.pl: error: .legit already exists\n";
        exit (0);
    }
    # creat staged dir
    mkdir $STAGE;
    # creat delete staged file
    open(FH, '>', $DLETE_STAGE) or die $!;
    close(FH);
    # creat index
    open(FH, '>', $IND) or die $!;
    close(FH);

    # create default branch
    if (creat_branch($NOW_BRANCH)) {
        print "Initialized empty legit repository in .legit\n";
        exit (1);
    }




}

## add -----------------------------------------------------------------------
sub add {
  my @filenames=@ARGV;

  # if no file given
  if (!@filenames) {
    print "Nothing specified, nothing added.\nMaybe you wanted to say 'legit add .'?\n\n";
    exit(0);
  }
  # nomal while add file to index and add file to staged dir
  while (@filenames) {
    my $filename= shift @filenames;
    add_progress($filename);
  }
  exit (1);
}
sub add_progress {
  my $filename=shift @_;
  #judeg if filename legal
  $judge=($filename =~ /^[a-zA-Z0-9]/)&&($filename =~ /^[a-zA-Z0-9\.\-\_]*$/);
  if (!$judge) {
    die "legit.pl add: error: illegal filenames $filename\n";
    exit (0);
  }
  else{







    #judge if file exist
    unless (-e $filename) {
      unless (-e $BRANCH_VER) {
        die "legit.pl: error: can not open '$filename'\n";
        exit (0);
      }

      my $status=get_file_status($filename);

      ## this means you useing unix rm befor now the add means add this delete status to the staged for commit
      if ($status==2||$status==12) {
        open(FH, '>>', $DLETE_STAGE) or die $!;
         print FH $filename."\n";
        close(FH);
        @tracked_files=get_track_file_list();
        ## delete it in index
        @tracked_files =  grep {$_ ne $filename} @tracked_files;

        ## delete it in index
        ## write to file
        open(FH, '>', $IND) or die $!;
          foreach my $filename(@tracked_files) {
            print FH $filename."\n";
          }
        close(FH);
        exit (1);
      }# you add it in index but using unix rm delete the file then add  so wejust trated it as you do not want to add the file
      elsif($status==9){
        unlink $STAGE."/$filename";
        @tracked_files=get_track_file_list();
        ## delete it in index
        @tracked_files =  grep {$_ ne $filename} @tracked_files;

        ## delete it in index
        ## write to file
        open(FH, '>', $IND) or die $!;
          foreach my $filename(@tracked_files) {
            print FH $filename."\n";
          }
        close(FH);
        exit (1);
      }
      else{
          die "legit.pl: error: can not open '$filename'\n";
      }

    }
    #
    ###############################  if pass abouve means this is somefile adding not by delete progress
    ###############################  check if something change so we need copy file to staged
    #
    # if there is no commit before
    if (!(-e $BRANCH_VER)) {
      my $staded_file=".legit/staged/".$filename;
      cp($filename,$staded_file);
    }else{ # else this is the nomal satiation
      #get the $now_version  from matser\version
      $now_version=get_now_vertion();

      ## if changed then just add it if not just

      if (if_file_need_staged($filename,$now_version)==1) {
        my $staded_file=".legit/staged/".$filename;
        cp($filename,$staded_file);
      }
    }
    ###############################

    # add file to index
    unless (if_somefile_intrack($filename)){
      open(FH, '>>', $IND) or die $!;
        print FH $filename."\n";
        #print $filename."add to index\n";  #<<<<<<<<<<<<<<<<<<<here
      close(FH);
    }
    #print $filename."\n";  #<<<<<<<<<<<<<<<<<<<here
  }
}

## commit -----------------------------------------------------------------------

sub commit {
  if (@ARGV==2) {
    my $dashm =shift @ARGV;


    unless ($dashm =~ /^\-m$/){
      die "usage: legit.pl commit [-a] -m commit-message\n";
    }

    my $message =shift @ARGV;

    commit_progress($message);

  }elsif(@ARGV==3){
    my $dasha =shift @ARGV;
    my $dashm =shift @ARGV;


    unless ($dashm =~ /^\-m$/ && $dasha =~ /^\-a$/){
      die "usage: legit.pl commit [-a] -m commit-message\n";
    }
    my $message =shift @ARGV;

    my @track_files_list = get_track_file_list();
    foreach my $file (@track_files_list) {
      add_progress($file);
    }

    commit_progress($message);
    exit (1);
  }else{
    die "usage: legit.pl commit [-a] -m commit-message\n";
    exit (0);
  }






}

sub commit_progress {
  my $message= shift @_;
  my @tracked_file;
  my $now_version=0;
 #--------------------------------------------------------

   my @delete_list;
   open(FH, '<', $DLETE_STAGE) or die $!;
     foreach $file(<FH>) {
       chomp ($file);
       if ($file) {
         push @delete_list, $file;
       }


     }

   close(FH);



  @stagefile_paths=glob "$STAGE/*";

  # only if stage has some file then we need commit
  if (@stagefile_paths || @delete_list) {
    # if this is the first commit
    if (!(-e $BRANCH_VER)) {

      # creat ver0 dir and version mark file
      open(FH, '>', $BRANCH_VER) or die $!;
        print FH "0";
      close(FH);
      $version_0path=".legit/".$NOW_BRANCH."/.0";
      mkdir $version_0path;
      # copy to it
      copy_two_dir($STAGE,$version_0path);
      # unlink all staged files
      unlink @stagefile_paths;

      # write message to log
      open(FH, '>>', $BRANCH_LOG) or die $!;

        print FH $now_version." ".$message."\n";
      close(FH);
      print "Committed as commit 0\n";

    }else{ # else this is the nomal satiation

      # first copy the orignal dir to new dir ------------------------------
      #get the $now_version  from matser\version
        $now_version=get_now_vertion();


      my $new_version=$now_version+1;
      my $branch_now_verdir=".legit/".$NOW_BRANCH."/.$now_version";
      my $branch_new_verdir=".legit/".$NOW_BRANCH."/.$new_version";

      # make new dir
      mkdir $branch_new_verdir;
      #copy all file to a new version dir
      copy_two_dir($branch_now_verdir,$branch_new_verdir);

      # then copy the staged file to dir  ----------------------------------
      copy_two_dir($STAGE,$branch_new_verdir);


      # if exist del commit
      foreach my $x (@delete_list) {
        unlink $branch_new_verdir."/".$x;
      }

      #clean delete
      open(FH, '>', $DLETE_STAGE) or die $!;
      close(FH);

      # change version mark ------------------------------------------------



      open(FH, '>', $BRANCH_VER) or die $!;
        print FH $new_version;
      close(FH);
      # unlink all staged files
      unlink @stagefile_paths;

      # write message to log
      open(FH, '>>', $BRANCH_LOG) or die $!;
        print FH $new_version." ".$message."\n";
      close(FH);
      print "Committed as commit $new_version\n";

    }
  }else{
    print "nothing to commit\n";
  }
  #-------------------------------------------------------

}


## log -----------------------------------------------------------------------
sub show_log {
  unless (-e $BRANCH_VER) {
    die "legit.pl: error: your repository does not have any commits yet\n";
  }

  open(FH, '<', $BRANCH_LOG) or die $!;
    @loglines=<FH>;
    @loglines=reverse sort @loglines; #for strings
    foreach my $line(@loglines) {
      print $line;
    }

  close(FH);
  exit (1);
}

## show -----------------------------------------------------------------------
sub show {
  die "usage: legit.pl show <commit>:<filename>\n" unless @ARGV==1;
  unless (-e $BRANCH_VER) {
    die "legit.pl: error: your repository does not have any commits yet\n";
  }
  my $option=shift @ARGV;
  unless ($option=~ /^(\d*)\:(\S+)$/) {
    die "usage: legit.pl show <commit>:<filename>\n" ;
  }

  (my $ver_num,my $filename)= $option=~ /^(\d*)\:(\S+)$/;
  #print $ver_num,$filename;

  if ($ver_num eq "") {
    if (-e $STAGE."/$filename") {

      print_file($STAGE."/$filename");
    }else{
        $now_version=get_now_vertion();
        my $last_store_dir=".legit/".$NOW_BRANCH."/.$now_version";

        @file_list=glob $last_store_dir."/*";

        my $aimfile_path=$last_store_dir."/$filename";
        if (grep {$_ eq $aimfile_path} @file_list) {
          my $file_path=$last_store_dir."/$filename";
          print_file($file_path);
        }else{
          die "legit.pl: error: \'$filename\' not found in index\n";
        }


    }


  }
  else{
    my $aim_store_dir=if_exist_storedir($ver_num);
    if ($aim_store_dir) {

      @file_list=glob $aim_store_dir."/*";

      my $aimfile_path=$aim_store_dir."/$filename";
      if (grep {$_ eq $aimfile_path} @file_list) {
        my $file_path=$aim_store_dir."/$filename";
        print_file($file_path);
      }else{
        die "legit.pl: error: \'$filename\' not found in commit $ver_num\n";
      }

    }else{
      die "legit.pl: error: unknown commit \'$ver_num\'\n";
    }

  }


  exit (1);

}



## remove -----------------------------------------------------------------------
sub rm {
    ## handle agruments
    die "usage: legit.pl rm [--force] [--cached] <filenames>\n" if @ARGV<1;
    my @filenames= @ARGV;
    my $force_flag=0;
    my $cached_flag=0;
    ## mark flag
    my $i=0;
    while ($i<2) {
      if ($filenames[0]=~/^\-\-cached$/) {
        $cached_flag=1;
        splice @filenames, 0, 1;
      }
      if($filenames[0]=~/^\-\-force$/){
        $force_flag=1;
        splice @filenames, 0, 1;
      }
      $i++;
    }



    foreach my $x (@filenames) {
      unless(($x  =~ /^[a-zA-Z0-9]/)&&($x =~ /^[a-zA-Z0-9\.\-\_]*$/)){
        die "usage: legit.pl rm [--force] [--cached] <filenames>\n";
      }
    }

    ## begin remove progress first do some check
    ## then rm files
    my %temphash;
    ## #check if everything safe according flag
    foreach my $filename (@filenames) {

      #   %status_hash=(
      #   1 => "untracked",
      #   2 => "file deleted",
      #   3 => "deleted",
      #   4 => "file changed, different changes staged for commit",
      #   5 => "file changed, changes staged for commit",
      #   6 => "file changed, changes not staged for commit",
      #   7 => "same as repo",
      #   8 => "added to index",
      # );

      ## using status to delete
        my $status=get_file_status($filename);
        $temphash{$filename}=$status;

        if ($status==1 || $status==3 || $status==11 ) {
          die "legit.pl: error: \'$filename\' is not in the legit repository\n";
        }

        if ($status==4) {
          unless ($force_flag) {
            die "legit.pl: error: \'$filename\' in index is different to both working file and repository\n"
          }


        }
        if ($status==5 || $status==8) {
          unless ($force_flag||$cached_flag) {
            die "legit.pl: error: \'$filename\' has changes staged in the index\n";
          }
        }


        if ($status==6) {
          unless ($force_flag||$cached_flag) {
            die "legit.pl: error: \'$filename\' in repository is different to working file\n";
          }
        }


    }
    ## everything is safe  delete


    @tracked_files=get_track_file_list();
    foreach my $filename (@filenames) {
      # delete progress

      ## if cached_flag leave current dir file
      unless ($cached_flag) {
        unlink $filename;
      }

      ## delete it in staged
      unlink $STAGE."/$filename";


      unless ($temphash{$filename}==8 ||$temphash{$filename}==9 ||$temphash{$filename}==12) {

        open(FH, '>>', $DLETE_STAGE) or die $!;
         print FH $filename."\n";
        close(FH);


      }


      ## delete it in index
      @tracked_files =  grep {$_ ne $filename} @tracked_files;

    }
    ## delete it in index
    ## write to file
    open(FH, '>', $IND) or die $!;
      foreach my $filename(@tracked_files) {
        print FH $filename."\n";
      }
    close(FH);
    exit (1);
}





## status-----------------------------------------------------------------------

sub status {

  unless (-e $BRANCH_VER) {
    die "legit.pl: error: your repository does not have any commits yet\n";
  }
  opendir ( DIR, "." ) || die "Error in opening dir $version_store_dir\n";
  my @working_dir_filenames = grep(/^[^\.]/,readdir(DIR));
  closedir(DIR);

  ## 2  file_list from lastrepo
  my $now_version=get_now_vertion();
  my $last_store_dir=".legit/".$NOW_BRANCH."/.$now_version";

  opendir ( DIR, $last_store_dir ) || die "Error in opening dir $version_store_dir\n";
  my @last_repo_dir_filenames = grep(/^[^\.]/,readdir(DIR));
  closedir(DIR);

  my @indexd_filenames = get_track_file_list();
  ##  build the file we focusd from above


  foreach my $x (@working_dir_filenames) {
    $focus_list{$x}=1;
  }
  foreach my $y (@last_repo_dir_filenames) {
    $focus_list{$y}=1;
  }
  foreach my $y (@indexd_filenames) {
    $focus_list{$y}=1;
  }
  my @focus_list=sort keys %focus_list;

  ###########################################################################################################
  foreach my $file (@focus_list) {

    %status_hash=(
    1 => "untracked",
    2 => "file deleted",
    3 => "deleted",
    4 => "file changed, different changes staged for commit",
    5 => "file changed, changes staged for commit",
    6 => "file changed, changes not staged for commit",
    7 => "same as repo",
    8 => "added to index",
    9 => "added to index",
    10 => "not exist",
    11 => "untracked",
    12 => "added to index",

  );
    my $status=get_file_status($file);
    print $file." - ".$status_hash{$status}."\n";

  }
  exit (1);


}

sub get_file_status {

  # there are 8 status and we return one status according the co-flag

  #   %status_hash=(
  #   1 => "untracked",
  #   2 => "file deleted",
  #   3 => "deleted",
  #   4 => "file changed, different changes staged for commit",
  #   5 => "file changed, changes staged for commit",
  #   6 => "file changed, changes not staged for commit",
  #   7 => "same as repo",
  #   8 => "added to index",
  # );

  ##  there are 3 file dir  1 working   2  staged   3 lastrepo
  ##  and one index file for note tracking

  ## 1  file_list from working
  opendir ( DIR, "." ) || die "Error in opening dir $version_store_dir\n";
  my @working_dir_filenames = grep(/^[^\.]/,readdir(DIR));
  closedir(DIR);

  ## 2  file_list from lastrepo
  my $now_version=get_now_vertion();
  my $last_store_dir=".legit/".$NOW_BRANCH."/.$now_version";

  opendir ( DIR, $last_store_dir ) || die "Error in opening dir $version_store_dir\n";
  my @last_repo_dir_filenames = grep(/^[^\.]/,readdir(DIR));
  closedir(DIR);


  ## 3 file list from staged dir
  opendir ( DIR, $STAGE ) || die "Error in opening dir $version_store_dir\n";
  my @stage_dir_filenames = grep(/^[^\.]/,readdir(DIR));
  closedir(DIR);

  ## 4 filename in indexfile

  my @indexd_filenames = get_track_file_list();

  #----------------------------------------------------------------------------------

  my $file= shift @_;

  ## initial flag
  my $in_working=0;
  my $in_repo=0;
  my $in_stage=0;
  my $in_index=0;
  my $messageee="";

  if (grep {$_ eq $file} @working_dir_filenames) {
    $in_working=1
  }
  if (grep {$_ eq $file} @last_repo_dir_filenames) {
    $in_repo=1
  }
  if (grep {$_ eq $file} @stage_dir_filenames) {
    $in_stage=1
  }
  if (grep {$_ eq $file} @indexd_filenames) {
    $in_index=1
  }



  # untracked file
  # YXXX
  if ($in_working && !$in_stage && !$in_repo && !$in_index) {
    return 1;
  }


  # file deleted by the unix rm
  # XXYY
  if (!$in_working && !$in_stage && $in_repo && $in_index) {
    return 2;
  }

  # file deleted by legit rm
  # XXYX
  if (!$in_working && !$in_stage && $in_repo && !$in_index) {
    return 3;
  }

  # file added to staged waiting for commit
  # YYYY
  if ($in_working && $in_stage && $in_repo && $in_index) {
    if (check_file_change($file,$STAGE."/".$file)) {
      return 4;
    }
    else{
      return 5;
    }


  }

  # file not_added to staged
  # YXYY
  if ($in_working && !$in_stage && $in_repo && $in_index) {

    if (check_file_change($file,$last_store_dir."/".$file)) {
      return 6;
    }
    else{
      return 7;
    }
  }

  # file new added in index
  # YYXY
  if ($in_working && $in_stage && !$in_repo && $in_index) {
    return 8;
  }
  # XYXY
  if (!$in_working && $in_stage && !$in_repo && $in_index) {
    return 9;
  }
  # XXXX
  if (!$in_working && !$in_stage && !$in_repo && !$in_index) {
    return 10;
  }
  # YXYX
  if ($in_working && !$in_stage && $in_repo && !$in_index) {
    return 11;
  }
  # XYYY
  if (!$in_working && $in_stage && $in_repo && $in_index) {
    return 12;
  }









}




## main -----------------------------------------------------------------------
sub main {
  ## build comand hash for check
  my @comand_list=qw(init add commit log show rm status branch checkout merge);
  my %conmend_hash;
  for(my $i = 1; $i < (@comand_list+1); $i++){
    $conmend_hash{$comand_list[($i-1)]}=$i;
  }




  if (@ARGV == 0 ){
    print_help();
  }
  else{
    my $command = shift @ARGV;
    if (!(exists $conmend_hash{$command})) {
      print_help();
    }
    if ($conmend_hash{$command}==1) {
      init();
    }
    unless (if_already_init()) {
      die "legit.pl: error: no .legit directory containing legit repository exists\n";
    }
    if ($conmend_hash{$command}==2) {
      add();
    }
    if ($conmend_hash{$command}==3) {
      commit();
    }
    if ($conmend_hash{$command}==4) {
      show_log();
    }
    if ($conmend_hash{$command}==5) {
      show();
    }
    if ($conmend_hash{$command}==6) {
      rm();
    }
    if ($conmend_hash{$command}==7) {

      status();
    }




  }
}







# sub dif_staged_and_some_version {
#   $now_version= shift @_;
#
#
#   ## check if something change
#   my $change_flag=0;
#   my $version_store_dir=$NOW_BRANCH."/.$now_version";
#
#   ## get two dir's filenames
#   opendir ( DIR, $STAGE ) || die "Error in opening dir $STAGE\n";
#   @staed_filenames = grep(/^[^\.]/,readdir(DIR));
#   closedir(DIR);
#
#   opendir ( DIR, $version_store_dir ) || die "Error in opening dir $version_store_dir\n";
#   @master_filenames = grep(/^[^\.]/,readdir(DIR));
#   closedir(DIR);
#
#   print "here is list of two dir\n";#  <<<<<<<<<<<  test
#   print @staed_filenames;#  <<<<<<<<<<<  test
#   print @master_filenames;#  <<<<<<<<<<<  test
#   print "here is list of two dir\n";#  <<<<<<<<<<<  test
#
#
# # check if some file changed
#   foreach my $x (@staed_filenames) {
#     if (grep {$_ eq $x} @master_filenames) {
#       my $file1_path=$STAGE."/$x";
#       my $file2_path=$version_store_dir."/$x";
#       ## some file changed
#       if (check_file_change($file1_path,$file2_path)) {
#
#         $change_flag=1;
#
#         return $change_flag;
#       }
#
#
#
#     }else{## some new file
#
#       $change_flag=1;
#       return $change_flag;
#     }
#   }
# }



#
# 09 21 / init add main half commit   index /n? chomp?
#
#
#
#
#
#



our $IND=".legit/index";
our $STAGE=".legit/staged";
our $DLETE_STAGE=".legit/del";
our $NOW_BRANCH="master";
our $BRANCH_VER=".legit/".$NOW_BRANCH."/version";
our $BRANCH_LOG=".legit/".$NOW_BRANCH."/log";
main();
