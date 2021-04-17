import PySimpleGUI as sg
import sys


def generate_cmd(server, first_team, second_team, map_file, show_log):
    show_log = "--show-log" if (show_log == "Yes") else ""
    return "java -jar \"{}\" --first-team=\"{}\" --second-team=\"{}\" --read-map=\"{}\" {}".format(
        server, first_team, second_team, map_file, show_log
    )


if len(sys.argv) == 1:
    server = sg.Checkbox("Choose server jar file")
else:
    server = sys.argv[1]

if len(sys.argv) == 1:
    server = sg.popup_get_file("Choose server jar file", file_types=(("Client", "*"),))
else:
    server = sys.argv[1]

if not server:
    sg.popup("Cancel", "No server jar file selected")
    raise SystemExit("Cancelling: no server jar supplied")

if len(sys.argv) == 1:
    first_team = sg.popup_get_file("Choose first team client file", file_types=(("Client", "*"),))
else:
    first_team = sys.argv[1]

if not first_team:
    sg.popup("Cancel", "No first team selected")
    raise SystemExit("Cancelling: no first team supplied")

if len(sys.argv) == 1:
    second_team = sg.popup_get_file("Choose second team client file", file_types=(("Client", "*"),))
else:
    second_team = sys.argv[1]

if not second_team:
    sg.popup("Cancel", "No second team selected")
    raise SystemExit("Cancelling: no second team supplied")

if len(sys.argv) == 1:
    map_file = sg.popup_get_file("Choose map.json file", file_types=(("Client", "*"),))
else:
    map_file = sys.argv[1]

show_log = False

if not map_file:
    sg.popup("Cancel", "No map file selected")
    raise SystemExit("Cancelling: no map file supplied")
else:
    show_log = sg.popup_yes_no(
        "Do you want to see extra logs? (may cause performance issues)"
    )
    sg.popup_get_text(
        "The command to run your server: (Use this command where \'map.config\' exists)",
        default_text=generate_cmd(server, first_team, second_team, map_file, show_log),
    )