# Aid Distribute
![aiddistribute-logo](https://github.com/Sednaoui/ethglobal-hack-istanbul-2023/assets/7014833/b3d2f415-89db-4e2c-9199-b75e10e459bc)

## What is it about
AidDistribute is a mechanism to ensures a traceable and accountable channel for direct stablecoin transfers

## The problem
Globally, conditional cash transfers are widely utilized social policy tools aiming to facilitate distribution of cash. The challenge with traditional conditional cash distribution lies in its inherent lack of transparency and accountability. Once funds are distributed, the tracking mechanisms become obscure, hindering the ability to trace the precise journey and utilization of the financial aid. This opacity poses a significant obstacle in ensuring that the funds reach their intended recipients and are spent in a manner aligned with the intended purpose. 

## The solution
AidDistribute addresses this issue by enabling organizations like Unicef to securely distrubute cash and conditionally allow for its spending. An Organization can deposit stablecoins into a transparent vault and mint bearing tokens to a distribute them to designated recipients. These tokens can be seamlessly be transferred to selected merchants or services, who, in turn, redeem them for stablecoi. AidDistribute ensures a traceable and accountable channel for direct cash transfers, fostering transparency, efficiency, and direct impact in humanitarian aid efforts.

## How its made
This project takes inspiration from ERC-4326 and is a modified vault version. We designed the smart contract where an owner can deposit ERC-20 tokens, and then mint ownership tokens to a list of recipients. The bearing tokens can only be transferred to a whitelisted addresses. In turn, whitelisted addresses have the opportunity to redeem the original ERC-20 tokens corresponding to their earned bearing tokens. The owner have the ability to set a daily withdrawal limits to the whitelisted addresses. 

## Deployments:
Arbitrum Goerli [0x006D0F160f2ce1C274f82006E4A9CcD8F8Ff35c3](https://goerli.arbiscan.io/address/0x006D0F160f2ce1C274f82006E4A9CcD8F8Ff35c3)

Polygon zkEVM
[0x006D0F160f2ce1C274f82006E4A9CcD8F8Ff35c3](https://testnet-zkevm.polygonscan.com/address/0x006D0F160f2ce1C274f82006E4A9CcD8F8Ff35c3)

Celesia Bubs
[0x006D0F160f2ce1C274f82006E4A9CcD8F8Ff35c3](https://bubs.calderaexplorer.xyz/address/0x006D0F160f2ce1C274f82006E4A9CcD8F8Ff35c3)

Celo
[0x006D0F160f2ce1C274f82006E4A9CcD8F8Ff35c3](https://alfajores.celoscan.io/address/0x006d0f160f2ce1c274f82006e4a9ccd8f8ff35c3)

Sepolia
[0xd8BcEFC4bBDb2aEd29d0D9A6F4e90Fd2E46D439e](https://sepolia.etherscan.io/address/0xd8BcEFC4bBDb2aEd29d0D9A6F4e90Fd2E46D439e)

Sepolia with Gho
[0x84cf63cdcb15acde0e07a71e4a278da9c984ee41](https://sepolia.etherscan.io/address/0x84cf63cdcb15acde0e07a71e4a278da9c984ee41)

Scroll Sepolia[0x006D0F160f2ce1C274f82006E4A9CcD8F8Ff35c3](https://sepolia.scrollscan.dev/address/0x006D0F160f2ce1C274f82006E4A9CcD8F8Ff35c3)

Linea Goerli: [0x006D0F160f2ce1C274f82006E4A9CcD8F8Ff35c3](https://explorer.goerli.linea.build/address/0x006D0F160f2ce1C274f82006E4A9CcD8F8Ff35c3)

Gnosis [0x006d0f160f2ce1c274f82006e4a9ccd8f8ff35c3](https://gnosisscan.io/address/0x006d0f160f2ce1c274f82006e4a9ccd8f8ff35c3)
