SET SERVER_URL=https://dev-java-gw.sealights.co/api
SET CUSTOMER_ID=Swagger
SET JAVA_CLASS_PREFIX="io/swagger"
SET APP_NAME=Swagger-Parser
SET BRANCH=My-Git-Branch
SET BUILD_ID=1


rem **** Compile the project without running tests ****
call mvn compile package -Dmaven.test.skip=true

rem **** Download the build agent ****
del java-build-agent-1.0.0-SNAPSHOT-jar-with-dependencies.jar
wget64 https://s3-us-west-2.amazonaws.com/sl-agent-repository/java-build-agent-1.0.0-SNAPSHOT-jar-with-dependencies.jar

rem **** Create an artifacts folder ****
md artifacts

rem **** Copy the jars that we want to instrument into this folder ****
copy .\modules\swagger-compat-spec-parser\target\swagger-compat-spec-parser-1.0.15-SNAPSHOT.jar .\artifacts
copy .\modules\swagger-parser\target\swagger-parser-1.0.15-SNAPSHOT.jar .\artifacts

rem **** Copy the sealights.json to the 'target' folder ****
copy .\modules\swagger-compat-spec-parser\sealights.json .\modules\swagger-compat-spec-parser\target
copy .\modules\swagger-parser\sealights.json .\modules\swagger-parser\target

rem **** Copy the aop.xml to the 'target' folder ****
copy .\modules\swagger-compat-spec-parser\aop.xml .\modules\swagger-compat-spec-parser\target
copy .\modules\swagger-parser\aop.xml .\modules\swagger-parser\target

rem **** Enable debugging ****
set NODE_DEBUG=sl

rem **** Install the build agent ****
call npm init -y
call npm install @sealights/sl-cia
call .\node_modules\.bin\sl-config-cia --customerid %CUSTOMER_ID% --server %SERVER_URL% --javahome "%JAVA_HOME%" --jar "java-build-agent-1.0.0-SNAPSHOT-jar-with-dependencies.jar" --javaclassprefix %JAVA_CLASS_PREFIX%

rem **** Run the build agent ****
call .\node_modules\.bin\sl-cia --workspacepath "artifacts" --branch "%BRANCH%" --build "%BUILD_ID%" --appname %APP_NAME% --technology java --scm git 

rem **** Run the tests ****
call mvn test