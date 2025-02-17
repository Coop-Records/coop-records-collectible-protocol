# Zora Protocol 1155 Contract Deployments

Contains deployment scripts, deployed addresses and versions for the Zora 1155 Contracts.

## Package contents

- [Deployment scripts](./script/) for deployment Zora Protocol Contracts
- [Deployed addresses](./addresses/) containing deployed addresses and contract versions by chain.

### Deploy

#### 1. deploy implementations

```bash
forge script script/DeployMintersAndImplementations.s.sol:DeployMintersAndImplementations --rpc-url https://sepolia.base.org --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
```

#### 2. copy deployed addresses to `addresses/{CHAINID}.json`:

```bash
pnpm tsx script/copy-deployed-contracts.ts
```

#### 3. update factoryImpl

- script/DeployFactory.s.sol - update factoryImpl in to the address of the factory implementation

#### 4. deploy factory proxy

```bash
forge script script/DeployFactory.s.sol:DeployFactory --rpc-url https://sepolia.base.org --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
```

#### 5. add the Factory Proxy address to `addresses/{CHAINID}.json`

- update `FACTORY_PROXY` with the address of the factory proxy you've just deployed

```bash
pnpm tsx script/copy-deployed-contracts.ts
```
