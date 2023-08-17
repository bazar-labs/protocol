// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/InventoryRegistry.sol";

contract Setup {
    InventoryRegistry registry;
    address owner = address(this);
    address player = address(0x1);

    constructor() {
        registry = new InventoryRegistry(owner);
        bytes memory data = abi.encode(owner);
        registry.init(data);
    }
}

contract Test_InventoryRegistry_create is Test, Setup {
    function test_should_create_item() public {
        string memory URI = "https://example.com/item1";
        registry.create(URI);
        assertEq(registry.itemDefinitionIDToURI(1), URI, "URI should be set");
    }

    function test_should_correctly_increment_item_definition_id_and_token_id() public {
        string memory URI1 = "https://example.com/item1";
        string memory URI2 = "https://example.com/item2";

        registry.create(URI1);
        registry.create(URI2);

        assertEq(registry.itemDefinitionIDToURI(1), URI1, "URI should be set");
        assertEq(registry.itemDefinitionIDToURI(2), URI2, "URI should be set");

        assertEq(registry.itemDefinitionIDToTokenIDs(1, 0), 1, "Token ID should be 1");
        assertEq(registry.itemDefinitionIDToTokenIDs(2, 0), 2, "Token ID should be 2");
    }

    function test_should_not_create_item_if_not_owner() public {
        vm.prank(player);
        vm.expectRevert(bytes("UNAUTHORIZED"));
        registry.create("https://example.com/item1");
    }
}

contract Test_InventoryRegistry_update is Test, Setup {
    function test_should_update_item_uri() public {
        registry.create("https://example.com/item1");
        string memory newURI = "https://example.com/item1_updated";
        registry.update(1, newURI);
        assertEq(registry.itemDefinitionIDToURI(1), newURI, "URI should be updated");
    }

    function test_should_not_update_item_uri_if_not_owner() public {
        registry.create("https://example.com/item1");
        string memory newURI = "https://example.com/item1_updated";
        vm.prank(player);
        vm.expectRevert(bytes("UNAUTHORIZED"));
        registry.update(1, newURI);
    }

    function test_should_not_update_item_uri_if_item_does_not_exist() public {
        vm.expectRevert(bytes("Item definition does not exist"));
        registry.update(1, "https://example.com/item1_updated");
    }
}

contract Test_InventoryRegistry_publish_unpublish is Test, Setup {
    function test_should_publish_then_unpublish_an_item() public {
        registry.create("https://example.com/item1");
        registry.publish(1);
        assertEq(registry.isItemDefinitionIDPublished(1), true, "Item should be published");
        registry.unpublish(1);
        assertEq(registry.isItemDefinitionIDPublished(1), false, "Item should be unpublished");
    }
}

contract Test_InventoryRegistry_mint is Test, Setup {
    function test_should_mint_the_correct_amount_of_fungible_items() public {
        registry.create("https://example.com/item1");
        assertEq(registry.balanceOf(player, 1), 0, "Balance should be 0");
        registry.mint(player, 1, 10, true);
        assertEq(registry.balanceOf(player, 1), 10, "Balance should be 10");
    }
}

contract Test_InventoryRegistry_burn is Test, Setup {
    function test_should_burn_the_correct_amount_of_fungible_items() public {
        registry.create("https://example.com/item1");
        registry.mint(player, 1, 50, true);
        vm.prank(player);
        registry.setApprovalForAll(owner, true);
        registry.burn(player, 1, 49);
        assert(registry.balanceOf(player, 1) == 1);
    }
}
