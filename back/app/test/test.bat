curl -X "POST"  "http://127.0.0.1:8001/telescope/processing"  -H "accept: application/json"  -H "Content-Type: application/json"  -d "{""contrast"": 1,""stretch"": 0.18,""r"": 1,""g"": 1,""b"": 1,""whites"": 65535,""blacks"": 1000,""midtones"": 1,""stretchAlgo"": 0}"



curl -X "POST" "http://127.0.0.1:8001/telescope/goto" -H "accept: application/json" -H "Content-Type: application/json" -d "{""ra"": 6.75,""dec"": 16.7,""object"": ""M51""}"


curl -X "GET" "http://127.0.0.1:8001/telescope/last_picture?process=true&size=1" -H "accept: application/json" --output result.jpg

