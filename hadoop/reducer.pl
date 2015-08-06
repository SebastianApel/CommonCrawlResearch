#!/usr/bin/env perl
# reducer.pl

use warnings;
use strict;

my $current_word = "";
my $current_count = 0;

while (<>) {
    chomp;

    my ($word, $count) = split /\t/;
  
    if ($word eq $current_word) {
        $current_count += $count;
    } else {
        print "$current_word\t$current_count\n" if length($current_word);
        $current_word = $word;
        $current_count = $count;
    }
}

print "$current_word\t$current_count\n";