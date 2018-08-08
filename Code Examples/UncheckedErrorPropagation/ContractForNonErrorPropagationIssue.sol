pragma solidity ^0.4.20;

import "browser/ContractForUncheckedReturn.sol";


/*
 * @title FundManager
 * @author  Luke Riley (https://www.linkedin.com/in/luke-riley-36484221/)
 * @notice The purpose of this smart contract is to show how code in a fallback function 
 * can cause an error and therefore unexpected logic between contracts 
 * WARNING: Do NOT use this contract 
 */
contract FundManager {
    
    //@param target - the Instantiated contract to connect to, in an attempt to become a king
    WhoIsTheKing target;
    //@param targetAddress - the address of the contract to connect to, in an attempt to become a king
    address targetAddress;
    //@param owner - the creator of the contract, who will want to be paid compensation if he becomes a king, and 
    //then someone else takes the throne
    address public owner;
    //occurs when ether has been paid
       event EthChange(string message, uint userEth);
  /*
  * @notice Instantiates this contract, connecting it king making contract
  * and setting the owner
  */
   constructor (address targetContract) public payable {
       
       target = WhoIsTheKing(targetContract);
       targetAddress = targetContract;
       owner = msg.sender;
       
   }
    
  /*
  * @notice This contract needs to deposit some ether (and beat the previous king deposit) to become king
  */
    function BecomeKing() public payable {
      require(targetAddress.call.value(msg.value).gas(600000)(bytes4(keccak256("becomeKing()"))) == true);

    }

  /*
  * @notice When dethroned, ether will be sent back to this contract via a send invocation
  * and will immediately attempt to send this ether to the contract owner
  * but because a send invocation is used, this fallback will run out of gas
  * @param msg.value - The ether the user wants to give to this contract
  */
  function () public payable {
    
        emit EthChange("The malicious contract has been sent eth", msg.value);
        //payout ether to owner
        giveEthToOwner();
  }
  
  /*
  * @notice A getter function that allows the user to check how much ether the contract has
  */ 
  function checkEth() public view returns(uint) {
      
      return address(this).balance;
      
  }
  
  /*
  * @notice Use this function to give this contract's ether to the contract owner
  */ 
  function giveEthToOwner() public {
      
      owner.transfer(address(this).balance);
  }

}


