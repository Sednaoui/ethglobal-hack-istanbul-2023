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
