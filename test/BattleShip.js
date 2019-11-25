const Battle = artifacts.require("./BattleShip.sol");



contract('BattleShip',function(accounts){

    let instance;
    let test = accounts[3];
    const ERROR_MSG = 'VM Exception while processing transaction: revert'; 
    before(async() =>{
        instance = await Battle.deployed();
    });
    


    /// Second Person Tests
    it("2nd Person enters valid Game Id",async () =>{
        instance = await Battle.deployed();    
        let test2 = accounts[2];
        let id = await instance.newGame.call({from : test});
        // console.log(id);
        await instance.newGame({from:test});
        // console.log(test2);
        // console.log(id);

        await instance.joinGame(id,{from:test2});

        games = await instance.games.call(id);

        assert.equal(games.player2,test2,ERROR_MSG);

    });


    it("2nd Person enters invalid Game Id",async() =>{
        instance = await Battle.deployed();
        let test2 = accounts[2];
        //console.log(test2);
        let err = null;
        let id = await instance.newGame.call({from:test});
        //console.log(id);
        await instance.newGame({from:test});
        try {
        //    console.log("sw");
            await instance.joinGame(100,{from:test2});
          //  console.log("swscdcd");
            
        } catch(error) {
            err = error;
            //console.log("lanjaaa");
        }
        //console.log(err);
        assert.ok(err instanceof Error,ERROR_MSG);    
    });
    

    it("if 3rd person tries to enter the Game",async() =>{
        instance = await Battle.deployed();
        let test2 = accounts[2];
        let err = null;
        let test3 = accounts[1];
        let id = await instance.newGame.call({from:test});
        //console.log(id);
        await instance.newGame({from:test});
        await instance.joinGame(id,{from:test2});
        try{

            await instance.joinGame(id,{from:test3});
        }catch(error){
            err = error;
        }

        assert.ok(err instanceof Error,ERROR_MSG);
    });



    /// Insert Move Tests

    it("If person tries to enter ship of length more than 5",async() => {
        instance = await Battle.deployed();
        let test2 = accounts[2];
        let err = null;
        let id = await instance.newGame.call({from:test});
        await instance.newGame({from:test});
        await instance.joinGame(id,{from:test2});
        //console.log("lanjaaa");
        try{
            await instance.insert(id,0,0,6,6,10,{from:test});
        }catch(error){
          //  console.log("lanjaaa");
            err = error;
        }
        //console.log(err);
        assert.ok(err instanceof Error,ERROR_MSG);
    });


    it("If input and length are not matching",async() => {
        instance = await Battle.deployed();
        let test2 = accounts[2];
        let err = null;
        let id = await instance.newGame.call({from:test});
        await instance.newGame({from:test});
        await instance.joinGame(id,{from:test2});
        try{
            await instance.insert(id,0,5,0,3,1,{from:test});
        }catch(error){
            err = error;
        }
        assert.ok(err instanceof Error,ERROR_MSG);
    });

    it("If he tries to insert in the same place before", async()=>{
        instance = await Battle.deployed();
        let test2 = accounts[2];
        let err = null;
        let id = await instance.newGame.call({from:test});
        await instance.newGame({from:test});
        await instance.joinGame(id,{from:test2});
        await instance.insert(id,0,4,0,2,3,{from:test});
        try{
            await instance.insert(id,0,3,0,2,2,{from:test});
        }catch(error){
            err = error;
        }
        assert.ok(err instanceof Error,ERROR_MSG);
    });

    it("Coordinates specified by user is not on the board",async()=>{
        instance = await Battle.deployed();
        let test2 = accounts[2];
        let err = null;
        let id = await instance.newGame.call({from:test});
        await instance.newGame({from:test});
        await instance.joinGame(id,{from:test2});
        await instance.insert(id,0,4,0,2,3,{from:test});
        try{
            await instance.insert(id,-1,1,4,3,{from:test2});
        }catch(error){
            err = error;
        }
        assert.ok(err instanceof Error,ERROR_MSG);
    });

    it("Tries to insert ships having same length",async()=>{
        instance = await Battle.deployed();
        let test2 = accounts[2];
        let err = null;
        let id = await instance.newGame.call({from:test});
        await instance.newGame({from:test});
        await instance.joinGame(id,{from:test2});
        games = await instance.games.call(id);
       // console.log(games.a);
        await instance.insert(id,0,2,0,4,3,{from:test});
        await instance.insert(id,0,2,0,4,3,{from:test2});
        //console.log(games.a);
        
        try{
            await instance.insert(id,1,2,1,4,3,{from:test2});
        }catch(error){
            err = error;
        }
      //  console.log(err);
        assert.ok(err instanceof Error,ERROR_MSG);
    });

    it("if all insertions are completed but trying to insert again",async()=>{
        instance = await Battle.deployed();
        let test2 = accounts[2];
        let err = null;
        let id = await instance.newGame.call({from:test});
        await instance.newGame({from:test});
        await instance.joinGame(id,{from:test2});
        await instance.insert(id,0,1,0,2,2,{from:test});
        await instance.insert(id,1,1,1,3,3,{from:test});
        await instance.insert(id,2,1,2,4,4,{from:test});
        await instance.insert(id,3,1,3,5,5,{from:test});

        try{
            await instance.insert(id,4,1,4,5,5,{from:test});
        }catch(error){
            err = error;
        }
        assert.ok(err instanceof Error,ERROR_MSG);
    })



    // after insertion making move


    it("Makes an invalid entry",async()=>{
        instance = await Battle.deployed();
        let test2 = accounts[2];
        let err = null;
        let id = await instance.newGame.call({from:test});
        await instance.newGame({from:test});
        await instance.joinGame(id,{from:test2});
        await instance.insert(id,0,1,0,2,2,{from:test});
        await instance.insert(id,1,1,1,3,3,{from:test});
        await instance.insert(id,2,1,2,4,4,{from:test});
        await instance.insert(id,3,1,3,5,5,{from:test});

        //insertion for player2
        await instance.insert(id,1,1,1,2,2,{from:test2});
        await instance.insert(id,2,1,2,3,3,{from:test2});
        await instance.insert(id,3,1,3,4,4,{from:test2});
        await instance.insert(id,4,1,4,5,5,{from:test2});


        try{
            await instance.move(id,11,0,{from:test});
        }catch(error){
            err = error;
        }

        assert.ok(err instanceof Error,ERROR_MSG);
    });


    it("Player1 playing Player2 turn",async()=>{
        instance = await Battle.deployed();
        let test2 = accounts[2];
        
        //insertion for player 1
        let err = null;
        let id = await instance.newGame.call({from:test});
        await instance.newGame({from:test});
        await instance.joinGame(id,{from:test2});
        await instance.insert(id,0,1,0,2,2,{from:test});
        await instance.insert(id,1,1,1,3,3,{from:test});
        await instance.insert(id,2,1,2,4,4,{from:test});
        await instance.insert(id,3,1,3,5,5,{from:test});

        //insertion for player2
        await instance.insert(id,1,1,1,2,2,{from:test2});
        await instance.insert(id,2,1,2,3,3,{from:test2});
        await instance.insert(id,3,1,3,4,4,{from:test2});
        await instance.insert(id,4,1,4,5,5,{from:test2});

        await instance.move(id,1,1,{from:test});

        try{
            await instance.move(id,2,3,{from:test});
        }catch(error){
            err = error;
        }

        assert.ok(err instanceof Error,ERROR_MSG);

    });


    it("player trying to hit where bomb is already hit",async()=>{
        instance = await Battle.deployed();
        let test2 = accounts[2];
        
        //insertion for player 1
        let err = null;
        let id = await instance.newGame.call({from:test});
        await instance.newGame({from:test});
        await instance.joinGame(id,{from:test2});
        await instance.insert(id,0,1,0,2,2,{from:test});
        await instance.insert(id,1,1,1,3,3,{from:test});
        await instance.insert(id,2,1,2,4,4,{from:test});
        await instance.insert(id,3,1,3,5,5,{from:test});

        //insertion for player2
        await instance.insert(id,1,1,1,2,2,{from:test2});
        await instance.insert(id,2,1,2,3,3,{from:test2});
        await instance.insert(id,3,1,3,4,4,{from:test2});
        await instance.insert(id,4,1,4,5,5,{from:test2});

        await instance.move(id,1,1,{from:test});
        await instance.move(id,1,1,{from:test2});

        try{
            await instance.move(id,1,1,{from:test});
        }catch(error){
            err = error;
        }

        assert.ok(err instanceof Error,ERROR_MSG);

    });


    it("if some 3rd party tries to make a move",async()=>{
        instance = await Battle.deployed();
        let test2 = accounts[2];
        
        //insertion for player 1
        let err = null;
        let id = await instance.newGame.call({from:test});
        await instance.newGame({from:test});
        await instance.joinGame(id,{from:test2});
        await instance.insert(id,0,1,0,2,2,{from:test});
        await instance.insert(id,1,1,1,3,3,{from:test});
        await instance.insert(id,2,1,2,4,4,{from:test});
        await instance.insert(id,3,1,3,5,5,{from:test});

        //insertion for player2
        await instance.insert(id,1,1,1,2,2,{from:test2});
        await instance.insert(id,2,1,2,3,3,{from:test2});
        await instance.insert(id,3,1,3,4,4,{from:test2});
        await instance.insert(id,4,1,4,5,5,{from:test2});

        await instance.move(id,1,1,{from:test});
        await instance.move(id,1,1,{from:test2});
        await instance.move(id,2,2,{from:test});
        //games = await instance.games.call(id);
        
        //console.log(games.playerTurn);
        try{
            await instance.move(id,1,2,{from:accounts[1]});
        }catch(error){
            err = error;
        }
        //games = await instance.games.call(id);
        
        //console.log(games.playerTurn);
        

    assert.ok(err instanceof Error,ERROR_MSG);

    });



 


    // Player1 Wins

    it("CHecking player2 tries to make a move after player1 won the round",async()=>{

        instance = await Battle.deployed();
        let test2 = accounts[2];
        
        //insertion for player 1
        let err = null;
        let id = await instance.newGame.call({from:test});
        await instance.newGame({from:test});
        await instance.joinGame(id,{from:test2});
        await instance.insert(id,0,1,0,2,2,{from:test});
        await instance.insert(id,1,1,1,3,3,{from:test});
        await instance.insert(id,2,1,2,4,4,{from:test});
        await instance.insert(id,3,1,3,5,5,{from:test});

        //insertion for player2
        await instance.insert(id,1,1,1,2,2,{from:test2});
        await instance.insert(id,2,1,2,3,3,{from:test2});
        await instance.insert(id,3,1,3,4,4,{from:test2});
        await instance.insert(id,4,1,4,5,5,{from:test2});


        await instance.move(id,1,1,{from:test});
        await instance.move(id,0,1,{from:test2});
        await instance.move(id,1,2,{from:test});
        await instance.move(id,0,2,{from:test2});

        await instance.move(id,2,1,{from:test});
        await instance.move(id,1,1,{from:test2});
        await instance.move(id,2,2,{from:test});
        await instance.move(id,1,2,{from:test2});
        await instance.move(id,2,3,{from:test});
        await instance.move(id,1,3,{from:test2});

        await instance.move(id,3,1,{from:test});
        await instance.move(id,2,1,{from:test2});
        await instance.move(id,3,2,{from:test});
        await instance.move(id,2,2,{from:test2});
        await instance.move(id,3,3,{from:test});
        await instance.move(id,2,3,{from:test2});
        await instance.move(id,3,4,{from:test});
        await instance.move(id,2,4,{from:test2});

        await instance.move(id,4,1,{from:test});
        await instance.move(id,3,1,{from:test2});
        await instance.move(id,4,2,{from:test});
        await instance.move(id,3,2,{from:test2});
        await instance.move(id,4,3,{from:test});
        await instance.move(id,3,3,{from:test2});
        await instance.move(id,4,4,{from:test});
        await instance.move(id,3,4,{from:test2});
        await instance.move(id,4,5,{from:test});

         //games = await instance.games.call(id);
        // let a = await instance.returnMyBoard.call(id,{from:test});
        
        // await instance.returnMyBoard(id,{from:test})
         //console.log(games.status);
        // console.log(a);

        // await instance.move(id,6,6,{from:test2});

        // console.log(games.status);

        try{
            await instance.move(id,3,5,{from:test2});
        }catch(error){
            err= error;
        };

        //games = await instance.games.call(id);
        //console.log(games.status);
       
        assert.ok(err instanceof Error,ERROR_MSG);

    });


    it("checking whether player1 has won or not",async()=>{

        instance = await Battle.deployed();
        let test2 = accounts[2];
        
        //insertion for player 1
        let err = null;
        let id = await instance.newGame.call({from:test});
        await instance.newGame({from:test});
        await instance.joinGame(id,{from:test2});
        await instance.insert(id,0,1,0,2,2,{from:test});
        await instance.insert(id,1,1,1,3,3,{from:test});
        await instance.insert(id,2,1,2,4,4,{from:test});
        await instance.insert(id,3,1,3,5,5,{from:test});

        //insertion for player2
        await instance.insert(id,1,1,1,2,2,{from:test2});
        await instance.insert(id,2,1,2,3,3,{from:test2});
        await instance.insert(id,3,1,3,4,4,{from:test2});
        await instance.insert(id,4,1,4,5,5,{from:test2});


        await instance.move(id,1,1,{from:test});
        await instance.move(id,0,1,{from:test2});
        await instance.move(id,1,2,{from:test});
        await instance.move(id,0,2,{from:test2});

        await instance.move(id,2,1,{from:test});
        await instance.move(id,1,1,{from:test2});
        await instance.move(id,2,2,{from:test});
        await instance.move(id,1,2,{from:test2});
        await instance.move(id,2,3,{from:test});
        await instance.move(id,1,3,{from:test2});

        await instance.move(id,3,1,{from:test});
        await instance.move(id,2,1,{from:test2});
        await instance.move(id,3,2,{from:test});
        await instance.move(id,2,2,{from:test2});
        await instance.move(id,3,3,{from:test});
        await instance.move(id,2,3,{from:test2});
        await instance.move(id,3,4,{from:test});
        await instance.move(id,2,4,{from:test2});

        await instance.move(id,4,1,{from:test});
        await instance.move(id,3,1,{from:test2});
        await instance.move(id,4,2,{from:test});
        await instance.move(id,3,2,{from:test2});
        await instance.move(id,4,3,{from:test});
        await instance.move(id,3,3,{from:test2});
        await instance.move(id,4,4,{from:test});
        await instance.move(id,3,4,{from:test2});
        await instance.move(id,4,5,{from:test});


        games = await instance.games.call(id);

        assert.equal(1,games.status,ERROR_MSG);


    });

    it("checking whether player2 has won or not",async()=>{

        instance = await Battle.deployed();
        let test2 = accounts[2];
        
        //insertion for player 1
        let err = null;
        let id = await instance.newGame.call({from:test});
        await instance.newGame({from:test});
        await instance.joinGame(id,{from:test2});
        await instance.insert(id,0,1,0,2,2,{from:test});
        await instance.insert(id,1,1,1,3,3,{from:test});
        await instance.insert(id,2,1,2,4,4,{from:test});
        await instance.insert(id,3,1,3,5,5,{from:test});

        //insertion for player2
        await instance.insert(id,1,1,1,2,2,{from:test2});
        await instance.insert(id,2,1,2,3,3,{from:test2});
        await instance.insert(id,3,1,3,4,4,{from:test2});
        await instance.insert(id,4,1,4,5,5,{from:test2});


    })

});