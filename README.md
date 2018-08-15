# Smart Contract Interactions
This folder lists examples of all the ways two smart contracts written in Solidity can interact, as well as some common problems solidity programmers come across. 



## Different Smart Contract Invocations

Given a smart contract s<sup>p</sup>, there are six different ways s<sup>p</sup> can invoke and interact with another smart contract s<sup>q</sup>. I will describe these six different invocation categories below. Additionally, there are coded examples of these invocation categories in the [CallingContract.sol](https://github.com/Luker501/SmartContractInteractions/blob/master/CallingContract.sol) file.

Note that in the following I use `<ContractType>`, `<ContractName>`, `<FunctionName>` and `<ContractAddress>` as placeholders.

* __Direct Invocation__: *new* `<ContractType>` __or__ `<ContractName>`.`<FunctionName>` -  This invocation method is the most simple way for smart contract s<sup>p</sup> to interact with a function f<sup>x</sup> in smart contract s<sup>q</sup>. If f<sup>x</sup> is contract s<sup>q</sup>'s constructor, then it is called through the *new* keyword followed by a reference to the `<ContractType>` of s<sup>q</sup>. Otherwise if f<sup>x</sup> is not a constructor,  s<sup>p</sup> must have already instantiated a `<ContractName>` variable representing s<sup>q</sup> through prior knowledge of the `<ContractAddress>` of s<sup>q</sup>. 

* __Low Level Call Invocation__: `<ContractAddress>`*.call(...)* - This invocation method  allows smart contract s<sup>p</sup> to invoke any function of smart contract s<sup>q</sup>. It is more complex than a direct invocation as the programmer needs to enter the function name and parameters types via string input and so no complie time checks can be made on if they are correct. If the programmer does not enter a valid function name and/or parameter types, then the fallback function of s<sup>q</sup> is called (if it exists).

*  __Delegation__: `<ContractAddress>`*.delegatecall(...)* __or__ `<ContractAddress>`*.callcode(...)* -  This invocation method allows smart contract s<sup>p</sup> to invoke any function of smart contract s<sup>q</sup> but for the function to operate over s<sup>p</sup>'s storage. Therefore *delegatecall*s are a security risk and require s<sup>p</sup> to trust s<sup>q</sup>. Note that *delegatecall* can be seen as a bug fix of *callcode* as *callcode* does not preserve msg.sender when a smart contract s<sup>p</sup> delegates to another smart contract s<sup>q</sup>. That is, if *callcode* was used s<sup>q</sup> would have s<sup>p</sup> as msg.sender, but if *delegatecall* was used s<sup>q</sup> would still have access to the msg.sender of s<sup>p</sup>.  

* __Send__: `<ContractAddress>`*.send(...)* - This invocation method allows smart contract s<sup>p</sup> to *send* ether to recipient smart contract s<sup>q</sup> as long as s<sup>q</sup> has a fallback function implemented.

* __Transfer__: `<ContractAddress>`*.transfer(...)* - This invocation method allows smart contract s<sup>p</sup> to *transfer* ether to recipient  smart contract s<sup>q</sup> as long as s<sup>q</sup> has a fallback function implemented.  *Transfer* is logically the same as the *send* invocation apart from *transfer* reverts on failure.

* __Self Destruct__: *selfdestruct(*`<ContractAddress>`*)* __or__ *suicide(*`<ContractAddress>`*)* - This invocation method allows smart contract s<sup>p</sup> to forceably send ether to the recipient smart contract s<sup>q</sup> even if no fallback is implemented in s<sup>q</sup>. Note that *suicide* is a depreciated alias of *selfdestruct*.


See CallingContract.sol for examples of all of these invocation methods.


## Smart Contract Invocation Comparison

I will now discuss the comparison between the invocation categories according to different criteria, where the discussion is summarised in the following table:

![Invocation comparison](InovationTable.png)

* __Can Set Gas Limit__ - Which invocation methods allow an explicit gas limit (for the called contract) to be set by the programmer? This is an optional feature for the direct, low level call and delegation invocations. The send and transfer invocations have a preset gas limit. Whereas no additional gas is needed for the self destruct invocation - instead users are "rewarded" for self-destructing their contracts with a negative gas cost for using this invocation. A reward is given because after a self destruct invocation is used, the code and storage of the destructed contract are removed from the ethereum virtual machine going forward. Note that nodes with access to the block where the contract was originally deployed will still be able to recover the contract's associated bytecode, so the concept of destruction is different from complete removal.

* __Gas Limit__ - There are currently explicit gas limits for send and transfer, set at 2300 each. While the direct, low level call and delegation invocations can accept all remaining  gas from the calling function or an explicit amount. Whereas self destruct uses negative gas for reasons described previously. Note that all of the direct, low level call and delegation invocations could allow reentrancy into the original contract's functions and/or storage, either by design (delegation) or as a by-product of allowing flexible gas limits (direct and low level call).

* __Return value if error occurs__ - After each invocation, what happens if there is an error? For direct and transfer invocations, they will both throw an error. Whereas the low level call, delegation and send invocation will only return false, hence if you want to propagate errors from these invocations, they should be wrapped in a require function. Finally, the self destruct invocation does not return a value or throw an error - as there is no contract left to return or throw anything.

* __Storage used__ - After the invocation, whose storage can be changed in the called contract's function? The direct and low level call invocations operate in the more natural way where the called contract can only change it's own storage. The delegation invocation is more complicated as it allows the called contract's functions to change the storage of the original contract. The send and transfer invocations do not provide enough gas to allow the called contract to make any state changes. Whereas the self-destruct invocation removes the storage of the contract performing the invocation.

* __Ether sent to called contract__ - The send and transfer invocations require an explicit ether amount to be given. Whereas the direct and low level call invocations allow ether to be optionally sent.
The delegation invocation does not allow ether to be passed on, as giving ether via the delegation invocation is effectively giving ether to yourself due to the way contract storage is manipulated in this invocation. Finally, self destruct forces the contract to pass on all remaining ether to a given address. 

## Common Solidity Programming Issues

Programmers unfamiliar with solidity can be caught out by the following two issues relating to the flow of code execution:


* __Possibly of Reentrancy__: When a smart contract s<sup>p</sup>'s function f<sup>x</sup> calls another function f<sup>y</sup>, the rest of function f<sup>x</sup> is effectively paused until f<sup>y</sup> completes. This can be an issue if f<sup>x</sup> wants to make some state changes after f<sup>y</sup> completes and f<sup>y</sup> resides in a different smart contract s<sup>q</sup> (which could have been created by a malicious individual). In this case f<sup>y</sup> can attempt to exploit the fact that f<sup>x</sup> is on pause, by calling functions in s<sup>p</sup> to take advantage of the fact that f<sup>x</sup> has not made all of its state changes yet.

The withdraw() function in [this solidity file](https://github.com/Luker501/SmartContractInteractions/blob/master/Code%20Examples/Re-Entry/ContractForReentry.sol) contains an example of how a re-entry attack can occur. In this example, a user withdraws their shares, which is processed by the low level call invocation and the corresponding ether is sent to the user's address. If the user's address is a smart contract, this smart contract can re-call the withdraw() function to take more ether out of the contract than is placed in the user's account. This attack can occur because: (i) the user's account is only set to zero after the low level call invocation occurs; and (ii) this low level call invocation has forwarded all remaining gas to the called contract. To fix this issue, the programmer should have set the user's account to zero value before the ether was send to the user.

* __No Error Propagation__: Some smart contract invocations propagate errors through the entire call stack while other invocations will instead return false if an error occurs. This can cause an issue if a programmer codes in a manner that expects all smart contract invocations to revert on failure. 

The becomeKing() function in [this solidity file](https://github.com/Luker501/SmartContractInteractions/blob/master/Code%20Examples/UncheckedErrorPropagation/ContractForUncheckedReturn.sol) contains an example of how not checking for error propagations can cause an application issue. In this example, a user bids ether to become the new king. If the user outbids the current king, then the user becomes the new king and the old king is paid some compensation. In this example a  send invocation is used to give the old king compensation. The send invocation only  allows for a small amount of gas to be used, meaning that if the old king is a smart contract that attempts to perform function calls after receiving ether, then this send invocation will fail. Crucially, there is no check in the becomeKing() function for if the send invocation fails. To fix this issue, another function could have been used for compensation requests from old kings where the compensation is made through the low level call invocation.
