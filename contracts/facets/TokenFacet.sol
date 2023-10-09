// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IERC20} from "../interfaces/IERC20.sol";

contract TokenFacet is IERC20 {
    uint256 private constant MAX_UINT256 = 2 ** 256 - 1;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    uint256 public totalSupply;

    string public name;
    uint8 public decimals;
    string public symbol;

    address owner_ = LibDiamond.contractOwner();

    constructor(
        uint256 _initialAmount,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol
    ) {
        balances[owner_] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
    }

    function transfer(
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        require(
            balances[owner_] >= _value,
            "token balance is lower than the value requested"
        );
        balances[owner_] -= _value;
        balances[_to] += _value;
        emit Transfer(owner_, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        uint256 allowance = allowed[_from][owner_];
        require(
            balances[_from] >= _value && allowance >= _value,
            "token balance or allowance is lower than amount requested"
        );
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][owner_] -= _value;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(
        address _owner
    ) public view override returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(
        address _spender,
        uint256 _value
    ) public override returns (bool success) {
        allowed[owner_][_spender] = _value;
        emit Approval(owner_, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) public view override returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}
