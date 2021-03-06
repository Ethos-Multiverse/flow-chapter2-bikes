import NonFungibleToken from "../standards/NonFungibleToken.cdc";
import MetadataViews from "../standards/MetadataViews.cdc";

pub contract Chapter2Bikes: NonFungibleToken {

  // Events
  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)
  pub event Minted(id: UInt64)

  // Named Paths
  pub let CollectionStoragePath: StoragePath
  pub let CollectionPublicPath: PublicPath
  pub let AdminStoragePath: StoragePath
  pub let AdminPrivatePath: PrivatePath

  // Contract Level Fields
  pub var totalSupply: UInt64
  pub var frameEditionSupply: UInt64
  pub var paintingEditionSupply: UInt64

  // Contract Level Composite Type Definitions

  // Each NFT is associated to an Edition/Type: Frame or Painting.
  pub enum Edition: UInt8 {
    pub case Frame
    pub case Painting
  }

  // Resource that represents the a Chapter2Bikes NFT
  pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
    pub let id: UInt64

    pub let edition: Edition

    pub var metadata: {String: String}

    init(_edition: Chapter2Bikes.Edition, _metadata: {String: String}) {
      self.id = Chapter2Bikes.totalSupply
      self.edition = _edition
      self.metadata = _metadata

      // Total Supply
      Chapter2Bikes.totalSupply = Chapter2Bikes.totalSupply + 1

      // Edition Supply
      if (_edition == Edition.Frame) {
        Chapter2Bikes.frameEditionSupply = Chapter2Bikes.frameEditionSupply + 1
      } else if (_edition == Edition.Painting) {
        Chapter2Bikes.paintingEditionSupply = Chapter2Bikes.paintingEditionSupply + 1
      } else {
        // Invalid Edition
        panic("Edition is invalid. Options: 0(Frame) or 1(Painting)")
      }

      // Emit Minted Event
      emit Minted(id: self.id)
    }

    pub fun getViews(): [Type] {
      return [
          Type<MetadataViews.Display>(),
          Type<MetadataViews.Editions>(),
          Type<MetadataViews.NFTCollectionData>(),
          Type<MetadataViews.NFTCollectionDisplay>()
      ]
    }

    pub fun resolveView(_ view: Type): AnyStruct? {
      switch view {
          case Type<MetadataViews.Display>():
            return MetadataViews.Display(
                name: self.metadata["name"]!,
                description: self.metadata["description"]!,
                thumbnail: MetadataViews.HTTPFile(url: self.metadata["external_url"]!)
            )
          case Type<MetadataViews.Editions>():
            // 50 Frame editions and 20 Painting editions
            let frameEditionInfo = MetadataViews.Edition(name: "Chapter2 B Harms Special Projects: Owners NFT 2022", number: self.id, max: 50)
            let paintingEditionInfo = MetadataViews.Edition(name: "B Harms Special Projects: “the second chapter”", number: self.id, max: 20)
            let editionList: [MetadataViews.Edition] = [frameEditionInfo, paintingEditionInfo]
            return MetadataViews.Editions(editionList)
          case Type<MetadataViews.ExternalURL>():
            return MetadataViews.ExternalURL("https://chapter2bikes.ethosnft.com")
          case Type<MetadataViews.NFTCollectionData>():
            return MetadataViews.NFTCollectionData(
                storagePath: Chapter2Bikes.CollectionStoragePath,
                publicPath: Chapter2Bikes.CollectionPublicPath,
                providerPath: /private/Chapter2BikesCollection,
                publicCollection: Type<&Chapter2Bikes.Collection{Chapter2Bikes.CollectionPublic}>(),
                publicLinkedType: Type<&Chapter2Bikes.Collection{Chapter2Bikes.CollectionPublic, NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(),
                providerLinkedType: Type<&Chapter2Bikes.Collection{Chapter2Bikes.CollectionPublic, NonFungibleToken.CollectionPublic, NonFungibleToken.Provider, MetadataViews.ResolverCollection}>(),
                createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
                  return <- Chapter2Bikes.createEmptyCollection()
                })
            )
          case Type<MetadataViews.NFTCollectionDisplay>():
            let ipfsHash = self.metadata["ipfsHash"]!
            let url = "https://ethos.mypinata.cloud/ipfs/".concat(ipfsHash)
            let frameMedia = MetadataViews.Media(
              file: MetadataViews.HTTPFile(url: url.concat("chapter2-bharms-koko-aero-frame.mp4")),
              mediaType: "video/mp4"
            )
            let paintingMedia = MetadataViews.Media(
              file: MetadataViews.HTTPFile(url: url.concat("chapter2-bharms-the-second-chapter.mp4")),
              mediaType: "video/mp4"
            )
            return MetadataViews.NFTCollectionDisplay(
              name: "Chapter2 Frame and Painting Collection",
              description: "For the past number of years, Bradley Harms has taken a leading role in a new and forward-looking wave of Canadian abstraction, building upon traditions within the medium, while creating work that both reflects and critiques contemporary social and technological developments.",
              externalURL: MetadataViews.ExternalURL("https://chapter2.ethosnft.com"),
              frameImage: frameMedia,
              paintingImage: paintingMedia,
              socials: {
                "instagram": MetadataViews.ExternalURL("https://www.instagram.com/chapter2bikes")
              }
            )
      }
      return nil 
    }

  }

  // Public Interface for Collection resource
  pub resource interface CollectionPublic {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}
    pub fun deposit(token: @NonFungibleToken.NFT)
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    pub fun borrowEntireNFT(id: UInt64): &Chapter2Bikes.NFT?
  }

  // Collection resource for managing Chapter2Bikes NFTs
  pub resource Collection: NonFungibleToken.Receiver, NonFungibleToken.Provider, NonFungibleToken.CollectionPublic, CollectionPublic, MetadataViews.ResolverCollection {

    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}
    
    // Withdraw
    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("Token not found")
      emit Withdraw(id: token.id, from: self.owner?.address)
      return <- token
    }

    // Deposit
    pub fun deposit(token: @NonFungibleToken.NFT) {
      let myToken <- token as! @Chapter2Bikes.NFT
      emit Deposit(id: myToken.id, to: self.owner?.address)
      self.ownedNFTs[myToken.id] <-! myToken
    }

    // Get IDs array
    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    // Borrow reference to NFT: read id
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
      return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
    }

    // Borrow reference to NFT: read all data
    pub fun borrowEntireNFT(id: UInt64): &Chapter2Bikes.NFT? {
      if self.ownedNFTs[id] != nil {
        let reference = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
        return reference as! &Chapter2Bikes.NFT
      } else {
        return nil
      }
    }

    pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
      let nft = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
      let chapter2NFT = nft as! &Chapter2Bikes.NFT
      return chapter2NFT as &AnyResource{MetadataViews.Resolver}
    }

    // Collection initialization
    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs 
    }
  }

  // Admin Resource
  pub resource Admin {
    // mint Chapter2 NFT
    pub fun mint(recipient: &{NonFungibleToken.CollectionPublic}, edition: Chapter2Bikes.Edition, metadata: {String: String}) {
        var newNFT <- create NFT(_edition: edition, _metadata: metadata)

        recipient.deposit(token: <- newNFT)
    }

    // batch mint Chapter2 NFT
    pub fun batchMint(recipient: &{NonFungibleToken.CollectionPublic}, edition: Chapter2Bikes.Edition, metadataArray: [{String: String}]) {
        var i: Int = 0
        while i < metadataArray.length {
            self.mint(recipient: recipient, edition: edition, metadata: metadataArray[i])
            i = i + 1;
        }
    }

    // Only an admin can create new Admins
    pub fun createNewAdmin(): @Admin {
        return <- create Admin()
    }
  }

  // Public interface for Admin Proxy
  pub resource interface AdminProxyPublic {
    pub fun giveAdminRights(cap: Capability<&Admin>)
  }

  // Admin Proxy Resource
  pub resource AdminProxy: AdminProxyPublic {
    access(self) var cap: Capability<&Admin>

    init() {
      self.cap = nil!
    }

    pub fun giveAdminRights(cap: Capability<&Admin>) {
      pre {
        self.cap == nil : "Capability is already set."
      }
      self.cap = cap
    }

    pub fun checkAdminRights(): Bool {
      return self.cap.check()
    }

    access(self) fun borrow(): &Admin {
      pre {
        self.cap != nil : "Capability is not set."
        self.checkAdminRights() : "Admin unliked capability."
      }
      return self.cap.borrow()!
    }

    pub fun mint(recipient: &{NonFungibleToken.CollectionPublic}, edition: Chapter2Bikes.Edition, metadata: {String: String}) {
      let admin = self.borrow()
      admin.mint(recipient: recipient, edition: edition, metadata: metadata)
    }

    pub fun batchMint(recipient: &{NonFungibleToken.CollectionPublic}, edition: Chapter2Bikes.Edition, metadataArray: [{String: String}]) {
      let admin = self.borrow()
      admin.batchMint(recipient: recipient, edition: edition, metadataArray:metadataArray)
    }
  }

  // Contract Level Function Defenitions

  // Public function to create an empty collection
  pub fun createEmptyCollection(): @NonFungibleToken.Collection {
    return <- create Collection()
  }

  // Map edition type to string
  pub fun editionString(_ edition: Edition): String {
    switch edition {
      case Edition.Frame:
        return "Frame"
      case Edition.Painting:
        return "Painting"
    }
    return ""
  }

  // Contract initialization
  init() {
    // Initialize all supplys
    self.totalSupply = 0
    self.frameEditionSupply = 0
    self.paintingEditionSupply = 0

    // Set named paths
    self.CollectionStoragePath = /storage/Chapter2BikesCollection
    self.CollectionPublicPath = /public/Chapter2BikesCollection
    self.AdminStoragePath = /storage/Chapter2BikesAdmin
    self.AdminPrivatePath = /private/Chapter2BikesAdminUpgrade

    // Create admin resource and save it to storage
    self.account.save(<-create Admin(), to: self.AdminStoragePath)

    // Create a Collection resource and save it to storage
    let collection <- create Collection()
    self.account.save(<-collection, to: self.CollectionStoragePath)

    // Create a public capability for the collection
    self.account.link<&Chapter2Bikes.Collection{NonFungibleToken.CollectionPublic, Chapter2Bikes.CollectionPublic, MetadataViews.ResolverCollection}>(
      self.CollectionPublicPath,
      target: self.CollectionStoragePath
    )

    // Create a private capability fot the admin resource
    self.account.link<&Chapter2Bikes.Admin>(self.AdminPrivatePath, target: self.AdminStoragePath) ?? panic("Could not get Admin capability")

    emit ContractInitialized()
  }

}