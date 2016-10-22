#!/bin/bash

function ask() {
    # http://djm.me/ask
    local prompt default REPLY

    while true; do

        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -n "$1 [$prompt] "

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read REPLY </dev/tty

        # Default?
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

source ~/.profile
ABS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $ABS_DIR

# If stardog env var is not set...
if [ -z "$STARDOG" ]; then
  if ask "Search for the stardog directory? This may take a while. (default: n)" N; then
    echo 'Looking for stardog...'
    find $HOME -iname "*stardog-*" -type d 2> /dev/null
  fi

  answer=0
  while [ $answer == 0 ]
  do
    if (( $answer == 0 )); then
      read -p 'Please input the correct (full) path: ' STARDOG_PATH
    fi

    echo
    echo $STARDOG_PATH
    if ask "Is this the correct path? (default: y)" Y; then
        answer=1
    fi
  done

  # Add export to profile for persistence
  echo 'export STARDOG='$STARDOG_PATH >> ~/.profile
  source ~/.profile
fi

echo 'Stardog directory: '$STARDOG
cd $STARDOG/bin
echo
sudo ./stardog-admin server stop
sudo ./stardog-admin server start --disable-security
echo

# Create table
if ask 'Reset votes table?'; then
  ./stardog-admin db drop votes
  ./stardog-admin db create -n votes $ABS_DIR/../ontology.ttl
fi
echo

cd $ABS_DIR

# Old framework
guake -n guake -e 'cd '$ABS_DIR'/../db_puter && python src/main.py' guake -r 'DB Interface'
echo 'Old framework started in new terminal window'
echo

# start ld-r
if ask 'start LD-R in dev mode? (default: n)' N; then
  guake -n guake -e 'cd '$ABS_DIR'/../ld-r && npm run dev' guake -r 'LD-R Dev'
else
  guake -n guake -e 'cd '$ABS_DIR'/../ld-r && npm run build' guake -r 'LD-R Build'
fi

echo 'LD-R started in new terminal window'
echo

if ask 'Download/Sync new vote data? (default: y)' Y; then
  guake -n guake -e 'echo && echo Hit ctrl-c at any point to stop the downloading! && sleep 2 && sh '$ABS_DIR'/../data-getters/govtrack/import-bulk-govtrack.sh '$ABS_DIR'/../data/govtrack/' guake -r "GovTrack synch" 
fi

echo 'Please stop any data downloads before proceeding'

if ask 'Import new vote data? (default: y)' Y; then
  guake -n guake -e 'python '$ABS_DIR'/../data-getters/govtrack' guake -r "Semantifier"
fi

echo
echo 'Done!'
