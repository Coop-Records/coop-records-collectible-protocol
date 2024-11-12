# Zora Protocol 1155 Contract Deployments

Contains deployment scripts, deployed addresses and versions for the Zora 1155 Contracts.

## Package contents

- [Deployment scripts](./script/) for deployment Zora Protocol Contracts
- [Deployed addresses](./addresses/) containing deployed addresses and contract versions by chain.

### Deplo

1. deploy implementations

```bash
forge script script/DeployMintersAndImplementations.s.sol:DeployMintersAndImplementations --rpc-url https://sepolia.base.org --private-key PRIVATE_KEY --broadcast --verify --etherscan-api-key BASESCAN_API_KEY -vvvv
```

1.1

- script/DeployFactory.s.sol - update factoryImpl in to the address of the factory implementation

2. deploy factory proxy

```bash
forge script script/DeployFactory.s.sol:DeployFactory --rpc-url https://sepolia.base.org --private-key PRIVATE_KEY --broadcast --verify --etherscan-api-key BASESCAN_API_KEY -vvvv
```

3. deploy SecondarySwap

```bash
forge script script/DeploySwapHelperSimple.s.sol:DeploySwapHelperSimple --rpc-url https://sepolia.base.org --private-key PRIVATE_KEY --broadcast --verify --etherscan-api-key BASESCAN_API_KEY -vvvv
```
