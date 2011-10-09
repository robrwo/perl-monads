package Monad::Maybe;

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

our @EXPORT = qw( lift Nothing Just );

=head2 Methods

=over

=item nothing

=cut

sub nothing {
    my ($class) = @_;
    return bless \&nothing, $class;
}

=item is_nothing

=cut

sub is_nothing {
    return ($_[0] == \&nothing);
}

=item just

=cut

sub just {
    my ($class, $arg) = @_;
    if (defined $arg) {
	return bless \$arg, $class;
    } else {
	return $class->nothing;
    }
}

=item bind

=cut

sub bind {
    my ($self, $func) = @_;
    if ($self->is_nothing) {
	return $self;
    } else {
	my $class = ref($self) || __PACKAGE__;
	eval {
	    my $val = &{$func}( ${$self} );
	    if ((ref $val) && $val->isa(__PACKAGE__)) {
		return $val;
	    } else {
		return $class->nothing;
	    }
	} or return $class->nothing;
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
	return $class->nothing;
    }
}

=back

=head2 Subroutines

=over

=item Nothing

=cut

sub Nothing() {
    __PACKAGE__->nothing();;
}

=item Just

=cut

sub Just {
    __PACKAGE__->just(@_);
}

=item lift

=cut

sub lift {
    my ($func) = @_;
    return sub {
	my $self   = $_[0];
	my $class  = ref($self) || __PACKAGE__;
	return $class->nothing if (grep $_->is_nothing, @_);
	eval {
	    return $class->just( &{$func}( map { ${$_} } @_ ) );
	} or return $class->nothing;
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
