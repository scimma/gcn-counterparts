#!/usr/bin/perl -w
###
### Author: rdt12@psu.edu
### Date: May 8, 2020
### Description, parse the GCN counterparts table:
###
###      https://gcn.gsfc.nasa.gov/counterpart_tbl.html
###
### to scrape counterparts to be added to a SCIMMA/HOP topic.
###
### This program will need to be updated if the form of the counterpart
### table changes.
###
### Counterparts are written as individual files in the subdirectory cpidr.
###
use strict;
use FileHandle;

my($counterparts);
$counterparts->{'grb'}  = [];
$counterparts->{'lvc'}  = [];
$counterparts->{'none'} = [];

my($cpdir) = "./cpdir";

my($line);
my($current_type) = "none";
my($current_url) = "";
my($cfound) = 0;
while ($line = <>) {
    if ($line =~ /href=(other\/[^>]+)>/) {
        $current_url = $1;
        $cfound = 1;
    }
    if ($line =~ /left>\s+GRB COUNTERPART/) {
        $current_type = "grb";
        next;
    }
    if ($line =~ /left>\s+LVC Counterpart/) {
        $current_type = "lvc";
    }
    if ($line =~ /<\/tr>/) {
        if ($cfound) {
            push(@{$counterparts->{$current_type}}, $current_url);
        }
        $cfound = 0;
        $current_type = "none";
        $current_url  = "";
        next;
    }
}

my($c,$url);
my($baseUrl) = "https://gcn.gsfc.nasa.gov/";
my(@lines);
my($fh);
my($cmd);
my(@nlines);
my($notices);
my($dateStr);
my($cdone);
for $c (@{$counterparts->{'lvc'}}) {
    if (defined($cdone->{$c})) {
        next;
    }
    $cdone->{$c} = 1;
    $cmd = sprintf("curl -s %s/%s |", $baseUrl, $c);
    $fh = FileHandle->new($cmd);
    @nlines = ();
    while (1) {
        $line = <$fh>;
        if ((!defined($line)) || ($line =~ /^\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\//)) {
            if (@nlines) {
                writeNotice(\@nlines);
            }
            @nlines = ();
            if (!defined($line)) {
                last;
            }
            next;
        }
        push(@nlines, $line);
    }
    $fh->close();
    sleep(5);
}

exit(0);

###
###
###
sub writeNotice {
    my($lines)   = shift;
    my($dateStr) = getDateStr($lines);
    my($fname)   = getFileName($dateStr);
    printf("Writing: %s\n", $fname);
    my($fh) = FileHandle->new($fname, "w");
    my($l);
    for $l (@{$lines}) {
        print $fh $l;
    }
    $fh->close();
}

sub getFileName {
    my($f) = shift;
    my($dh);
    my($fname);
    my($n) = 0;
    while (1) {
        $fname = sprintf("%s/%s-%03d.gcn3", $cpdir, $f, $n);
        if ($n >= 1000) {
            fatalError("Could not find file name for circular.");
        }
        if (-f $fname) {
            $n++;
            next;
        } else {
            last;
        }
    }
    return $fname;
}

sub getDateStr {
    my($month) = {'Jan' => 1,
                  'Feb' => 2,
                  'Mar' => 3,
                  'Apr' => 4,
                  'May' => 5,
                  'Jun' => 6,
                  'Jul' => 7,
                  'Aug' => 8,
                  'Sep' => 9,
                  'Oct' => 10,
                  'Nov' => 11,
                  'Dec' => 12};
    my($lines) = shift;
    my($line);
    my($mday, $mName, $syear, $hour, $min, $sec);
    my($year, $mon);
    my($dateStr);
    for $line (@{$lines}) {
        if ($line =~ /^NOTICE_DATE:\s+\S+\s+([0-9]+)\s+(\S+)\s+([0-9]+)\s+([0-9][0-9]):([0-9][0-9]):([0-9][0-9])\s+UT/) {
            ($mday, $mName, $syear, $hour, $min, $sec) = ($1, $2, $3, $4, $5, $6);
            $dateStr = sprintf("%4d%02d%02d.%02d%02d%02d",
                               $syear + 2000, $month->{$mName}, $mday,
                               $hour, $min, $sec);
            last;
        }
    }
    if (!defined($dateStr)) {
        fatalError("Could not find date.");
    }
    return $dateStr;
}


sub fatalError {
    my($format) = shift;
    printf(STDERR "Error: " . $format . "\n", @_);
    printf(STDERR "Exiting.\n");
    exit(-1);
}
