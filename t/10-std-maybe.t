#!perl -T

use strict;
use warnings;

use Test::More tests => 12;

use Monad::Maybe;

my $x = Just(10);
my $y = Just(5);
my $z = Nothing;

foreach my $o ($x, $y, $z) {
    ok($o->isa('Monad::Maybe'), 'isa');
}

ok(Just()->is_nothing, 'no args is_nothing');
ok(Just(undef)->is_nothing, 'undef is_nothing');

my $succ = sub {
    my $x = shift;
    return Just($x+1);
};

my $test = lift(sub {
    my ($a, $b) = @_;
    is($a, $b, 'lifted is');
});

&{$test}($x, Just(10));
&{$test}($y, Just(5));
&{$test}($z, Nothing); # not actually run

&{$test}($x->bind($succ), Just(11));
&{$test}($y->bind($succ), Just(6));
&{$test}($z->bind($succ), Nothing); # not actually run

my $div = lift(sub {
  my ($a, $b) = @_;
  return $a / $b;
});

&{$test}( &{$div}($x, $x), Just(1));
&{$test}( &{$div}($x, $y), Just(2));
&{$test}( &{$div}($x, Just(0)), Nothing); # not actually run
&{$test}( &{$div}($x, $z), Nothing); # not actually run
&{$test}( &{$div}($z, $x), Nothing); # not actually run

&{$test}(Just(1)->join, Nothing); # not actually run
&{$test}(Just(Just(1))->join, Just(1));
