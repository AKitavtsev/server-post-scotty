curl -v POST http://localhost:3000/user -d "{\"name\":\"Andrey\", \"surname\":\"Kitavtsev\",  \"avatar\":\"\",  \"login\":\"KITk\", \"password\":\"KIT3095\"}"

curl -v http://localhost:3000/user/11.020210429154645d44e7b93d17981fed7a8169684df477a

curl -v "http://localhost:3000/token?login=KIT&password=KIT3095"

curl -v http://localhost:3000/user/1.1202104301627401b4056772f899bfcb6a0c827a3ccc222

psql -d posts -U postgres




REM http://localhost:3000/users?name=Andrey&surname=Kitavtsev&avatar= &login=KITf&password=KIT3095