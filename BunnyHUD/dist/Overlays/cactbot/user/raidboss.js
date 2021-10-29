'use strict';

// Disable all cactbot alerts
//Options.TextAlertsEnabled = false;
//Options.SoundAlertsEnabled = false;
//Options.SpokenAlertsEnabled = false;
Options.DisabledTriggers = {
    'UWU Titan Gaols': true,
};
Options.Triggers.push({
    zoneId: ZoneId.TheEpicOfAlexanderUltimate,
    triggers: [
        {
            id: 'TEA Trine Initial',
            type: 'Ability',
            netRegex: NetRegexes.abilityFull({ source: 'Perfect Alexander', id: '488F', x: '100', y: '(?:92|100|108)' }),
            preRun: function (data, matches) {
                var _a;
                (_a = data.trine) !== null && _a !== void 0 ? _a : (data.trine = []);
                // See: https://imgur.com/a/l1n9MhS
                var trineMap = {
                    92: 'r',
                    100: 'g',
                    108: 'y',
                };
                var thisTrine = trineMap[parseFloat(matches.y)];
                if (!thisTrine)
                    throw new UnreachableCode();
                data.trine.push(thisTrine);
            },
            alertText: function (data, _matches, output) {
                var _a;
                // Call out after two, because that's when the mechanic is fully known.
                (_a = data.trine) !== null && _a !== void 0 ? _a : (data.trine = []);
                if (data.trine.length !== 2)
                    return;
                // Find the third one based on the first two.
                var threeArr = ['r', 'g', 'y'].filter(function (x) { var _a; return !((_a = data.trine) === null || _a === void 0 ? void 0 : _a.includes(x)); });
                var three = threeArr[0];
                var one = data.trine[0];
                if (!one || !three)
                    return;
                // Start on the third trine, then move to the first.
                var threeOne = three + one;
                // For parks and other forestry solutions.
                var locations = {
                    r: [92, 100],
                    g: [100, 100],
                    y: [108, 100],
                };
                data.trineLocations = [locations[three], locations[one]];
                data.secondTrineResponse = 'north';
                switch (threeOne) {
                    case 'gr': return { en: '3 to 4', };
                    case 'rg': return { en: '4 to 3', };
                    case 'ry': return { en: '4 to D', };
                    case 'yr': return { en: 'D to 4', };
                    case 'gy': return { en: 'Mid to D', };
                    case 'yg': return { en: 'D to Mid', };
                }
            },
        },
        {
            id: 'TEA Trine Second',
            type: 'Ability',
            netRegex: NetRegexes.abilityFull({ source: 'Perfect Alexander', id: '4890', capture: false }),
            suppressSeconds: 15,
            alertText: 'Go',
        },
    ],
});

Options.Triggers.push({
    zoneId: ZoneId.MatchAll,
    triggers: [
        {
            id: 'General Assize',
            type: 'Ability',
            regex: Regexes.ability({ id: 'DF3' }),
            condition: function (data, matches) {
                return (matches.source === data.me && matches.target === matches.source);
            },
            promise: async (data) => {
                await new Promise(r => setTimeout(r, 43000));
            },
            infoText: 'Apply Assize',
        },
        {
            id: 'General Dia',
            type: 'Ability',
            regex: Regexes.ability({ id: '4094' }),
            condition: function (data, matches) {
                return (matches.source === data.me);
            },
            promise: async (data) => {
                await new Promise(r => setTimeout(r, 27000));
            },
            infoText: function (data, matches) {
                return { en: 'Apply Dia to ' + matches.target, };
                }
        },
        {
            id: 'General POM',
            type: 'Ability',
            regex: Regexes.ability({ id: '88' }),
            condition: function (data, matches) {
                return (matches.source === data.me);
            },
            promise: async (data) => {
                await new Promise(r => setTimeout(r, 147000));
            },
            infoText: 'Apply Presence of Mind',
        },
        {
            id: 'General LD',
            type: 'Ability',
            regex: Regexes.ability({ id: '1D8A' }),
            condition: function (data, matches) {
                return (matches.source === data.me);
            },
            promise: async (data) => {
                await new Promise(r => setTimeout(r, 57000));
            },
            infoText: 'Apply Lucid Dreaming',
        }
    ],
});
//wh strat https://ff14.toolboxgaming.space/?id=960813815903061&preview=1

//Settings
//var kb_trigger = true;
//var hell = true;



//manually enable tea headmarkers for limit cut and wormhole
//Options.PerTriggerOptions = {
//  'TEA Limit Cut Numbers': {
//    SpeechAlert: true,
//    SoundAlert: true,
//    TextAlert: true,
//    TTSText: function(data) {
//      if (data.phase == 'wormhole') {
//        if (hell) {
//          switch (data.limitCutNumber) {
//            case 1:
//              return { en: 'LEFT North one first cleave', };
//            case 2:
//              return { en: 'RIGHT North two first dash', };
//            case 3:
//              return { en: 'South LEFT three', };
//            case 4:
//              return { en: 'South RIGHT four', };
//            case 5:
//              return { en: 'LEFT Side five inside portal', };
//            case 6:
//              return { en: 'RIGHT six inside portal', };
//            case 7:
//              return { en: 'LEFT seven outside portal second soak', };
//            case 8:
//              return { en: 'RIGHT eight outside portal second soak', };
//          }
//        } else {
//          switch (data.limitCutNumber) {
//            case 1:
//              return { en: 'North one face north', };
//            case 2:
//              return { en: 'South bait super jump first dash', };
//            case 3:
//              return { en: 'North, three', };
//            case 4:
//              return { en: 'South, four', };
//            case 5:
//              return { en: 'North, five inside portal', };
//            case 6:
//              return { en: 'South six inside portal', };
//            case 7:
//              return { en: 'North, seven', };
//            case 8:
//              return { en: 'South, eight', };
//          }
//        }
//      } else if (!hell){
//        switch (data.limitCutNumber) {
//          case 1:
//            return { en: 'One',};
//          case 2:
//            return { en: 'Two',};
//          case 3:
//            return { en: 'Three', };
//          case 4:
//            return { en: 'Four', };
//          case 5:
//            return { en: 'Five', };
//          case 6:
//            return { en: 'Six face inside', };
//          case 7:
//            return { en: 'Seven run back circle', };
//          case 8:
//            return { en: 'Eight face forward', };
//        }
//    } else {
//      switch (data.limitCutNumber) {
//        case 1:
//          return { en: 'One go northwest, first group cleave', };
//        case 2:
//          return { en: 'Two go northwest, first group dash', };
//        case 3:
//          return { en: 'Three go southeast, first group cleave', };
//        case 4:
//          return { en: 'Four go southeast, first group dash', };
//        case 5:
//          return { en: 'Five go northwest, second group cleave', };
//        case 6:
//          return { en: 'Six go northwest, second group dash', };
//        case 7:
//          return { en: 'Seven go southeast, second group cleave', };
//        case 8:
//          return { en: 'Eight go southeast, second group dash', };
//      }
//    }
//    },
//  },
//  'TEA Limit Cut Knockback': {
//    SpeechAlert: kb_trigger,
//    SoundAlert: kb_trigger,
//    TextAlert: kb_trigger,
//  },
//};
