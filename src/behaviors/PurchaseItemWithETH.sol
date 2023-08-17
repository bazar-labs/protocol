// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BaseBehavior.sol";
import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract PurchaseItemWithETH is BaseBehavior, Owned, Initializable {
    mapping(uint256 => uint256) public listings;

    event ListingSet(uint256 indexed itemDefinitionID, uint256 indexed price);
    event ListingRemoved(uint256 indexed itemDefinitionID);
    event ItemPurchased(address indexed player, uint256 indexed itemDefinitionID, uint256 amount);

    constructor(address _owner, address _controller, IInventoryRegistry _registry) Owned(_owner) BaseBehavior(_controller, _registry) {}

    function init(bytes calldata data) external payable initializer {
        (owner, controller, registry) = abi.decode(data, (address, address, IInventoryRegistry));
    }

    function set(uint256 itemDefinitionID, uint256 price) public onlyOwner {
        listings[itemDefinitionID] = price;
        emit ListingSet(itemDefinitionID, price);
    }

    function remove(uint256 itemDefinitionID) public onlyOwner {
        require(listings[itemDefinitionID] != 0, "Item not found");
        delete listings[itemDefinitionID];
        emit ListingRemoved(itemDefinitionID);
    }

    function execute(address player, bytes calldata data) public payable override onlyController {
        (uint256 itemDefinitionID, uint256 amount) = abi.decode(data, (uint256, uint256));
        uint256 price = listings[itemDefinitionID];

        require(price > 0, "Price for the item is not set");
        require(msg.value == price * amount, "Insufficient funds to purchase item");

        registry.mint(player, amount, itemDefinitionID, true);

        emit ItemPurchased(player, itemDefinitionID, 1);
    }
}
