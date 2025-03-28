# KATENA ⛓️ 

[![DOI](https://zenodo.org/badge/472717537.svg)](https://zenodo.org/badge/latestdoi/472717537)

Operations on Blockchain with TOSCA.

This repo contains all the files needed to setup and run the experiments used in the evaluation of KATENA.
The prototype has been tested on Ubuntu 20.04.

**NOTE**: to reproduce the experiments reported in the paper refer to [Experiments Reproducibility](#experiments-reproducibility) section. For each experiment, we provided the required step to run it.
If you want further information on how to use KATENA to deploy your applications refer to [Development](DEVELOPMENT.md) file. For extra information on Number of Tokens computation see [here](NUMBER_OF_TOKENS.md).

## Install and run KATENA

The suggested way to reproduce the experiments is to use Docker (if not installed, check this [link](https://docs.docker.com/get-docker/)).

1. Clone this repository and navigate into the project folder
2. To build the KATENA Docker image execute
   ```
   docker build -t katena .
   ```
3. To access KATENA container execute
   ```
   docker run -it katena
   ```

## Experiments Reproducibility

The KATENA container allows to reproduce both the deployment of benchmark applications and the Number of Tokens analysis as described below.

**The following commands must be executed within KATENA containers (i.e., after the execution of step 3 of the previous section). The two experiments are independent, so there is no specific order to execute them.**

- ### Benchmark application deployment

  To deploy the benchmark applications execute within the KATENA container the following command.

  ```
  ./run-deploy.sh
  ```

  The script automatically:

  - Bootstraps a Ganache instance.
  - Retrieves the credentials of Account 0 (among the ones generated by Ganache) and uses them to pay for transactions on the local Ganache Blockchain.
  - Stores these credentials in KATENA
  - Instructs KATENA to deploy ENS, Dark Forest, and dydx by providing the TOSCA models (stored in folder `benchmark`) and the smart contract ABIs (stored in folders `nodes/contracts-<APP_NAME>` where APP_NAME can be either ens, dydx or dark-forest).

Note that depending on the hardware configuration this step could take a while (approximatively 10/20 minutes).

The deployment succeeds if this output is printed in the console.

```
deploying ens...
ens deployed successfully
deploying dark-forest...
dark-forest deployed successfully
deploying dydx...
dydx deployed successfully
```

- ### Number of Tokens analysis

  To execute the analysis execute within the KATENA container the following command.

  ```
  ./run-not-evaluation-all.sh
  ```

  This script compares the difference in Number of Tokens between KATENA specification files used to deploy the applications and the original deployment scripts.

  The experiment succeeds if the output is:

  ```
  dark-forest
  YAML: 304
  JS: 1765
  ens
  YAML: 87
  JS: 95
  dydx
  YAML: 559
  JS: 923
  ```

More information regarding the analysis can be found [here](NUMBER_OF_TOKENS.md).

## Error logs

The errors produced by KATENA (if any) are stored in file `deploy.log` which can be accessed _within KATENA container_.

## Benchmark Applications

- Ethereum Name Service (ENS): a DNS working on Ethereum
- dydx: DeFi application
- Dark Forest: on-chain game that uses the Diamond pattern.

Note that if you want to deploy Dark Forest smart contracts _manually_ (i.e., without using script `run-deploy.sh`), Ganache must be started with the following options to remove smart contract size constraint and to increase the gas limit.

```
ganache-cli -l 10000000 -g 1 --allowUnlimitedContractSize
```

## Repository structure

- [benchmark](./benchmark/): contains Service Template for app used in evaluation: dydx, dark forest, ens.

- [examples](./examples/): files used to test the implementation. Contains basic use cases to test relationships, library linkage, and diamond pattern.

- [nodes](./nodes/): contains:

  - smart contract ABIs used by xopera to deploy smart contracts (folders `contracts-*`)
  - Ansible playbooks attached to xopera node and relationships types (folder `playbooks`)
  - Python scripts used to communicate with the chain (using Web3.py) (folder `scripts`)
  - all the node, relationships, capabilities, and relationships used to model the dApps (files `capabilities.yaml`, `contract.yaml`, `network.yaml`, `relationships.yaml`, `wallet.yaml`)

- [not-comparison](./not-comparison/) files used for the evaluation using the Number of Tokens (NoT) metric.

<!-- - [Smart Contract Example](./smart-contract-example/): contains a truffle project used to test and use JS and TS capabilities to use functions of the benchmark apps -->
