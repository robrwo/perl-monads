package Monad::Either;

require v5.10;

use strict;
use warnings;

=head1 NAME

Monad::Either - A quasi-implementation of the Either String monad in
Perl

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

=head1 DESCRIPTION

This is an experimental Perl implementation of a class with some
properties of the Either monad.

=cut

use Exporter::Lite;

our @EXPORT = qw/ lift Left Right /;

use enum qw( LEFT RIGHT );

use English qw/ -no_match_vars /;
use Scalar::Util qw/ blessed /;

use overload 'bool' => \&is_right;

=head2 Methods

=over

=item left

  $x = Monad::Either->left( $scalar );

A left-sided constructor for the monad. This is used for indicating
error confitions, e.g.

  eval { ... } or Monad::Either->left( $EVAL_ERROR );

=cut

sub left {
    my ($class, $val) = @_;
    my $self = [ LEFT, $val ];
    return bless $self, $class;
}

=item is_left

  if ($x->is_left) { ... }

Returns true if the object is a left-sided monad.

=cut

sub is_left {
    my ($self) = @_;
    return ($self->[0] == LEFT);
}

=item right

  $x = Monad::Either->right( $scalar );

A right-sided constructor for the monad. This is used for non-error
("right") values.

=cut

sub right {
    my ($class, $val) = @_;
    my $self = [ RIGHT, $val ];
    return bless $self, $class;
}

=item is_right

  if ($x->is_right) { ... }

Returns true if the object is a right-sided monad.

=cut

sub is_right {
    my ($self) = @_;
    return ($self->[0] == RIGHT);
}

=item bind

  $x->bind( $f );

Applies a function to the value of C<$x>, where C<$f> is a function
that takes a non-monad as an argument and returns a C<Monad::Either>
value.

If the function does not return a C<Monad::Either> object, or it
returns an error, then it will return a left-sided monad with an
error message.

If C<$x> is left-sided, then the C<$f> is not actually run, and C<bind>
returns C<$x>, passing the error.

=cut

sub bind {
    my ($self, $func) = @_;
    if ($self->is_left) {
	return $self;
    } else {
	my $class = ref($self) || __PACKAGE__;
	eval {
	    my $val = $func->( ${$self} );
	    if ((blessed $val) && $val->isa(__PACKAGE__)) {
		return $val;
	    } else {
		return $class->left('Expected '.__PACKAGE__);
	    }
	} or return $class->left($EVAL_ERROR); # ?
    }
}

=item join

  $x->join;

Takes a C<Monad::Either> of a C<Monad::Either> and returns a
C<Monad::Either>.

If C<$x> is not a C<Monad::Either> of a C<Monad::Either>, then it
returns a left-sided monad with the error.

=cut

sub join {
    my ($self) = @_;
    if ($self->isa(__PACKAGE__)
	&& blessed(${$self}) && ${$self}->isa(__PACKAGE__)) {
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

  $x = Left( $scalar );

This is shorthand for the L</left> constructor.

=cut

sub Left {
    __PACKAGE__->left(@_);
}

=item Right

  $x = Right( $scalar );

This is shorthand for the L</right> constructor.

=cut

sub Right {
    __PACKAGE__->right(@_);
}

=item lift

  $g = lift( $f );

Lifts a non-monadic function to a C<Monad::Either> function.

If any of the values passed to the lifted function are left-sided,
then C<$f> is not actually executed, and C<$g> returns the first
left-sided monad in the argument list..

If C<$f> dies, then C<$g> returns a left-sided monad with the error.

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

Copyright 2011-2014 Robert Rothenberg.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Monad::Either
