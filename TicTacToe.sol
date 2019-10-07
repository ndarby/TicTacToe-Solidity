pragma solidity ^0.5.8;

contract TicTacToe {
    //addresses for players
    address payable player1;
    address payable player2;
    //names of the players
    string public _p1 = "Player 1";
    string public _p2 = "Player 2";
    //move counters
    uint8 moves = 0;
    //keeps track of if a game is finished or not
    //check best method to finish the game
    bool winner = false;
    
    enum BoardSpace {Empty, X, O}
    BoardSpace[3][3] theBoard;

    //amount both players put into the contract, the winner gets all of it
    uint256 winnings = 0;
    address winnerAddress;
    mapping(address => bool) playersBet;

    //list of events emitted by this contract
    event xMoved();
    event oMoved();
    event gameStart();
    event xWon();
    event oWon();
    event draw();
    
    
    //sets the players to their respective addresses, caller is player1 
    constructor() public {
        player1 = msg.sender;
        
    }
    //sets the player2
    //@dev requires player2 to have not been set yet
    function setPlayer2() public {
        require(player2 == address(0));
        player2 = msg.sender;
        emit gameStart();
    }
    
    //sets the name of the player who calls the method
    function setName(string memory name) public {
        if(msg.sender == player1){
            _p1 = name;
        }else if(msg.sender == player2){
            _p2 = name;
        }
    }

    //allows players to send an amount to the contract to start the game
    //currently 0.5 ether is needed to play
    function makePayment() external payable {
        require (msg.value == 0.5 ether && !playersBet[msg.sender]);
        playersBet[msg.sender] = true;
        
    }

    //function modifier ensures that the players have paid the initial amount
    modifier paid() { 
        require (playersBet[msg.sender] == true); 
        _; 
    }
    
    
    //check what mark is in the specified space, returns the string representation of that mark
    function stringSpace(uint8 xpos, uint8 ypos) internal view onBoard(xpos, ypos) returns(string memory){
        if(theBoard[xpos][ypos] == BoardSpace.Empty){
            return "  ";
        }else if(theBoard[xpos][ypos] == BoardSpace.X){
            return "X";
        }else if(theBoard[xpos][ypos] == BoardSpace.O){
            return "O";
        }
    }
    //returns the entire row as a string
    function printRow(uint8 ypos) internal view returns(string memory) {
        return string(abi.encodePacked(stringSpace(0, ypos), "|", stringSpace(1, ypos), "|", stringSpace(2, ypos)));
    }
    //returns the entire board as a string
    function printBoard() public view returns(string memory){
        return string(abi.encodePacked("\n",
            printRow(0), "\n", "--------", "\n",
            printRow(1), "\n", "--------", "\n",
            printRow(2), "\n"
            ));
    }
    //sets the specified space with the players mark
    //@dev requires the specified space is empty
    function setSpace(uint8 xpos, uint8 ypos) internal{
        require(theBoard[xpos][ypos] == BoardSpace.Empty);
        if(msg.sender == player1){
            theBoard[xpos][ypos] = BoardSpace.X;
        } else {
            theBoard[xpos][ypos] = BoardSpace.O;
        }
    }
    
    //Checks to see which player is playing and if it is their turn, allows them to makeMove
    function makeMove(uint8 xpos, uint8 ypos) external onBoard(xpos, ypos) paid() {
        if(msg.sender == player1){
            require(moves %2 == 0);
            setSpace(xpos, ypos);
            moves++;
            emit xMoved();
        }else if(msg.sender == player2){
            require(moves % 2 != 0);
            setSpace(xpos, ypos);
            moves++;
            emit oMoved();
        }
    }

    //@dev bounds for the marks
    modifier onBoard(uint8 xpos, uint8 ypos) {
        require(0 <= xpos && 0 <= ypos && 3 > xpos && 3 > ypos);
        _;
    }
    
    //function to check if the specified space is empty
    function checkSpace(uint8 xpos, uint8 ypos) public view returns(bool empty){
        if(theBoard[xpos][ypos] == BoardSpace.Empty){
            empty = true;
        }else{
            empty = false;
        }
    }

    //checks to see if there is a winner
    function checkWin() public view returns(string memory _name, bool win, bool _draw){
       bool xwin = false;
       bool owin = false;

       xwin = xWins();
       owin = oWins();


        if(xwin){
            _name = string(abi.encodePacked(_p1, " wins!"));
            win = true;
            _draw = false;
        } else if(owin){
            _name = string(abi.encodePacked(_p2, " wins!"));
            win = true;
            _draw = false;
        }else if(moves == 9) {
            _name = string(abi.encodePacked("Draw!"));
            win = true;
            _draw = true;
        }else {
            _name = string(abi.encodePacked("No winner yet..."));
            win = false;
            _draw = false;
        }
        
    }
    //helper function to see if X has won
    function xWins() internal view returns(bool){
       uint8 row;
       uint8 col;
       uint8 result = 0;
        for (row = 0; result == 0 && row < 3; row++) {
            uint8 row_result = 1;
            for (col = 0; row_result == 1 && col < 3; col++)
                if (theBoard[row][col] != BoardSpace.X)
                    row_result = 0;
            if (row_result != 0)
                result = 1;
        }

        
        for (col = 0; result == 0 && col < 3; col++) {
            uint8 col_result = 1;
            for (row = 0; col_result != 0 && row < 3; row++)
                if (theBoard[row][col] != BoardSpace.X)
                    col_result = 0;
            if (col_result != 0)
                result = 1;
        }

        if (result == 0) {
            uint8 diag1Result = 1;
            for (row = 0; diag1Result != 0 && row < 3; row++)
                if (theBoard[row][row] != BoardSpace.X)
                    diag1Result = 0;
            if (diag1Result != 0)
                result = 1;
        }
        if (result == 0) {
            uint8 diag2Result = 1;
            for (row = 0; diag2Result != 0 && row < 3; row++)
                if (theBoard[row][3 - 1 - row] != BoardSpace.X)
                    diag2Result = 0;
            if (diag2Result != 0)
                result = 1;
        }
        if(result == 1){
            return true;
        } else{
            return false;
        }
    }

    //helper function to see if O has won
    function oWins() internal view returns(bool){
       uint8 row;
       uint8 col;
       uint8 result = 0;
        for (row = 0; result == 0 && row < 3; row++) {
            uint8 row_result = 1;
            for (col = 0; row_result == 1 && col < 3; col++)
                if (theBoard[row][col] != BoardSpace.O)
                    row_result = 0;
            if (row_result != 0)
                result = 1;
        }

        
        for (col = 0; result == 0 && col < 3; col++) {
            uint8 col_result = 1;
            for (row = 0; col_result != 0 && row < 3; row++)
                if (theBoard[row][col] != BoardSpace.O)
                    col_result = 0;
            if (col_result != 0)
                result = 1;
        }

        if (result == 0) {
            uint8 diag1Result = 1;
            for (row = 0; diag1Result != 0 && row < 3; row++)
                if (theBoard[row][row] != BoardSpace.O)
                    diag1Result = 0;
            if (diag1Result != 0)
                result = 1;
        }
        if (result == 0) {
            uint8 diag2Result = 1;
            for (row = 0; diag2Result != 0 && row < 3; row++)
                if (theBoard[row][3 - 1 - row] != BoardSpace.O)
                    diag2Result = 0;
            if (diag2Result != 0)
                result = 1;
        }

        if(result == 1){
            return true;
        } else{
            return false;
        }
    }

    //Function to set the winner and disperse the funds held in the contract
    //can only be called after the game is won, or there is a draw
    //if there is a winner, the player who won gets the balance of the contract
    //in the case of a draw, the balance is split between the two players
    function setWinner () external payable{
         (, bool b, bool c) = checkWin();

        require(b == true || c == true);

        if(oWins()){
            winner = true;
            winnerAddress = player2;
            player2.transfer(address(this).balance);
            emit oWon();

        }else if(xWins()){
            winner = true;
            winnerAddress = player1;
            player1.transfer(address(this).balance);
            emit xWon();

        }else if(c){
            winnerAddress = address(0);
            player1.transfer((address(this).balance/2));
            player2.transfer((address(this).balance/2));
            emit draw();
        }
        
    }

    //This function can only be called if there is a winner, or a draw
    //self-destructs the contract to player1 address
    //@dev still needs modification to ensure it cannot be called before funds are dispersed to the winner
    function gameOver() external {
    	
         require (winner == true || moves == 9);
          
         selfdestruct(address(player1));
    }
    
}

