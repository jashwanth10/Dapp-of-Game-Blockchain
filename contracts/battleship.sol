pragma solidity >=0.4.0 <0.7.0;


contract BattleShip{
    
    uint256 private number_game;
    
    constructor() public{
        number_game = 0;
    }
    event Player1Joined(address a);
    event Player2Joined(address a);
    event WrongEntry(address a,uint256 gameId);
    event allInputMovesInserted(address a,uint256 gameId);
    event checkInputs(address a,uint256 gameId);
    event inputInserted(address a,uint256 gameId);
    event notYourTurn(address a,uint256 gameId);
    event moveInsertBombHit(address a,uint256 gameId);
    event moveInsert(address a,uint256 gameId);
    event gameCompleted(uint256 gameId);
    //address payable public owner;
    struct Game{
        address player1;
        address player2;
        uint256 statusGame;
        // player1_board_1 for storing his board
        // player1_board_2 for storing opponent board sticks
        uint256[10][10] player1_board_1;
        uint256[10][10] player1_board_2;
        
        // player2_board_1 for storing his board
        // player2_board_2 for storing opponent board sticks
        uint256[10][10] player2_board_1;
        uint256[10][10] player2_board_2;
        
        uint256 insertion_1;
        uint256 insertion_2;
        uint256[5] check_1;
        uint256[5] check_2;
        // 1 -> first player
        // 2 -> second player
        uint256 playerTurn;
        uint256 status;
    }
    mapping(uint256 => Game) private games;
    
    function newGame() public returns(string memory,uint256){
        Game memory game;
        game.player1 = msg.sender;
        number_game++;
        games[number_game] = game;
        games[number_game].playerTurn = 1;
        games[number_game].status=0;
        emit Player1Joined(games[number_game].player1);
        return ("true",number_game);
    }
    function joinGame(uint256 gameId) public returns(string memory){
        if(gameId>number_game){
            emit WrongEntry(msg.sender,gameId);
            return ("false");
        }
        if(games[gameId].player2!=address(0)){
            emit WrongEntry(msg.sender,gameId);
            return "false";
        }
        games[gameId].player2 = msg.sender;
        emit Player2Joined(msg.sender);
        return ("true");
    }
    function insert(uint256 gameId,uint256 x1,uint256 y1,uint256 x2,uint256 y2,uint256 length) public returns(bool)
    {
        if(msg.sender==games[gameId].player1)
        {
            if(games[gameId].insertion_1!=0){
                emit allInputMovesInserted(games[gameId].player1,gameId);
                return false;
            }    
            else
            {
                if(games[gameId].check_1[length-1]!=0){
                    emit checkInputs(games[gameId].player1,gameId);
                    return false;
                }
                else
                {
                    if(x1==x2)
                    {
                        
                        if(y1>y2 && y1-y2==length-1)
                        {
                            for(uint256 i=y2;i<=y1;i++)
                            {
                                if(games[gameId].player1_board_1[x1][i]==1)
                                {
                                    for(uint256 j=i-1;j<=y2;j--)
                                        games[gameId].player1_board_1[x1][j]=0;
                                    emit checkInputs(games[gameId].player1,gameId);
                                    return false;
                                }
                                else
                                    games[gameId].player1_board_1[x1][i]=1;
                            }
                            games[gameId].check_1[length-1]=1;
                        }
                        else if(y2>y1 && y2-y1==length-1)
                        {
                            for(uint256 i=y1;i<=y2;i++)
                            {
                                if(games[gameId].player1_board_1[x1][i]==1)
                                {
                                    for(uint256 j=i-1;j<=y1;j--)
                                        games[gameId].player1_board_1[x1][j]=0;
                                    emit checkInputs(games[gameId].player1,gameId);
                                    return false;
                                }
                                else
                                    games[gameId].player1_board_1[x1][i]=1;
                            }
                            games[gameId].check_1[length-1]=1;
                        }
                        else{
                            emit checkInputs(games[gameId].player1,gameId);
                            return false;
                        }    
                    }
                    else if(y1==y2)
                    {
                        if(x1>x2 && x1-x2==length-1)
                        {
                            for(uint256 i=x2;i<=x1;i++)
                            {
                                if(games[gameId].player1_board_1[i][y1]==1)
                                {
                                    for(uint256 j=i-1;j<=x2;j--)
                                        games[gameId].player1_board_1[j][y1]=0;
                                    emit checkInputs(games[gameId].player1,gameId);
                                    return false;
                                }
                                else
                                    games[gameId].player1_board_1[i][y1]=1;
                            }
                            games[gameId].check_1[length-1]=1;
                        }
                        else if(x2>x1 && x2-x1==length-1)
                        {
                            for(uint256 i=x1;i<=x2;i++)
                            {
                                if(games[gameId].player1_board_1[i][y1]==1)
                                {
                                    for(uint256 j=i-1;j<=x1;j--)
                                        games[gameId].player1_board_1[j][y1]=0;
                                    emit checkInputs(games[gameId].player1,gameId);
                                    return false;
                                }
                                else
                                    games[gameId].player1_board_1[i][y1]=1;
                            }
                            games[gameId].check_1[length-1]=1;
                        }
                        else{
                            emit checkInputs(games[gameId].player1,gameId);
                            return false;
                        }
                            
                    }
                    else{
                        emit checkInputs(games[gameId].player1,gameId);
                        return false;
                    }
                }
            }
            if(games[gameId].check_1[4]==1 && games[gameId].check_1[3]==1 && games[gameId].check_1[2]==1 && games[gameId].check_1[1]==1)
                games[gameId].insertion_1=1;
        }
        else if(msg.sender==games[gameId].player2)
        {
            if(games[gameId].insertion_2!=0){
                emit allInputMovesInserted(games[gameId].player2,gameId);   
                return false;
            }
            else
            {
                if(games[gameId].check_2[length-1]!=0){
                    emit checkInputs(games[gameId].player2,gameId);   
                    return false;
                }
                else
                {
                    if(x1==x2)
                    {
                        
                        if(y1>y2 && y1-y2==length-1)
                        {
                            for(uint256 i=y2;i<=y1;i++)
                            {
                                if(games[gameId].player2_board_1[x1][i]==1)
                                {
                                    for(uint256 j=i-1;j<=y2;j--)
                                        games[gameId].player2_board_1[x1][j]=0;
                                    emit checkInputs(games[gameId].player2,gameId);
                                    return false;
                                }
                                else
                                    games[gameId].player2_board_1[x1][i]=1;
                            }
                            games[gameId].check_2[length-1]=1;
                        }
                        else if(y2>y1 && y2-y1==length-1)
                        {
                            for(uint256 i=y1;i<=y2;i++)
                            {
                                if(games[gameId].player2_board_1[x1][i]==1)
                                {
                                    for(uint256 j=i-1;j<=y1;j--)
                                        games[gameId].player2_board_1[x1][j]=0;
                                    emit checkInputs(games[gameId].player2,gameId);
                                    return false;
                                }
                                else
                                    games[gameId].player2_board_1[x1][i]=1;
                            }
                            games[gameId].check_2[length-1]=1;
                        }
                        else{
                            emit checkInputs(games[gameId].player2,gameId);
                            return false;
                        }
                    }
                    else if(y1==y2)
                    {
                        if(x1>x2 && x1-x2==length-1)
                        {
                            for(uint256 i=x2;i<=x1;i++)
                            {
                                if(games[gameId].player2_board_1[i][y1]==1)
                                {
                                    for(uint256 j=i-1;j<=x2;j--)
                                        games[gameId].player2_board_1[j][y1]=0;
                                    emit checkInputs(games[gameId].player2,gameId);
                                    return false;
                                }
                                else
                                    games[gameId].player2_board_1[i][y1]=1;
                            }
                            games[gameId].check_2[length-1]=1;
                        }
                        else if(x2>x1 && x2-x1==length-1)
                        {
                            for(uint256 i=x1;i<=x2;i++)
                            {
                                if(games[gameId].player2_board_1[i][y1]==1)
                                {
                                    for(uint256 j=i-1;j<=x1;j--)
                                        games[gameId].player2_board_1[j][y1]=0;
                                    emit checkInputs(games[gameId].player2,gameId);
                                    return false;
                                }
                                else
                                    games[gameId].player2_board_1[i][y1]=1;
                            }
                            games[gameId].check_2[length-1]=1;
                        }
                        else{
                            emit checkInputs(games[gameId].player2,gameId);
                            return false;
                        }
                    }
                    else{
                        
                        emit checkInputs(games[gameId].player2,gameId);
                        return false;
                    }
                }
            }
            if(games[gameId].check_2[4]==1 && games[gameId].check_2[3]==1 && games[gameId].check_2[2]==1 && games[gameId].check_2[1]==1)
                games[gameId].insertion_2=1;
            
        }
        emit inputInserted(msg.sender,gameId);
        return true;
    }
    function move(uint256 gameId,uint256 x,uint256 y) public returns (string memory)
    {
        if(games[gameId].status!=0){
            emit gameCompleted(gameId);
            return "game Completed";
        }
        if(games[gameId].playerTurn==1)
        {
            if(msg.sender!=games[gameId].player1){
               emit notYourTurn(msg.sender,gameId); 
               return "its not your turn";
            }
            else
            {
                if(games[gameId].player1_board_2[x][y]==2 || games[gameId].player1_board_2[x][y]==3)
                    return "already inserted";
                if(games[gameId].player2_board_1[x][y]==1){
                    games[gameId].player1_board_2[x][y]=3;
                    games[gameId].player2_board_1[x][y]=3;
                    games[gameId].playerTurn = 2;
                    emit moveInsertBombHit(msg.sender,gameId);
                    return "move is inserted and bomb hit the target";
                }
                else{
                    games[gameId].player1_board_2[x][y]=2;
                    games[gameId].player2_board_1[x][y]=1;
                    games[gameId].playerTurn = 2;        
                    emit  moveInsert(msg.sender,gameId);
                    return "move is inserted but bomb didnt hit the target";
                }
            }
            
        }
        else{
            
            if(games[gameId].player2!=msg.sender){
                emit notYourTurn(msg.sender,gameId);
                return "its not your turn";
            }
            else{
                if(games[gameId].player2_board_2[x][y]==2 || games[gameId].player2_board_2[x][y]==3)
                    return "already inseted";
                if(games[gameId].player1_board_1[x][y]==1)
                {
                    games[gameId].player1_board_1[x][y]=3;
                    games[gameId].player2_board_2[x][y]=3;
                       games[gameId].playerTurn = 1;
                       emit moveInsertBombHit(msg.sender,gameId);
                    return "move is inserted and bomb hit the target";
                }
                else{
                        games[gameId].player1_board_1[x][y]=1;
                        games[gameId].player2_board_2[x][y]=2;
                           games[gameId].playerTurn = 1;
                        emit moveInsert(msg.sender,gameId);
                        return "move is inserted but bomb didnt hit the target";
                }
            }
        }
        
        gameStatus(gameId);
        if(games[gameId].status!=0)
            emit gameCompleted(gameId);
    }
    function returnMyBoard(uint256 gameId) public view returns(uint256[10][10] memory)
    {
        if(msg.sender==games[gameId].player1)
            return games[gameId].player1_board_1;
        else
            return games[gameId].player2_board_1;
    }
    
    function returnOtherBoard(uint256 gameId) public view returns(uint256[10][10] memory)
    {
        if(msg.sender==games[gameId].player1)
            return games[gameId].player1_board_2;
        else
            return games[gameId].player2_board_2;
    }
    
    function gameStatus(uint256 gameId) public returns(string memory){
        if(games[gameId].status==1)
        {
            return "game completed player 1 has won the game";
        }
        if(games[gameId].status==2)
            return "game completed player 2 has won the game";
        uint256 count = 0;
        for(uint256 i=0;i<10;i++)
        {
            for(uint256 j=0;j<10;j++)
            {
                if(games[gameId].player2_board_1[i][j]==1)
                    count++;
            }
        }
        if(count==0)
        {
            games[gameId].status = 1;
            return "game completed player 1 has won the game";
        }
        count = 0;
        for(uint256 i=0;i<10;i++)
        {
            for(uint256 j=0;j<10;j++)
            {
                if(games[gameId].player1_board_1[i][j]==1)
                    count++;
            }
        }
        if(count==0)
        {
            games[gameId].status = 2;
            return "game completed player 2 has won the game";
        }
        return "false";
    }
}