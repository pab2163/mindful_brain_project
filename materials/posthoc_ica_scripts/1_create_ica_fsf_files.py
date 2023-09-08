import os

os.system('mkdir sub_fsfs')

def make_level1(sub, ica_template):
    fsf_out = f'sub_fsfs/ica_{sub}.fsf'
    
    # define replacements
    replacements = {
        'SUBID':sub}
    
    with open(ica_template) as infile: 
        # outfile = useable config file that is being created for every subject and every run 
        with open(fsf_out, 'w') as outfile:
            for line in infile:
                # This code will make new config files that replace all of the wild cards we made above!  
                for src, target in replacements.items():
                    line = line.replace(src, target)
                outfile.write(line)

subs = ['sub-rtBANDA049', 'sub-rtBANDA056', 'sub-rtBANDA060', 'sub-rtBANDA066', 'sub-rtBANDA073',
        'sub-rtBANDA088', 'sub-rtBANDA106', 'sub-rtBANDA116', 'sub-rtBANDA145']

for i in subs:
    make_level1(sub=i, ica_template='ica_template.fsf')