import Chapter2Bikes from "../../contracts/Chapter2Bikes.cdc"

pub fun main(): AnyStruct {

    log("Total Supply:")
    log(Chapter2Bikes.totalSupply)
    log("Total Frame Supply:")
    log(Chapter2Bikes.frameEditionSupply)
    log("Total Painting Supply:")
    log(Chapter2Bikes.paintingEditionSupply)
    return {
      "totalSupply": Chapter2Bikes.totalSupply,
      "totalFrameSupply": Chapter2Bikes.frameEditionSupply,
      "totalPaintingSupply": Chapter2Bikes.paintingEditionSupply
    }
}
