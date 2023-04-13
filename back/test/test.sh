#!/bin/sh

echo "Set coordinates"
curl -X 'POST' \
  'http://127.0.0.1:8000/planning' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "lon": 3.13,
  "lat": 50.67,
  "height": 0
}'

echo "set time"
curl -X 'POST' \
  'http://127.0.0.1:8000/planning/time' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "time": "2022-01-01 08:09"
}'

echo "get visible"
curl -X 'GET' \
  'http://127.0.0.1:8000/planning/visible' \
  -H 'accept: application/json'

echo "goto"
curl -X 'PUT' \
  'http://127.0.0.1:8000/telescope/goto/?ra=6.75&dec=16.7' \
  -H 'accept: application/json'

curl -X 'GET' \
  'http://127.0.0.1:8000/planning/objects/M51%2CM52' \
  -H 'accept: application/json'
