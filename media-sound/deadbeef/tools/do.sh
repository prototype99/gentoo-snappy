#!/bin/bash

(( $# )) || { echo "Usage: $0 DB_PLUGIN_*"; exit 1; }

type=$1
plugins_list=(
	$( ag --files-with-matches ${type^^} plugins | grep -Po '(?<=plugins/)[^/]+' | sort )
)

for p in "${plugins_list[@]}" ; do
	awk -v p=$p '
		BEGIN{
			printf "%s - ",p
		}
		
		function format_line() {
			ok = match($0, /^[^=]+= *"([^"]+)/, m)
			if ( !ok ) print error,"\"",$0,"\""
			return m[1]
		}

		/[ \t]\.plugin\.name *=/ {
			printf "%s - ",format_line()
		}

		/[ \t]\.plugin\.descr *=/ {
                        printf("%s\n", format_line())
                }
	' plugins/$p/*.c
done | sed -e 's|\\n|. |g' -e 's| \. | |g' -e 's|\([a-zA-Z0-9]\)\.\.*|\1.|g' | tr -s  " "

