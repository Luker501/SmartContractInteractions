pragma solidity ^0.4.20;

// THIS CONTRACT CONTAINS A BUG - DO NOT USE
/*
 * @title WhoIsTheKing
 * @author Inspired by https://www.kingoftheether.com/postmortem.html
 * @author written by Luke Riley (https://www.linkedin.com/in/luke-riley-36484221/)
 * @notice The purpose of this smart contract is to show how a contract can be vunerable to re-entrancy attacks
 * WARNING: Do NOT use this contract as it contains a bug for demostration purposes
 */
contract WhoIsTheKing {
    
     //@param currentKing - who is the current King of ethereum?
    address currentKing;

     constructor () public payable {}
    
    //an event that is emitted whenever the value of the contract changes
   event EthChange(string message, address user, uint userEth, uint totalEth);

  

  /*
  * @notice Lets attempt to become the new kingof ethereum 
  */
    function becomeKing() public payable {
        
        if (msg.value > address(this).balance){
            //we have a new king!
            emit EthChange("There is a new king!", msg.sender, msg.value, address(this).balance);
            //so pay off previous king
            //WARNING - if the send fails, the previous king will not get any compensation
            currentKing.send(address(this).balance);
            //set the new king
            currentKing = msg.sender;
        }
        
    }
    
 /*
  * @notice A getter function that allows the user to check how much ether the contract has
  */ 
  function checkEth() public view returns(uint) {
      
      return address(this).balance;
      
  }
}


