import sys
import csv
from os.path import isdir, join
import os
from itertools import izip

#for g in sys.argv[1:]:

# CHANGE PATH NAME BELOW
dir_data_name = '/Volumes/BioSemiData/'
# CHANGE PATHNAME ABOVE

dir_data = os.listdir(dir_data_name)
stdin_files = []
for dir_ in dir_data:
	temp_dir_path = '%s%s/' % (dir_data_name, dir_)
	if isdir(join(dir_data_name,dir_)):
		temp_dir_data = os.listdir(temp_dir_path)
		for tem_file_ in temp_dir_data:
			#print tem_file_
			temp_file_path = '%s%s' % (temp_dir_path, tem_file_)
			stdin_files.append(temp_file_path)


for ss_file in stdin_files:
    if '_Data_Checksums.txt' in ss_file:
        dir_fullpath = '/'.join(ss_file.split('/')[0:-1]) # full path to subject directory
        # e.g. /Users/dae/Data/BioSemiRuns/2014-/Data\ 2014-/01-2014-07-23
        dir_subj = '/'.join(ss_file.split('/')[-2:-1]) # subject directory name
        # e.g. 01-2014-07-23
        subjn = '-'.join(dir_subj.split('-')[0:1]) # subject number when dir name is in ##-yyyy-mm-dd format
        # e.g. 01
        
        ofile = open(dir_fullpath + '/__' + subjn + '_Verified_Data.Checksums_Expanded.txt', 'w').write("Checksums Match, Path: " + dir_fullpath + "\n\n")

        try:
            os.remove(dir_fullpath + '/___ERROR_Data.Checksums.txt')
        except OSError:
            pass
        
        
        file1 = open(dir_fullpath + '/_Data_Checksums.txt', 'rb')
        file2 = open(dir_fullpath + '/_Data.Checksums_Expanded.txt', 'rb')
        reader1 = csv.reader(file1, delimiter='\t')
        reader2 = csv.reader(file2, delimiter='\t')
        
        for row1, row2 in izip(reader1,reader2):
            if (row1[6] == row2[6]):
                ofile = open(dir_fullpath + '/__' + subjn + '_Verified_Data.Checksums_Expanded.txt', 'a')
                ofile.write(row1[6] + ' -- O: ' + dir_subj + '\n')
                ofile.write(row2[6] + ' -- E\n\n')
                ofile.close()
            else:
                ofile = open(dir_fullpath + '/__ERROR_Data.Checksums.txt', 'a')
                ofile.write(row1[6] + ' -- O: ' + dir_subj + '\n')
                ofile.write(row2[6] + ' -- E' + row1[0] + '\n\n')
                ofile.close()
                print 'MISMATCH MD5#: ' + ss_file + '\n'
