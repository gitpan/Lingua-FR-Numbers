package Lingua::FR::Numbers::Ordinate;
use strict;
use Lingua::FR::Numbers qw(number_to_fr);
use Exporter;
use Carp qw(carp);
use vars qw( $VERSION @ISA %ORDINALS @EXPORT_OK $MODE );

$VERSION   = 0.01;
@ISA       = qw(Exporter Lingua::FR::Numbers);
@EXPORT_OK = qw( &ordinate_fr &ordinate_fr_FR );

%ORDINALS = (
    'fr_FR' => {
        1 => 'premier',
        5 => 'cinqu',
        9 => 'neuv',
    },
);

$MODE = 'fr_FR';

=pod

=head1 NAME

Lingua::FR::Numbers::Ordinate - Convert numbers into French ordinate adjectives.

=head1 FUNCTION-ORIENTED INTERFACE

=head2 ordinate_fr( $number )

=head2 ordinate_fr_FR( $number )

 use Lingua::FR::Numbers::Ordinate qw(ordinate_fr);
 my $twenty  = number_to_fr( 20 );
 print "Tintin est reporter au petit $vingt";

These two functions (which are the same at the moment) can be exported
by the module.
 
=cut

sub ordinate_fr {
    my $number = shift;
    my $locale = shift;
    return undef unless $number;
    my $num = Lingua::FR::Numbers::Ordinate->new($number) or return undef;
    $num->get_string( MODE => $locale );
}

sub ordinate_fr_FR {
    ordinate_fr( shift, 'fr_FR' ) or undef;
}

=pod

=head1 OBJECT-ORIENTED INTERFACE

See Lingua::FR::Numbers for description of this interface.
Lingua::FR::Numbers::Ordinate only modifies the get_string()
method.

=cut

sub new {

    my $class  = shift;
    my $number = shift;
    my $self = bless {}, $class;

    if ( $number ) {
        $self->parse($number) or return undef;
    }
    return $self;
}

sub parse {
	my $self   = shift;
	my $n = shift;
	if ($n && $n != abs $n){
		carp "cannot generate ordinates for negative number '$n'";
		return undef;
	}
	$self->SUPER::parse($n);
	1;
}

sub get_string {
    my $self    = shift;
    my $ordinal = $self->SUPER::get_string;

	foreach ( keys %{ $ORDINALS{$MODE} } ){

		# XXX
		my $last = $self->{string_data}->{number}->{1}->{number};
		next unless $last;
		$last = substr($last,-1,1);
		
		if ( $self->{numeric_data}->{number} == 1 ){
			return $ORDINALS{$MODE}->{ 1 };
		}
		elsif ( $_ != 1 && $last == $_ ){
			my $replace = number_to_fr( $last );
			$ordinal =~ s/$replace$/$ORDINALS{$MODE}->{$_}/;
		}
	}
	
    $ordinal =~ s/e?$/ième/;
    $ordinal;
}

1;

__END__

=pod

=head1 BUGS AND COMMENT

The sames as Lingua::FR::Number, and probably more.

http://rt.cpan.org/NoAuth/Bugs.html?Dist=Lingua-FR-Numbers

=head1 COPYRIGHTS

Copyright (c) 2002, Briac Pilpré. All rights reserved. This code is free
software; you can redistribute it and/or modify it under the same terms
as Perl itself.

=head1 AUTHOR

Briac Pilpré <briac@cpan.org>

=head1 SEE ALSO

Lingua::FR::Numbers 

