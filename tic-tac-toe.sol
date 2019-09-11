pragma solidity >=0.4.0 <0.7.0;
import './coin.sol';

contract TTT{
    
    Coin bank;
    uint256 num;
    enum Symbol{None, play1, play2}
    address public owner;
    
    struct Game {
        address player1;
        address player2;
        Symbol[3][3] board;
        uint whichPlayerTurn;
        uint[] winner;
        uint ngames;
        uint256 stake;
        bool active;
    }
    
    mapping(uint256 => Game) game;
    
    constructor(address _t) public{
        bank = Coin(_t);
        owner = msg.sender;
    }
    
    function createGame(uint256 stake) public returns (uint256){
        Game memory g;
        num++;
        g.player1 = msg.sender;
        for(uint i=1;i<=2;i++){
            g.winner[i] = 0;
        }
        for(uint i=0;i<3;i++){
            for(uint j=0;j<3;j++){
                g.board[i][j] = Symbol.None;
            }
        }
        g.whichPlayerTurn = 1;
        g.ngames = 0;
        g.active = true;
        g.stake = stake;
        bank.send(msg.sender, owner, stake);
        game[num] = g;
        return num;
    }
    
    function joinGame(uint256 gameId, uint256 stake) public{
        require(game[gameId].active);
        game[gameId].stake == stake;
        bank.send(msg.sender, owner, stake);
        game[gameId].player2 = msg.sender;
    }
    
    function makeMove(uint256 gameId, uint i, uint j) public{
        require(game[gameId].active);
        require(
            isValid(msg.sender, gameId),
            "Not your move"
        );
        if(msg.sender == game[gameId].player1){
            game[gameId].board[i][j] = Symbol.play1;
        }else{
            game[gameId].board[i][j] = Symbol.play2;
        }
        address retadd;bool retbool;
        (retadd, retbool) = checkWinner(gameId); 
        if(retadd == game[gameId].player1 && retbool == true){
            game[gameId].winner[1]++;
            restartGame(gameId);
        }else if(retadd == game[gameId].player2 && retbool == true){
            game[gameId].winner[2]++;
            restartGame(gameId);
        }else if(retadd == address(0) && retbool == true){
            restartGame(gameId);
        }
    }
    
    function checkWinner(uint256 gameId) private view returns (address , bool){
        require(game[gameId].active);
        Game memory g = game[gameId];
        for(uint i=0;i<3;i++){
            if(g.board[i][0] == g.board[i][1] && g.board[i][0] == g.board[i][2] && g.board[i][0] == Symbol.play1){
                return (g.player1, true);            
            }
            if(g.board[i][0] == g.board[i][1] && g.board[i][0] == g.board[i][2] && g.board[i][0] == Symbol.play2){
                return (g.player2, true);            
            }
        }
        for(uint i=0;i<3;i++){
            if(g.board[0][i] == g.board[1][i] && g.board[1][i] == g.board[2][i] && g.board[0][i] == Symbol.play1){
                return (g.player1, true);            
            }
            if(g.board[0][i] == g.board[1][i] && g.board[0][i] == g.board[2][i] && g.board[0][i] == Symbol.play2){
                return (g.player2, true);            
            }
        }
        for(uint i=0;i<3;i++){
            for(uint j=0;j<3;j++){
                if(g.board[i][j] == Symbol.None){
                    return (address(0), false);
                }
            }
        }
        return (address(0), true);
    }
    
    function restartGame(uint256 gameId) private{
        require(game[gameId].active);
        if(game[gameId].ngames > 2){
            for(uint i=0;i<3;i++){
                for(uint j=0;j<3;j++){
                    game[gameId].board[i][j] = Symbol.None;
                }
            }
            game[gameId].ngames++;
            game[gameId].whichPlayerTurn = 2;
        }else if(game[gameId].ngames > 2){
            for(uint i=0;i<3;i++){
                for(uint j=0;j<3;j++){
                    game[gameId].board[i][j] = Symbol.None;
                }
            }
            game[gameId].ngames++;
            game[gameId].whichPlayerTurn = 1;
        }
        if(game[gameId].ngames >= 4){
            if(game[gameId].winner[1] > game[gameId].winner[2]){
                bank.send(owner, game[gameId].player1, game[gameId].stake);
            }else if(game[gameId].winner[1] < game[gameId].winner[2]){
                bank.send(owner, game[gameId].player2, game[gameId].stake);
            }
        }
    }
    
    function isValid(address ad, uint256 gameId) private view returns (bool){
        require(game[gameId].active);
        if(ad == game[gameId].player1 && game[gameId].whichPlayerTurn == 1){
            return true;
        }
        if(ad == game[gameId].player2 && game[gameId].whichPlayerTurn == 2){
            return true;
        }
        return false;
    }
    
    
    
    

    
}
