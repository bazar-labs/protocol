// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BaseBehavior.sol";
import "solmate/auth/Owned.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract OpenLootboxBehavior is BaseBehavior, Owned, Initializable {
    struct LootID {
        uint256 itemDefinitionId;
        uint256 weight;
    }

    // mapping(uint256 lootboxID => LootID[] items) public lootTableItems;
    mapping(uint256 => LootID[]) public lootTableItems;

    event LootboxOpened(address indexed player, uint256 indexed lootboxID, uint256[] itemDefinitionIds);

    constructor(address _owner, address inventoryController_, IInventoryRegistry inventoryRegistry_)
        Owned(_owner)
        BaseBehavior(inventoryController_, inventoryRegistry_)
    {}

    function init(bytes calldata data) external payable initializer {
        (owner, inventoryController, inventoryRegistry) = abi.decode(data, (address, address, IInventoryRegistry));
    }

    function setLootbox(uint256 lootboxID, LootID[] memory items) public onlyGame {
        delete lootTableItems[lootboxID];
        for (uint256 i = 0; i < items.length; i++) {
            lootTableItems[lootboxID].push(items[i]);
        }
    }

    function deleteLootbox(uint256 lootboxID) public onlyOwner {
        require(lootTableItems[lootboxID].length > 0, "Lootbox not found");
        delete lootTableItems[lootboxID];
    }

    function execute(address player, bytes calldata data) public payable override onlyGame nonPayable {
        uint256 lootboxID = abi.decode(data, (uint256));
        _openLootbox(player, lootboxID);
    }

    function _openLootbox(address player, uint256 lootboxID) internal {
        require(lootTableItems[lootboxID].length > 0, "Loot box is empty or not set");

        uint256 lootboxTokenId = inventoryRegistry.itemDefIDToTokenIDs(lootboxID, 0);

        inventoryRegistry.burnFrom(player, lootboxTokenId, 1);

        uint256[] memory droppedItemDefinitionIds = _calculateDrop(getRandomNumber(), lootboxID);

        for (uint256 i = 0; i < droppedItemDefinitionIds.length; i++) {
            // mint each item to the player (assuming that `mintTo` function requires definitionId instead of tokenId)
            inventoryRegistry.mintTo(player, 1, droppedItemDefinitionIds[i], true);
        }
        emit LootboxOpened(player, lootboxID, droppedItemDefinitionIds);
    }

    function _calculateDrop(uint256 randomness, uint256 lootboxID) internal view returns (uint256[] memory) {
        LootID[] memory LootIDs = lootTableItems[lootboxID];

        uint256 totalWeight = 0;
        for (uint256 i = 0; i < LootIDs.length; i++) {
            totalWeight += LootIDs[i].weight;
        }

        // Create a dynamic array to store the dropped items
        uint256[] memory droppedItems = new uint256[](LootIDs.length);
        uint256 itemCount = 0;

        for (uint256 i = 0; i < LootIDs.length; i++) {
            uint256 dropChance = (randomness + i) % totalWeight; // Use 'i' to introduce variability
            if (dropChance < LootIDs[i].weight) {
                droppedItems[itemCount] = LootIDs[i].itemDefinitionId;
                itemCount++;
            }
        }

        // Resize the array to fit the number of dropped items
        uint256[] memory finalDroppedItems = new uint256[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            finalDroppedItems[i] = droppedItems[i];
        }

        return finalDroppedItems;
    }

    function getRandomNumber() internal view returns (uint256) {
        // This is NOT a secure way to generate randomness and can be gamed by miners or other malicious actors.
        // For real use cases, consider using a secure, verified randomness source like Chainlink VRF.
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
    }
}
