# Wire Protocol Reference

Frames are line-based. Each line is `<VERB> <args...>\n`. JSON payloads
are single-line UTF-8.

## Shop (Phase 3)

| Verb           | Direction | Args                                              |
| -------------- | --------- | ------------------------------------------------- |
| `SHOP_OPEN`    | S→C       | `<shop_id> <json>` — open the modal with stock    |
| `SHOP_UPDATE`  | S→C       | `<shop_id> <json>` — refresh stock + multiplier   |
| `SHOP_CLOSE`   | S↔C       | (no args) — client requests close / server ack    |
| `SHOP_BUY`     | C→S       | `<shop_id> <slot_idx> <qty>` — buy from slot      |
| `SHOP_SELL`    | C→S       | `<inv_slot_idx> <qty>` — sell from open shop      |
| `SAVE_SHOP_DEF`| C→S       | `<json>` — editor persists ShopDef to disk        |

`SHOP_OPEN` / `SHOP_UPDATE` JSON shape:

```json
{
  "id": "village_shop",
  "name": "Vila",
  "buy_multiplier": 0.5,
  "items": [
    { "item_id": "potion", "qty": 3, "max": 3, "price": 10 }
  ]
}
```

`qty` is the live stock; `max` is the def's stock cap (0 means unlimited).
`buy_multiplier` is what the shop pays for items the player sells —
0.5 means "50% of `ItemDef.Value`".

### Server-side gating

`SHOP_BUY` and `SHOP_SELL` require `Player.OpenShop == shop_id`. The
flag is set by `SHOP_OPEN` (which the merchant NPC fires on `TALK`) and
cleared by `SHOP_CLOSE`. Stock is refilled per slot when
`RestockSec > 0` seconds elapse since the last buy that took the slot
below max.
