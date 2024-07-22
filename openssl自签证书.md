openssl genrsa -out "ca.key" 4096

openssl req -new -key ca.key -out ca.csr -sha256

openssl x509 -req -days 3650 -in ca.csr -signkey ca.key -sha256 -out ca.crt



openssl genrsa -out test.key 4096

openssl req -new -key test.key -out test.csr -sha256

openssl x509 -req -days 365 -in test.csr -sha256 -CA ../ca/ca.crt -CAkey ../ca/ca.key -CAcreateserial -out test.crt



#自签证书

openssl genrsa -out "http.key" 4096

openssl req -new -x509 -days 3650 -key http.key -out http.crt -subj "/C=US/ST=California/O=Software/OU=es/CN=kibana"
