pragma solidity ^0.5.0;

/*
 * @title CalledContract
 * @author Luke Riley (https://www.linkedin.com/in/luke-riley-36484221/)
 * @notice The purpose of this smart contract is to show all of the different 
 * ways that two smart contracts can interact.
 * Therefore the functions in this contract are called by the corresponding CallingContract
 */
contract CalledContract {
  
    //@param message - a variable that changes depending on what function is called
   string public message;

    //an event that is emitted whenever the message variable is changed
   event MessageChange(string message);
   //an event that is emitted whereever ether can be received
   event ReceivedFunds(uint value);
   
 /*
  * @notice Instantiates this contract, allowing it to receive ether
  */
   constructor () public payable {}

 /*
  * @notice A simple function that cannot receive ether
  */  
  function helloFunction() public {
      
     message = "hello there";
     emit MessageChange(message);
     return;
     
  }
  
  /*
  * @notice A simple function that can receive ether
  * @param msg.value - The ether the user wants to give to this contract
  */
  function callMeFunction() public payable {
     
     message = "I was called";
     emit MessageChange(message);
     emit ReceivedFunds(msg.value);
     return;
     
  }
  
  /*
  * @notice A getter function that allows the user to check how much ether the contract has
  */ 
  function checkEth() public view returns(uint) {
      
      return address(this).balance;
      
  }
  
  /*
  * @notice The fallback function that is the default function used to recieve ether
  * note that if you want send and transfer invocations to use the fallback then
  * only a emit log can be coded in the function.
  * @param msg.value - The ether the user wants to give to this contract
  */
  function () external payable {
    
    //uncomment the following two lines if you want to check that send and
    //transfer invocation do not allow extra functionality in the fallback
    //function:
    //message = "just paid via the fallback function";
    //emit MessageChange(message);
    emit ReceivedFunds(msg.value);
    
  }

}
