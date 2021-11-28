local g = import 'general.lib.jsonnet';

{
  "bio1": {
    "name": "GRANT_BIO1",
    "amount": 150,
    "specialty_uid": g.biology.name,
    "difficulty": 1
  },
  "bio2": {
    "name": "GRANT_BIO2",
    "amount": 200,
    "specialty_uid": g.biology.name,
    "difficulty": 20
  },
  "phys1": {
    "name": "GRANT_PHYS1",
    "amount": 170,
    "specialty_uid": g.physics.name,
    "difficulty": 15
  },
  "phys2": {
    "name": "GRANT_PHYS2",
    "amount": 240,
    "specialty_uid": g.physics.name,
    "level": 2,
    "difficulty": 25
  }
}
