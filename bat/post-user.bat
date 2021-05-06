curl -v POST http://localhost:3000/user -d "{\"name\":\"Andrey\", \"surname\":\"Kitavtsev\",  \"avatar\":\"\",  \"login\":\"KITk\", \"password\":\"KIT3095\"}"

curl -v http://localhost:3000/user/11.020210429154645d44e7b93d17981fed7a8169684df477a

curl -v "http://localhost:3000/token?login=KIT&password=KIT3095"

curl -v http://localhost:3000/user/1.1202104301627401b4056772f899bfcb6a0c827a3ccc222

curl -v -X DELETE http://localhost:3000/user/1.1202104301627401b4056772f899bfcb6a0c827a3ccc222/3

curl -v -X DELETE http://localhost:3000/user/4.02021050115300175d7b7b6892d1c18dd7b4b3eaea277cf/4

curl -v "http://localhost:3000/file/?path=D:\myprograms\haskell\example\server\server-post-scotty\images\kit.jpg"
curl -v "http://localhost:3000/D:\myprograms\haskell\example\server\server-post-scotty\images\kit.jpg"

chcp 1251
psql -d posts -U postgres




