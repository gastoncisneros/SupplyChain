// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./ItemManager.sol";

/*
    We create a new item contract to assign an address to every item, so when the user wants to buy 
    a new item, he just has to send money to certain address (the item address), and the contract will
    handle that transaction and trigger the method on ItemManager, so the user never has to interact with 
    the ItemManager contract.

    We create a new Item in ItemManager, it gives us a new address where we have to deploy the Item contract,
    and we give that address to the custer, so they can send money to that address, and in this way they bought the item.
*/
contract Item{
    uint public priceInWei;
    uint public index;
    uint pricePaid;

    ItemManager itemManager;

    constructor(ItemManager parentContract, uint itemPrice, uint itemIndex){
        priceInWei = itemPrice;
        index = itemIndex;
        itemManager = parentContract;
    }

    // call function is a low level function, more dangerous than anothers because it does not trigger error if it was,
    //but it returns a boolean that we can use instead.
    receive() external payable{
        require(pricePaid == 0, "The item was already purchased");
        require(priceInWei == msg.value, "Only full payments allowed");
        pricePaid += msg.value;
        (bool success, ) = address(itemManager).call{value:msg.value}(abi.encodeWithSignature("triggerPayment(uint256)", index));
        require(success, "The transaction wasn't successful, canceling");
    }

    fallback() external{}
}