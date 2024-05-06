// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MultiSig {
    address[] public owners;

    struct Transaction{
        address destination;
        uint256  amount;
        bool  executed;
        bytes data;
    }
    Transaction[] public transactions;
    mapping(uint256 => uint256) public confirmationCount;
    mapping(uint => mapping(address => bool)) public confirmations;
    uint256 public required;
    constructor(address[] memory _owners,uint256 _required){
        require(_owners.length>0);
        require(_required!=0);
        require(_required<=_owners.length);
        owners = _owners;
        required= _required;
    }

  receive() external payable{

    }
   
   function isOwner(address addr) private view returns(bool) {
        for(uint i = 0; i < owners.length; i++) {
            if(owners[i] == addr) {
                return true;
            }
        }
        return false;
    }

    function transactionCount()public view returns(uint256){
        return transactions.length;
    }

    function addTransaction(address _destination,uint256 _amount, bytes memory data )internal returns(uint256){
        Transaction memory transaction = Transaction(_destination,_amount,false,data);
        transactions.push(transaction);
        return transactionCount()-1;
    }

    function confirmTransaction(uint256 id)public{
        require(isOwner(msg.sender));
        confirmations[id][msg.sender] = true;
        confirmationCount[id]++;
        if(getConfirmationsCount(id)>=required){
            executeTransaction(id);
        }
    }
    function getConfirmationsCount(uint transactionId) public view returns(uint256){
        return confirmationCount[transactionId];
    }
    

    function submitTransaction(address _destination,uint256 amount, bytes memory data)external payable{
       confirmTransaction(addTransaction(_destination, amount,data));
    } 

    function isConfirmed(uint id)public view returns(bool){
        return getConfirmationsCount(id) >= required;
            
    }

    function executeTransaction(uint id) public {
        require(isConfirmed(id),"Still transaction is not confirmed");
        (bool s, ) = transactions[id].destination.call{value:transactions[id].amount}(transactions[id].data);
        require(s);
        transactions[id].executed = true;

    }


}
