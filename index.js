//Online TicTacToe Game (Player 1)
//Nathan Darby
//July 22 2019

const Web3 = require('web3');
const readline = require('readline');

const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:7545'));
// const web3 = new Web3(new Web3.providers.HttpProvider("https://rinkeby.infura.io/v3/bd854d0d449d4de98596813e8d67c58e"));

//abi for communicating with the contract
const abi =   [
    {
      "constant": true,
      "inputs": [],
      "name": "_p1",
      "outputs": [
        {
          "name": "",
          "type": "string"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "_p2",
      "outputs": [
        {
          "name": "",
          "type": "string"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "constructor"
    },
    {
      "anonymous": false,
      "inputs": [],
      "name": "xMoved",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [],
      "name": "oMoved",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [],
      "name": "gameStart",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [],
      "name": "xWon",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [],
      "name": "oWon",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [],
      "name": "draw",
      "type": "event"
    },
    {
      "constant": false,
      "inputs": [],
      "name": "setPlayer2",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "constant": false,
      "inputs": [
        {
          "name": "name",
          "type": "string"
        }
      ],
      "name": "setName",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "constant": false,
      "inputs": [],
      "name": "makePayment",
      "outputs": [],
      "payable": true,
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "printBoard",
      "outputs": [
        {
          "name": "",
          "type": "string"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    },
    {
      "constant": false,
      "inputs": [
        {
          "name": "xpos",
          "type": "uint8"
        },
        {
          "name": "ypos",
          "type": "uint8"
        }
      ],
      "name": "makeMove",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [
        {
          "name": "xpos",
          "type": "uint8"
        },
        {
          "name": "ypos",
          "type": "uint8"
        }
      ],
      "name": "checkSpace",
      "outputs": [
        {
          "name": "empty",
          "type": "bool"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "checkWin",
      "outputs": [
        {
          "name": "_name",
          "type": "string"
        },
        {
          "name": "win",
          "type": "bool"
        },
        {
          "name": "_draw",
          "type": "bool"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    },
    {
      "constant": false,
      "inputs": [],
      "name": "setWinner",
      "outputs": [],
      "payable": true,
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "constant": false,
      "inputs": [],
      "name": "gameOver",
      "outputs": [],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
    }
  ];

//varibles for connecting with the contract and player info
const address = '0xF7e416Ad5d90c769d42f7860009e69530883C469';
var ticTacToeGame = new web3.eth.Contract(abi, address);
var xPlayer = '0xF75866A0Dd24d04aeD12D63f99Ddd5B18Ad2766E';
var name = 'Player 1';
var opponentName = 'Player 2';

//interface for getting user input
var rl = readline.createInterface({input: process.stdin, output: process.stdout});

//payment to be able to play the game
ticTacToeGame.methods.makePayment().send({from: xPlayer, value: web3.utils.toWei('0.5', 'ether')});

console.log("Waiting for player2...");

//These track events emitted by the smart contract
//When an event is detected, the corresponding function is called
ticTacToeGame.events.oMoved({fromBlock: 'latest'}, print);
ticTacToeGame.events.gameStart({fromBlock: 'latest'}, _setName);

//This method allows the user to set their player name
function _setName(){
	rl.question('Enter your name: ', async function(input){
		name = input;
		rl.question('You have entered: ' + name + "\nProceed with this name? (Y/N)", 
			async function(input){
				if(input == 'y' || input == 'Y'){
					await ticTacToeGame.methods.setName(name).send({from: xPlayer}, () => {print()});
				}else{
					_setName();
				}
			});
		
	});
}

//This method gets user input, verifies it, then sends the move to the smart contract
function _xMove(){
    rl.question(name + ', make a move (column row): ', async function(input){
    	var col = await _cFromString(input);
    	var row = await _rFromString(input);
    	if(col != 0 && col != 1 && col != 2){
    		console.log("Invalid input...");
    		_xMove();
    	} else if(row != 0 && row != 1 && row != 2) {
    		console.log("Invalid input...");
    		_xMove();
    	} else{
    		await ticTacToeGame.methods.checkSpace(col, row).call().then(async function(response){
    			if(response == true){
    				await ticTacToeGame.methods.makeMove(col, row).send({from: xPlayer}, () => {moveComplete()});
    			}else{
    				console.log("Invalid move...");
    				_xMove();
    			}
    		});	
       	}
      
    });
  }  

//Method to get the column from the user input
function _cFromString(str) {
	str = str.trim();
    var pos = str.split(' ');
    if(pos[0] == undefined){
    	return -1;
    }
    var c = pos[0].trim();
    if(c === ''){
    	return -1;
    }else{
    	return Number(c);
    }  
  }

//Method to get the row from the user input
function _rFromString(str) {
  	str = str.trim();
    var pos = str.split(' ');
    if(pos[1] == undefined){
    	return -1;
    }
    var r = pos[1].trim();
    if(r === ''){
    	return -1;
    }else{
    	return Number(r);
    }
  }

//Prints the board to the console then calls the checkWinner method
function print(){
    ticTacToeGame.methods.printBoard().call().then(function(response){
      console.log(response);
      console.log('---------------------------------------');
    }).then(() => checkWinner());
  }

//This method is called after a move has been completed, 
//Prints the board to the console then calls checkWinner with an argument of true to signify the move has been completed
function moveComplete(){
	ticTacToeGame.methods.printBoard().call().then(function(response){
      console.log(response);
      console.log('---------------------------------------');
    }).then(() => checkWinner(true));
}

//Calls the contract to see if there is a winner, 
//if there is a winner or a draw, prints the appropriate response and ends the game
//if there is no winner and it is the player turn, it calls _oMove
//if there is no winner and the player has made a move(determined by passing an argument of true to the method), 
//  it displays a wait message and ends the turn
  function checkWinner(moveFinished) {
    ticTacToeGame.methods.checkWin().call().then(async function(response){
      if(response[1] == true ){
        console.log(response[0]);
        ticTacToeGame.methods.setWinner().send({from: xPlayer}, () => 
        	{console.log('-----------------GAME OVER---------------')});
        
      }else if(response[2] == true){
      	console.log("Draw!");
      	 ticTacToeGame.methods.setWinner().send({from: xPlayer}, () => 
        	{console.log('-----------------GAME OVER---------------')});

      }else if(moveFinished){
        opponentName = await ticTacToeGame.methods._p2().call();
      	console.log("Waiting for " + opponentName + "...");
      }else{
      	_xMove();
      }
    });

  }

 
