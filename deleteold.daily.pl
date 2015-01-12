#!/usr/bin/perl
use strict;

#0 * * * * /usr/bin/perl /root/pxebackup/deleteold.daily.pl 2>&1 >/tmp/deleting.txt

my $passwd = `cat /root/sharepw.sekretairin.txt`;
chomp($passwd);

my $mountdir = "/mnt/feuss";
my $MINBACKUPCOUNT = 1;
my $percentfree = 10;
#my $MINFREE = 100*1024*1024;

foreach my $j ("sekretairin") {
   print "Mounting...\n";
   system("/bin/umount", $mountdir."/");
   if (my $err = system("/bin/mount", "-t", "cifs", "-o", 'user=clonezilla,password='.$passwd, '//192.168.44.11/'.$j, $mountdir)) {
      print "error mounting: ".$err."\n";
      exit($err);
   }
   if (-e $mountdir."/"."backup_directory") {
      print "Backupdir found.\n";
      my $df = [split(/\s+/, `df |grep $mountdir`)];
      my $MINFREE = int(($df->[1] / 100) * $percentfree);
      print "Free is ".$df->[3]." of ".$MINFREE." needed.\n";
      #system("/bin/bash");
      #my $j = 0;
         if (($df->[1] =~ m,^\d+$,) &&
             ($df->[3] =~ m,^\d+$,) && ($df->[3] > $MINFREE)) {
            print "Enough free.\n";
            next;
         }
         my @x = (); 
         opendir(DIR, $mountdir) || die("opendir: ".$!);
         while(my $dir = readdir(DIR)) {
            next unless $dir =~ /^(\d{4})\-(\d{2})\-(\d{2}).*\-img/;
            push(@x, $dir);
         }
         closedir(DIR);
         if (scalar(@x) < $MINBACKUPCOUNT) {
            print "Only ".(scalar(@x) || "0")." Backups, returning.\n";
            next;
         }
         my $todelete = shift(@x);
         #foreach my $deleteme (reverse sort @x) {
         #   next unless (++$i < 7);
            print "Deleting ".$todelete."\n";
            system("/bin/rm", "-R", $mountdir."/".$todelete);
         #}
   } else {
      print "No backupdir found!\n";
   }
}

system("/bin/umount", $mountdir."/");

