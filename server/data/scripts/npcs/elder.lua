-- Elder: simple quest-giver dialogue. Each option's hook fires
-- server-side, so the client cannot grant rewards by spoofing a node
-- pick.
return {
  id    = "elder",
  name  = "Elder Aren",
  title = "Village Elder",
  dialog = {
    start = {
      text = "The orcs raid us nightly. Will you help?",
      options = {
        { text = "Tell me more.",       next_node ="more" },
        { text = "Goodbye.",             next_node ="end" },
      },
    },
    more = {
      text = "Bring me 3 orc teeth and slay 3 of them. I will reward you well.",
      options = {
        {
          text = "I accept.",
          next_node ="accepted",
          hook = { type = "quest_start", quest = "orc_hunt" },
        },
        { text = "Not today.", next_node ="end" },
      },
    },
    accepted = {
      text = "May the old gods watch over you.",
      options = {
        { text = "Goodbye.", next_node ="end" },
      },
    },
    return_in_progress = {
      text = "The hunt is not yet finished. Return when the deed is done.",
      options = {
        { text = "Goodbye.", next_node ="end" },
      },
    },
    return_done = {
      text = "You honour the village. Take this as my thanks.",
      options = {
        {
          text = "Thank you.",
          next_node ="end",
          hook = { type = "quest_complete", quest = "orc_hunt" },
        },
      },
    },
  },
}
