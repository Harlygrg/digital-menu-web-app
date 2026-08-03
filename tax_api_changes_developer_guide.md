Tax API Changes – Client Developer Guide

Tax API Changes — Client App Developer Guide
**Audience:** Mobile / client app developers  

**Base URL:** `/api/v1`  

**Auth:** `Authorization: Bearer <jwt_token>` (required for all APIs in this doc)

---

1. What changed vs what is new
NEW (must handle in client)
Item

Where

Meaning

`taxmode`

`getTaxSettings` response

Branch tax mode: `0` = bill-wise, `1` = item-wise

`taxmode`

`createOrder` / `editOrder` request

Client should send the mode used for this order

`TaxId`

`getProductRelatedData` → each product

Default tax ID for the item (`itemmaster.TaxId`)

`TaxId`

`getProductRelatedData` → each modifier

Default tax ID for the modifier

`TaxId`

`createOrder` / `editOrder` → each `orderDtls` line

Required when `taxmode = 1`

`TaxAmnt`

`orderDtls` line

Line-level tax amount (required for item-wise)

Line `taxpercent`

`orderDtls` line

Must match `taxmaster.TaxPercentage` (±0.05)

Line `taxtype`

`orderDtls` line

Must match `taxmaster.TaxType` (case-insensitive)

Line `taxname`

`orderDtls` line

Optional label; useful to store with the line

Line `ItmCancld`

`orderDtls` line

`0` = active line (validated); `1` = cancelled (skipped)

 

CHANGED (existing fields, new rules)
Item

Before

Now

Order tax validation

Header metadata mostly optional / soft

Strict by `taxmode` when `havetax = true`

Bill-wise (`taxmode = 0`)

Header tax fields loosely used

If header `taxamnt > 0`, header `taxpercent` **must be > 0**

Item-wise (`taxmode = 1`)

Not supported

Each active line needs valid `TaxId` + matching % / type; header `taxamnt` must equal **sum of line `TaxAmnt`** (±0.05)

`getTaxSettings`

Returned `tax_enabled` + `taxes`

Also returns **`taxmode`**

`getProductRelatedData`

Products/modifiers without tax

Products and modifiers include **`TaxId`**

 

UNCHANGED
• Header fields still exist: `taxamnt`, `taxtype`, `taxname`, `taxpercent`
• If branch `havetax = false` (`tax_enabled = false`), **tax validation is skipped**
• Server does **not** calculate tax for you — client calculates and sends values
• Success response shapes of create/edit order are the same (order ids only)
---

2. Recommended client flow
Code Example

1. Call GET /getTaxSettings?branch_id=...

  → read tax_enabled + taxmode + taxes[]

 

2. Call GET /getProductRelatedData?branch_id=...

  → read TaxId on each product / modifier

 

3. Build cart:

  - If taxmode = 0 (bill-wise):

      calculate one tax on bill → send header taxamnt + taxpercent (+ taxtype/taxname)

  - If taxmode = 1 (item-wise):

      for each line, use product/modifier TaxId

      lookup taxmaster row from getTaxSettings.taxes

      set line TaxId, taxpercent, taxtype, taxname, TaxAmnt

      set header taxamnt = sum(line TaxAmnt)

 

4. POST /createOrder (or POST /editOrder)

---

3. Validation rules (server)
When `tax_enabled` / `havetax` is false
Tax validation is **skipped**. Order can be placed without tax fields.

When tax is enabled
#### `taxmode` must be valid

• Allowed: `0` (bill-wise), `1` (item-wise)
• Else error: `taxmode must be 0 (bill-wise) or 1 (item-wise)`
• If client omits `taxmode`, server falls back to branch `appsettings.taxmode` (or `0`)
#### `taxmode = 0` (bill-wise)

• If header `taxamnt > 0` → header `taxpercent` must be present and `> 0`
• Else error: `Bill-wise tax requires HDR taxpercent when Taxamnt > 0`
#### `taxmode = 1` (item-wise)

For each non-cancelled line (`ItmCancld = 0`):

1. `TaxId` required and `> 0`

2. `TaxId` must exist in **active** `taxmaster` for that branch

3. Line `taxpercent` must match taxmaster percentage (tolerance **0.05**)

4. Line `taxtype` must match taxmaster `TaxType` (case-insensitive)

5. Header `taxamnt` must equal sum of line `TaxAmnt` (tolerance **0.05**)

Cancelled lines (`ItmCancld = 1`) are ignored for tax checks/sum.

---

4. API details with dummy request / response
---

4.1 GET `/getTaxSettings`
**What is NEW:** response field `taxmode`

#### Request

Code Example

GET /api/v1/getTaxSettings?branch_id=2

Authorization: Bearer <jwt_token>

Query

Type

Required

Description

`branch_id`

integer

Yes

Branch / CID

 

#### Success response `200`

Code Example

{

 "success": true,

 "message": "Tax settings retrieved successfully",

 "data": {

   "branch_id": 2,

   "tax_enabled": true,

   "taxmode": 1,

   "taxes": [

     {

       "ID": 1,

       "TaxType": "exclusive",

       "TaxName": "VAT 5%",

       "TaxPercentage": 5,

       "gstsplit": false,

       "UserID": 1,

       "Date": "2026-07-28 10:00:00",

       "ModifiedBy": null,

       "MDate": null,

       "active": 1,

       "isUploaded": 0,

       "CID": 2

     },

     {

       "ID": 2,

       "TaxType": "inclusive",

       "TaxName": "GST 12%",

       "TaxPercentage": 12,

       "gstsplit": true,

       "UserID": 1,

       "Date": "2026-07-28 10:05:00",

       "ModifiedBy": null,

       "MDate": null,

       "active": 1,

       "isUploaded": 0,

       "CID": 2

     }

   ]

 }

}

#### Field notes for client

• `tax_enabled = false` → do not apply tax UI rules; tax validation skipped on create/edit
• `taxmode = 0` → bill-wise UI
• `taxmode = 1` → item-wise UI; use `taxes[]` + product `TaxId`
• Use `taxes[].ID` as `TaxId` on order lines
• Use `TaxType` / `TaxPercentage` / `TaxName` when filling line tax fields
---

4.2 GET `/getProductRelatedData`
**What is NEW:** `TaxId` on products and modifiers

#### Request

Code Example

GET /api/v1/getProductRelatedData?branch_id=2&ordertypeid=8

Authorization: Bearer <jwt_token>

Query

Type

Required

Description

`branch_id`

integer

Yes

Branch / CID

`ordertypeid`

integer

No

Order-type price override

 

#### Success response `200` (tax-related parts highlighted)

Code Example

{

 "success": true,

 "data": {

   "message": "Product related data retrieved successfully",

   "branch_id": 2,

   "categories": [

     {

       "Id": 10,

       "Category": "Burgers",

       "Inactive": 0,

       "CID": 2

     }

   ],

   "modifiers": [

     {

       "ID": 11,

       "modifier": "Extra Cheese",

       "Rate": "2.00",

       "Date": "2026-07-11 02:17:00",

       "UserID": 1,

       "DescriptionOl": "Extra cheese",

       "TaxId": 1,

       "isUploaded": 0,

       "CID": 2,

       "other_lang": null

     }

   ],

   "products": [

     {

       "Id": 60,

       "Iname": "Chicken Burger",

       "Icode": "60",

       "CategoryId": 10,

       "Price": "100.00",

       "TaxId": 1,

       "is_available_in_online": 1,

       "related_modifiers": [11],

       "UnitPriceList": [

         {

           "unit_fk_id": 1,

           "price": "100.00",

           "unit_name": "PCS",

           "other_lang": "",

           "is_main_unit": true

         }

       ]

     },

     {

       "Id": 61,

       "Iname": "Veg Wrap",

       "Icode": "61",

       "CategoryId": 10,

       "Price": "80.00",

       "TaxId": 2,

       "is_available_in_online": 1,

       "related_modifiers": [],

       "UnitPriceList": [

         {

           "unit_fk_id": 1,

           "price": "80.00",

           "unit_name": "PCS",

           "other_lang": "",

           "is_main_unit": true

         }

       ]

     }

   ]

 }

}

#### Client usage

• Product line: take `products[].TaxId`
• Modifier line: take `modifiers[].TaxId`
• `TaxId` may be `null` — if `taxmode = 1` and line is active, client must still send a valid TaxId (resolve from branch defaults / UI / backend master)
---

4.3 POST `/createOrder` — bill-wise (`taxmode = 0`)
**What is NEW:** request field `taxmode`  

**What is CHANGED:** if `taxamnt > 0`, `taxpercent` must be `> 0`

#### Request

Code Example

POST /api/v1/createOrder

Authorization: Bearer <jwt_token>

Content-Type: application/json

Code Example

{

 "grosstotal": 100,

 "discount": 0,

 "servicecharge": 0,

 "nettotal": 105,

 "taxamnt": 5,

 "taxmode": 0,

 "taxpercent": 5,

 "taxtype": "exclusive",

 "taxname": "VAT 5%",

 "tableID": 1,

 "OrderType": "8",

 "cid": 2,

 "no_of_guest": 2,

 "orderNotes": "No onion",

 "roundoff": 0,

 "orderDtls": [

   {

     "slno": 1,

     "itmId": 60,

     "itmremarks": "",

     "qty": 1,

     "unitID": 1,

     "rate": 100,

     "total": 100,

     "itmType": 0

   }

 ]

}

> For bill-wise, line tax fields are **not required**. Header tax is enough.

#### Success response `200`

Code Example

{

 "success": true,

 "data": {

   "message": "Order created successfully",

   "orderid": 402041,

   "online_order_id": 740108,

   "OrderNo": 134647

 }

}

---

4.4 POST `/createOrder` — item-wise (`taxmode = 1`)
**What is NEW:** per-line tax fields + header `taxamnt` = sum of line taxes

#### Request

Code Example

{

 "grosstotal": 180,

 "discount": 0,

 "servicecharge": 0,

 "nettotal": 189.6,

 "taxamnt": 9.6,

 "taxmode": 1,

 "tableID": 1,

 "OrderType": "8",

 "cid": 2,

 "no_of_guest": 1,

 "roundoff": 0,

 "orderDtls": [

   {

     "slno": 1,

     "itmId": 60,

     "itmremarks": "",

     "qty": 1,

     "unitID": 1,

     "rate": 100,

     "total": 100,

     "itmType": 0,

     "TaxId": 1,

     "TaxAmnt": 5,

     "taxpercent": 5,

     "taxtype": "exclusive",

     "taxname": "VAT 5%",

     "ItmCancld": 0

   },

   {

     "slno": 2,

     "itmId": 61,

     "itmremarks": "",

     "qty": 1,

     "unitID": 1,

     "rate": 80,

     "total": 80,

     "itmType": 0,

     "TaxId": 2,

     "TaxAmnt": 4.6,

     "taxpercent": 12,

     "taxtype": "inclusive",

     "taxname": "GST 12%",

     "ItmCancld": 0

   }

 ]

}

#### Important math check

Code Example

header taxamnt (9.6)  ==  line1 TaxAmnt (5) + line2 TaxAmnt (4.6)

#### Success response `200`

Same shape as bill-wise create success.

---

4.5 POST `/editOrder`
**What is NEW:** `taxmode` + line tax fields on add/update  

**What is CHANGED:** when tax/totals/lines change, server validates against **final order state** (existing lines + add/update − remove)

#### Request

Code Example

POST /api/v1/editOrder

Authorization: Bearer <jwt_token>

Content-Type: application/json

Code Example

{

 "order_id": 402041,

 "taxmode": 1,

 "taxamnt": 15,

 "grosstotal": 280,

 "nettotal": 295,

 "orderDtls": [

   {

     "action": "update",

     "pk_id": 123456,

     "qty": 2,

     "rate": 100,

     "total": 200,

     "TaxId": 1,

     "TaxAmnt": 10,

     "taxpercent": 5,

     "taxtype": "exclusive",

     "taxname": "VAT 5%",

     "ItmCancld": 0

   },

   {

     "action": "add",

     "slno": 3,

     "itmId": 70,

     "qty": 1,

     "unitID": 1,

     "rate": 80,

     "total": 80,

     "itmType": 0,

     "TaxId": 1,

     "TaxAmnt": 5,

     "taxpercent": 5,

     "taxtype": "exclusive",

     "taxname": "VAT 5%",

     "ItmCancld": 0

   },

   {

     "action": "remove",

     "pk_id": 123457

   }

 ]

}

#### Success response `200`

Code Example

{

 "success": true,

 "data": {

   "message": "Order edited successfully",

   "orderid": 402041,

   "online_order_id": 740108,

   "OrderNo": 134647,

   "items_added": 1,

   "items_updated": 1,

   "items_removed": 1

 }

}

#### Edit notes for client

• After add/update/remove, recalculate:
 - each remaining active line tax

 - header `taxamnt` = sum of remaining active line `TaxAmnt`

• Send updated header `taxamnt` in the same request when changing lines under item-wise mode
---

5. Error responses (dummy)
Tax / validation failures typically return **HTTP 422**.

Invalid taxmode
Code Example

{

 "success": false,

 "message": "The given data was invalid.",

 "errors": {

   "taxmode": [

     "taxmode must be 0 (bill-wise) or 1 (item-wise)"

   ]

 }

}

Bill-wise: tax amount without tax percent
Code Example

{

 "success": false,

 "message": "The given data was invalid.",

 "errors": {

   "taxpercent": [

     "Bill-wise tax requires HDR taxpercent when Taxamnt > 0"

   ]

 }

}

Item-wise: missing TaxId on a line
Code Example

{

 "success": false,

 "message": "The given data was invalid.",

 "errors": {

   "orderDtls.0.TaxId": [

     "TaxId is required and must be > 0 for item-wise tax"

   ]

 }

}

Item-wise: TaxId not in active taxmaster
Code Example

{

 "success": false,

 "message": "The given data was invalid.",

 "errors": {

   "orderDtls.0.TaxId": [

     "TaxId must exist in active taxmaster"

   ]

 }

}

Item-wise: percent mismatch
Code Example

{

 "success": false,

 "message": "The given data was invalid.",

 "errors": {

   "orderDtls.0.taxpercent": [

     "Line taxpercent must match taxmaster percentage"

   ]

 }

}

Item-wise: taxtype mismatch
Code Example

{

 "success": false,

 "message": "The given data was invalid.",

 "errors": {

   "orderDtls.0.taxtype": [

     "Line taxtype must match taxmaster TaxType"

   ]

 }

}

Item-wise: header tax ≠ sum of line taxes
Code Example

{

 "success": false,

 "message": "The given data was invalid.",

 "errors": {

   "taxamnt": [

     "HDR TaxAmnt must equal sum of line TaxAmnt"

   ]

 }

}

> Note: depending on Laravel/exception handling, message text may appear as `The given data was invalid.` or the first validation message. Always read `errors` object.

---

6. Field cheat-sheet
Header (order) fields
Field

Type

Bill-wise

Item-wise

 

`taxmode`

int `0\

1`

Send `0`

Send `1`

`taxamnt`

number

Required on create

Required on create; must = sum of line `TaxAmnt`

 

`taxpercent`

number

Required if `taxamnt > 0`

Not used for item-wise validation

 

`taxtype`

string

Recommended

Optional on header

 

`taxname`

string

Recommended

Optional on header

 

 

Line (`orderDtls[]`) fields
Field

Type

Bill-wise

Item-wise (active lines)

 

`TaxId`

int

Optional

**Required**, must be active taxmaster ID

 

`TaxAmnt`

number

Optional

**Required for sum check**

 

`taxpercent`

number

Optional

**Required**, match taxmaster (±0.05)

 

`taxtype`

string

Optional

**Required**, match taxmaster (case-insensitive)

 

`taxname`

string

Optional

Recommended

 

`ItmCancld`

`0\

1`

Optional (default 0)

`0` validated; `1` skipped

 

---

7. Client checklist (accommodate this change)
1. Read `taxmode` from `getTaxSettings`.

2. Read `TaxId` from products and modifiers in `getProductRelatedData`.

3. Keep a local map of `taxes[]` by `ID`.

4. Branch UI:

  - `taxmode = 0` → one tax on bill

  - `taxmode = 1` → tax per cart line using item/modifier TaxId

5. Always send `taxmode` on create/edit.

6. For item-wise:

  - fill line tax fields from taxmaster

  - set `taxamnt` = sum of line `TaxAmnt`

7. On edit with line changes, recompute final tax totals before submit.

8. Handle 422 `errors` messages listed above and show user-friendly text.

9. If `tax_enabled = false`, skip tax UI and send `taxamnt: 0` (or existing app default).

---

8. Quick dummy values you can paste in Postman
Name

Value

Branch

`2`

JWT

your token

Tax A

`ID=1`, type=`exclusive`, percent=`5`

Tax B

`ID=2`, type=`inclusive`, percent=`12`

Product A

`itmId=60`, `TaxId=1`, rate=`100`

Product B

`itmId=61`, `TaxId=2`, rate=`80`

 

**Bill-wise sample tax:** `taxamnt=5`, `taxpercent=5`, `taxmode=0`  

**Item-wise sample tax:** lines `5 + 4.6`, header `taxamnt=9.6`, `taxmode=1`

---

9. Affected APIs summary
API

Method

Change type

`/getTaxSettings`

GET

**NEW** field: `taxmode`

`/getProductRelatedData`

GET

**NEW** field: `TaxId` on products & modifiers

`/createOrder`

POST

**NEW** `taxmode` + line tax fields; **CHANGED** validation

`/editOrder`

POST

**NEW** `taxmode` + line tax fields; **CHANGED** final-state validation

 

---

*Doc generated for taxmode / item-wise tax API alignment. Use with latest backend on `main`.*