pragma solidity >=0.4.0 <0.7.0;

contract TicTacToe{
    uint256 num;
    enum Symbol{None, play1, play2}
    uint256[4] public accBets;
    address payable public owner;
    address payable this;
    uint public test;
    address public addtest;
    
    struct Game {
        address payable player1;
        address payable player2;
        Symbol[3][3] board;
        uint whichPlayerTurn;
        uint[3] winner;
        uint ngames;
        uint256 stake;
        bool active;
        bool isRandom;
    }
    mapping(uint256 => Game) game;
    
    constructor() public{
        owner = msg.sender;
        num = 0;
        test = 0;
        for(uint i=0;i<4;i++){
            accBets[i] = 25*(i+1);
        }
    }
    function random() private view returns (uint) {
       return uint(uint256(keccak256(abi.encodePacked(block.timestamp)))%251);
    }
    
    function createGame(uint256 stake, uint randomPlayer) public payable returns (uint256){
        require(randomPlayer <= 1 && randomPlayer >= 0);
        require(stake == msg.value);
        bool allow = false;
        for(uint i=0;i<4;i++){
            allow = allow || (accBets[i] == stake);
        }
        require(allow);
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
        if(randomPlayer == 0){
            g.isRandom = false;
        }else{
            g.player2 = address(this);
            g.isRandom = true;
        }
        game[num] = g;
        return num;
    }
    
    function getBoard(uint256 gameId) public view returns (Symbol[3][3] memory) {
        return game[gameId].board;
    }
    
    
    function joinGame(uint256 gameId, uint256 stake) public payable{
        require(game[gameId].active);
        require(stake == msg.value);
        require(stake == game[gameId].stake);
        game[gameId].stake += stake;
        game[gameId].player2 = msg.sender;
    }
    
    function gettest() public view returns (uint) {
        return test;
    }
    
    function getaddtest() public view returns (address) {
        return addtest;
    }
    function makeMove(uint256 gameId, uint i, uint j) public{
        require(game[gameId].active);
        if(game[gameId].isRandom == false){
            require(
                isValid(msg.sender, gameId),
                "Not your move"
            );
            if(msg.sender == game[gameId].player1){
                game[gameId].board[i][j] = Symbol.play1;
                game[gameId].whichPlayerTurn = 2;
            }else{
                game[gameId].board[i][j] = Symbol.play2;
                game[gameId].whichPlayerTurn = 1;
            }
        }else{
            if(game[gameId].player2 == address(this) && game[gameId].whichPlayerTurn == 1){
                game[gameId].board[i][j] = Symbol.play1;
                game[gameId].whichPlayerTurn = 2;
            }else if(game[gameId].player2 == address(this) && game[gameId].whichPlayerTurn == 2){
                game[gameId].board[i][j] = Symbol.play2;
                game[gameId].whichPlayerTurn = 1;
            }
        }
        address retadd;bool retbool;
        (retadd, retbool) = checkWinner(gameId); 
        //Handling after game finishes or not
        if(retadd == game[gameId].player1 && retbool == true){
            game[gameId].winner[1]++;
            restartGame(gameId);
            return;
        }else if(retadd == game[gameId].player2 && retbool == true){
            game[gameId].winner[2]++;
            restartGame(gameId);
            return;
        }else if(retadd == address(0) && retbool == true){
            restartGame(gameId);
            return;
        }
        //Random Player 
         if(game[gameId].isRandom && game[gameId].whichPlayerTurn == 2){
            uint x;
            uint y;
            for(uint ii=0;ii<3;ii++){
                for(uint jj=0;jj<3;jj++){
                    if(game[gameId].board[ii][jj] == Symbol.None){
                        x=ii;y=jj;
                        if(random()%2 == 1){
                            makeMove(gameId,ii, jj);
                            return;
                        }
                    }
                }
            }
            makeMove(gameId, x, y);
            return;
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
        }else if(game[gameId].ngames < 2){
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
                address(game[gameId].player1).transfer(game[gameId].stake);
            }else if(game[gameId].winner[1] < game[gameId].winner[2]){
                address(game[gameId].player2).transfer(game[gameId].stake);
            }else{
                address(owner).transfer(game[gameId].stake);
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
