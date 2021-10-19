// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/erc721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract InternNft is ERC721Enumerable, VRFConsumerBase, Ownable {

    bytes32 internal keyHash;
    uint256 internal fee;
    
    uint256 public randomNumber;
    string public prefixURI;
    uint256 public constant MAX_SUPPLY = 1000;

    constructor(string memory _prefixURI)
    ERC721("Intern-nfts", "INFT")
    VRFConsumerBase(
        0x3d2341ADb2D31f1c5530cDC622016af293177AE0, // VRF Coordinator for polygon
        0xb0897686c545045aFc77CF20eC7A532E3120E0F1  // LINK Token for polygon
    )
    {
        keyHash = 0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da; //key hash for polygon
        fee = 0.1 * 10 ** 15; // 0.0001 LINK (on polygon)
        setPrefixURI(_prefixURI);
    }

    /** 
     * Requests randomness 
     */
    function getRandomNumber() public onlyOwner returns (bytes32 requestId) {
        require(randomNumber != 0, "Random already set");
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomNumber = randomness;
    }

    function withdrawLinkTokens() external onlyOwner {
        LINK.transfer(owner(), LINK.balanceOf(address(this)));
    }

    function mintMultiple(address[] memory _to) external onlyOwner {
        for (uint256 i; i < _to.length; i+=1) {
            mint(_to[i], i);
        }
    }

    function mint(address _to, uint256 _tokenId) public onlyOwner {
        require(randomNumber == 0, "Can mint only if random not set"); //Can't cheat
        require(totalSupply() <= MAX_SUPPLY, "All nft already minted");
        _safeMint(_to, _tokenId);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
 
        uint256 attributes = tokenAttributes(_tokenId);
        return bytes(prefixURI).length > 0 ? string(abi.encodePacked(prefixURI, attributes)) : "";
    }
    
    function tokenAttributes(uint256 _tokenId) public view returns (uint256) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        uint256 sushi = randomAttribute(_tokenId, "character");
        if (sushi == 9) sushi = randomAttribute(_tokenId, "this sushi looks rare");
        
        uint256 background = randomAttribute(_tokenId, "character");
        if (background == 9) background = randomAttribute(_tokenId, "this background looks rare");

        uint256 character = randomAttribute(_tokenId, "character");
        if (character == 9) character = randomAttribute(_tokenId, "this character looks rare");
        return sushi * 100 + background * 10 + character;
    }

    function randomAttribute(uint256 _tokenId, string memory _attr) public view returns (uint256) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        return uint256(keccak256(abi.encode(randomNumber, _tokenId, _attr))) % 10;
    }

    function setPrefixURI(string memory _prefixURI) public onlyOwner {
        prefixURI = _prefixURI;
    }

}