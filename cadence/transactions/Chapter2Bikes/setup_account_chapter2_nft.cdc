import Chapter2Bikes from "../../contracts/Chapter2Bikes.cdc"
import NonFungibleToken from "../../standards/NonFungibleToken.cdc"

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