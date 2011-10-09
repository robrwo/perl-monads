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
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'perl-monad-*' },
);
