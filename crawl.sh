#!/bin/bash

data_base=data/
index_file=${data_base}index.txt

if [ ! -d ${data_base} ]; then
	mkdir ${data_base};
fi

if [ ! -f ${index_file} ]; then
	touch ${index_file};
fi

crawl () {

	target_site=$1
	target_hash=`echo $target_site | sha256sum | sed -n "s/\([^\ ]*\).*/\1/p"`;
	target_hash_file=${data_base}${target_hash}.log;
	echo ${target_hash} ${target_site} >> ${index_file};

	echo "mapping link hashes to ${target_site} ...";

	if [ -f ${target_hash_file} ]; then
		rm ${target_hash_file}; 
		touch ${target_hash_file};
	else
		touch ${target_hash_file};
	fi
	for link in `curl -v --silent $1 2> /dev/null | sed -n 's/.*\(http[s]:[^"]*\).*/\1/p'`;
	do 
		hash_value=`echo $link | sha256sum | sed -n "s/\([^\ ]*\).*/\1/p" | sort -u`;
		echo ${hash_value} >> ${target_hash_file}; 
		echo ${hash_value} ${link} >> ${index_file};
	done
	
}

link_map () {
	for link in `curl -v --silent $1 2> /dev/null | sed -n 's/.*\(http[s]:[^"]*\).*/\1/p'`;
	do
		echo $link;
	done;
}

recursive_crawl () {
	if [ $1 -gt 1 ]; then
		crawl $2;
		for link in `link_map $2`;
		do
			depth=`expr $1 - 1`
			recursive_crawl $depth $link
		done
	else
		crawl $2;
		cat ${index_file} | sort -u > tmp;
		mv tmp ${index_file};
	fi

}

report () {
	for hashes in `cat ${data_base}*.log | uniq -c | sort -n | tail -n 3 | awk '{print $2}'`;
	do
		cat ${index_file} | grep ${hashes} | sed -n 's/.*\(http[s]:[^"]*\).*/\1/p';
	done
}

#recursive_crawl 2 https://en.wikipedia.org/wiki/Battleship

report 
