#!/usr/bin/perl

use strict;
use warnings;

unless ( $ARGV[0] && -e $ARGV[0] ) {
	die("Usage: $0 <path to file>\n");
}

my @functionsToFix = ();

open(FILE, "<$ARGV[0]");
while ( <FILE> ) {
	my $line = $_;
	chomp($line);

	while ( $line =~ m/^\s+private \$(.*) = (.*);/ig ) {
		my $member = $1;
		my $value = $2;

		# set-Method
		print("\n".
			"/**\n".
			" * Set method for member variable $member\n".
			" * \n".
			" * \@param ");

		my $temp = "";

		if ( $2 =~ m/^('|\")/ ) {
			# String representant
			printf("String \$%s \n", $member);
			printf(" * \@throws InvalidArgumentException If the given value is not a string\n");
			printf(" **/\n");

			$temp = "public function set%s(\$%s)\n".
					"{\n".
					"\tif ( is_string(\$%s) ) {\n".
					"\t\t\$this->%s = trim(utf8_encode(\$%s));\n".
					"\t}\n".
					"\telse {\n".
					"\t\tthrow new InvalidArgumentException(\"Not a string value!\");\n".
					"\t}\n".
					"}\n";

			printf($temp,
				toUppercase($member),
				$member,
				$member,
				$member,
				$member
				);
		}
		elsif ( $2 =~ m/^null$/i ) {
			# Object representant
			printf("Object \$%s \n", $member);
			printf(" * \@throws InvalidArgumentException If the given value is not an object reference\n");
			printf(" **/\n");

			$temp = "public function set%s(&\$%s)\n".
					"{\n".
					"\tif ( is_null(\$%s) == false && is_object(\$%s) && is_subclass_of(\$%s, \"<Fixme>\") ) {\n".
					"\t\t\$this->%s = \$%s;\n".
					"\t}\n".
					"\telse {\n".
					"\t\tthrow new InvalidArgumentException(\"Value was null, not an object or not an object of the wanted class!\");\n".
					"\t}\n".
					"}\n";

			printf($temp,
				toUppercase($member),
				$member,
				$member,
				$member,
				$member,
				$member,
				$member
				);

			push(@functionsToFix, sprintf("public function set%s(&\$%s)", toUppercase($member), $member));
		}
		elsif ( $2 =~ m/^(false|true)$/i ) {
			# Boolean representations
			printf("boolean \$%s \n", $member);
			printf(" * \@throws InvalidArgumentException If the given value is not a boolean\n");
			printf(" **/\n");

			$temp = "public function set%s(\$%s)\n".
					"{\n".
					"\tif ( is_bool(\$%s) ) {\n".
					"\t\t\$this->%s = \$%s;\n".
					"\t}\n".
					"\telse {\n".
					"\t\tthrow new InvalidArgumentException(\"Not a boolean value!\");\n".
					"\t}\n".
					"}\n";

			printf($temp,
				toUppercase($member),
				$member,
				$member,
				$member,
				$member
				);
		}
		elsif ( $2 =~ m/^\d+$/ ) {
			# Integer representation
			printf("int \$%s \n", $member);
			printf(" * \@throws InvalidArgumentException If the given value is not a integer\n");
			printf(" **/\n");

			$temp = "public function set%s(\$%s)\n".
					"{\n".
					"\tif ( is_int(\$%s) ) {\n".
					"\t\t\$this->%s = \$%s;\n".
					"\t}\n".
					"\telse {\n".
					"\t\tthrow new InvalidArgumentException(\"Not a boolean value!\");\n".
					"\t}\n".
					"}\n";

			printf($temp,
				toUppercase($member),
				$member,
				$member,
				$member,
				$member
				);
		}
		else {
			printf("unknown \$%s \n **/\n", $member);
			printf("public function set%s(\$%s) {\n\t\$this->%s = \$%s;\n}\n", toUppercase($member), $member, $member, $member);
		}

		# get-Method
		printf("\n/**\n * Get method for member variable $member\n *\n * \@return Value of %s\n **/\n", $member);
		printf("public function get%s() {\n\treturn \$this->%s;\n}\n", toUppercase($member), $member);
	}
}
close(FILE);

if ( $hasAnObject == 1 ) {
	print("\n\n#######################\n");
	print("# Warning:\n");
	print("#\tWe had one or more object so replace <Fixme> with a class name in the follogwing set methods:\n");
	foreach my $currentFunction ( @functionsToFix ) {
		printf("#\t\t- %s\n", $currentFunction);
	}
	print("#######################\n");
}

sub toUppercase {
	my $l = shift;
	$l =~ s/\b(\w)/\U$1/g;
	return $l;
	#return join '', map { ucfirst lc } split /(\s+)/, $_[0];
}