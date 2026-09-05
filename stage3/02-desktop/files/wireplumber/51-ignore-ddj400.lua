rule = {
  matches = {
    {
      { "device.name", "matches", "alsa_card.usb-Pioneer_DJ_Corporation_DDJ-400*" },
    },
    {
      { "alsa.card_name", "matches", "*DDJ-400*" },
    },
  },
  apply_properties = {
    ["device.disabled"] = true,
  },
}
table.insert(alsa_monitor.rules, rule)
