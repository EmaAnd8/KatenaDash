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

## Compile through Truffle
1. Install Truffle globally.
```
npm install -g truffle
```
2.	Create the Truffle folder and move inside it.
```
mkdir MyTruffleProject
cd MyTruffleProject
```
3.  Truffle initialization.
```
truffle init
```
4. Add contract solidity (.sol) in the directory "contracts" and if you want you can edit the configuration file "truffle-config.js"
5. Compile the contract and the file json is in directory "build/contracts"
```
truffle compile
```



# Install and Run with Docker Compose



