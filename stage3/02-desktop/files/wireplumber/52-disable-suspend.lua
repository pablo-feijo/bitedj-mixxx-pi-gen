alsa_monitor.rules = {
  {
    matches = { { "node.name", "matches", "*" } },
    apply_properties = { ["session.suspend-timeout-seconds"] = 0 },
  }
}
rule = {
  matches = { { "node.name", "matches", "bluez_output.*" } },
  apply_properties = { ["session.suspend-timeout-seconds"] = 0 },
}
table.insert(alsa_monitor.rules, rule)
