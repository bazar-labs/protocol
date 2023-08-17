- always regenarate the mappings via `forge remappings > remappings.txt`

## Generate Interfaces

Run command below to generate the interfaces

```bash
forge build && \
cast interface -n IInventoryController -o ./src/interfaces/IInventoryController.sol ./out/InventoryController.sol/InventoryController.json && \
cast interface -n IInventoryRegistry -o ./src/interfaces/IInventoryRegistry.sol ./out/InventoryRegistry.sol/InventoryRegistry.json && \
cast interface -n IBaseBehavior -o ./src/interfaces/IBaseBehavior.sol ./out/BaseBehavior.sol/BaseBehavior.json
```
