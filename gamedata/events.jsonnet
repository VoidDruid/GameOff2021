local Event = {
    name: "EVENT_" + std.asciiUpper(self.name_),
    script: "res://gamedata/events/scripts/" + self.name_ + ".gd",
    description: "DESC_" + self.name,
};

local EventBack(background) = Event {
    visuals: {
        video: null,
        background: "res://gamedata/events/backgrounds/" + background + ".png",
        object: null
    },
};
local EventChar(background, icon) = Event {
    visuals: {
        video: null,
        background: "res://gamedata/events/backgrounds/" + background + ".png",
        object: "res://gamedata/icons/character" + icon + ".png"
    },
};
local EventAlien(background, alien) = Event {
    visuals: {
        video: null,
        background: "res://gamedata/events/backgrounds/" + background + ".png",
        object: "res://gamedata/icons/aliens" + alien + ".png"
    },
};
local EventVideo(video) = Event {
    visuals: {
        video: "res://gamedata/events/animations/" + video + ".webm",
        background: null,
        object: null,
    },
};

local Option(name) = {
    name: "OPTION_" + std.asciiUpper(name),
    modifiers: [],
};

[
    EventBack("university") {
        name_: "budget",
        options: [
            Option("take"),
            Option("donate"),
        ],
        params: {
            money: 1100,
            reputation: 20
        },
    },
    EventVideo("1") {
        name_: "alien_visit",
        options: [
            Option("physics"),
            Option("math"),
            Option("bio"),
            Option("ling"),
        ]
    }
]
