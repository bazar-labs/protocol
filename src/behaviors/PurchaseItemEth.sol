// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BaseBehavior.sol";
import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract PurchaseItemEth is BaseBehavior, Owned, Initializable {
    mapping(uint256 => uint256) public prices;

    event ItemPurchased(address indexed player, uint256 indexed itemDefinitionID, uint256 amount);

    event PriceSet(uint256 indexed itemDefinitionID, uint256 indexed price);

    event ListingDeleted(uint256 itemDefinitionID);

    constructor(address _owner, address inventoryController_, IInventoryRegistry inventoryRegistry_)
        Owned(_owner)
        BaseBehavior(inventoryController_, inventoryRegistry_)
    {}

    function init(bytes calldata data) external payable initializer {
        (owner, inventoryController, inventoryRegistry) = abi.decode(data, (address, address, IInventoryRegistry));
    }

    function setPriceForItem(uint256 itemDefinitionID, uint256 price) public onlyOwner {
        prices[itemDefinitionID] = price;
        emit PriceSet(itemDefinitionID, price);
    }

    function deleteListing(uint256 itemDefinitionID) public onlyOwner {
        require(prices[itemDefinitionID] != 0, "Item not found");
        delete prices[itemDefinitionID];
    }

    function execute(address player, bytes calldata data) public payable override onlyGame {
        (uint256 itemDefinitionID, uint256 amount) = abi.decode(data, (uint256, uint256));
        uint256 price = prices[itemDefinitionID];

        require(price > 0, "Price for the item is not set");

        require(msg.value == price * amount, "Insufficient funds to purchase item");

        // Mint the purchased item to the player
        // Assume that `mintTo` function requires definitionId instead of tokenId
        inventoryRegistry.mintTo(player, amount, itemDefinitionID, true);

        emit ItemPurchased(player, itemDefinitionID, 1);
    }
}
