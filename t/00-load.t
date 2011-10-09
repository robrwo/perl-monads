#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Monad::Maybe' ) || print "Bail out!
";
}

diag( "Testing Monad::Maybe $Monad::Maybe::VERSION, Perl $], $^X" );
