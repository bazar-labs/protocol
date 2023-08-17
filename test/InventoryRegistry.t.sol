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
        uint256 id = registry.create(URI);
        assertEq(registry.itemDefinitionIDToURI(id), URI, "URI should be set");
    }

    function test_should_not_create_item_if_uri_is_empty() public {
        vm.expectRevert(bytes("URI is empty"));
        registry.create("");
    }

    function test_should_correctly_increment_item_definition_id_and_token_id() public {
        string memory URI1 = "https://example.com/item1";
        string memory URI2 = "https://example.com/item2";

        uint256 id1 = registry.create(URI1);
        uint256 id2 = registry.create(URI2);

        assertEq(registry.itemDefinitionIDToURI(id1), URI1, "URI should be set");
        assertEq(registry.itemDefinitionIDToURI(id2), URI2, "URI should be set");

        assertEq(registry.itemDefinitionIDToTokenIDs(id1, 0), 1, "Token ID should be 1");
        assertEq(registry.itemDefinitionIDToTokenIDs(id2, 0), 2, "Token ID should be 2");
    }

    function test_should_not_create_item_if_not_owner() public {
        vm.prank(player);
        vm.expectRevert(bytes("UNAUTHORIZED"));
        registry.create("https://example.com/item1");
    }
}

contract Test_InventoryRegistry_update is Test, Setup {
    function test_should_update_item_uri() public {
        uint256 id = registry.create("https://example.com/item1");
        string memory newURI = "https://example.com/item1_updated";
        registry.update(id, newURI);
        assertEq(registry.itemDefinitionIDToURI(id), newURI, "URI should be updated");
    }

    function test_should_not_update_item_uri_if_uri_is_empty() public {
        uint256 id = registry.create("https://example.com/item1");
        vm.expectRevert(bytes("URI is empty"));
        registry.update(id, "");
    }

    function test_should_not_update_item_uri_if_not_owner() public {
        uint256 id = registry.create("https://example.com/item1");
        string memory newURI = "https://example.com/item1_updated";
        vm.prank(player);
        vm.expectRevert(bytes("UNAUTHORIZED"));
        registry.update(id, newURI);
    }

    function test_should_not_update_item_uri_if_item_does_not_exist() public {
        vm.expectRevert(bytes("Item definition does not exist"));
        registry.update(404, "https://example.com/item1_updated");
    }
}

contract Test_InventoryRegistry_publish_unpublish is Test, Setup {
    function test_should_publish_then_unpublish_an_item() public {
        uint256 id = registry.create("https://example.com/item1");

        registry.publish(id);
        assertEq(registry.isItemDefinitionIDPublished(id), true, "Item should be published");

        registry.unpublish(id);
        assertEq(registry.isItemDefinitionIDPublished(id), false, "Item should be unpublished");
    }

    function test_should_not_publish_if_not_owner() public {
        uint256 id = registry.create("https://example.com/item1");

        vm.prank(player);
        vm.expectRevert(bytes("UNAUTHORIZED"));
        registry.publish(id);

        vm.prank(player);
        vm.expectRevert(bytes("UNAUTHORIZED"));
        registry.unpublish(id);
    }
}

contract Test_InventoryRegistry_mint is Test, Setup {
    function test_should_mint_the_correct_amount_of_fungible_items() public {
        uint256 id = registry.create("https://example.com/item1");
        registry.publish(id);
        assertEq(registry.balanceOf(player, id), 0, "Balance should be 0");
        registry.mint(player, id, 10, true);
        assertEq(registry.balanceOf(player, id), 10, "Balance should be 10");
    }

    function test_should_not_mint_if_not_owner() public {
        uint256 id = registry.create("https://example.com/item1");
        vm.prank(player);
        vm.expectRevert(bytes("UNAUTHORIZED"));
        registry.mint(player, id, 10, true);
    }

    function test_should_not_mint_if_item_does_not_exist() public {
        vm.expectRevert(bytes("Item definition does not exist"));
        registry.mint(player, 404, 10, true);
    }

    function test_should_not_mint_if_item_is_not_published() public {
        uint256 id = registry.create("https://example.com/item1");
        vm.expectRevert(bytes("Item definition is not published"));
        registry.mint(player, id, 10, true);
    }
}

contract Test_InventoryRegistry_burn is Test, Setup {
    function test_should_burn_the_correct_amount_of_fungible_items() public {
        uint256 id = registry.create("https://example.com/item1");
        registry.publish(id);
        registry.mint(player, id, 50, true);
        vm.prank(player);
        registry.setApprovalForAll(owner, true);
        registry.burn(player, id, 49);
        assert(registry.balanceOf(player, id) == 1);
    }
}
