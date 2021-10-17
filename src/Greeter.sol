// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/erc721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract InternNft is ERC721("Intern-nfts", "INFT") {

    string public prefixURI;

    constructor(string memory _prefixURI) {
        prefixURI = _prefixURI;
    }

}