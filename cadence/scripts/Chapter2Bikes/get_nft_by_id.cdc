import Chapter2Bikes from "../../contracts/Chapter2Bikes.cdc"


pub fun main(address: Address){
  let nftOwner = getAccount(address)

  // Find the public Receiver capability for their Collection
  let capability = nftOwner.getCapability<&{Chapter2Bikes.CollectionPublic}>(Chapter2Bikes.CollectionPublicPath)

  // borrow a reference from the capability
  let receiverRef = capability.borrow()
      ?? panic("Could not borrow the receiver reference")

  // Log the NFTs that they own as an array of IDs
  log("Account 2 NFTs")
  log(receiverRef.getIDs())
  log(receiverRef.borrowNFT(id: 0))

  //look into doing a pre-condition before depositing, where if the tokenID exists in the collections array, you cannot put another one
}
