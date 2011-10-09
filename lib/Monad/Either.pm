package Monad::Either;

use warnings;
use strict;

=head1 NAME

Monad::Maybe - A quasi-implementation of the Maybe monad in Perl

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

=head1 DESCRIPTION

This is an experimental Perl implementation of a class with some
properties of the Maybe monad.

=cut

require Exporter;

our @ISA = qw( Exporter );

our @EXPORT = qw( lift Left Right );

use enum qw( LEFT RIGHT );

use English qw( -no_match_vars );

=head2 Methods

=over

=item left

=cut

sub left {
    my ($class, $val) = @_;
    my $self = [ LEFT, $val ];
    return bless $self, $class;
}

=item is_left

=cut

sub is_left {
    my ($self) = @_;
    return ($self->[0] == LEFT);
}

=item right

=cut

sub right {
    my ($class, $val) = @_;
    my $self = [ RIGHT, $val ];
    return bless $self, $class;
}

=item bind

=cut

sub bind {
    my ($self, $func) = @_;
    if ($self->is_left) {
	return $self;
    } else {
	my $class = ref($self) || __PACKAGE__;
	eval {
	    my $val = &{$func}( ${$self} );
	    if ((ref $val) && $val->isa(__PACKAGE__)) {
		return $val;
	    } else {
		return $class->left('Expected '.__PACKAGE__);
	    }
	} or return $class->left($EVAL_ERROR); # ?
    }
}

=item join

=cut

sub join {
    my ($self) = @_;
    if ($self->isa(__PACKAGE__)
	&& ref(${$self}) && ${$self}->isa(__PACKAGE__)) {
	return ${$self};
    } else {
	my $class = ref($self) || __PACKAGE__;
	return $class->left('Expected '.__PACKAGE__);
    }
}

=back

=head2 Subroutines

=over

=item Left

=cut

sub Left {
    __PACKAGE__->left(@_);
}

=item Right

=cut

sub Right {
    __PACKAGE__->right(@_);
}

=item lift

=cut

sub lift {
    my ($func) = @_;
    return sub {
	my $self   = $_[0];
	my $class  = ref($self) || __PACKAGE__;
	if (my @lefts = (grep $_->is_left, @_)) {
	    return $lefts[0];
	}
	eval {
	    return $class->right( &{$func}( map { ${$_} } @_ ) );
	} or return $class->left($EVAL_ERROR);
    };
}

=back

=head1 AUTHOR

Robert Rothenberg, C<< <rrwo at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Robert Rothenberg.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Monad::Maybe
