import Chapter2Bikes from 0xf8d6e0586b0a20c7
import NonFungibleToken from 0xf8d6e0586b0a20c7

transaction {

  prepare(acct: AuthAccount) {

    let collection <- Chapter2Bikes.createEmptyCollection()

    // Store the empty NFT collection in account storage
    acct.save<@NonFungibleToken.Collection>(<-collection, to: Chapter2Bikes.CollectionStoragePath)

    log("Collection created")

    // Create a public capability for the collection
    acct.link<&Chapter2Bikes.Collection{NonFungibleToken.CollectionPublic, Chapter2Bikes.CollectionPublic}>(
      Chapter2Bikes.CollectionPublicPath,
      target: Chapter2Bikes.CollectionStoragePath
    )
    log("Collection public capability created")
  }

  execute {
    
  }
}