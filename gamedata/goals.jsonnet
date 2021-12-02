local g = import 'general.lib.jsonnet';
local grants = import 'grants.jsonnet';

local REQUIRED_GRANTS = "_GRANTS_";
local description(obj) = obj.name + "DESCRIPTION";

{
  "bio_goal": {
    "name": "BIO_GOAL_",
    "description": description(self),
    "icon_uid": null,
    "requirements": {
      [g.biology.name]: 6,
      [g.physics.name]: 2,
      [REQUIRED_GRANTS]: [
        grants.bio_start.name,
      ]
    },
  },
  "phys_goal": {
    "name": "ENGINEER_GOAL_",
    "description": description(self),
    "icon_uid": null,
    "requirements": {
      [g.math.name]: 2,
      [g.physics.name]: 6,
      [REQUIRED_GRANTS]: [
        grants.phys_start.name,
      ]
    }
  },
  "soc_goal": {
    "name": "COMMUNICATION_GOAL_",
    "description": description(self),
    "icon_uid": null,
    "requirements": {
      [g.lingsoc.name]: 4,
      [g.philosophy.name]: 4,
      [REQUIRED_GRANTS]: [grants.math_start.name]
    }
  },
  "understanding_goal": {
    "name": "UNDERSTANDING_GOAL_",
    "description": description(self),
    "icon_uid": null,
    "requirements": {
      [g.math.name]: 3,
      [g.philosophy.name]: 4,
      [REQUIRED_GRANTS]: [grants.ling_start.name]
    }
  }
}
