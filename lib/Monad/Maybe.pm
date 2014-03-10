package Monad::Maybe;

require v5.10;

use strict;
use warnings;

=head1 NAME

Monad::Maybe - A quasi-implementation of the Maybe monad in Perl

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

  use Maybe::Monad;

  *suc = sub { Just(1 + shift) };

  $a = Just(10);

  $x->bind(\&suc);   # returns Just(11);

  *div = lift(sub { $_[0] / $_[1] });

  *add = lift(sub { $_[0] + $_[1] });

  $b = Just(0);

  $c = div($a, $b);  # $c is Nothing

  $d = add($c, $a);  # $d is Nothing

=head1 DESCRIPTION

This is an experimental Perl implementation of a class with some
properties of the Maybe monad.

=cut

use Exporter::Lite;
use Scalar::Util qw/ blessed refaddr /;

use overload 'bool' => \&is_just;

our @EXPORT = qw/ lift Nothing Just /;

=head2 Methods

=over

=item nothing

  $x = Monad::Maybe->nothing;

A constructor that returns "nothing".

=cut

sub nothing {
    my ($class) = @_;
    return bless \&nothing, $class;
}

=item is_nothing

  if ($x->is_nothing) { ... }

Returns true if the object is "nothing".

=cut

sub is_nothing {
    return (refaddr($_[0]) == refaddr(\&nothing));
}

=item just

  $x = Monad::Maybe->just( $scalar );

A constructor that sets the value of the monad to "just" the argument.

=cut

sub just {
    my ($class, $arg) = @_;
    if (defined $arg) {
	return bless \$arg, $class;
    } else {
	return $class->nothing;
    }
}

=item is_just

  if ($x->is_just) { ... }

Returns true if the object is not "nothing".

=cut

sub is_just {
    return (refaddr($_[0]) != refaddr(\&nothing));
}

=item bind

  $x->bind( $f );

Applies a function to the value of C<$x>, where C<$f> is a function
that takes a non-monad as an argument and returns a C<Monad::Maybe>
value.

If the function does not return a C<Monad::Maybe> object, or it
returns an error, then it will return "nothing".

If C<$x> is nothing, then the C<$f> is not actually run, and C<bind>
returns "nothing".

=cut

sub bind {
    my ($self, $func) = @_;
    if ($self->is_nothing) {
	return $self;
    } else {
	my $class = ref($self) || __PACKAGE__;
	eval {
	    my $val = $func->( ${$self} );
	    if ((blessed $val) && $val->isa(__PACKAGE__)) {
		return $val;
	    } else {
		return $class->nothing;
	    }
	} or return $class->nothing;
    }
}

=item join

  $x->join;

Takes a C<Monad::Maybe> of a C<Monad::Maybe> and returns a
C<Monad::Maybe>.

If C<$x> is not a C<Monad::Maybe> of a C<Monad::Maybe>, then it
returns "nothing".

=cut

sub join {
    my ($self) = @_;
    if ($self->isa(__PACKAGE__)
	&& blessed(${$self}) && ${$self}->isa(__PACKAGE__)) {
	return ${$self};
    } else {
	my $class = ref($self) || __PACKAGE__;
	return $class->nothing;
    }
}

=back

=head2 Subroutines

=over

=item Nothing

  $x = Nothing;

Shorthand for the L</nothing> constructor.

=cut

sub Nothing() {
    __PACKAGE__->nothing();;
}

=item Just

  $x = Just( $v );

Shorthand for the L</just> constructor.

=cut

sub Just {
    __PACKAGE__->just(@_);
}

=item lift

  $g = lift( $f );

Lifts a non-monadic function to a C<Monad::Maybe> function.

If any of the values passed to the lifted function are "nothing", then
C<$f> is not actually executed, and C<$g> returns "nothing".

If C<$f> dies, then  C<$g> returns "nothing".

=cut

sub lift {
    my ($func) = @_;
    return sub {
	my $self   = $_[0];
	my $class  = ref($self) || __PACKAGE__;
	return $class->nothing if (grep $_->is_nothing, @_);
	eval {
	    return $class->just( $func->( map { ${$_} } @_ ) );
	} or return $class->nothing;
    };
}

=back

=head1 CAVEATS

This is an experimental module. The interface may change completely.

=head1 SEE ALSO

=over 4

=item L<Data::Monad>

=item L<https://gist.github.com/peczenyj/9445226>

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

1; # End of Monad::Maybe
