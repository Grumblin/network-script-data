Error_Handler:
  type: world
  debug: false
  events:
    on server start:
      - yaml id:error_handler create
    on script generates error:
    # % ██ [ Verify Connection             ] ██
      - define Timeout <util.time_now.add[1m]>
      - waituntil <bungee.connected> || <[Timeout].duration_since[<util.time_now>]> != 0:
      - if !<bungee.connected> || <context.queue.id||invalid> == invalid || !<list[hub1|behrcraft|survival|relay|xeane].contains[<bungee.server>]>:
        - stop

    # % ██ [ Track Errors                  ] ██
      - define data <map>
      - if <context.script||invalid> != invalid:
        - yaml id:error_handler set <context.script>:->:<util.time_now>
        - define Error_Count <yaml[error_handler].read[<context.script>].size>
        - define Data <[Data].with[Error_Count].as[<[Error_Count]>]>

    # % ██ [ Cache the Information Needed  ] ██
      - define Data <map.with[Server].as[<bungee.server>]>
      - define Data <[Data].with[Error_Count].as[0]>
      - if <context.queue.player||invalid> != invalid:
        - define Player_Map <map.with[Name].as[<queue.player.name>].with[UUID].as[<queue.player.uuid>]>
        - define Data <[Data].with[Player].as[<[Player_Map]>]>
      - if <context.script.name||Invalid> != invalid:
        - define Script_Map <map.with[Name].as[<context.script>].with[Line].as[<context.line||Invalid>].with[File_Location].as[<bungee.server>/./<context.script.filename.after[/plugins/Denizen/scripts/repo-link/]||Invalid>]>
        - define Data <[Data].with[Script].as[<[Script_Map]>]>
      - define Data <[Data].with[Message].as[<context.message>]>
      - define Data <[Data].with[Definition_Map].as[<context.queue.definition_map>]>

    # % ██ [ Send to Relay                 ] ██
      - bungeerun relay Error_Response_Webhook def:<[Data]>
