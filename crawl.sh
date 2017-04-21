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
	for link in `curl -v --silent $1 2> /dev/null | sed -n 's/.*\(http[s]:[^"=?]*\).*/\1/p'`;
	do 
		hash_value=`echo $link | sha256sum | sed -n "s/\([^\ ]*\).*/\1/p" | sort -u`;
		echo ${hash_value} >> ${target_hash_file}; 
		echo ${hash_value} ${link} >> ${index_file};
	done
	
}

link_map () {
	for link in `curl -v --silent $1 2> /dev/null | sed -n 's/.*\(http[s]:[^"=?]*\).*/\1/p'`;
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
	fi

}

report () {

	cat ${index_file} | sort -u -n > tmp;
	mv tmp ${index_file};

	echo "Here is a report of page ranking ... ";
	sort data/*.log | uniq -c | sort -n -r | head -n 20 | awk '{printf $1 " "} system("grep "$2" data/index.txt")' | sed -n "/http[s].*/p" | awk '{print $1 " " $3}';
}

recursive_crawl 6 https://en.wikipedia.org/wiki/HMS_Hood

#report 
