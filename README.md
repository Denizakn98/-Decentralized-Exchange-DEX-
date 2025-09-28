# -Decentralized-Exchange-DEX-
simple dex exp. 
# Decentralized Exchange (DEX) Smart Contract

A minimal automated market maker (AMM) decentralized exchange smart contract inspired by Uniswap V2, written in Solidity.

## Features

- Swap between two ERC-20 tokens
- Add liquidity to the pool
- Remove liquidity and withdraw tokens
- Tracks reserves and issues LP tokens

## Requirements

- Solidity ^0.8.0
- Hardhat or Remix for deployment/testing
- Two ERC-20 token contracts for testing

## How to Use

1. Deploy two ERC-20 tokens (e.g., TokenA, TokenB)
2. Deploy the `SimpleDEX` contract, passing token addresses to the constructor
3. Add liquidity by calling `addLiquidity`
4. Swap tokens using `swap`
5. Remove liquidity with `removeLiquidity`

## Example

See `test/DEX.test.js` for Hardhat test usage examples.

**This is an educational project. Do not use in production.**
