use ExtUtils::MakeMaker;
WriteMakefile(
	NAME          => 'Lingua::FR::Numbers',
	VERSION_FROM  => 'lib/Lingua/FR/Numbers.pm',
	PREREQ_PM     => { 
		# 'Module::Foo' => $version,	
	},
	ABSTRACT_FROM => 'lib/Lingua/FR/Numbers.pm',
	AUTHOR        => 'Briac Pilpré <briac@cpan.org>',
);
