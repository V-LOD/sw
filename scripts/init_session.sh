#!/usr/bin/env bash
cd ~/sw/scripts/
sh ./stardog.sh &
sh ./reset-db.sh & 
sh ./app.sh &
cd ../ld-r
npm run dev &
