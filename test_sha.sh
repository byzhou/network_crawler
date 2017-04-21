for link in `curl -v --silent https://en.wikipedia.org/wiki/Battleship 2> /dev/null | sed -n 's/.*\(http[s]:[^"]*\).*/\1/p'`;
do 
	curl -v --silent $link 2> /dev/null | sha256sum; 
done
