// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../InventoryBehavior.sol";
import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

/// @title PurchaseItemWithETH
/// @notice Inventory behavior for purchasing items with ETH
contract PurchaseItemWithETH is InventoryBehavior, Owned, Initializable {
    mapping(uint256 => uint256) public listings;

    event ListingSet(uint256 indexed itemDefinitionID, uint256 indexed price);
    event ListingRemoved(uint256 indexed itemDefinitionID);
    event ItemPurchased(address indexed player, uint256 indexed itemDefinitionID, uint256 amount);

    constructor(address _owner, address _controller, IInventoryRegistry _registry)
        Owned(_owner)
        InventoryBehavior(_controller, _registry)
    {}

    /// @dev Called once after cloned via factory, acts as a constructor
    /// @param data ABI-encoded address of owner, controller, and registry
    function init(bytes calldata data) external payable initializer {
        (owner, controller, registry) = abi.decode(data, (address, address, IInventoryRegistry));
    }

    /// @notice Sets the price for an item
    /// @param itemDefinitionID ID of the item definition
    /// @param price Price of the item
    function set(uint256 itemDefinitionID, uint256 price) public onlyOwner {
        require(price > 0, "Price must be greater than 0");
        listings[itemDefinitionID] = price;
        emit ListingSet(itemDefinitionID, price);
    }

    /// @notice Removes the price for an item
    /// @param itemDefinitionID ID of the item definition
    function remove(uint256 itemDefinitionID) public onlyOwner {
        require(listings[itemDefinitionID] > 0, "Item isn't listed");
        delete listings[itemDefinitionID];
        emit ListingRemoved(itemDefinitionID);
    }

    /// @notice Mint item(s) to a player in exchange for ETH
    /// @param player Player to mint the item to
    /// @param data ABI-encoded item definition ID and amount
    function execute(address player, bytes calldata data) public payable override onlyController {
        (uint256 itemDefinitionID, uint256 amount) = abi.decode(data, (uint256, uint256));
        uint256 price = listings[itemDefinitionID];

        require(price > 0, "Item isn't listed");
        require(msg.value == price * amount, "Insufficient funds to purchase item");

        // FIXME listing might be or might not be fungible
        registry.mint(player, amount, itemDefinitionID, true);

        // FIXME user might purchase multiple items at once
        emit ItemPurchased(player, itemDefinitionID, 1);
    }
}
