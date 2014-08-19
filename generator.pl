#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Term::ANSIColor;

# Config
our $sourcefile = '';
our $phpdoc = 0;
our @functionsToFix;
our $version = "1.0";

main();

sub main {
	parseOptions();
	parseFile();

	warnAboutObjects();
}

sub parseOptions {
	GetOptions
	(
		"sourcefile=s" => \$sourcefile,
		"phpdoc" => \$phpdoc,
		"help" => \&printHelp
	);

	die("Sourcefile not found or not given. Use the --sourcefile option\n") if ( ! -e $sourcefile );
}

sub printHelp {
	print <<EOS;
PHP SetGet generator - A CLI tool to generate setter and getter methods
			based on existing members and their data types

Copyright (C) 2014  Josef 'veloc1ty' Stautner ( hello\@veloc1ty.de)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation version 3 of the License.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

Application version: $version

Command line options:
required:
	--sourcefile => Path to the php class file

optional:
	--phpdoc => Generate basic PHPDoc documentation
	--help => Print this screen
EOS

	exit 0;
}

sub toUppercase {
	my $l = shift;
	$l =~ s/\b(\w)/\U$1/g;
	return $l;
}

sub parseFile {
	open(SOURCEFILE, "<$sourcefile");
	while ( <SOURCEFILE> ) {
		my $line = $_;
		chomp($line);

		if ( $line =~ m/^\s+(private|protected) \$(.*) = (.*);/ig ) {
			my $modifier = $1;
			my $member = $2;
			my $value = $3;

			if ( $value =~ m/('|")/ ) {
				print(makeStringPHPDoc($member)) if ( $phpdoc );
				print(makeStringMethod($modifier, $member));
				print("\n");
				print(makeGetterPHPDoc($member, 'string')) if ( $phpdoc );
			}
			elsif ( $value =~ m/^null/ ) {
				print(makeObjectPHPDoc($member)) if ( $phpdoc );
				print(makeObjectMethod($modifier, $member));
				print("\n");
				print(makeGetterPHPDoc($member, 'object')) if ( $phpdoc );
			}
			elsif ( $value =~ m/(false|true)/ ) {
				print(makeBoolPHPDoc($member)) if ( $phpdoc );
				print(makeBoolMethod($modifier, $member));
				print("\n");
				print(makeGetterPHPDoc($member, 'bool')) if ( $phpdoc );
			}
			elsif ( $value =~ m/^\d+$/ ) {
				print(makeIntegerPHPDoc($member)) if ( $phpdoc );
				print(makeIntegerMethod($modifier, $member));
				print("\n");
				print(makeGetterPHPDoc($member, 'int')) if ( $phpdoc );
			}
			elsif ( $value =~ m/^array/ ) {
				print(makeArrayPHPDoc($member)) if  ( $phpdoc );
				print(makeArrayMethod($modifier, $member));
				print("\n");
				print(makeGetterPHPDoc($member, 'array')) if ( $phpdoc );
			}
			else {
				print(makeFloatPHPDoc($member)) if ( $phpdoc );
				print(makeFloatMethod($modifier, $member));
				print("\n");
				print(makeGetterPHPDoc($member, 'float')) if ( $phpdoc );
			}

			print(makeGetterMethod($modifier, $member));
			print("\n");
		}
	}
	close(SOURCEFILE);
}

##
## String stuff
##
sub makeStringMethod {
	my ( $modifier, $name ) = @_;

	my $format = <<EOS;
%s function set%s(%s) {
	if ( is_string(%s) ) {
		\$this->%s = utf8_encode(\$%s);
	}
	else {
		throw new InvalidArgumentException("Not a string value");
	}
}
EOS

	return fillInTheVariables($format, $modifier, $name);
}

sub makeStringPHPDoc {
	my ( $member ) = @_;

	return <<EOS;
/**
 * Sets the value for $member
 * 
 * \@param String \$$member 
 * \@throws InvalidArgumentException If the given value is no a string value
 **/
EOS
}

##
## Integer stuff
##
sub makeIntegerMethod {
	my ( $modifier, $name ) = @_;

	my $format = <<EOS;
%s function set%s(\$%s) {
	if ( is_int(\$%s) ) {
		\$this->%s = \$%s;
	}
	else {
		throw new InvalidArgumentException("Not an integer value");
	}
}
EOS

	return fillInTheVariables($format, $modifier, $name);
}

sub makeIntegerPHPDoc {
	my ( $member ) = @_;

	return <<EOS;
/**
 * Sets the value for $member
 * 
 * \@param int \$$member 
 * \@throws InvalidArgumentException If the given value is no an integer value
 **/
EOS
}

##
## Object stuff
##
sub makeObjectMethod {
	my ( $modifier, $name ) = @_;

	my $format = <<EOS;
%s function set%s(&\$%s) {
	if ( \$%s instanceof Fixme ) {
		\$this->%s = \$%s;
	}
	else {
		throw new InvalidArgumentException("Value was null, not an object or not an object of the wanted class!");
	}
}
EOS

	push(@functionsToFix, sprintf("%s function set%s(&\$%s)", $modifier, toUppercase($name), $name));

	return fillInTheVariables($format, $modifier, $name);
}

sub makeObjectPHPDoc {
	my ( $member ) = @_;

	return <<EOS
/**
 * Sets the reference to an object for $member
 * 
 * \@param Object \$$member 
 * \@throws InvalidArgumentException If the given reference if from the false object or null
 **/
EOS
}

##
## Boolean stuff
##
sub makeBoolMethod {
	my ( $modifier, $name ) = @_;

	my $format = <<EOS;
%s function set%s(\$%s) {
	if ( is_bool(\$%s) ) {
		\$this->%s = \$%s;
	}
	else {
		throw new InvalidArgumentException("Not a boolean value");
	}
}
EOS
	return fillInTheVariables($format, $modifier, $name);
}

sub makeBoolPHPDoc {
	my ( $member ) = @_;

	return <<EOS
/**
 * Sets the value for $member
 * 
 * \@param bool \$$member 
 * \@throws InvalidArgumentException If the given value is no a boolean value
 **/
EOS
}

##
## Float stuff
##
sub makeFloatMethod {
	my ( $modifier, $name ) = @_;

	my $format = <<EOS;
%s function set%s(\$%s) {
	if ( is_float(\$%s) ) {
		\$this->%s = \$%s;
	}
	else {
		throw new InvalidArgumentException("Not a float value");
	}
}
EOS

	return fillInTheVariables($format, $modifier, $name);
}

sub makeFloatPHPDoc {
	my ( $member ) = @_;

	return <<EOS
/**
 * Sets the value for $member
 * 
 * \@param float \$$member 
 * \@throws InvalidArgumentException If the given value is no a float value
 **/
EOS
}

##
## Array stuff
##
sub makeArrayMethod {
	my ( $modifier, $name ) = @_;

	my $format = <<EOS;
%s function set%s(\$%s) {
	if ( is_array(\$%s) ) {
		\$this->%s = \$%s;
	}
	else {
		throw new InvalidArgumentException("Not an array");
	}
}
EOS

	return fillInTheVariables($format, $modifier, $name);
}

sub makeArrayPHPDoc {
	my ( $member ) = @_;

	return <<EOS
/**
 * Sets the value for $member
 * 
 * \@param array \$$member 
 * \@throws InvalidArgumentException If the given value is no an array
 **/
EOS
}

##
## Getter stuff
##
sub makeGetterMethod {
	my ( $modifier, $name ) = @_;

	my $format = <<EOS;
%s function get%s() {
	return \$this->%s;
}
EOS

	return sprintf($format,
		$modifier,
		toUppercase($name),
		$name
		);
}

sub makeGetterPHPDoc {
	my ( $member, $datatype ) = @_;
	my $message = ( $datatype eq 'object' ) ? 'The reference' : 'The value';

	return <<EOS;
/**
 * Get the value for $member
 * 
 * \@return $datatype $message
 **/
EOS
}

sub fillInTheVariables {
	my ( $format, $modifier, $name ) = @_;

	return sprintf($format,
		$modifier,
		toUppercase($name),
		$name,
		$name,
		$name,
		$name
		);
}

sub warnAboutObjects {
	my $amountOfWarnings = scalar(@functionsToFix);
	my $message = '';

	if ( $amountOfWarnings == 0 ) {
		$message .= sprintf("\n\nWarning: We had a object-setter function. Please replace 'Fixme' in this function: %s\n", $functionsToFix[0]);
	}
	elsif ( $amountOfWarnings > 1 ) {
		$message .= sprintf("\n\nWarning: We had %d object setter functions. Replace 'Fixme' in the following functions with an existing class name:\n", $amountOfWarnings);
		foreach my $currentFunction ( @functionsToFix ) {
			$message .= sprintf("- %s\n", $currentFunction);
		}
	}

	print(colored($message,'red'));
}