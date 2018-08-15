pragma solidity ^0.4.20;
import "browser/CalledContract.sol";

/*
 * @title CallingContract
 * @author Luke Riley (https://www.linkedin.com/in/luke-riley-36484221/)
 * @notice The purpose of this smart contract is to show all of the different 
 * ways that two smart contracts can interact.
 */
contract CallingContract {
    
   //@param message is used to show how the delegation invocation works
   string public message;

  /*
  * @notice Instantiates a new contract
  * @param msg.value - The ether the user wants to give to the new contract 
  */
  function DirectInvocationA() public payable {
      
      CalledContract newContract = new CalledContract();
      //If you want to pass through ether in the constructor, do:
      //newContract = (new CalledContract).value(msg.value)(); 

  }
  
  /*
  * @notice Loads a contract and calls a function on it
  * @param addressOfContract - The address of the contract to interact with
  */
  function DirectInvocationB(address addressOfContract) public payable {
      
      CalledContract newContract = CalledContract(addressOfContract);
      newContract.callMeFunction();
      //if you want to pass through ether to the function, do:
      //newContract.callMeFunction.value(msg.value)();
      //if you additionally want to set a gas limit do, do:
      //newContract.callMeFunction.value(msg.value).gas(200000)();
    
  }
  
  /*
  * @notice Calls the fallback function of the contract at the given address
  * @param addressOfContract - The address of the contract to interact with
  * @param msg.value - The ether the user wants to give to the contract at addressOfContract
  */
  function LowLevelCallInvocationA(address addressOfContract) public payable {
      
      //A low level call does not propagate exceptions, 
      //therefore a require function has been added to propagate an exception
      //if one is found (when the return is false)
      require(addressOfContract.call.value(msg.value).gas(200000)() == true);
      
  }
  
  /*
  * @notice Attempts to call the hardcoded function given via string ("callMeFunction()"), 
  * of the contract at the given address. If "callMeFunction()" is not found, then the 
  * fallback function will run instead
  * @param addressOfContract - The address of the contract to interact with
  * @param msg.value - The ether the user wants to give to the contract at addressOfContract
  */
  function LowLevelCallInvocationB(address addressOfContract) public payable {
     
      //A low level call does not propagate exceptions, 
      //therefore a require function has been added to propagate an exception
      //if one is found (when the return is false)
      require(addressOfContract.call.value(msg.value).gas(600000)(bytes4(keccak256("callMeFunction()"))) == true);
      
  }

  /*
  * @notice Similar to the previous function, but in this case the called function
  * will run using this contract's storage variables. I.e. the message variable changed
  * by the helloFunction() will be the one in this contract
  * @param addressOfContract - The address of the contract to interact with
  */
  function DelegationInvocation(address addressOfContract) public payable {

      //A delegation does not propagate exceptions, 
      //therefore a require function has been added to propagate an exception
      //if one is found (when the return is false)
      require(addressOfContract.delegatecall.gas(30000)(bytes4(keccak256("helloFunction()"))) == true);
      //if you do not want to preserve msg.sender, do:
      //require(addressOfContract.callcode.gas(30000)(bytes4(keccak256("helloFunction()"))) == true);
      
  }

  /*
  * @notice A simple invocation that makes sure that the only code that can be 
  * run in the fallback function of the called contract is a logging event. 
  * @param addressOfContract - The address of the contract to interact with
  * @param msg.value - The ether the user wants to give to the contract at addressOfContract
  */
  function SendInvocation(address addressOfContract) public payable {

      //A send does not propagate exceptions, 
      //therefore a require function has been added to propagate an exception
      //if one is found (when the return is false)
      require(addressOfContract.send(msg.value) == true);
      
  }

  /*
  * @notice A simple invocation that makes sure that the only code run in the fallback
  * function of the called contract is a logging event. This invocation propagates errors
  * @param addressOfContract - The address of the contract to interact with
  * @param msg.value - The ether the user wants to give to the contract at addressOfContract
  */
   function TransferInvocation(address addressOfContract) public payable {
      
      addressOfContract.transfer(msg.value);
      
  }
  
  /*
  * @notice Calling this function will set this contract to inactive forever.
  * The remaining ether will be sent to the given address
  * Note that if the given address is a smart contract which does not have a 
  * fallback function implemented - ether will still be received by it through this invocation
  * @param addressOfContract - The address of the contract to interact with
  */
  function SelfDestructionInvocation(address addressOfContract) public payable {
      
      selfdestruct(addressOfContract);
      //a deprecated version is:
      //suicide(addressOfContract);
      
  }
  
  

}






