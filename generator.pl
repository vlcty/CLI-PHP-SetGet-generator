#!/usr/bin/perl

use strict;
use warnings;

unless ( $ARGV[0] && -e $ARGV[0] ) {
	die("Usage: $0 <path to file>\n");
}

my $DEBUG = 0;

open(FILE, "<$ARGV[0]");
while ( <FILE> ) {
	my $line = $_;
	chomp($line);

	while ( $line =~ m/^\s+private \$(.*) = (.*);$/ig ) {

		print("Group 1: $1\n") if ($DEBUG);
		print("Group 2: $2\n") if ($DEBUG);

		my $member = $1;
		my $value = $2;

		# set-Method
		print("\n/**\n\tSet method for member variable $member\n*/\n");

		if ( $2 =~ m/^'/ || $2 =~ m/^\"/ ) {
			printf("public function set%s(\$%s) {\n\t\$this->%s = utf8_encode(\$%s);\n}\n", toUppercase($member), $member, $member, $member);
		}
		elsif ( $2 =~ m/null/ || $2 =~ m/NULL/ ) {
			printf("public function set%s(&\$%s) {\n\t\$this->%s = \$%s;\n}\n", toUppercase($member), $member, $member, $member);
		}
		else {
			printf("public function set%s(\$%s) {\n\t\$this->%s = \$%s;\n}\n", toUppercase($member), $member, $member, $member);
		}

		# get-Method
		print("\n/**\n\tGet method for member variable $member\n*/\n");
		printf("public function get%s() {\n\treturn \$this->%s;\n}\n", toUppercase($member), $member);

		print("----------------------\n") if ($DEBUG);
	}
}
close(FILE);

sub toUppercase {
	my $l = shift;
	$l =~ s/\b(\w)/\U$1/g;
	return $l;
	#return join '', map { ucfirst lc } split /(\s+)/, $_[0];
}