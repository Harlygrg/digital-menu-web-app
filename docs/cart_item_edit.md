# Cart item edit / update flow

## Overview

Users can open the same **Add to cart** customization dialog from the cart screen to change size, add-ons, and special instructions for an existing line. **Line quantity is fixed** in this dialog; quantity is still changed only from the cart row controls.

## Data flow

1. **Cart screen** (`lib/views/cart/cart_screen.dart`): **Edit** resolves add-ons via `HomeProvider.getModifiersForProduct(cartItem.item.id)` and calls `showAddToCartPopup` with `editingCartItem: cartItem`, `item`, `sizes: item.unitPriceList`, and `addons`.
2. **Popup** (`lib/views/home/widgets/add_to_cart_popup.dart`): With `editingCartItem` set, initial state is filled from the line; the quantity stepper is replaced by a read-only quantity; the primary action is **Update** (EN) / **تحديث** (AR). Submit builds the same payload shape as add-to-cart and calls `CartController.updateCartItemFromPopup` instead of `addToCartFromPopup`.
3. **Controller** (`lib/controllers/cart_controller.dart`): `updateCartItemFromPopup` builds a candidate `CartItemModel` using `_buildCartItemModelFromPopupPayload` (shared with add), forces **quantity** to the existing line’s quantity, then applies remove / merge / insert (see below).

## Merge and no-op rules

- **Same configuration as add:** `_findExistingItemIndex` treats two lines as mergeable when they share the same `item.id`, same `selectedUnit?.unitFkId`, and the same modifier list **length and index-wise** `id` and `quantity` (as in add-to-cart). It does **not** compare `specialInstructions` for merge.
- **Edit no-op (case D):** If the new payload would not change the line, the controller returns without writing Hive or notifying. No-op compares:
  - same unit (`unitFkId`),
  - trimmed special instructions,
  - positive-qty modifiers **by id and quantity**, order-insensitive (so lines that only differ by zero-qty modifier rows or stored order still no-op when the popup payload matches).

## Edit update algorithm (cases A–E)

1. Availability is checked (`checkProductAvailability`), same as add.
2. Build **candidate** line from payload with `quantity = existing.quantity`.
3. If **no-op**, return `false` (no persistence).
4. Otherwise **remove** the old line at its index.
5. Run `_findExistingItemIndex(candidate)` on the **remaining** list:
   - **Merge (case E):** If another row matches, add `candidate.quantity` to that row’s quantity.
   - **In-place replace (cases A–C):** If no match, **insert** the candidate at the **same index** the old line had, with **`id` copied from the old line** so quantity/modifier/remove actions keyed by `id` stay valid.

## Edge cases

| Case | Behavior |
|------|----------|
| A–C Variant / add-ons / note change | Old line removed; new configuration merged or inserted at old index with preserved line `id`. |
| D No effective change | No Hive write; popup shows a “no changes” message. |
| E Matches another row | After removing the edited line, quantities merge into the other row (same as add). |
| Product missing from menu | `getModifiersForProduct` throws; cart shows an error snackbar and does not open the dialog. |

## Files touched

- `lib/controllers/cart_controller.dart` — `_buildCartItemModelFromPopupPayload`, `_isEditNoop`, `updateCartItemFromPopup`, `addToCartFromPopup` refactored to use the shared builder.
- `lib/views/home/widgets/add_to_cart_popup.dart` — optional `editingCartItem`, edit UI and submit branch.
- `lib/views/cart/cart_screen.dart` — Edit control and `showAddToCartPopup` wiring.

## Related behavior (unchanged)

- Checkout and order payloads still consume `CartItemModel` lists as before.
- `syncCartPrices` / `needsPriceSync` are not altered by this feature.
