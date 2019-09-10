pragma solidity >=0.4.0 <0.7.0;
import './coin.sol';

contract TTT{
    
    Coin bank;
    uint256 num;
    enum Symbol{None, play1, play2}
    
    struct Game {
        address player1;
        address player2;
        Symbol[3][3] board;
        uint whichPlayerTurn;
        uint[] winner;
    }
    
    mapping(uint256 => Game) game;
    
    constructor(address _t) public{
        bank = Coin(_t);
    }
    
    function createGame() public returns (uint256){
        Game memory g;
        num++;
        g.player1 = msg.sender;
        for(uint i=1;i<=2;i++){
            g.winner[i] = 0;
        }
        g.whichPlayerTurn = 1;
        game[num] = g;
        return num;
    }
    
    function joinGame(uint256 gameId) public{
        game[gameId].player2 = msg.sender;
    }
    
    function makeMove(uint256 gameId, uint i, uint j) private{
        require(
            isValid(msg.sender, gameId),
            "Not your move"
        );
        if(msg.sender == game[gameId].player1){
            game[gameId].board[i][j] = Symbol.play1;
        }else{
            game[gameId].board[i][j] = Symbol.play2;
        }
        if(checkWinner(gameId) == game[gameId].player1){
            game[gameId].winner[1]++;
            restartGame();
        }else if(checkWinner(gameId) == game[gameId].player2){
            game[gameId].winner[2]++;
            restartGame();
        }
    }
    
    function checkWinner(uint256 gameId) private view returns (address){
        Game memory g = game[gameId];
        for(uint i=0;i<3;i++){
            if(g.board[i][0] == g.board[i][1] && g.board[i][0] == g.board[i][2] && g.board[i][0] == Symbol.play1){
                return g.player1;            
            }
            if(g.board[i][0] == g.board[i][1] && g.board[i][0] == g.board[i][2] && g.board[i][0] == Symbol.play2){
                return g.player2;            
            }
        }
        for(uint i=0;i<3;i++){
            if(g.board[0][i] == g.board[1][i] && g.board[1][i] == g.board[2][i] && g.board[0][i] == Symbol.play1){
                return g.player1;            
            }
            if(g.board[0][i] == g.board[1][i] && g.board[0][i] == g.board[2][i] && g.board[0][i] == Symbol.play2){
                return g.player2;            
            }
        }
    }
    
    function restartGame() private{
        
    }
    
    function isValid(address ad, uint256 gameId) private view returns (bool){
        if(ad == game[gameId].player1 && game[gameId].whichPlayerTurn == 1){
            return true;
        }
        if(ad == game[gameId].player2 && game[gameId].whichPlayerTurn == 2){
            return true;
        }
        return false;
    }
    
    
    
    

    
}
