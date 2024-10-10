# BlockVerse(Katena Dashboard)
The very first tentative of giving a dashboard to katena:

Katena is a container which allows to exploit different experiment.  
This project aims at giving a dashboard to katena, so that the normale user which wants to use Katena   
has an underling software which is able to use all the potentialities of Katena  


# Requirements
```

-Flutter 3.22;  
-Dart 3.40;  
-All the requirements needed in order to use Katena;   
-Firebase console and configuration files;    
-Node.js
-npm
-Docker
-Solidity v0.8.0+commit.c7dfd78e
-License MIT for verify contract
```

# Contract Compile
You can compile the contract through Hardhat or Truffle, via the following steps:

## Compile through Hardhat
1. Create the Truffle folder and move inside it.
```
mkdir MyHardhatProject
cd MyHardhatProject
```
2. Initialize Hardhat
```
npm init -y
npm install –save-dev hardhat
npx hardhat
npm install --save-dev @nomicfoundation/hardhat-toolbox 
```
3. Create the contracts directory and add contract solidity (.sol) inside it.
```
mkdir contracts 
```
4. Compile the contracts and the file json is in the directory "artifacts/contracts"
```
npx hardhat compile
```
-Firebase console and configuration files;
-Docker Engine

```

# How to execute

```
docker build -t BlockVerse .
docker run -d --name container-name -p 8080:8080 BlockVerse

Inside the terminal


docker exec -it flutter-app-container  bash

the execution as you can see in the dockerfile is on:

 python3 -m http.server 8080

```



# Install and Run with Docker Compose





