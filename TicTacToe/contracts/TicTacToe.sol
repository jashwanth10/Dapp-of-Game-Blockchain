pragma solidity >=0.4.0 <0.7.0;

contract TicTacToe{
    uint256 num;
    uint256[4] public accBets;
    address payable public owner;
    
    struct Game {
        address payable player1;
        address payable player2;
        uint[3][3] board;
        uint whichPlayerTurn;
        uint[3] winner;
        uint ngames;
        uint256 stake;
        bool active;
        bool isRandom;
        uint256 currt; 
    }
    mapping(uint256 => Game) public game;
    
    constructor() public{
        owner = msg.sender;
        num = 0;
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
                g.board[i][j] = 0;
            }
        }
        g.whichPlayerTurn = 1;
        g.ngames = 1;
        g.active = true;
        
        g.stake = stake;
        if(randomPlayer == 0){
            g.isRandom = false;
        }else{
            g.player2 = owner;
            g.isRandom = true;
        }
        game[num] = g;
        game[num].currt = now;
        return num;
    }
    
    function getBoard(uint256 gameId) public view returns (uint[3] memory, uint[3] memory, uint[3] memory) {
        return (game[gameId].board[0],game[gameId].board[1], game[gameId].board[2]);
    }
    
    function getWinner(uint256 gameId) public view returns (uint[3] memory) {
        return game[gameId].winner;
    }
    
    function claimTimeout(uint256 gameId) public {
        require(msg.sender == game[gameId].player1 || msg.sender == game[gameId].player2);
        require(!isValid(msg.sender, gameId));
        require(now >= game[gameId].currt + 2);
        game[gameId].active = false;
        address(msg.sender).transfer(game[gameId].stake);
    }
    
    function joinGame(uint256 gameId, uint256 stake) public payable{
        require(game[gameId].active);
        require(game[gameId].player1 != msg.sender);
        require(game[gameId].isRandom == false);
        require(stake == msg.value);
        require(stake == game[gameId].stake);
        game[gameId].stake += stake;
        game[gameId].player2 = msg.sender;
    }

    function makeMove(uint256 gameId, uint i, uint j) public{
        require(game[gameId].active);
        require(i>=0 && i<=2 && j>=0 && j<=2);
        if(game[gameId].isRandom == false){
            require(
                isValid(msg.sender, gameId),
                "Not your move"
            );
            if(msg.sender == game[gameId].player1){
                require(game[gameId].board[i][j] == 0);
                game[gameId].board[i][j] = 1;
                game[gameId].whichPlayerTurn = 2;
            }else{
                require(game[gameId].board[i][j] == 0);
                game[gameId].board[i][j] = 2;
                game[gameId].whichPlayerTurn = 1;
            }
        }else{
            if(game[gameId].player2 == owner && game[gameId].whichPlayerTurn == 1){
                require(game[gameId].board[i][j] == 0);
                game[gameId].board[i][j] = 1;
                game[gameId].whichPlayerTurn = 2;
            }else if(game[gameId].player2 == owner && game[gameId].whichPlayerTurn == 2){
                require(game[gameId].board[i][j] == 0);
                game[gameId].board[i][j] = 2;
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
            makeRandomMove(gameId);
        }
    }

    function makeRandomMove(uint256 gameId) private {
        uint x;
        uint y;
        for(uint ii=0;ii<3;ii++){
            for(uint jj=0;jj<3;jj++){
                if(game[gameId].board[ii][jj] == 0){
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
    
    function checkWinner(uint256 gameId) private view returns (address , bool){
        require(game[gameId].active);
        Game memory g = game[gameId];
        for(uint i=0;i<3;i++){
            if(g.board[i][0] == g.board[i][1] && g.board[i][0] == g.board[i][2] && g.board[i][0] == 1){
                return (g.player1, true);            
            }
            if(g.board[i][0] == g.board[i][1] && g.board[i][0] == g.board[i][2] && g.board[i][0] == 2){
                return (g.player2, true);            
            }
        }
        for(uint i=0;i<3;i++){
            if(g.board[0][i] == g.board[1][i] && g.board[1][i] == g.board[2][i] && g.board[0][i] == 1){
                return (g.player1, true);            
            }
            if(g.board[0][i] == g.board[1][i] && g.board[0][i] == g.board[2][i] && g.board[0][i] == 2){
                return (g.player2, true);            
            }
        }

        if(g.board[0][0] == g.board[1][1] && g.board[1][1] == g.board[2][2] && g.board[0][0] == 1){
            return (g.player1, true);    
        }else if(g.board[0][0] == g.board[1][1] && g.board[1][1] == g.board[2][2] && g.board[0][0] == 2){
            return (g.player2, true); 
        }else if(g.board[0][2] == g.board[1][1] && g.board[1][1] == g.board[2][0] && g.board[0][0] == 1){
            return(g.player1, true);
        }else if(g.board[0][2] == g.board[1][1] && g.board[1][1] == g.board[2][0] && g.board[0][0] == 2){
            return(g.player2, true);
        }

        for(uint i=0;i<3;i++){
            for(uint j=0;j<3;j++){
                if(g.board[i][j] == 0){
                    return (address(0), false);
                }
            }
        }
        return (address(0), true);
    }
    
    function restartGame(uint256 gameId) private{
        require(game[gameId].active);
        if(game[gameId].ngames >= 4){
            if(game[gameId].winner[1] > game[gameId].winner[2]){
                address(game[gameId].player1).transfer(game[gameId].stake);
            }else if(game[gameId].winner[1] < game[gameId].winner[2]){
                address(game[gameId].player2).transfer(game[gameId].stake);
            }else{
                address(owner).transfer(game[gameId].stake);
            }
            game[gameId].active = false;
            return;
        }
        if(game[gameId].ngames >= 2){
            for(uint i=0;i<3;i++){
                for(uint j=0;j<3;j++){
                    game[gameId].board[i][j] = 0;
                }
            }
            game[gameId].ngames++;
            game[gameId].whichPlayerTurn = 2;
            if(game[gameId].isRandom){
                makeRandomMove(gameId);
            }
        }else if(game[gameId].ngames < 2){
            for(uint i=0;i<3;i++){
                for(uint j=0;j<3;j++){
                    game[gameId].board[i][j] = 0;
                }
            }
            game[gameId].ngames++;
            game[gameId].whichPlayerTurn = 1;
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
