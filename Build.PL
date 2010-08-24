use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Class::Constant',
    license             => 'perl',
    dist_author         => 'Robert Norris <rob@eatenbyagrue.org>',
    dist_version_from   => 'lib/Class/Constant.pm',
    build_requires => {
        'Test::More' => 0.95,
    },
    requires => {
        'Scalar::Util' => 0,
    },
    add_to_cleanup      => [ 'Class-Constant-*' ],
    create_makefile_pl => 'passthrough',
);

$builder->create_build_script();
