import sublime, sublime_plugin
from os.path import basename
import re

class UpdatePacketsIndexesAutoCommand(sublime_plugin.EventListener):
	def on_load(self, view):
		view.run_command("update_packets_indexes")

	def on_pre_save(self, view):
		view.run_command("update_packets_indexes")

class UpdatePacketsIndexesCommand(sublime_plugin.TextCommand):
	def run(self, edit):
		if basename(self.view.file_name()) == 'packets.cpp':
			self.update_client(edit)

		if basename(self.view.file_name()) == 'packets.h':
			self.update_server(edit)

		if basename(self.view.file_name()) == 'PacketClient.as' or basename(self.view.file_name()) == 'PacketServer.as':
			self.update_client(edit)

		if basename(self.view.file_name()) == 'client.packets' or basename(self.view.file_name()) == 'server.packets':
			self.update_client(edit)

	def update_client(self, edit):
		full_region = sublime.Region(0, self.view.size())
		text = self.view.substr(full_region)
		old_text = text
		fixes = re.findall('// [A-Z_]+\\([0-9]+\\);', text)
		has_min = len(re.findall('MIN_TYPE', text)) == 0

		for i in range(len(fixes)):
			string = fixes[i]
			text = text.replace(string, self.client_fixed_string(string, i + (has_min if 1 else 0)))
		
		if text == old_text:
			return

		self.view.replace(edit, full_region, text)

	def update_server(self, edit):
		full_region = sublime.Region(0, self.view.size())
		text = self.view.substr(full_region)
		old_text = text
		fixes = re.findall('[a-zA-Z_:]+::init\\(\\+\\+next_type.*\\);\t+// [0-9]+', text)

		print(fixes)

		for i in range(len(fixes)):
			string = fixes[i]
			text = text.replace(string, self.server_fixed_string(string, i + 1))
		
		if text == old_text:
			return

		self.view.replace(edit, full_region, text)

	def client_fixed_string(self, string, index):
		return re.sub('\\([0-9]+\\)', '(' + str(index) + ')', string)

	def server_fixed_string(self, string, index):
		return re.sub('// [0-9]+', '// ' + str(index), string)
