#! /usr/bin/perl -w

########################################################################
## Sat Apr 10 13:47:04 PDT 2010
## this will read a population (assumed to have a single group) and will
## create a duplicate of each individual but with group 2 instead.
## For now, now worries about kinship just assume it's a starting population
## with only age and sex mattering
########################################################################

my @pop=<STDIN>;
print STDERR "snorked ".scalar(@pop)." records on stdin\n";
chomp(@pop);
my $maxid=0;
my $maxgroup=1;

foreach(@pop){
  my($id,$sex,$group,$mstat,$bdate)=split(' ',$_);
  print $_."\n";
  $maxid=($id>$maxid?$id:$maxid);
  $maxgroup=($group>$maxgroup?$group:$maxgroup);
}

foreach(@pop){
  my@line=split(' ',$_);

  print join(" ",$line[0]+$maxid,
	     $line[1],$line[2]+$maxgroup,$line[3],
	     $line[4],@line[5..12])."\n";
}

