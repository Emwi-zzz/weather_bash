#!/bin/bash

City=""
lat=""
lon=""


replace_polish_characters() {
    local input="$1"

    echo "$input" | sed -e 's/ą/a/g' \
                        -e 's/ć/c/g' \
                        -e 's/ę/e/g' \
                        -e 's/ł/l/g' \
                        -e 's/ń/n/g' \
                        -e 's/ó/o/g' \
                        -e 's/ś/s/g' \
                        -e 's/ż/z/g' \
                        -e 's/ź/z/g' \
                        -e 's/Ą/A/g' \
                        -e 's/Ć/C/g' \
                        -e 's/Ę/E/g' \
                        -e 's/Ł/L/g' \
                        -e 's/Ń/N/g' \
                        -e 's/Ó/O/g' \
                        -e 's/Ś/S/g' \
                        -e 's/Ż/Z/g' \
                        -e 's/Ź/Z/g'
}

get_name(){

  json_data=$(curl -s "https://nominatim.openstreetmap.org/search.php?q=$1&format=jsonv2")
  
  City=$(echo $json_data | jq -r '.[0].name')

  lat=$(echo $json_data | jq -r '.[0].lat')

  lon=$(echo $json_data | jq -r '.[0].lon')

}

load_data(){
  data=$(curl -s "https://danepubliczne.imgw.pl/api/data/synop/")
  
  i=1
  echo "\e[33m0/62\e[0m"

  echo $data | jq -r '.[].stacja' | while read -r station; do
    latin_station=$(replace_polish_characters $station)
    get_name $latin_station
    
    echo -e "\033[F\033[K" 

    if [ "$debug" -eq 1 ]; then
      echo "Station: $latin_station"
    fi

    echo -e "\e[33m$i/62\e[0m"
    
    echo "$City $lat $lon" >> rc
    

    sleep 1
    i=$((i+1))
  done

}

city=""
debug=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --city)
      city="$2"
      shift 2
      ;;
    --debug)
      debug=1
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

if [ -f "rc" ]; then 
  if [ "$debug" -eq 1 ]; then
    echo -e "\e[33mfile was found\e[0m"
  fi
else
  load_data  
fi

if [ -z "$city" ]; then
  echo -e "\033[31mExpected non-empty --city argument\033[0m"
  exit 1
fi

get_name $city

if [ "$debug" -eq 1 ]; then
  echo "City: $City"
  echo "lat: $lat"
  echo "lon: $lon"

fi

echo $city
