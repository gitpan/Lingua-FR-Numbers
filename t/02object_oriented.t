#!/usr/bin/perl -w
use strict;
use Test;
BEGIN { plan tests => 58 }
use Lingua::FR::Numbers;
use vars qw(@numbers);
do 't/numbers';

while (@numbers){
	my ($number, $test_string) = splice(@numbers, 0, 2);
	my $num = Lingua::FR::Numbers->new($number);
	ok( $num->get_string, $test_string );
}

