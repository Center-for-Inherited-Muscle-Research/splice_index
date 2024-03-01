#! /vcu_gpfs2/home/ikegamik/miniconda3/bin/python
import argparse
import pandas as pd
import math

def get_arguments():
	parser = argparse.ArgumentParser(description= "Arguments the user wishes to pass")
	parser.add_argument( "-f", "--files", 
						help="List of files provided by nextflow", 
						required=True, type=str)
	parser.add_argument("-n", "--norms", 
						help="Excel file which contains psi values for 95% percentile and median controls", 
						required=True, type=str)
	return parser.parse_args()


def calc_masseq(file_list, norms): #calculate SI score for each file in file_list and write to csv file
	norm = pd.read_excel(norms, skiprows= 0, names = ['per', 'med']) #read in norm file and save as data frame 
	#print(norm)
	masseq = pd.DataFrame()
	psi = pd.DataFrame()
	for i in file_list:
		event_counts = pd.read_csv(i, sep = " ", header=None, names=['counts', 'events']) #read in file and save as data frame 
		ind = i.split('_')[0] #isolate and save file name as a variable

		event_inc = event_counts[event_counts.events.str.contains('POS')] #define inclusion event / isolate gene name
		event_inc['event'] = event_inc.events.str.split("_").str[0] 
		inclusion = event_inc.groupby('event').sum() #sum counts for each gene 

		event_exc = event_counts[event_counts.events.str.contains('NEG')] #define exclusion event / isolate gene name
		event_exc['event'] = event_exc.events.str.split("_").str[0]
		exclusion = event_exc.groupby('event').sum() #sum counts for each gene
	
		psi = inclusion['counts']/(inclusion['counts'] + exclusion['counts']) #calculate psi
		print(psi)
		mas = (psi-norm['med'])/(norm['per']-norm['med']) #calculate SI score for each gene using psi and norm values
		#print(mas)
		score = sum(mas)/22
		
		#print(score)
		masseq.loc[ind, 'Masseq'] = score #add score to data frame using index as column name
		print(masseq)
		
	masseq = masseq.sort_values(by = 'Masseq') #sort data frame by SI score values
	masseq.to_csv('si_scores.csv') #write data frame to csv
	
def psi_calculation(file_list): #calculate psi values for each file in file_list and write to csv file
	psi = pd.DataFrame()
	for i in file_list: #loop through each file in file_list and calculate psi values for each gene
		event_counts = pd.read_csv(i, sep = " ", header=None, names=['counts', 'events'])
		ind = i.split('_')[0] #isolate and save file name as a variable 

		event_inc = event_counts[event_counts.events.str.contains('POS')] #define inclusion event / isolate gene name 
		event_inc['event'] = event_inc.events.str.split("_").str[0]
		inclusion = event_inc.groupby('event').sum()

		event_exc = event_counts[event_counts.events.str.contains('NEG')] #define exclusion event / isolate gene name
		event_exc['event'] = event_exc.events.str.split("_").str[0] 
		exclusion = event_exc.groupby('event').sum()
	
		psi[ind] = inclusion['counts']/(inclusion['counts'] + exclusion['counts']) #calculate psi using index as column name
		print(psi)

	psi.to_csv('psi_values.csv') #write data fram to csv




args = get_arguments()
file_list = args.files
file_list = file_list.split(",")
norms = args.norms

psi_calculation(file_list)
calc_masseq(file_list, norms)
