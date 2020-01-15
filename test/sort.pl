#!/usr/bin/perl -w

#
# ferm, a firewall setup program that makes firewall rules easy!
#
# Copyright 2001-2017 Max Kellermann
#
# Bug reports and patches for this program may be sent to the GitHub
# repository: L<https://github.com/MaxKellermann/ferm>
#

# This script sorts the tables and chains in ferm output so the
# unit test suite can use "diff" to verify it.  It's a kludge that is
# necessary because ferm outputs these in random order (because Perl
# does).

use strict;

my %rules;
my $table;

sub flush_output() {
    foreach my $key (sort keys %rules) {
        foreach my $line (@{$rules{$key}}) {
            print $line;
        }
    }
    undef %rules;
    undef $table;
}

while (<>) {
    if (/^(# Generated .+) on .+/) {
        flush_output;
        print $1, "\n";
    } elsif (/^#/) {
        next;
    } elsif (/^(\w+)tables -t (\w+) -([NAP]) (\S+)/ or
          /^(\w+)tables(?: --atomic-file \w+)? -t (\w+) -([FX])()$/) {
        my $key = $3 eq 'P' ? "$1 $2  $4" : "$1 $2 $4";
        $key .= ' z' if $4 eq '';
        my $array = $rules{$key} ||= [];
        push @$array, $_;
    } elsif (/^\*(\S+)/) {
        $table = $1;
        my $key = $table;
        my $array = $rules{$key} ||= [];
        push @$array, $_;
    } elsif (/^COMMIT/) {
        my $key = $table . 'z';
        my $array = $rules{$key} ||= [];
        push @$array, $_;
    } elsif (/^(:)(\S+)/ or /^-(A) (\S+)/) {
        my $key = $table . $1 . $2;
        my $array = $rules{$key} ||= [];
        push @$array, $_;
    } elsif (/^ebtables -t (\w+) --atomic-file (\S+) (\N+)/) {
        my $key = $2;
        my $array = $rules{$key} ||= [];
        push @$array, $_;
    } else {
        die;
    }
}
flush_output;
