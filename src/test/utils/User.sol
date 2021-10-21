// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./../../SushiChan.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract User is IERC721Receiver {
    SushiChan internal sushiChan;

    constructor(SushiChan _sushiChan) {
        sushiChan = _sushiChan;
    }

    function mint() public {
        sushiChan.mint(address(this));
    }

    function mintMultiple() public {
        address[] memory addresses = new address[](2);
        addresses[0] = address(this);
        addresses[1] = address(this);
        sushiChan.mintMultiple(addresses);
    }

    function withdrawLinkTokens() public {
        sushiChan.withdrawLinkTokens();
    }

    function setPrefixURI(string memory _prefixURI) public {
        sushiChan.setPrefixURI(_prefixURI);
    }

    function getRandomNumber() public {
        sushiChan.getRandomNumber();
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
