#!/usr/bin/env perl

use strict;
use warnings;

use Module::Build;

my $builder = Module::Build->new(
	module_name => 'Mongol',

	dist_author => 'Tudor Marghidanu',
	dist_abstract => 'Perl Mongo wrapper for Moose objects',

	# NOTE: Keep list sorted!
	requires => {
		'Class::Load' => undef,
		'MongoDB' => undef,
		'Moose' => undef,
		'MooseX::ClassAttribute' => undef,
		'MooseX::Storage::Base::SerializedClass' => undef,
		'MooseX::Storage' => undef,
		'Test::More' => undef,
		'Test::Pod::Coverage' => undef,
		'Test::Pod' => undef,
	},

	optional => { },
);

$builder->create_build_script();
