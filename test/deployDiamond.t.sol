// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/facets/TokenFacet.sol";
import "../contracts/facets/NFTFacet.sol";
import "../contracts/facets/Marketplace.sol";
import "../contracts/Diamond.sol";

import "./helpers/DiamondUtils.sol";

contract DiamondDeployer is DiamondUtils, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    TokenFacet tokenF;
    NFTFacet nftFacet;
    Marketplace mPlace;

    // Test-scoped state variables
    address to;
    uint256 tokenId;

    function setUp() public {
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(
            address(this),
            address(dCutFacet),
            "Blessed",
            "BTK",
            "MyNFT",
            "MNT"
        );
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        tokenF = new TokenFacet(18);
        nftFacet = new NFTFacet();
        mPlace = new Marketplace();

        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](3);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(nftFacet),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("NFTFacet")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();

        to = address(0x1111);
        tokenId = 1;
        NFTFacet(address(diamond)).mint(to, tokenId);
    }

    function testNFTName() public {
        // Test that the name of the NFT is the same as at construction time
        assertEq(NFTFacet(address(diamond)).name(), "MyNFT");
    }

    function testNFTSymbol() public {
        // Test that the NFT synbol is the same as construction time
        assertEq(NFTFacet(address(diamond)).symbol(), "MNT");
    }

    function testMint() public {
        vm.startPrank(to);

        assert(NFTFacet(address(diamond)).ownerOf(tokenId) == to);
    }

    function testFailMint() public {
        address _fakeAddress = address(0x2222);
        vm.prank(to);
        assert(NFTFacet(address(diamond)).ownerOf(tokenId) == _fakeAddress);
    }

    function testBurn() public {
        vm.prank(to);
        NFTFacet(address(diamond)).burn(tokenId);
    }

    function testOwnerOf() public {
        // Test that the ownerOf an NFT is the current owner
        vm.prank(to);
        assert(NFTFacet(address(diamond)).ownerOf(tokenId) == to);
    }

    function testBalanceOfWrongAddress() public {
        // Test that the balance of a wrong address is zero
        address fakeAddress_ = address(0x2222);
        assertEq(NFTFacet(address(diamond)).balanceOf(fakeAddress_), 0);
    }

    function testBalanceOf() public {
        // Test that the balanceOf the owner of the token is the tokenId
        vm.prank(to);
        assertEq(NFTFacet(address(diamond)).balanceOf(to), tokenId);
    }

    function testBalanceOfAfterTransfer() public {
        // Test that the recepient balance increases after transfer
        address anotherAddress_ = address(0x2222);
        vm.prank(to);
        NFTFacet(address(diamond)).transferFrom(to, anotherAddress_, tokenId);
        assertEq(NFTFacet(address(diamond)).balanceOf(anotherAddress_), 1);
    }

    function testFailTransferFrom() public {
        // Test that only token owner can call transfer tokens (i.e., call transferFrom)
        address fakeAddress_ = address(0x2222);
        vm.prank(fakeAddress_);
        NFTFacet(address(diamond)).transferFrom(to, fakeAddress_, tokenId);
    }

    function testFailTransferFromAddressZero() public {
        // Test that token cannot be transferred to an invalid address e.g., address(0)
        vm.prank(to);
        NFTFacet(address(diamond)).transferFrom(to, address(0), tokenId);
    }

    function testTransferFrom() public {
        address anotherAddress_ = address(0x2222);
        vm.prank(to);
        NFTFacet(address(diamond)).transferFrom(to, anotherAddress_, tokenId);
        assertEq(NFTFacet(address(diamond)).ownerOf(tokenId), anotherAddress_);
    }

    function testFailNonExistentToken() public {
        address anotherAddress_ = address(0x2222);
        vm.prank(to);
        uint256 tokenId_ = 2;
        NFTFacet(address(diamond)).transferFrom(to, anotherAddress_, tokenId_);
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
