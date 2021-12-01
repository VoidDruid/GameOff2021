# For each item (name, icon_id, price, modifiers) is a unique index
local build_uid(obj) = std.md5(obj.name + obj.icon_id + obj.price + obj.modifiers);

{
  "printer": {
    "name": "PRINTER_",
    "uid": build_uid(self),
    "icon_id": "0",
    "price": 1000,
    "modifiers": [
      {
        "value": 0.05,
        "property": "breakthrough_chance"
      }
    ]
  }
}
