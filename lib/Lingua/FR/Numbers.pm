package Lingua::FR::Numbers;
use strict;

use Carp qw(carp);
use Exporter;

use vars qw( $VERSION @ISA @EXPORT_OK );
use vars qw(
  $MODE
  %NUMBER_NAMES
  %SIGN_NAMES
  %OUTPUT_DECIMAL_DELIMITER
);

$VERSION   = 0.01;
@ISA       = qw(Exporter);
@EXPORT_OK = qw(
  number_to_fr
  number_to_fr_FR
);

%SIGN_NAMES = (
    'fr_FR' => [ 'moins', '' ],
);

%OUTPUT_DECIMAL_DELIMITER = (
    'fr_FR' => 'virgule',
);

%NUMBER_NAMES = (
    'fr_FR' => {
        0      => 'zéro',
        1      => 'un',
        2      => 'deux',
        3      => 'trois',
        4      => 'quatre',
        5      => 'cinq',
        6      => 'six',
        7      => 'sept',
        8      => 'huit',
        9      => 'neuf',
        10     => 'dix',
        11     => 'onze',
        12     => 'douze',
        13     => 'treize',
        14     => 'quatorze',
        15     => 'quinze',
        16     => 'seize',
        17     => 'dix-sept',
        18     => 'dix-huit',
        19     => 'dix-neuf',
        20     => 'vingt',
        30     => 'trente',
        40     => 'quarante',
        50     => 'cinquante',
        60     => 'soixante',
        70     => 'soixante',
        80     => 'quatre-vingt',
        90     => 'quatre-vingt',
        10**2  => 'cent',
        10**3  => 'mille',
        10**6  => 'million',
        10**9  => 'milliard',
        10**12 => 'billion',
        10**18 => 'trillion',
        10**24 => 'quatrillion',
        10**30 => 'quintillion',
        10**36 => 'sextillion',		# the sextillion is the biggest legal unit
    },

);

$MODE = 'fr_FR';

=pod

=head1 NAME

Lingua::FR::Numbers - Converts numeric values into their French string
equivalents

=head1 SYNOPSIS

 # OO Style
 use Lingua::FR::Numbers;
 my $nombre = Lingua::FR::Numbers->new( 123 );
 print $nombre->get_string;

 my $autre_nombre = Lingua::FR::Numbers->new;
 $autre_nombre->parse( 7340 );
 $french_string = $autre_nombre->get_string;

 # Function style
 use Lingua::FR::Numbers qw(number_to_fr);
 print number_to_fr( 345 );

=head1 DESCRIPTION

This module tries to convert a number into French cardinal numeral
adjective. It only supports integers number for now.

The interface tries to conform to the one defined in Lingua::EN::Number,
though this module does not provide any parse() method. Also, notes that
unlike Lingua::En::Numbers, you can use this module in a functionnal
manner by importing the number_to_fr() function.

=cut

=pod

=head2 VARIABLES

=item $Lingua::FR::Numbers::MODE

The current locale mode. Currently only 'fr_FR' (French from France) is
supported.

=head1 FUNCTION-ORIENTED INTERFACE

=head2 number_to_fr( $number )

=head2 number_to_fr_FR($number)

 use Lingua::FR::Numbers qw(number_to_fr);
 my $depth = number_to_fr( 20_000 );
 my $year  = number_to_fr( 1870 );
 print "Jules Vernes écrivit _$depth lieues sous les mers_ en $year.";

These two functions (which are the same at the moment) can be exported by the module.

=cut

sub number_to_fr {
    my $number = shift;
    my $locale = shift;
    return undef unless defined $number;
    my $num = Lingua::FR::Numbers->new($number) or return undef;
    $num->get_string( MODE => $locale );
}

sub number_to_fr_FR {
    number_to_fr( shift, 'fr_FR' ) or undef;
}

=pod

=head1 OBJECT-ORIENTED INTERFACE

=head2 new( [ $number ] )

 my $start = Lingua::FR::Numbers->new( 500 );
 my $end   = Lingua::FR::Numbers->new( 3000 );
 print "Nous partîmes ", $start->get_string, 
       "; mais par un prompt renfort\n",
       "Nous nous vîmes ", $end->get_string," en arrivant au port"


Creates and initialize a new instance of an object.

=cut

sub new {
    my $class  = shift;
    my $number = shift;

    my $self = bless {}, $class;

    if ( defined $number ) {
        $self->parse($number) or return undef;
    }
    return $self;
}

=pod

=head2 parse( $number )

Initialize (or reinitialize) the instance. Note that the number is treated as an integer.

=cut

sub parse {
    my $self          = shift;
    my $number_string = shift;

    my ( $number, $decimal, $sign ) = string_to_number($number_string)
      or return undef;
    return undef unless defined $number;

    $self->{numeric_data}{number} = $number;

    # TODO
    #$self->{numeric_data}{decimal} = $decimal;
    $self->{numeric_data}{sign} = $sign;

    $self->{string_data}{number} = parse_number($number);

    # TODO
    #$self->{string_data}{decimal}  = parse_number($decimal);
    $self->{string_data}{sign} = $SIGN_NAMES{$MODE}[$sign];

    return 1;
}

=pod

=head2 get_string( [ %options ] )

 my $string = $number->get_string;
 my $string = $number->get_string( MODE => 'fr_CH' );
 
Returns the number as a formatted string in French, lowercased.
The hash of options can be used to set the locale to use for the output
(currently unimplemented.)

=cut

sub get_string {
    my $self    = shift;
    my %options = @_;
    my $string;

    if ( !$self->{numeric_data}{sign} ) {
        $string .= $self->{string_data}{sign} . " ";
    }
    $string .= $self->do_get_string('number');
    if ( $self->{numeric_data}{decimal} ) {
        $string .= " $OUTPUT_DECIMAL_DELIMITER{$MODE} ";
        $string .= $self->do_get_string('decimal');
    }
    $string =~ s/^\s+|\s+$//g;
    return $string;
}

sub do_get_string {
    my $self  = shift;
    my $block = shift;
    my @blockStrings;

    my $number = $self->{'string_data'}{$block};

    foreach my $component ( sort { $b <=> $a } keys %$number ) {
        my $magnitude = $number->{$component}{'magnitude'};
        my $factor    = $number->{$component}{'factor'};

        # Let's throw in some grammar rules

        # pluriel million, milliard, ...
        if ( $component >= 10**6 && $factor->[0][0]
          && $factor->[0][0] ne $NUMBER_NAMES{$MODE}{1} )
        {
            $magnitude .= "s";
        }

        # 'un cent' => 'cent'
        if ( $factor->[0][0] && $factor->[0][1]
          && $factor->[0][0] eq $NUMBER_NAMES{$MODE}{1}
          && $factor->[0][1] eq $NUMBER_NAMES{$MODE}{100} )
        {
            splice( @{ $factor->[0] }, 0, 1 );
        }

        # 'un mille' => 'mille'
        if ( $magnitude eq $NUMBER_NAMES{$MODE}{1000}
          && $factor->[0][0] eq $NUMBER_NAMES{$MODE}{1} )
        {
            $factor = [];
        }

        # pluriel cent: 'trois cents' but 'trois cent deux'
        if ( !$factor->[1] && !$magnitude && $factor->[0][1] && $factor->[0][0]
          && $factor->[0][0] ne $NUMBER_NAMES{$MODE}{1}
          && $factor->[0][1] eq $NUMBER_NAMES{$MODE}{100} )
        {
            $factor->[0][1] .= 's';
        }

        # pluriel vingt: 'quatre-vingts' but 'quatre-vingt-trois'
        if ( !$factor->[1] && $factor->[0][0]
          && $factor->[0][0] =~ /.+$NUMBER_NAMES{$MODE}{20}$/ )
        {
            $factor->[0][0] .= 's';
        }

        my @strings;
        map { push @strings, join ( ' ', @$_ ) } @$factor;
        my $string = join ( ' ', @strings ) . ' ' . $magnitude;
        push @blockStrings, $string;
    }

    my $blockString = join ( ' ', @blockStrings );
    $blockString =~ s/\s+$//;
    return $blockString;

}

#################################################################
# Math Routines
#################################################################

sub pow10Block {
    my ($number) = @_;
    if ($number) {
		# XXX the '+1' is needed because of a rounding error with
		# int() when using 1000 or 1_000_000 as number...
        return ( int( ( log( $number + 1 ) / log(10) ) / 3 ) * 3 );
    }
    else {
        return 0;
    }

}

#################################################################
# Numeric String Parsing Routines
#################################################################

sub string_to_number {
    my $string = shift;

    # from PERLDOC PERLFAQ
    if ( $string !~ /^[+-]?(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/ ) {
        carp "bad number format: '$string'";
        return undef;
    }


	if ( abs $string > 999999999999999 ){
        carp "number too big: '$string'";
		return undef;
	}

    my $integer = abs int $string;
    my $decimal = $string - int($string);    # XXX beware of 'infinite decimals'
    my $sign = abs $string == $string ? 1 : 0;

    return ( $integer, $decimal, $sign );
}

sub parse_number {
    my $number = shift;

    if ( defined $number && !$number ) {
        return {
            1 => {
                magnitude => '',
                factor    => [ [ $NUMBER_NAMES{$MODE}{0} ] ]
            }
        };
    }

    my %names;
    my $powerOfTen = pow10Block($number);

    while ( $powerOfTen > 0 ) {
        my $factor     = int( $number / 10**$powerOfTen );
        my $component  = $factor * 10**$powerOfTen;
        my $magnitude  = $NUMBER_NAMES{$MODE}{ 10**$powerOfTen };
        my $factorName = parse_number_low($factor);

        $names{$component}{factor}    = $factorName;
        $names{$component}{magnitude} = $magnitude;

        $number -= $component;
        $powerOfTen = pow10Block($number);

    }
    if ($number) {
        $names{1}{factor}    = parse_number_low($number);
        $names{1}{magnitude} = '';
    }
    return \%names;
}

# Numbers lower than 100
sub parse_number_low {
    my $number = shift;

    my @names;

    my %cents;
    if ( $number >= 100 ) {
        my $hundreds = int $number / 100;
        push @names,
          [ $NUMBER_NAMES{$MODE}{$hundreds}, $NUMBER_NAMES{$MODE}{100} ];
        $number -= $hundreds * 100;
    }

    my $decim = int( $number / 10 ) * 10;
    my $unit  = $number % 10;

    if ( $decim == 0 ) {
        push @names, [ $NUMBER_NAMES{$MODE}{$unit} ] if $unit;
    }
    elsif ( $decim == 80 && $unit ) {
        push @names,
          [ $NUMBER_NAMES{$MODE}{$decim} . '-' . $NUMBER_NAMES{$MODE}{$unit} ];
    }
    elsif ( $decim == 70 || $decim == 90 ) {
        $unit += 10;

        # XXX Special case for 71 :-/
        my $str_number =
          $decim == 70 && $unit == 11 ?
          $NUMBER_NAMES{$MODE}{$decim} . ' et ' . $NUMBER_NAMES{$MODE}{$unit} :
          $NUMBER_NAMES{$MODE}{$decim} . '-' . $NUMBER_NAMES{$MODE}{$unit};
        push @names, [$str_number];
    }
    else {

        if ( $decim == 10 ) {
            push @names, [ $NUMBER_NAMES{$MODE}{ $decim + $unit } ];
        }
        elsif ( $unit == 1 || $unit == 11 ) {
            push @names, [ $NUMBER_NAMES{$MODE}{$decim} . ' et '
                . $NUMBER_NAMES{$MODE}{$unit} ];
        }
        elsif ( $unit == 0 ) {
            push @names, [ $NUMBER_NAMES{$MODE}{$decim} ];
        }
        else {
            push @names, [ $NUMBER_NAMES{$MODE}{$decim} . '-'
                . $NUMBER_NAMES{$MODE}{$unit} ];
        }
    }
    return \@names;
}

1;

__END__

=pod

=head1 TODO

=over

=item *

support decimal numbers - although I do not know how decimal are
supposed to be written in French.

=item *

support for fr_* languages.

 - fr_FR
 - fr_BE
 - fr_CA
 - fr_CH
 - fr_LU

=item *

support for very large numbers ( sextillion de sextillion ... )/
 
=back

=head1 DIAGNOSTICS

=over

=item Error: bad number format: '$number'.

(W) The number specified is not in a valid numeric format.

=item Error: number too big: '$number'

(W) The number is to big to be converted into a string.

=back

=head1 BUGS AND COMMENTS

Though the modules should be able to convert big numbers (up to 10**36),
I do not know how perl handles them.

Probably a lot. If you find one, please use the L<Request Tracker
Interface|http://rt.cpan.org/NoAuth/Bugs.html?Dist=Lingua-FR-Numbers>
- http://rt.cpan.org/NoAuth/Bugs.html?Dist=Lingua-FR-Numbers to report
it, thanks.


=head1 SOURCE

I<Le français correct - Maurice GREVISSE>

I<Décret n° 61-501 du 3 mai 1961. relatif aux unités de mesure
et au contrôle des instruments de mesure.>
- http://www.adminet.com/jo/dec61-501.html

=head1 COPYRIGHTS

Copyright (c) 2002, Briac Pilpré. All rights reserved. This code is free
software; you can redistribute it and/or modify it under the same terms
as Perl itself.

=head1 AUTHOR

Briac Pilpré <briac@cpan.org>

=head1 SEE ALSO

Lingua::EN::Numbers 

