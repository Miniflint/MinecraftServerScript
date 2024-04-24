import os
import time
import tqdm


def get_folder_size(folder_path):
	total_size = 0
	current_fil = None
	for folders in folder_path:
		for dirpath, dirnames, filenames in tqdm.tqdm(os.walk(folders)):
			for filename in filenames:
				filepath = os.path.join(dirpath, filename)
				current_file = filename
				total_size += os.path.getsize(filepath)
				
	return (total_size)
	
def spy_tar_progress_bar(maximum_size:int, spy_path:str):
	current_size = os.path.getsize(spy_path)
	progress_bar = tqdm.tqdm(total=maximum_size, ascii=" >=", desc="Processing", unit="%", leave=True, initial=current_size)
	while current_size < maximum_size:
		current_size = os.path.getsize(spy_path)
		progress_bar.update(current_size - progress_bar.n)
		time.sleep(0.1)
	progress_bar.close()

def main():
	dir_path = ["/opt/minecraftFabric_test2"]
	file_path = "/home/ubuntu/Backup/Backup-test---2024-01-19tar.gz"
	size:int = 31486149549
	spy_tar_progress_bar(size, file_path)

if __name__ == "__main__":
	main()
