# BlockVerse(Katena Dashboard)
The very first tentative of giving a dashboard to katena:

Katena is a container which allows to exploit different experiment.  
This project aims at giving a dashboard to katena, so that the normale user which wants to use Katena   
has an underling software which is able to use all the potentialities of Katena


# Requirements
```
-Docker
-Solidity v0.8.0+commit.c7dfd78e
```


# Install and Run
To install the application, run the following command:
```
./build_container.sh
```
Questo script esegue Docker Compose per l'applicazione, clona il repository di Blockscout ed esegue il suo Docker Compose.



# Compilation and Verification of Contracts.
You can compile the contract through Hardhat, via the following steps:

1. Create the Hardhat folder and move inside it.
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

3. In the folder, open the ```hardhat.config.js``` file and change the ```“version”``` section by setting it to ```“0.8.0”```

4. Create the contracts directory and add contract solidity (.sol) inside it.
```
mkdir contracts 
```
5. Compile the contracts and the file json is in the directory "artifacts/contracts"
```
npx hardhat compile
```







