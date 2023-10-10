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

        // cut[2] = (
        //     FacetCut({
        //         facetAddress: address(tokenF),
        //         action: FacetCutAction.Add,
        //         functionSelectors: generateSelectors("TokenFacet")
        //     })
        // );

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
        assertEq(NFTFacet(address(diamond)).name(), "MyNFT");
    }

    function testNFTSymbol() public {
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
        // NFTFacet(address(diamond)).mint(to_, tokenId_);
        NFTFacet(address(diamond)).burn(tokenId);
    }

    function testOwnerOf() public {
        vm.prank(to);
        // NFTFacet(address(diamond)).mint(_to, _tokenId);

        assert(NFTFacet(address(diamond)).ownerOf(tokenId) == to);
    }

    function testBalanceOfWrongAddress() public {
        address fakeAddress_ = address(0x2222);
        assertEq(NFTFacet(address(diamond)).balanceOf(fakeAddress_), 0);
    }

    function testBalanceOf() public {
        vm.prank(to);
        assertEq(NFTFacet(address(diamond)).balanceOf(to), 1);
    }

    function testFailTransferFrom() public {
        address fakeAddress_ = address(0x2222);
        vm.prank(to);
        NFTFacet(address(diamond)).transferFrom(to, fakeAddress_, tokenId);
    }

    // function testTransferFrom() public {
    //     address fakeAddress_ = address(0x2222);
    //     address fakeAddress2_ = address(0x3333);
    //     vm.prank(to);
    //     // Approve the contract to make transfer
    //     NFTFacet(address(diamond)).setApprovalForAll(fakeAddress_, true);
    //     NFTFacet(address(diamond)).setApprovalForAll(fakeAddress2_, true);
    //     NFTFacet(address(diamond)).setApprovalForAll(address(diamond), true);

    //     NFTFacet(address(diamond)).approve(fakeAddress_, tokenId);
    //     NFTFacet(address(diamond)).transferFrom(to, fakeAddress_, tokenId);
    // }

    // function testTransfer() public {
    //     vm.startPrank(address(0x1111));
    //     tokenF(address(diamond)).mint(address);
    // }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
