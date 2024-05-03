#!/bin/zsh

# Search symbol mentioned in compiled binary file
# Different search modes are under comments - uncomment to use

# use example
# ~/-lib-search.sh "traffic\.redirect\.get"

STR_TO_SEARCH=$1

if [ -z "${STR_TO_SEARCH}" ];
then
    echo "Error: empty search string. Exit."
    exit 0;
fi

echo 🔎 $STR_TO_SEARCH

# Search with `nm` instead of `strings` and verbose version for debug
if [[ "$*" == *"--nm"* ]] && [[ "$*" == *"--verbose"* ]];
then
    find ./Pods -type f -name "*.o" -o -type f -name '*.a' -o -type f -name "*.lib" -o -type f ! -name "*.*" -exec sh -c 'for my_file do echo 📄 $my_file; MY_FILE_TYPE_INFO=`file $my_file`; if [[ $MY_FILE_TYPE_INFO =~ "Mach-O universal binary" ]]; then echo 🔎 $1 in 📚 $my_file; if  grep -q "$1" $my_file ; then echo "    👉" $my_file; nm $my_file | grep "$1" | sed "s/^/        /"; fi; fi;  done' sh_in_find "$STR_TO_SEARCH" {} +
    exit 0;
fi


# Search with `nm` instead of `strings`
if [[ "$*" == *"--nm"* ]];
then
    find ./Pods -type f -name "*.o" -o -type f -name '*.a' -o -type f -name "*.lib" -o -type f ! -name "*.*" -exec sh -c 'for my_file do MY_FILE_TYPE_INFO=`file $my_file`; if [[ $MY_FILE_TYPE_INFO =~ "Mach-O universal binary" ]]; then if  grep -q "$1" $my_file ; then echo 👉 $my_file; nm $my_file | grep "$1" | sed "s/^/        /"; fi; fi;  done' sh_in_find "$STR_TO_SEARCH" {} +
    exit 0;
fi


# Verbose version for debug
if [[ "$*" == *"--verbose"* ]];
then
    find ./Pods -type f -name "*.o" -o -type f -name '*.a' -o -type f -name "*.lib" -o -type f ! -name "*.*" -exec sh -c 'for my_file do echo 📄 $my_file; MY_FILE_TYPE_INFO=`file $my_file`; if [[ $MY_FILE_TYPE_INFO =~ "Mach-O universal binary" ]]; then echo 🔎 $1 in 📚 $my_file; if  grep -q "$1" $my_file ; then echo "    👉" $my_file; strings $my_file | grep "$1" | sed "s/^/        /"; fi; fi;  done' sh_in_find "$STR_TO_SEARCH" {} +
    exit 0;
fi


# Default search mode
find ./Pods -type f -name "*.o" -o -type f -name '*.a' -o -type f -name "*.lib" -o -type f ! -name "*.*" -exec sh -c 'for my_file do MY_FILE_TYPE_INFO=`file $my_file`; if [[ $MY_FILE_TYPE_INFO =~ "Mach-O universal binary" ]]; then if  grep -q "$1" $my_file ; then echo 👉 $my_file; strings $my_file | grep "$1" | sed "s/^/        /"; fi; fi;  done' sh_in_find "$STR_TO_SEARCH" {} +
