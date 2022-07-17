import Chapter2Bikes from 0xf8d6e0586b0a20c7
import NonFungibleToken from 0xf8d6e0586b0a20c7

transaction(edition: UInt8, metadata: {String: String}) {

let adminCheck: &Chapter2Bikes.Admin

var editionCheck: Chapter2Bikes.Edition

let receiver: &{NonFungibleToken.CollectionPublic}

prepare(acct: AuthAccount) {

  // if Admin account doesn't have a LJL collection
  if acct.borrow<&Chapter2Bikes.Collection>(from: Chapter2Bikes.CollectionStoragePath) == nil {

    log("Admin does not hold LJL collection")

    // create an empty collection 
    let collection <- Chapter2Bikes.createEmptyCollection()

    // store the empty NFt Collection in account storage
    acct.save<@NonFungibleToken.Collection>(<-collection, to: Chapter2Bikes.CollectionStoragePath)

    log("Collection created")

    // create a public capability for that Collection
    acct.link<&Chapter2Bikes.Collection{NonFungibleToken.CollectionPublic, Chapter2Bikes.CollectionPublic}>(
      Chapter2Bikes.CollectionPublicPath,
      target: Chapter2Bikes.CollectionStoragePath
    )
    log("Admin capability created")

  }

  self.editionCheck = Chapter2Bikes.Edition.Frame

  self.adminCheck = acct.borrow<&Chapter2Bikes.Admin>(from: Chapter2Bikes.AdminStoragePath)
  ?? panic("could not borrow admin reference")

  // Edition Check
  if (edition == 0) {
    self.editionCheck = Chapter2Bikes.Edition.Frame
  } else if (edition == 1) {
    self.editionCheck = Chapter2Bikes.Edition.Painting
  } else {
    panic("Invalid edition type: 0(Frame) or 1(Painting)")
  }

  self.receiver = acct.getCapability<&Chapter2Bikes.Collection{NonFungibleToken.CollectionPublic}>(Chapter2Bikes.CollectionPublicPath).borrow()
  ?? panic("could not borrow capability")

}

execute {
  self.adminCheck.mint(recipient: self.receiver, edition: self.editionCheck, metadata: metadata)
  log("Mint successful")
}
}
