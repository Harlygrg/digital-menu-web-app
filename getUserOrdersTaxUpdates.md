What changed (highlight)

PLACE	              BEFORE	                                       AFTER
Header	            taxamnt, taxtype, taxname, taxpercent only	  + taxmode
Each line	          no tax	                                      + TaxId, TaxAmnt, taxpercent, taxtype,                                                                  taxname
getUserOrders 
lines	 —	                                                        + ItmCancld

Files updated:
GetUserOrdersController.php
OrderCopyToLocalController.php
TAX_API_CHANGES_CLIENT_GUIDE.md

Mode 0 — Bill-wise
GET /getUserOrders
Request
GET /api/v1/getUserOrders
Authorization: Bearer <token>
Response (key tax parts)
{
  "success": true,
  "orders": [{
    "taxamnt": 5,
    "taxmode": 0,
    "taxtype": "exclusive",
    "taxname": "VAT 5%",
    "taxpercent": 5,
    "order_details": [{
      "item_id": 60,
      "total": 100,
      "TaxId": null,
      "TaxAmnt": 0,
      "taxpercent": null,
      "taxtype": null,
      "taxname": null,
      "ItmCancld": 0
    }]
  }]
}
Use header tax. Line tax can be null/0.