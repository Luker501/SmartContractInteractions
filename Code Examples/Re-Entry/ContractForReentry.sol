pragma solidity ^0.4.20;

// THIS CONTRACT CONTAINS A BUG - DO NOT USE
/*
 * @title Fund
 * @author Ethereum Foundation (https://solidity.readthedocs.io/en/develop/security-considerations.html#re-entrancy)
 * Modified by Luke Riley (https://www.linkedin.com/in/luke-riley-36484221/)
 * @notice The purpose of this smart contract is to show how a contract can be vunerable to re-entrancy attacks
 * WARNING: Do NOT use this contract as it contains a bug for demostration purposes
 */
contract Fund {
    
     //@param shares - mapping the deposits stored in the contract for each address.
    mapping(address => uint) shares;
  
     constructor () public payable {}
    
    //an event that is emitted whenever the value of the contract changes
   event EthChange(string message, address user, uint userEth, uint totalEth);
    
  /*
  * @notice Lets a user withdraw all their ether. re-entrancy attack can occur threw this function!
  */
  function withdraw() public {
            uint oldbalance = shares[msg.sender];
            //if the balance is positive...
            if (oldbalance > 0){
                //send the ether to the withdrawing address
                msg.sender.call.value(shares[msg.sender])("");
                //reset the balance to zero
                shares[msg.sender] = 0;
                //Because the reset happens after the call, a malicious calling contract can re-enter
                //this function multiple times and so withdraw more eth then they deposited
                emit EthChange("The following user has withdrawn eth", msg.sender, oldbalance, address(this).balance);
            }

    }

  /*
  * @notice Lets a user deposit ether into this contract
  */
    function deposit() public payable {
        
        //the users ether is stored separately to everyone else 
        shares[msg.sender] = shares[msg.sender] + msg.value;
        //this event emits the users total ether and the total ether of the contract
        emit EthChange("The following user has deposited eth", msg.sender, shares[msg.sender], address(this).balance);
        
    }
    
 /*
  * @notice A getter function that allows the user to check how much ether the contract has
  */ 
  function checkEth() public view returns(uint) {
      
      return address(this).balance;
      
  }
}


