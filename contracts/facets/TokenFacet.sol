// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IERC20} from "../interfaces/IERC20.sol";

contract TokenFacet is IERC20 {
    uint256 private constant MAX_UINT256 = 2 ** 256 - 1;
    // mapping(address => uint256) public balances;
    // mapping(address => mapping(address => uint256)) public allowed;
    // uint256 public totalSupply;

    // string public name;
    // string public symbol;
    uint8 public decimals;

    address owner_ = LibDiamond.contractOwner();

    constructor(
        // uint256 _initialAmount,
        // string memory _tokenName,
        // string memory _tokenSymbol,
        uint8 _decimalUnits
    ) {
        // balances[owner_] = _initialAmount;
        // totalSupply = _initialAmount;
        // name = _tokenName;
        // symbol = _tokenSymbol;
        decimals = _decimalUnits;
    }

    function name() public view virtual returns (string memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.name;
    }

    function mint(
        address account,
        uint256 amount
    ) public view returns (string memory) {}

    function balanceOf() public view virtual returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.balances[owner_];
    }

    function transfer(
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(
            ds.balances[owner_] >= _value,
            "token balance is lower than the value requested"
        );
        ds.balances[owner_] -= _value;
        ds.balances[_to] += _value;
        emit Transfer(owner_, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        uint256 _allowance = ds.allowed[_from][owner_];
        require(
            ds.balances[_from] >= _value && _allowance >= _value,
            "token balance or _allowance is lower than amount requested"
        );
        ds.balances[_to] += _value;
        ds.balances[_from] -= _value;
        if (_allowance < MAX_UINT256) {
            ds.allowed[_from][owner_] -= _value;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(
        address _owner
    ) public view override returns (uint256 balance) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.balances[_owner];
    }

    function approve(
        address _spender,
        uint256 _value
    ) public override returns (bool success) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.allowed[owner_][_spender] = _value;
        emit Approval(owner_, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) public view override returns (uint256 remaining) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.allowed[_owner][_spender];
    }
}
