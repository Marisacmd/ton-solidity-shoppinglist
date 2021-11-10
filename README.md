# 📜💬 ton-solidity-shoppinglist
TONOS based DeBot with CRUD logic, demonstrates basic user-contract interaction using DeBots paradigm. 

# Deploy

1. Structure of the project & deploy order

There is main DeBot contract (ShoppingListDebot.sol) and two inheriting contracts: PurchaseStarter and PurchaseFinisher. 

(Contract1) creates input parameter  -> (Contract2) accepts input parameter

Both of them are CRUD. The first contract has a Create option from CRUD. The second DeBot works with a ready-made contract and has the Update function as the main one. To deploy the Finisher contract, the constructor of the 2nd contract accepts the address of the ShoppingList created by the first contract. 

2. Launch on DevNet

Actual version:
2 debots:

- [Purchase starter](https://web.ton.surf/debot?address=0%3Af96034ef8b5019de55f482bd331481ea480a9ded8bd1dbd8c7bb98757abfa439&net=devnet)
- [Purchase finisher](https://web.ton.surf/debot?address=0%3A7cf3b6119827f6c62eb355d73afe102267c2a7f2d31fb79a0324f65570b63e2f&net=devnet)

# ToDo plans

1. Expand functionality.
2. Continue the division of the code into frequently used files (commons, common_functions etc.) and "code users".
3. Add autodeploy (.sh) + add deploy instructions
4. Track and fix possible bugs. 

