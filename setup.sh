#!/usr/bin/env sh

# This script sets up the environment required for the tool to run.
usage()
{
	echo "Usage   : $0 [ -b <path_to_netbsd_src> ] [-s ] [-c ]"
	echo "Options :  "
	echo "     -b : Run bear, generate compile_command.json"
	echo "     -s : Setup"
	echo "     -c : Clean"
	exit 2
}

if [ $# -eq 0 ]
then
	usage
	exit
fi

SYS2SYZ_PATH=$(pwd)

while getopts "b:sc" opt && opt=-${opt} ;
do
	case "${opt}" in
			-b)
					echo "Generating compile_commands.json"
					cd ${OPTARG}
					bear make -j8 buildworld buildkernel
					mv compile_commands.json $SYS2SYZ_PATH/.
					cd $SYS2SYZ_PATH
					echo $SYS2SYZ_PATH
					
					;;
			-s)
					echo "SETTING UP"
					apt-get install -y bear
					;;
			-c)
					echo "CLEANING..."
					rm compile_commands.json
					rm -r preprocessed
					;;
			esac
done
