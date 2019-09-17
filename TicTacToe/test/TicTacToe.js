const Tic = artifacts.require("./TicTacToe.sol");

contract('TicTacToe', function(accounts) {
    let instance;
    let test = accounts[0];
    const ERROR_MSG = 'VM Exception while processing transaction: revert';   
    before(async() =>{
        instance = await Tic.deployed();
    });
    it("Initial balance of contract is zero.", async() => {
        const amount = 0;
        let num = await web3.eth.getBalance(instance.address);
        assert.equal(amount , num, "Ayya");
        
    });

    //*****Unit test for createGame*******

    it("Contract gets specified stake amount", async() => {
        const stake = 50;
        let ret = await instance.createGame(stake, 0, {from: test, value: 50});
        // console.log(await web3.eth.getBalance(instance.address));
        assert.equal(await web3.eth.getBalance(instance.address), stake, "HI");
    });

    it("Raises error when value sent is not equal to Stake", async() => {
        const stake = 100;
        let err = null;
        try{
            let ret = await instance.createGame.call(stake, 0, {from: test, value:10})
        } catch(error) {
            err = error;
        }
        assert.ok(err instanceof Error);
    })

    it("Raises error with non-acceptable stake amount", async() => {
        //accepted stakes are [25, 50, 75, 100];
        const stake = 90;
        let err = null;
        try{
            await instance.createGame.call(stake, 0, {from: test, value: stake})
        } catch(error){
            err = error
        }
        assert.ok(err instanceof Error, "Error with this test");
    });

    it("Initiates a random player", async() => {
        const stake = 25;
        const inst = await Tic.deployed();
        let id = await inst.createGame.call(stake, 1, {from: test, value: stake});
        // console.log(await web3.eth.getBalance(inst.address));
        await inst.createGame(stake, 1, {from: test, value: stake});
        own = await inst.game.call(id);

        assert.equal(own.isRandom, true, ERROR_MSG);
        // console.log(await web3.eth.getBalance(inst.address));
        // assert.equal(id, 1, ERROR_MSG);
        // console.log(id.v());
    });

    it("Plays with normal Player", async() => {
        const stake = 25;
        instance = await Tic.deployed();
        let id = await instance.createGame.call(stake, 0, {
            from: test, value: stake});
        // console.log(await web3.eth.getBalance(inst.address));
        await instance.createGame(stake, 0, {from: test, value: stake});
        own = await instance.game.call(id);
        assert.equal(own.isRandom, false, ERROR_MSG);
    })


    //************JoinGame*************

    it("SecondPlayer Joins the Game", async() => {
        instance = await Tic.deployed();
        let test2 = accounts[1];
        const stake = 25;
        let id = await instance.createGame.call(stake, 0, {from: test, value: stake});

        await instance.createGame(stake, 0, {from:test, value: stake}); 
        await instance.joinGame(id, stake, {from:test2, value:stake});

        game = await instance.game.call(id);

        assert.equal(game.player2, test2, ERROR_MSG);
    });

    it("Doesnt allow when SecondPlayer provides incorrect stake", async() => {
        instance = await Tic.deployed();
        let err = null;
        let test2 = accounts[1];
        const stake = 25;
        let id = await instance.createGame.call(stake, 0, {from: test, value: stake});

        await instance.createGame(stake, 0, {from:test, value: stake}); 
        try {
            await instance.joinGame(id, stake + 10, {from:test2, value:stake});
        } catch(error) {
            err = error;
        }    
        game = await instance.game.call(id);
        assert.ok(err instanceof Error, ERROR_MSG);
    });

    it("Doesnt allow SecondPlayer Joining filled game slot", async() => {
        instance = await Tic.deployed();
        let err = null;
        let test2 = accounts[1];
        let test3 = accounts[2];

        const stake = 25;
        let id = await instance.createGame.call(stake, 0, {from: test, value: stake});

        await instance.createGame(stake, 0, {from:test, value: stake}); 
        await instance.joinGame(id, stake, {from:test2, value:stake});
        try {
            await instance.joinGame(id, stake, {from:test3, value:stake});
        } catch(error) {
            err = error;
        }    
        game = await instance.game.call(id);
        assert.ok(err instanceof Error, ERROR_MSG);
    });

    it("Doesnt Allow SecondPlayer Joining RandomPlayer game", async() => {
        instance = await Tic.deployed();
        let err = null;
        let test2 = accounts[1];

        const stake = 25;
        let id = await instance.createGame.call(stake, 1, {from: test, value: stake});

        await instance.createGame(stake, 1, {from:test, value: stake}); 
        try {
            await instance.joinGame(id, stake, {from:test2, value:stake});
        } catch(error) {
            err = error;
        }    
        assert.ok(err instanceof Error, ERROR_MSG);
    });

    //********MakeMove************/

    it("Player Makes move in his turn and board gets updated", async() => {
        //Symbol for Player1 is "1" and Symbol for Player2 is 2
        instance = await Tic.deployed();
        let err = null;
        let test2 = accounts[1];

        const stake = 25;
        let id = await instance.createGame.call(stake, 0, {from: test, value: stake});
        await instance.createGame(stake, 0, {from:test, value: stake}); 
        await instance.joinGame(id, stake, {from:test2, value:stake});

        let x=1;let y =1;    
        await instance.makeMove(id, x, y, {from: test});
        let array = await instance.getBoard.call(id);
        assert.equal(array[x][y], 1, ERROR_MSG);

        await instance.makeMove(id, x+1, y, {from: test2});
        array = await instance.getBoard.call(id);
        assert.equal(array[x+1][y], 2, ERROR_MSG);

    });

    it("Throws error when a Player Makes move in his opponent's turn or invalid cell", async() => {
        instance = await Tic.deployed();
        let err = null;
        let test2 = accounts[1];

        const stake = 25;
        let id = await instance.createGame.call(stake, 0, {from: test, value: stake});
        await instance.createGame(stake, 0, {from:test, value: stake}); 
        await instance.joinGame(id, stake, {from:test2, value:stake});

        let x=1;let y =1;    
        await instance.makeMove(id, x, y, {from: test});
        //After this It will be opponent's turn;
        try {
            await instance.makeMove(id, x+1, y, {from: test});
        } catch(error) {
            err = error;
        } 
        assert.ok(err instanceof Error, ERROR_MSG);
        err = null;
        try {
            await instance.makeMove(id, x, y, {from: test2});
        } catch(error) {
            err = error;
        } 
        assert.ok(err instanceof Error, ERROR_MSG);

    });

    it("Marks the winning Player and Board gets reset", async() => {
        instance = await Tic.deployed();
        let err = null;
        let test2 = accounts[1];

        const stake = 25;
        let id = await instance.createGame.call(stake, 0, {from: test, value: stake});
        await instance.createGame(stake, 0, {from:test, value: stake}); 
        await instance.joinGame(id, stake, {from:test2, value:stake});
        let game = await instance.getWinner.call(id);
        assert.equal(game[1], 0, ERROR_MSG);
        //Here 1st Player is winning Player;
        for(var i=0;i<3;i++){
            await instance.makeMove(id, 1, i, {from:test});
            try{
                await instance.makeMove(id, 2, i, {from:test2});
            }catch(error){
                err = error;
                assert.ok(err instanceof Error, ERROR_MSG);
            }
            
        }
        game = await instance.getWinner.call(id);
        array = await instance.getBoard.call(id);
        //Board getting reset
        for(var i=0;i<3;i++){
            for(var j=0;j<3;j++){
                assert.equal(array[i][j], 0, ERROR_MSG);
            }
        }
        assert.equal(game[1], 1, ERROR_MSG);

    });

    it("Changes the first turn of Players after two games", async() => {
        instance = await Tic.deployed();
        let err = null;
        let test2 = accounts[1];

        const stake = 25;
        let id = await instance.createGame.call(stake, 0, {from: test, value: stake});
        await instance.createGame(stake, 0, {from:test, value: stake}); 
        await instance.joinGame(id, stake, {from:test2, value:stake});
        let game = await instance.getWinner.call(id);
        assert.equal(game[1], 0, ERROR_MSG);
        //Here 1st Player is winning Player;
        for(var k=0;k<4;k++){
            let game = await instance.game.call(id);
            // console.log(game.whichPlayerTurn);
            if(k < 2){
                let game = await instance.game.call(id);
                assert.equal(game.whichPlayerTurn, 1, ERROR_MSG);
            }else if(k >= 2 ){
                let game = await instance.game.call(id);
                assert.equal(game.whichPlayerTurn, 2, ERROR_MSG);
            }
            for(var i=0;i<3;i++){
                if(k < 2){
                    await instance.makeMove(id, 1, i, {from:test});
                    if(i!=2)await instance.makeMove(id, 2, i, {from:test2});
                }else{
                    await instance.makeMove(id, 1, i, {from:test2});
                    if(i!=2)await instance.makeMove(id, 2, i, {from:test});
                }
                
            }
            //Board getting reset            
        }
    });

    it("Stake gets transferred to the winning Player", async() => {
        //Since transaction is in wei and 1 gwei = 10^9 wei,
        //we need to compare only last 9 digits
        instance = await Tic.deployed();
        let err = null;
        let test2 = accounts[1];
        var current = await web3.eth.getBalance(test);
        console.log(current);
        const stake = 25;
        var expected = String(BigInt(current) + BigInt(stake));
        expected = expected.slice(-9);
        let id = await instance.createGame.call(stake, 0, {from: test, value: stake});
        await instance.createGame(stake, 0, {from:test, value: stake}); 
        await instance.joinGame(id, stake, {from:test2, value:stake});
        //Here 1st Player is winning Player;
        for(var k=0;k<4;k++){
            // console.log(game.whichPlayerTurn);
            for(var i=0;i<3;i++){
                if(k < 2){
                    await instance.makeMove(id, 1, i, {from:test});
                    if(i!=2)await instance.makeMove(id, 2, i, {from:test2});
                }else{
                    if(i!=2)await instance.makeMove(id, 1, i, {from:test2});
                    else await instance.makeMove(id, 0, i, {from:test2});
                    await instance.makeMove(id, 2, i, {from:test});
                }
                
            }
            //Board getting reset            
        }
        
        var actual = await web3.eth.getBalance(test);
        actual = actual.slice(-9);

        // actual = BigInt(actual);
        console.log(actual);
        assert.equal(expected, actual, ERROR_MSG);
    });
    // it("Random Player Makes a Valid Move")












    


//   it('should put 10000 MetaCoin in the first account', async () => {
//     const metaCoinInstance = await MetaCoin.deployed();
//     const balance = await metaCoinInstance.getBalance.call(accounts[0]);

//     assert.equal(balance.valueOf(), 10000, "10000 wasn't in the first account");
//   });
//   it('should call a function that depends on a linked library', async () => {
//     const metaCoinInstance = await MetaCoin.deployed();
//     const metaCoinBalance = (await metaCoinInstance.getBalance.call(accounts[0])).toNumber();
//     const metaCoinEthBalance = (await metaCoinInstance.getBalanceInEth.call(accounts[0])).toNumber();

//     assert.equal(metaCoinEthBalance, 2 * metaCoinBalance, 'Library function returned unexpected function, linkage may be broken');
//   });
//   it('should send coin correctly', async () => {
//     const metaCoinInstance = await MetaCoin.deployed();

//     // Setup 2 accounts.
//     const accountOne = accounts[0];
//     const accountTwo = accounts[1];

//     // Get initial balances of first and second account.
//     const accountOneStartingBalance = (await metaCoinInstance.getBalance.call(accountOne)).toNumber();
//     const accountTwoStartingBalance = (await metaCoinInstance.getBalance.call(accountTwo)).toNumber();

//     // Make transaction from first account to second.
//     const amount = 10;
//     await metaCoinInstance.sendCoin(accountTwo, amount, { from: accountOne });

//     // Get balances of first and second account after the transactions.
//     const accountOneEndingBalance = (await metaCoinInstance.getBalance.call(accountOne)).toNumber();
//     const accountTwoEndingBalance = (await metaCoinInstance.getBalance.call(accountTwo)).toNumber();


//     assert.equal(accountOneEndingBalance, accountOneStartingBalance - amount, "Amount wasn't correctly taken from the sender");
//     assert.equal(accountTwoEndingBalance, accountTwoStartingBalance + amount, "Amount wasn't correctly sent to the receiver");
//   });
});
