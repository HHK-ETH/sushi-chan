// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract SushiChan is ERC721Enumerable, VRFConsumerBase, Ownable {
    bytes32 internal keyHash;
    uint256 internal fee;

    uint256 public randomNumber;
    string public prefixURI;
    uint256 public constant MAX_SUPPLY = 1000;

    constructor(
        address _vrfCoordinator,
        address _linkToken,
        string memory _prefixURI
    )
        ERC721("Sushi-chan", "SCHAN")
        VRFConsumerBase(
            _vrfCoordinator, //0x3d2341ADb2D31f1c5530cDC622016af293177AE0 VRF Coordinator for polygon
            _linkToken //0xb0897686c545045aFc77CF20eC7A532E3120E0F1 LINK Token for polygon
        )
    {
        keyHash = 0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da; //key hash for polygon
        fee = 0.1 * 10**15; // 0.0001 LINK (on polygon)
        setPrefixURI(_prefixURI);
    }

    /**
     * Requests randomness
     */
    function getRandomNumber() public onlyOwner returns (bytes32 requestId) {
        require(randomNumber != 0, "Random already set");
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        randomNumber = randomness;
    }

    /**
     * Withdraw all Link token to owner
     */
    function withdrawLinkTokens() external onlyOwner {
        LINK.transfer(owner(), LINK.balanceOf(address(this)));
    }

    /**
     * Mint for multiple addresses in a single transaction
     */
    function mintMultiple(address[] memory _to) external onlyOwner {
        for (uint256 i; i < _to.length; i += 1) {
            mint(_to[i]);
        }
    }

    /**
     * Mint for 1 address
     */
    function mint(address _to) public onlyOwner {
        require(randomNumber == 0, "Can't mint once random number is set"); //Can't cheat
        require(totalSupply() < MAX_SUPPLY, "All nft already minted");
        _safeMint(_to, totalSupply());
    }

    /**
     * Return tokenURI
     */
    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        if (randomNumber == 0) {
            return string(abi.encodePacked(prefixURI, "nrs")); //not ready ser
        }

        uint256 attributes = tokenAttributes(_tokenId);
        return string(abi.encodePacked(prefixURI, attributes));
    }

    /**
     * Return token attributes
     */
    function tokenAttributes(uint256 _tokenId) public view returns (uint256) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        uint256 background = random(_tokenId, "background");
        uint256 character = random(_tokenId, "character");
        uint256 sushi = random(_tokenId, "sushi");

        return background * 100 + character * 10 + sushi;
    }

    /**
     * Return random attribute between 0 and 9
     */
    function random(uint256 _tokenId, string memory _attr)
        public
        view
        returns (uint256)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        uint256 randomUint = uint256(
            keccak256(abi.encode(randomNumber, _tokenId, _attr))
        );
        return randomUint % 2 == 1 ? randomUint % 8 : randomUint % 9; //9 is the rarest id
    }

    /**
     * Set prefixURI
     */
    function setPrefixURI(string memory _prefixURI) public onlyOwner {
        prefixURI = _prefixURI;
    }
}
