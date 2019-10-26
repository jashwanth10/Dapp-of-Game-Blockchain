pragma solidity >=0.4.0 <0.7.0;

contract Basic{
    uint x;
    function get() public view returns (uint) {
        return x;
    }
    function set(uint val) public{
        x = val;
    }
}