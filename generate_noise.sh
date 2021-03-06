#!/bin/bash

# Wait time range for random wait time generator
lowerWaitTime="1"
upperWaitTime="10"

threads="3"

wordFile="nouns.list"


# start="https://en.wikipedia.org/wiki/Main_Page"
start="http://www.cnn.com/"




urlencoder() {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

function getRandomWord() {
#  sort -R $wordFile | head -n 100
  shuf -n 2 $wordFile
}



function getSeedUrl() {
  encodedWords=`urlencoder "$1"`

#  echo $1
#  echo $encodedWords

  echo "https://www.google.com/search?btnI&q="$encodedWords

}


function crawl() {

  sleepVal=$(( ( RANDOM % $upperWaitTime ) + $lowerWaitTime ))
  echo "Sleeping for $sleepVal seconds"
  sleep $sleepVal

  tocrawl="$1"

  # If blank url / no url found, reset
  # TODO: work on this more
  if [[ $toCrawl == "" ]] ; then

    tocrawl=$start;
    tocrawl=$(getSeedUrl);

  fi

  # make page request, return all links on page
  allUrlsOnPage="$(lynx -dump -listonly "$tocrawl"  2> /dev/null | awk '{print $2}' | grep "http*")"

  # Count URLs found
  numOfUrls=$(printf "$allUrlsOnPage" | wc -l)

  # Convert to array
  allUrlsOnPage=($allUrlsOnPage)

  # Randomly select array index to pick URL from page
  urlToSelect=$(( ( RANDOM % ($numOfUrls + 1) ) ))
#  urlToSelect=$(( ( RANDOM % $numOfUrls ) + 1 ))

  selectedUrl=${allUrlsOnPage[$urlToSelect]}


  # Recursive step - crawl randomly selected url
  echo "Crawling $selectedUrl"
  crawl "$selectedUrl"


}


function startCrawl() {
  seed=$(getSeedUrl "`getRandomWord` `getRandomWord`")
  echo "Starting with $seed"
  crawl "$seed"
}


function getRandomUrl() {
  seed=$(getSeedUrl "`getRandomWord` `getRandomWord`")

  echo "Crawling $seed"
#  curl "$seed" > /dev/null 2> /dev/null
  curl "$seed" -L

  getRandomUrl
}

getRandomUrl;

startCrawl


