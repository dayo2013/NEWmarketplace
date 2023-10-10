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
    }

    function testNFTName() public {
        assertEq(NFTFacet(address(diamond)).name(), "MyNFT");
    }

    function testNFTSymbol() public {
        assertEq(NFTFacet(address(diamond)).symbol(), "MNT");
    }

    function testMint() public {
        uint _tokenId = 1;
        address _to = address(0x1111);
        vm.startPrank(_to);
        NFTFacet(address(diamond)).mint(_to, _tokenId);

        assert(NFTFacet(address(diamond)).ownerOf(_tokenId) == _to);
    }

    function testFailMint() public {
        uint _tokenId = 1;
        address _to = address(0x1111);
        address _fakeAddress = address(0x2222);
        vm.prank(_to);
        NFTFacet(address(diamond)).mint(_to, _tokenId);

        assert(NFTFacet(address(diamond)).ownerOf(_tokenId) == _fakeAddress);
    }

    function testBurn() public {
        uint tokenId_ = 1;
        address to_ = address(0x1111);

        vm.prank(to_);
        NFTFacet(address(diamond)).mint(to_, tokenId_);
        NFTFacet(address(diamond)).burn(tokenId_);
    }

    function testOwnerOf() public {
        uint _tokenId = 1;
        address _to = address(0x1111);
        vm.prank(_to);
        NFTFacet(address(diamond)).mint(_to, _tokenId);

        assert(NFTFacet(address(diamond)).ownerOf(_tokenId) == _to);
    }

    function testTransfer() public {
        uint tokenId = 1;
        address to_ = address(0x1111);
        vm.prank(_to);
        NFTFacet(address(diamond)).mint();
    }

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
