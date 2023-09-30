import os
from datetime import date
from time import sleep

NOW = date.today()
BASE_DIR = "/opt/"

NC	= '\033[0m'
RED	= '\033[0;31m'
CYAN	= '\033[0;36m'
GREEN	= '\033[0;32m'

def print_color(output:str):
	print(f"[{GREEN}OK{NC}]: {CYAN}{output}{NC}")

def handle_error(error_str:str, exit_code:int) -> None:
	print(RED + error_str + NC)
	exit(exit_code)

def check_backup_done() -> None:
	sleep(1)

def check_exist_dir(pathdir:str) -> bool:
	if (os.path.isdir(pathdir) or os.path.isfile(pathdir)):
		return True
	return False

def display_available_dir() -> None:
	dirs = os.listdir(BASE_DIR)
	for directory in dirs:
		print(BASE_DIR + directory)

def questions():
	PathToBackup = input(f"{GREEN}Enter the full path of the folder to backup\n{CYAN}ex: {NC}/opt/minecraftPaperMC\n")
	if not check_exist_dir(PathToBackup):
		handle_error("Couldn't find the minecraft folder path", 127)
	backup_path_dir = input(f"{GREEN}Enter the backup path\n{CYAN}ex: {NC}/home/ubuntu/Backup\n")
	if not check_exist_dir(backup_path_dir):
		handle_error("Couldn't find the backup path", 127)
	backup_name = input(f"{GREEN}Enter the backup Name\n{CYAN}ex: {NC}Backup- \n")
	if check_exist_dir(backup_name):
		handle_error(f"Backup already exist", 1)
	print_color(PathToBackup)
	print_color(backup_path_dir)
	print_color(backup_name)
	if not PathToBackup.endswith("/"):
		PathToBackup = PathToBackup + "/"
	return PathToBackup, backup_path_dir, backup_name

def get_required_dir_file(path_dir:str):
	#get jar executable file
	files = [f for f in os.listdir(path_dir) if not os.path.isdir(f) and f.endswith(".jar")][0]
	#get world dir
	world_dir = path_dir + "world"
	if not check_exist_dir(world_dir):
		handle_error("Couldn't find the world dir", 127)
	logs_dir	= path_dir + "logs"
	mod_dir 	= path_dir + "mods"
	config_dir 	= path_dir + "config"
	world_end	= path_dir + "world_the_end"
	world_nether	= path_dir + "world_the_nether"
	plugin_dir	= path_dir + "plugins"		
	library_dir	= path_dir + "libraries"
	whitelist_file	= path_dir + "whitelist.json"
	server_file	= path_dir + "server.properties"
	eula_file	= path_dir + "eula.txt"
	banned_file	= path_dir + "banned-players.json"
	bannedip_file	= path_dir + "banned-ips.json"
	paper_yml	= path_dir + "paper_yml"
	spigot_yml	= path_dir + "spigot_yml"
	bukkit_yml	= path_dir + "bukkit_yml"
	ops_json	= path_dir + "ops.json"

	checking_dirs = [logs_dir, mod_dir, config_dir, world_dir, world_end, world_nether, plugin_dir, library_dir, whitelist_file, server_file, eula_file, banned_file, bannedip_file, paper_yml, spigot_yml, bukkit_yml, ops_json]

	for folders in checking_dirs.copy():
		if not check_exist_dir(folders):
			checking_dirs.remove(folders)
		else:
			print_color(folders)
	return " ".join(checking_dirs)

def exec_tar(backup_dir:str, backup_name:str, folders_to_backup:str) -> bool:
	backup_fullpath = backup_dir + backup_name + "-" + str(NOW) + "tar.gz"
	command = f"tar -czvf {backup_fullpath} {folders_to_backup}"
	hide_output = " > /dev/null 2>&1"
	os.system(command + hide_output)

def main():
	print("\033c", end="")
	display_available_dir()
	print("\n")
	path_dir, backup_dir, backup_name = questions()
	files_to_tar = get_required_dir_file(path_dir)
	exec_tar(backup_dir, backup_name, files_to_tar)

if __name__ == "__main__":
	try:
		main()
	except KeyboardInterrupt as e:
		print(f"\n{NC}:)")
