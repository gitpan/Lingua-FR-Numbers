#!/usr/bin/perl -w
use strict;
use Test;
BEGIN { plan tests => 4 }
use Lingua::FR::Numbers qw( number_to_fr );

use vars qw(@numbers);
@numbers = (
	'foo'   => undef,
	'12bar' => undef,
	'12e2'  => 'mille deux cents',
	1234567890123456 => undef,
);

while (@numbers){
	my ($number, $test_string) = splice(@numbers, 0, 2);
	ok( number_to_fr( $number ), $test_string );
}


