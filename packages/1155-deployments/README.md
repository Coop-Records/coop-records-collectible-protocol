# Zora Protocol 1155 Contract Deployments

Contains deployment scripts, deployed addresses and versions for the Zora 1155 Contracts.

## Package contents

- [Deployment scripts](./script/) for deployment Zora Protocol Contracts
- [Deployed addresses](./addresses/) containing deployed addresses and contract versions by chain.

### Deploy

#### Quick Deploy (All Steps)

To execute all deployment steps automatically:

```bash
pnpm deploy-protocol
```

Required environment variables in `.env`:

- `RPC_URL`: Network RPC endpoint
- `PRIVATE_KEY`: Deployer wallet private key
- `ETHERSCAN_API_KEY`: API key for contract verification

#### Manual Deployment Steps

For more granular control, you can execute each step manually:

#### 1. deploy implementations

```bash
forge script script/DeployMintersAndImplementations.s.sol:DeployMintersAndImplementations --rpc-url https://sepolia.base.org --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
```

#### 2. copy deployed addresses to `addresses/{CHAINID}.json`:

```bash
pnpm tsx script/copy-deployed-contracts.ts
```

#### 3. deploy factory proxy

```bash
forge script script/DeployFactory.s.sol:DeployFactory --rpc-url https://sepolia.base.org --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv
```

#### 4. add the Factory Proxy address to `addresses/{CHAINID}.json`

- update `FACTORY_PROXY` with the address of the factory proxy you've just deployed

```bash
pnpm tsx script/copy-deployed-contracts.ts
```
