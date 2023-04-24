import sublime, sublime_plugin
from os.path import basename

# now you can call it directly with basename

class UpdatePackets(sublime_plugin.EventListener):
	def on_load(self, view):
		name = basename(view.file_name())
		if name in ['packets.cpp', 'PacketClient.as', 'PacketServer.as', 'client.packets', 'server.packets']:
			view.set_syntax_file('Packages/Packets/packets.tmLanguage')