#!/usr/bin/perl -w
use strict;
use Test;
BEGIN { plan tests => 20 }
use Lingua::FR::Numbers::Ordinate qw( ordinate_fr );

use vars qw( @numbers );
do 't/ordinates';

while ( @numbers ){
	my ( $number, $result ) = splice( @numbers, 0, 2);
	ok( ordinate_fr($number), $result);
}

