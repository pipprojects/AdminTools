#!/usr/bin/perl
#
use Getopt::Std;
use MIME::Base64;
#
# Globals
#
use vars qw/ %opt /;

#
# Command line options processing
#
sub init()
{
$FNAME="$0";

$OPT1="[-e string]";
$OPT2="[-d string]";
$OPT3="[-h]";
$OPT4="[-V Version]";
$USAGE="Usage: $FNAME $OPT1 $OPT2 $OPT3 $OPT4 ";
$opt_e="";
$opt_d="";
$opt_h="";
$opt_V="";
if ( ! Getopt::Std::getopts('d:e:hV') ) {
 printf "%s\n",$USAGE;
 exit 1;
}
}

#
# Message about this program and how to use it
#
sub usage()
{
 print STDERR << "EOF";

This program does...

usage: $0 [-v] [-d string]|[-e string]

 -h		: this (help) message
 -d string	: string to decode
 -e string	: string to encode

example: $0 -e mypassword

EOF
 exit;
}

init();

if ( $opt_h ) {
 usage() if $opt{h};
 exit 0;
}
if ( $opt_d ) {
 $STRING=$opt_d;
 $decoded = decode_base64($STRING);
 printf "%s\n",$decoded;
};
if ( $opt_e ) {
 $STRING=$opt_e;
 $encoded = encode_base64($STRING);
 printf "%s",$encoded;
};

#
