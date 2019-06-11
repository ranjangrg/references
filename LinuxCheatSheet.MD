# LINUX CHEAT SHEET 

###  Print file contents (esp long ones)
`cat myFile | less`
Pagewise result; 'q' to quit

### Change file permissions/attrib
`chmod u=rwx,g=rx,o=x myFile`

### Show filtered content (except)
`cat myFile | grep -v 'someString'`
Show content while skipping lines containing the given string

### Create nested directories
`mkdir -p a/b/c`
Create nested directories incl. ones that don't exist

### Find empty directories
`find <path> -type d -empty`
Find all the empty directories 

### Create symlink
`ln -sf /path/to/file ./someName`
Creates symlink called 'someName' pointing to the file described in the path

### Remove symlink
`rm /path/to/link`
Removes symlink. Note: symlink is a file even though it may point to a directory. So, no path/

### Mount using sftp
`sftp://lxdK2/home/root`
Network Drive (using sftp). Safer than hard mounting a network drive. Less corruption especially from opening files at multiple editors etc.

### Custom alias commands
`alias customCommandName='originalCommand'`
Custom command shortcuts

### Convert Date to Unix timestamp
`date -j -f "%Y-%m-%d" "2010-10-02" "+%s"`
Convert local time to Unix timestamp

### Using `screen` command
To run some command on linux that runs even when the terminal is closed.
Useful for things like batch processing or bad connections where ssh fails.
Some useful command options in screen:
* `screen -ls` to list all the screens currently running/available
* `screen -r [session ID]` to reattach the screen 
While inside a screen session:
* `Ctrl + A` -> then ? for help
* `Ctrl + A` -> then d to detach from screen (will not kill the session/screen)
* `Ctrl + A` -> then k to kill the session/screen
* `Ctrl + A` -> then c to create a new screen
* `Ctrl + A` -> then [0 to 9] to access screen windows (when we have multiple windows in screen)

### Show unique lines of texts in file (no duplicates)
`sort -u myfile.csv -o myfile.csv`
The options mean:
	-u - keep only unique lines
	-o - output to this file instead of stdout
You should view man sort for more information.
The -u option for uniq will only print unique lines. In this file, all lines are duplicates so they will not be printed out.

### Show difference between two files
`diff <file1> <file2>`
Shows the difference in between the two files. Useful for comparing csv results.

### Solve mounting error: exFAT Filesystem
`sudo apt-get install exfat-fuse exfat-utils`
If you have error mounting drives with exFAT filesystem.

### Install fonts via terminal
Copy font files to ```/usr/local/share/fonts``` -> Decide truetype or opentype first
For the fonts' directory:
	```sudo chmod 755 <nameOfDir>```
For the fonts' files
	```sudo chmod 644 <nameOfDir>```
Then rebuild the font cache by:
	```fc-cache -f -v```

### Find files by name
`find <path> -name "*.err"`

### Find files with text containing some special text.
`grep -iRl "your-text-to-find" ./`

### Find text(s) containing a pattern but exclude ones that match another pattern
Example: Search for "man-made-car" but exclude "man-made-cargo"
`grep -iR "man-made-car" . | grep -iv "man-made-cargo"`
// searches for pattern "man-made-car" in current directory; lists all the lines
// then the result is piped to another grep which excludes lines that match with "man-made-cargo"

### Type Special Characters like copyright, degree etc.
Linux (Ubuntu test): (CTRL + SHIFT + U) then the four digit unicode 

### Install LAMP stack 
```bash
sudo apt install apache2
sudo systemctl stop apache2.service
sudo systemctl start apache2.service
sudo systemctl enable apache2.service
sudo apt-get install mariadb-server mariadb-client
sudo systemctl stop mariadb.service
sudo systemctl start mariadb.service
sudo systemctl enable mariadb.service
sudo mysql_secure_installation
sudo mysql -u root -p **FOR TESTING SQL Password etc
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php7.2 libapache2-mod-php7.2 php7.2-common php7.2-mbstring php7.2-xmlrpc php7.2-soap php7.2-gd php7.2-xml php7.2-intl php7.2-mysql php7.2-cli php7.2-zip php7.2-curl
sudo nano /etc/php/7.2/apache2/php.ini
```
SETTINGS for php.ini
```php
file_uploads = On
allow_url_fopen = On
memory_limit = 256M
upload_max_file_size = 100M
max_execution_time = 360
date.timezone = America/Chicago
```
```bash
sudo systemctl restart apache2.service
sudo nano /var/www/html/phpinfo.php ** Creating a info file
```
CONTENT inside the phpinfo.php file:
```php
<?php phpinfo(); ?>
```

### PHPmyadmin giving permission errors
Possible due to version mismatch. To fix this, we can download the latest phpmyadmin files and manually put the files in /usr/share/phpmyadmin/

### Kill a 'SCREEN' session in screen
```bash
$ screen -ls
$ screen -X -S [session # you want to kill] quit
```
Ctrl + A -> 'K' to kill 'D' to detach while inside the screen

### Change ownership recursively
```sudo chown username:groupname files```

### Read and write data across network connection
On dst:	```nc -l <port-number>```
On src:	```nc <dst> <port-number>```
Port-numbers have to match

### Check if a port is open
```netstat -an | grep PORTNUMBER | grep -i listen```
If empty output, the port is not listening to anything atm.

### Function in a BASH shell
```bash
#("function" keyword is optional)
function test foo1 () { 
	echo Good Morning $1
	return 4
}
foo1 MyName
	(echoes on terminal "Good Morning MyName")
echo $?
	(echoes "4" i.e. the return value of the previously run command/function)
```

### Batch rename files
Rename all files numerically:
```i=0; for f in *; do mv "$f" "$i.JPG"; let "i++" ; done```
Rename all .jpg files to .img
```for f in *.jpg; do mv $f ${f%jpg}img; done```

### Truncate characters from a string variable
```bash
$name=file2uselessparts.fn;
echo ${name%useless*}; 
output: file2
# note: searches from the end of string
```

### Substitue characters in a string variable
```bash
$name=file2uselessparts.fn;
echo ${name/useless/useful}; 
output: file2usefulpart.fn
# note: searches from the start of string, and only replaces ONCE
```

### Play WAV files via terminal
```aplay <filename/executable sound generator>```

### Create symlink to directory
```ln -s /path/directoryA/ linkName```

### Copy directory (preserving attributes and recursive)
(source: https://www.cyberciti.biz/faq/copy-folder-linux-command-line/)
cp -avr /home/Downloads/cpp /home/Desktop/cpp-copy
where,
-a : Preserve the specified attributes such as directory an file mode, ownership, timestamps, if possible additional attributes: context, links, xattr, all.
-v : Explain what is being done.
-r : Copy directories recursively.

### Show SVN difference between working copy and repository
svn diff -r head
svn diff -r head --diff-cmd meld
source: kdopen @ https://stackoverflow.com/questions/4926896/svn-how-to-compare-working-copy-with-repository-revision

### Change IP Address of a container(or machine)
ifconfig // show list of network interfaces
ifconfig eth0 down;	ifconfig eth0 up; // restart if needed; not required
ifconfig eth0 172.0.2.123 // Assigning static IP to eth0: 172.0.2.123

### Remove first 8 characters from each line in a file
sed 's/^........//' <fileName>
sed 's/^........//' <fileName> > otherFile // pipe the output to a new file

Alternatively, 
cut -c9-

### Remove last 4 characters from each line in a file
sed 's/....$//' <fileName>

### Overwrite local changes to HEAD of repository
svn revert -R <path>; // -R means recursive
Note: Overwrites! so caution

### Change Directory to previous location (history wise)
cd - 
OR 
cd $OLDPWD

### Covert string to Hex-number via command line
echo -n "Hello" | od -A n -t x1
(source: https://stackoverflow.com/questions/6791798/convert-string-to-hexadecimal-on-command-line/6791875)

### Covert hex string in to ASCII via command line
Method 1:
for c in `cat test_file.txt`; do printf "\x$c"; done;
(source: https://stackoverflow.com/questions/13160309/conversion-hex-string-into-ascii-in-bash-command-line)
Method 2:
cat file.txt | od -An -vtx2
(source: https://unix.stackexchange.com/questions/268514/how-do-i-print-the-numerical-ascii-values-of-each-character-in-a-file/268515)

### HexDump of a file (very useful, shows ASCII + hex values)
```od -A x -t x1z -v <fileName>```

### Batch Downsample FLAC files using ffmpeg
```bash
#!/bin/sh
# requires: ffmpeg
for f in *.flac;
do
echo "Processing $f"
ffmpeg -i "$f" -sample_fmt s16 -ar 48000 "${f%.flac}-16.flac"	# downsampling to 48Khz and 16bit, renamed with -16 added as suffix
done
```
(source: https://stackoverflow.com/a/50867944)

### Bash scripting: create directories using Filenames (without the extensions)
```bash
#!/bin/sh
for f in *.flac;
do
	mkdir ${f%%.flac}
done

#Example 2:
root@linux:$ f="MaryJane.mp.sj"
root@linux:$ echo $f
MaryJane.mp.sj
root@linux:$ echo ${f}
MaryJane.mp.sj
root@linux:$ echo ${f%%}
MaryJane.mp.sj
root@linux:$ echo ${f%%.sj}
MaryJane.mp
root@linux:$ echo ${f%%.mp}
MaryJane.mp.sj
root@linux:$ echo ${f%%.mp.sj}
MaryJane
```

### exFAT drives mounting error solution
sudo apt-get install exfat-fuse exfat-utils

### Bash scripting: Force Y/n on commands
```bash
yes | cp -i src.c dest.c
(if 'dest.c' exists, overwrite? promt appears, holding the script)
(Using 'yes', it sends 'y' to the command)
('yes' can send other than 'y'; e.g. 'yes okay', sends 'okay' to the terminal)

Split audio into chunks at certain intervals (using ffmpeg)
# Splits all the flac files in the current directory and puts the new files in directory called "./splittedAudio"
DIR_NAME="splittedAudio"
for f in *.flac;
do
# If each file needs its own directory with its split files
#	if [ -d ${f%%.flac} ]; then
#		echo "Exists"
#	else
#		mkdir ${f%%.flac}
#	fi
	ffmpeg -i $f -map 0 -c copy -f segment -segment_time 1 -segment_start_number 1 $DIR_NAME/${f%%.flac}_%03dsecs.flac
done

NOTE: To fix duration issue of the new clips (start != 0), rerun ffmpeg on the files (no options)
for f in splittedAudio/*;
do
	echo $f
	yes | ffmpeg -i $f $f	# accept overwrite by default
done
```

### Empty contents of a 'regular' file in Terminal
```> fileName.fil```

### Arithmetic operations in shell script:
```bash
num=10;
echo $((num*9)); # output: 90
```

### BASH script to cut first few seconds off of audio	
```bash
#!/bin/sh
# requires: ffmpeg

DIR_NAME="splittedAudio"
SEG_TIME=1

if [ -d $DIR_NAME ]; then
	echo "DIR_NAME directory already exists"
else
	mkdir $DIR_NAME
fi

for f in *.mp3;
do
# If each file needs its own directory with its split files
#	if [ -d ${f%%.flac} ]; then
#		echo "Exists"
#	else
#		mkdir ${f%%.flac}
#	fi
	#ffmpeg -i $f -map 0 -c copy -f segment -segment_time 1 -segment_start_number 1 $DIR_NAME/${f%%.flac}_%03dsecs.flac
	#ffmpeg -i $f -map 0 -c copy -f segment -segment_time 1 $DIR_NAME/${f%%.flac}_%03dsecs.flac
	ffmpeg -i $f -ss 5 -map 0 $DIR_NAME/${f%%.mp3}.mp3	
	echo "$f"
done

# to fix start time and duration issues
for f in splittedAudio/*;
do
	echo $f
	yes | ffmpeg -i $f $f	# accept overwrite by default
done
```

### Plot '.csv' using gnuplot
(e.g. log.csv contains 
...
1,34
5,54
7,78
...
)
set datafile separator ","; plot 'log.csv' with line;
x-axis is first column and y-axis is the second column

### Export 'gnuplot' output as File
source: "https://stackoverflow.com/questions/29625776/how-to-save-a-graph-through-command-line-with-gnuplot"
```gnuplot -e "set terminal png size 400,300; set output 'xyz.png'; plot 'data.csv' using lines;"```
	OR do it through the gnuplot CLI:
```set terminal png size 400,300; set output 'xyz.png'; plot 'data.csv' using lines;```

### Plot a binary file:
source: "https://stackoverflow.com/questions/38436120/plot-single-column-binary-file-with-gnuplot" 
within gnuplot CLI:
```plot 'binary.file' binary format='%double' using 0:1 with lines;```

### See contents of a static library in C (shared library .a/.o)
(at terminal)
```ar -t <libFile>```
(lists object files)

### Install *.deb packages using dpkg
dpkg -i {.deb package file}

### Info about dpkg package
dpkg --info {.deb package file}

### Uninstall *.deb packages using dpkg
dpkg --remove {name of package NOT .deb file}

### Find if a variable is empty or not
```bash
if [ -z "$var" ]; then 
	# it is empty
else
	# it is not empty
fi
(also: if test -z "$var"; then)
```

### Copy mysql tables from one MySQL server to another
```bash
$ mysqldump -u root -p database_name table_name > dump.txt
Copy the dump file in the destination server, then run this command in destination.
$ mysql -u root -p database_name < dump.txt
```
Single step command:
```bash
$ mysqldump -u root -p database_name \| mysql -h other-host.com database_name
```
