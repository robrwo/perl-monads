
require 5.006;

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Monad::Maybe',
    AUTHOR              => q{Robert Rothenberg <rrwo@cpan.org>},
    VERSION_FROM        => 'lib/Monad/Maybe.pm',
    ABSTRACT_FROM       => 'lib/Monad/Maybe.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
	'enum'		=> 0,
        'overload'	=> 0,
        'Exporter::Lite' => 0,
	'Scalar::Util'  => 0,
        'Test::More'	=> 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'perl-monad-*' },
);
