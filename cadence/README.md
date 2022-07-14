# Chapter2Bikes.cdc

## Introduction  

Contract on the Flow blockchain that allows Admins to batch mint native NFTs(`Chapter2Bikes` frame or painting editions).
Admins are granted power through the `Admin` resource.
Admins can withdraw NFTs that reside in the `Chapter2BikesCollection` resource to recipients
## Live Project  

link
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
	     "description":"",
	     "external_url":"https://ethos.customlink",
	     "image":"https://ipfs.io/ipfs/QmSNpzoJsYaqGybdVKtRpynRaGGKJYkLYVXcBKyyApvbeN",
	     "name":"Chapter 2 Bikes ...",
	  }
```

## Contract Description


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