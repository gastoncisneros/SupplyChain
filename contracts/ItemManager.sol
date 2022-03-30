// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";
import "./Item.sol";

 contract ItemManager is Ownable{
    enum SupplyChainSteps{Created, Paid, Delivered}

    struct S_Item{
        Item item;
        SupplyChainSteps step;
        string stepDescription;
        string identifier;
        uint priceInWei;
    }

    mapping(uint => S_Item) public items;
    uint index;

    event SupplyChainStep(uint itemIndex, string identifier, uint step, address itemAddress);

    function createItem(string memory identifier, uint itemPrice) public onlyOwner{
        Item newItem = new Item(this, itemPrice, index);
        items[index].item = newItem;
        items[index].identifier = identifier;
        items[index].priceInWei = itemPrice;
        items[index].step = SupplyChainSteps.Created;
        items[index].stepDescription = "Creado";
        emit SupplyChainStep(index, identifier, uint(items[index].step), address(newItem));
    }

    function triggerPayment(uint itemIndex) public payable{
        require(items[itemIndex].priceInWei == msg.value, "Only full payments accepted");
        require(items[itemIndex].step == SupplyChainSteps.Created, "Item is further in the chain.");
        items[itemIndex].step = SupplyChainSteps.Paid;
        items[index].stepDescription = "Pagado";

        emit SupplyChainStep(itemIndex,items[itemIndex].identifier, uint(items[itemIndex].step), address(items[itemIndex].item));
    }

    function triggerDelivery(uint itemIndex) public onlyOwner{
        require(items[itemIndex].step == SupplyChainSteps.Paid, "Item was not paid yet, is further in the chain.");
        items[itemIndex].step = SupplyChainSteps.Delivered;
        items[index].stepDescription = "Entregado";

        emit SupplyChainStep(itemIndex,items[itemIndex].identifier, uint(items[itemIndex].step), address(items[itemIndex].item));
    }
}