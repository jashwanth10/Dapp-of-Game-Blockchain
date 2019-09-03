pragma solidity >=0.4.0 <0.7.0;

contract TTT{
    
    mapping (uint => string) public board;
    
    function checkString(string a, string b) private pure returns (bool) {
        if(bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
        }
    }
    
    function check_l2(uint a, uint b, uint c) private view returns (string){
        if(checkString(board[a],board[b]) && checkString(board[b],board[c])){
            return board[a];
        }
    }
    

    
}
