# Chapter2Bikes.cdc

## Introduction  

Contract on the Flow blockchain that allows Admins to batch mint native NFTs(`Chapter2Bikes` frame or painting editions).
Admins are granted power through the `Admin` resource.
Admins can withdraw NFTs that reside in the `Chapter2BikesCollection` resource to recipients
## Live Project  

https://chapter2bikes.ethosnft.com/
## Video demo  

link
## Roadmap  

### V1:
Restricted functions, resources, and capabilities.
[Admin] Mint native NFTs
[Admin] Batch mint native NFTs
[Admin] Send native NFT to recipients
[Admin] Destroy native NFT resource
## Metadata schema

Sample:
  
``` javascript
    {
      "description": "Full rendering of the Chapter2 / BHarms+Special Projects KOKO Artist Edition frame. A true digital proof of ownership uploaded to the Blockchain",
      "external_url": "https://ipfs.ethosnft.com/chapter2bikes/chapter2-bharms-koko-aero-frame.mp4",
      "image": "https://ethos.mypinata.cloud/ipfs/QmUAp7acHwUFomUVrdHWmk7FGTEeqY1BvVGaXp7cy95Z4S/chapter2-bharms-koko-aero-frame.mp4",
        "ipfsHash": "QmUAp7acHwUFomUVrdHWmk7FGTEeqY1BvVGaXp7cy95Z4S"
      "name": "Chapter2 B Harms Special Projects: Owners NFT 2022"
    }
```

## Contract Description
```javascript

  /*
    Description: Central Smart Contract for Chapter2 Bikes
    
    This smart contract contains the core functionality for 
    Chapter2 Bikes, created by Ethos Multiverse Inc.
    
    The contract manages the data associated with each NFT and 
    the distribution of each NFT to recipients.
    
    Admins throught their admin resource object have the power 
    to do all of the important actions in the smart contract such 
    as minting and batch minting.
    
    When NFTs are minted, they are initialized with a metadata object and an Edition type and then
    stored in the admins Collection.
    
    The contract also defines a Collection resource. This is an object that 
    every Chapter2 NFT owner will store in their account
    to manage their NFT collection.
    
    The main Chapter2 Bikes account operated by Ethos Multiverse Inc. 
    will also have its own Chapter2 collection it can use to hold its 
    own NFT's that have not yet been sent to a user.
    
    Note: All state changing functions will panic if an invalid argument is
    provided or one of its pre-conditions or post conditions aren't met.
    Functions that don't modify state will simply return 0 or nil 
    and those cases need to be handled by the caller.
*/
```

## Sequence Diagram  

### Transactions
**Admin**

  * Admin sends tx to batch mint `frame edition` NFT
  ``` mermaid
            sequenceDiagram
            participant C as Chapter2Bikes.cdc
            actor A as AuthEthos
            A->>C: batchMint tx args(frameEdition, arrayOfMetadataObjects)
            C->>A: Receives batch of Chapter2Bikes frame edition NFTs into Chapter2BikesCollection
  ```
  * Admin sends tx to batch mint `painting edition` NFT
  ``` mermaid
            sequenceDiagram
            participant C as Chapter2Bikes.cdc
            actor A as AuthEthos
            A->>C: batchMint tx args(paintingEdition, arrayOfMetadataObjects)
            C->>A: Receives batch of Chapter2Bikes painting edition NFTs into Chapter2BikesCollection
  ```
  * Admin sends tx to withdraw NFT from storage and deposit it to recipient
  ``` mermaid
            sequenceDiagram
            participant C as Chapter2Bikes.cdc
            actor A as AuthEthos
            actor U as User
            A->>C: withdraw tx args(claimerWallet, nftId)
            C->>U: Receives Chapter2Bikes NFT 
  ```
  * Admin sends tx to create a new Admin Resource
  ``` mermaid
            sequenceDiagram
            participant C as Chapter2Bikes.cdc
            actor A as AuthEthos
            actor A2 as AuthEthos2
            A->>C: createNewAdmin tx 
            C->>A2: Receives Admin resource 
  ```
TODO Admin sends tx to destroy Admin resource

**User**
  * User sends a tx requesting a `Chapter2BikesCollection` object
  ``` mermaid
            sequenceDiagram
                  participant C as Chapter2Bikes.cdc
                actor A as AuthEthos
                actor U as User
                C->A: owner
                U->>C: setupUser tx
                C->>U: Receives Chapter2BikesCollection
  ```

### Scripts

**Admin**
  * Admin sends tx to borrow NFT by id
  * Admin sends tx to borrow entire NFT
User
## Class Diagram

`Edition` enum
``` mermaid
		  classDiagram
		  class Edition{
		  +case frame
		  +case painting
		  }
```
`NFT` resource
``` mermaid
		  classDiagram
		  class NFT{
		  +UInt64 id
		  +Edition edition
		  +Dictionary metadata
		  ~init(metadata: string)
		  }
```
`CollectionPublic` resource interface
``` mermaid
		  classDiagram
		  class CollectionPublic{
		  +Dictionary ownedNFTs
		  +deposit(token: NFT) 
		  +getIDs()  Array UInt64
		  +borrowNFT(id: UInt64): NonFungibleTokenNFT
		  +borrowEntireNFT(id: UInt64) Chapter2BikesNFT
		  }
```
`Collection` resource
``` mermaid
		  classDiagram
		  class Collection{
		  +Dictionary ownedNFTs
		  +withdraw(withdrwaID: UInt64) NFT
		  +deposit(token: NFT)
		  +getIDs() Array UInt64
		  +borrowNFT(id: UInt64) NFT
		  +borrowEntireNFT(id: UInt64) NFT
		  -destroy()
		  -init()
		  }
```
`Admin` resource
``` mermaid
		  classDiagram
		  class Admin{
		  +mintNFT(edition: UInt8, metadata: Array String)
		  +batchMint(edition: UInt8, metadataArray: Objects Array)
		  +createNewAdmin() Admin
		  }
```