# PERL Cheat Sheet
```perl
@numbers = (1,2,3,'tiger');
map {$_ * $_ || 9999} @numbers;
# result:	(1,4,9,9999)
```
Since 'tiger' can't be squared i.e. 'tiger' * 'tiger', alternate value (after `||`) is used.


# Multi line comments
```perl
=begin comment .... =cut
```

# Single quote VS Double quote
```perl
$name = 'abc';
print "hello $name\n" . NextLine
	# hello abc 
	# NextLine
print 'hello $name' . 'NextLine';
	# hello $name\nNextLine
```
Single quote `'` doesn't recognize special characters.

# `$var = >>"someString";`
`$var` will contain all the content afterwards the command, right until the next line is that very string i.e. "someString" (and nothing else). 
Also note variables used within this range will be read as variable. But if single quote is used e.g. `$var = >>'someString';` it all will be interpreted as text.
```perl
$name = 'AName';
$story = <<'ENDOFSTORY';
Long time ago blah blah blah
blah blah blah
$name\n
And then blah blah
ENDOFSTORY
```
	`$name\n` will be stored as `$name\n` with `ENDOFSTORY`.
	`AName` followed by new line will be stored if `ENDOFSTORY`.

# Print the statement prepared for SQL
```perl
print $sth->{Statement} # with a statement handle
# AND/OR
print $dbh->{Statement} # with a database handle
```
> Prints the statement prepared for SQL (doesn't fill in the ? though)

# Using packages from local pm files
package file:
`Shape.pm`:
```perl
use strict;
sub disp() {
print "\nInside the package now\n";
}
1;
```
Code file:
`code.pl`
```perl:
...
use lib '.'; # Looks for pm in current directory
use Shape; # Name of the file
disp(); 
```
>Careful with matching sub names!!! e.g. if you have sub names that are common in multiple packages.

# Delete entry in a hash
```perl
delete($hash{$key});
```

# Renaming a Hash Key
```perl
$hash{$new} = delete $hash{$old};
```
`delete` returns the old key value hence the new hash will get the same value from the deleted hash.

# Adding hash to an array
First what `\` does:
```perl
my $foo = "bar";
say $foo;    #prints "bar"
say \$foo;   #prints SCALAR(0x7fad01029070) or something like that
```
We can use something like this:
```perl
my @switch_ports = (); #Empty list/array
my %port = ( data1 => 0, data2 => 0, changed => 0 );
my $port_ref = \%port;

push( @switch_ports, $port_ref );
```
OR, we can just use `\` and not use `$port_ref` at all:
```perl
push( @switch_ports, \%port );
```

# Format string
```perl
my $number = 2.39;
# Format number with up to 8 leading zeroes
my $result = sprintf("%08d", $number);	
# Round number to 3 digits after decimal point	
my $rounded = sprintf("%.3f", $number);
```

# Find where PERL modules are installed
At terminal type:
```perl
perl -E "say for @INC"
```

# Retreive data from SQL database: SELECT
```perl
my @row;                                # row data
my $dbh = DBI->connect();              # connect
my $var = "value to search for";
my $sql = qq/select * from table where column = ?/;
# the query to execute with parameter
my $sth = $dbh->prepare($sql);         # prepare the query
$sth->execute(($var));                 # execute the query with parameter
while (@row = $sth->fetchrow_array) { # retrieve one row
	print join(", ", @row), "\n";
}
$var = "another value to search for";
$sth->execute(($var));                 # execute the query (no need to re-prepare)
while (@row = $sth->fetchrow_array) { # retrieve one row
	print join(", ", @row), "\n";
}
```

# Overloading functions in PERL:
```perl
sub test {
	return @_;
}
```
`return` results:
1. `test()`	0
2. `test(1)`	1
3. `test(1,1)`	2
4. `test(1,1,1)`	3
>NOTE
```perl
sub test {
	my $a = shift();
return @_;
}
```
`return` results:
1. `test()`	0
2. `test(1)`	0
3. `test(1,1)`	1
4. `test(1,1,1)`	2
First shift takes 1 argument.

# Remove an element in an Array by value
```perl
# Creating a list of dimensions without 'dim_date'
my @dim_list_no_date =  map( $_->{name} , @{$columns->{dimensions}}); #['dim_month', 'dim_date' , 'dim_id', 'dim_laeq']
my $index = 0;
$index++ until $dim_list_no_date[$index] eq "dim_date";
splice (@dim_list_no_date, $index, 1);
```
Removes `dim_date` from the array/list?

# Swap variables
```perl
($first, $second) = ($second, $first);
```

# Find if a string contains text (using patterns)
```perl
if ($string =~ m/pattern/) {
	print "'$string' matches the pattern\n";       
}
```

# Remove first 4 characters in a string
```perl
my $str = "123456";
print substr($str, 4);
```