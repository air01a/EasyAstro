	curl -X POST -H "Content-type: application/json" "http://127.0.0.1:8001/telescope/time?" --data "{\"time\":\"2023-07-19 23:34\"}"  
  
  curl -X POST -H "Content-type: application/json" "http://127.0.0.1:8001/telescope/location?"  --data "{\"lon\":3.1836662,\"lat\":37.6742605,\"height\":0}" 

  
  
  curl -X POST -H "Content-type: application/json"  -X POST -H "Content-type: application/json"  "http://127.0.0.1:8001/telescope/goto?" --data "{\"ra\":118.80104042497287,\"dec\":20.80222582439502,\"object\":\"Sun\"}" 

  
  
  curl -X POST -H "Content-type: application/json"  "http://127.0.0.1:8001/telescope/exposition?" --data "{\"exposition\":-1,\"gain\":100}"
  
  
  
  curl "http://127.0.0.1:8001/telescope/status?"
  pause
  curl "http://127.0.0.1:8001/telescope/status?"
  pause
  curl -X POST -H "Content-type: application/json"  "http://127.0.0.1:8001/telescope/stacking?" --data "{\"ra\":118.80104042497287,\"dec\":20.80222582439502,\"object\":\"Sun\"}" 
