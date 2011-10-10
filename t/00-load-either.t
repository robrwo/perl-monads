#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Monad::Either' ) || print "Bail out!
";
}

diag( "Testing Monad::Either $Monad::Either::VERSION, Perl $], $^X" );
