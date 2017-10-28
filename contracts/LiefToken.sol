pragma solidity ^0.4.4;
import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract LiefToken is StandardToken {
    string public name = 'LiefToken';
    string public symbol = 'LF';
    uint public decimals = 2;
    uint public INITIAL_SUPPLY = 12000;
    function LiefToken() {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
}