#!/usr/bin/perl -w
use strict;
use LWP::Simple;
use Getopt::Long;
use POSIX qw(strftime);

my $difficulty = 1;
my $count = 50;
my %levels = ( 1=>"Easy", 2=>"Medium", 3=>"Hard", 4=>"Evil" );

GetOptions('difficulty=i' => sub {
        $difficulty = $_[1];
        ($difficulty > 0 && $difficulty <= 4) or die "Invalid Difficulty Level ($difficulty). Level has to be between 1 and 4"
    }, 'count=i' => \$count ) or exit 1;

sub getSudokuPuzzle($) {
    my $level = shift(@_); # Easy = 1, Medium = 2; Hard = 3; Evil = 4
    exit 1 unless ($level > 0 && $level <= 4);
    my $url = "http://show.websudoku.com/?level=";
    
    my $html = get("$url$level");
    
    $html =~ /INPUT NAME=cheat ID=\"cheat\" TYPE=hidden VALUE=\"([0-9]+)\"/;
    my $cheat = $1;
    $html =~ /INPUT ID=\"editmask\" TYPE=hidden VALUE=\"([0-9]+)\"/;
    my $editmask = $1;
    
    my $sudoku = "";
    if (length($cheat) == 81 && length($editmask) == 81) {
        for (my $i=0; $i < 81; $i++) {
            if(substr($editmask,$i,1) eq "0")
                { $sudoku .= "0" }
            else
                { $sudoku .= substr($cheat,$i,1) };
        }
        return "$sudoku";
    } else {
        return "";
    }
}


my $date = strftime "%Y-%m-%d", localtime;
print '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
print "<opensudoku>\n";
print "  <name>Sudoku Fetch</name>\n";
print "  <author>reibuehl</author>\n";
print "  <description></description>\n";
print "  <comment></comment>\n";
print "  <created>$date</created>\n";
print "  <source>SudokuFetch.pl</source>\n";
print "  <level>" . $levels{$difficulty} . "</level>\n";
print "  <sourceURL></sourceURL>\n";
for (my $c=1; $c <= $count; $c++) {
    print "  \<game data=\"" . getSudokuPuzzle($difficulty) . "\" \/\>\n";
}
print "</opensudoku>\n";