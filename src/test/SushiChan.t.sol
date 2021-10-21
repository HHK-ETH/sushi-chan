// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "./../SushiChan.sol";
import "./utils/User.sol";

contract SushiChanTest is DSTest {
    SushiChan internal sushiChan;
    User internal owner;
    User internal user;
    string internal prefixURI = "ipfs://xxxxxxxxxxxxxxxxxxxxxxxx/";

    function setUp() public {
        sushiChan = new SushiChan(
            0x3d2341ADb2D31f1c5530cDC622016af293177AE0, //vrf
            0xb0897686c545045aFc77CF20eC7A532E3120E0F1, //link token
            prefixURI
        );

        owner = new User(sushiChan);
        user = new User(sushiChan);

        sushiChan.transferOwnership(address(owner));
    }

    function test_mint() public {
        uint256 prevBalance = sushiChan.balanceOf(address(owner));
        owner.mint();
        uint256 postBalance = sushiChan.balanceOf(address(owner));
        assertEq(prevBalance + 1, postBalance);
    }

    function testFail_mint_not_owner() public {
        user.mint();
    }

    function testFail_mint_more_than_max_supply() public {
        for (uint256 index = 0; index < sushiChan.MAX_SUPPLY() + 2; index++) {
            owner.mint();
        }
    }

    function test_mintMultiple() public {
        uint256 prevBalance = sushiChan.balanceOf(address(owner));
        owner.mintMultiple();
        uint256 postBalance = sushiChan.balanceOf(address(owner));
        assertEq(prevBalance + 2, postBalance);
    }

    function testFail_mintMultiple_not_owner() public {
        user.mintMultiple();
    }

    function test_setPrefixURI() public {
        owner.setPrefixURI("new link");
        assertEq(sushiChan.prefixURI(), "new link");
    }

    function testFail_setPrefixURI_not_owner() public {
        user.setPrefixURI("this will revert");
    }

    function test_tokenURI_random_not_set() public {
        owner.mint();
        assertEq(
            sushiChan.tokenURI(sushiChan.totalSupply() - 1),
            string(abi.encodePacked(prefixURI, "nrs"))
        );
    }
}
