// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/InventoryRegistry.sol";

contract InventoryRegistryTest is Test {
    InventoryRegistry registry;
    address owner = address(this);
    address player = address(0x1);

    constructor() {
        registry = new InventoryRegistry(owner);
        bytes memory data = abi.encode(owner);
        registry.init(data);
    }

    function test_create() public {
        string memory URI1 = "https://example.com/item1";
        string memory URI2 = "https://example.com/item2";
        registry.create(URI1);
        registry.create(URI2);
        assertEq(registry.itemDefinitionIDToURI(1), URI1, "URI should be set");
        assertEq(registry.itemDefinitionIDToURI(2), URI2, "URI should be set");
    }

    function test_update() public {
        registry.create("https://example.com/item1");
        string memory newURI = "https://example.com/item1_updated";
        registry.update(1, newURI);
        assertEq(registry.itemDefinitionIDToURI(1), newURI, "URI should be updated");
    }

    function test_publish_unpublish() public {
        registry.create("https://example.com/item1");
        registry.publish(1);
        assertEq(registry.isItemDefinitionIDPublished(1), true, "Item should be published");
        registry.unpublish(1);
        assertEq(registry.isItemDefinitionIDPublished(1), false, "Item should be unpublished");
    }

    function test_mint() public {
        registry.create("https://example.com/item1");
        assertEq(registry.balanceOf(player, 1), 0, "Balance should be 0");
        registry.mint(player, 1, 10, true);
        assertEq(registry.balanceOf(player, 1), 10, "Balance should be 10");
    }

    function test_burn() public {
        registry.create("https://example.com/item1");
        registry.mint(player, 1, 50, true);
        vm.prank(player); // set transaction sender to player for a single transaction
        registry.setApprovalForAll(owner, true); // approve owner to burn item on player's behalf
        registry.burn(player, 1, 49);
        assert(registry.balanceOf(player, 1) == 1);
    }
}
