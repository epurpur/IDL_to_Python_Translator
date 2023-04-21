
import pandas as pd
import numpy as np
import re
filepath='op_output.d'


tmaxmax=1600

ld=0

dummy1=12
dumhead=''
idens=0
itemp=0
iself=0
iplay=0
specs=10
a=10
gd=1.0*10**12
tns=1.0*10**6

#read header
with open(filepath) as myFile:
    # first we will separate out the header from the data. At the moment, the header is the firstr 96 lines of the file
    for line in myFile:   # loop over each line in the file
                
        if "GAS DENSITY,Av VARIES WITH TIME:" in line:
            substring = line[63:]  
            if "YES" in substring:
                idens = 1    
        if "GAS & GRAIN TEMPERATURES VARY WITH TIME:" in line:
            substring = line[63:]
            if "YES" in substring:
                itemp = 1    
        if "DO SELF-SHIELDING CALCULATIONS:" in line:
            substring = line[63:]
            if "2" in substring:
                iself = 2
        if "PRINT IMPORTANT RATES:" in line:
            substring = line[63:]
            iplay_int = int(line[84])
            if iplay_int > 0:
                 iplay = 1
        if "NUMBER OF CHEMICAL SPECIES," in line:
            nsmax = int(line[64:])
        if "NUMBER OF GAS PHASE SPECIES," in line:
            nsgas = int(line[64:])
        if "NUMBER OF GRAIN SPECIES," in line:
            nsgrain = int(line[64:])
        if "NUMBER OF ELEMENTS," in line:
            nemax = int(line[64:])
        if "GAS TO DUST RATIO (BY NUMBER DENSITY)," in line:
            gd = float(line[64:])
        if "NUMBER OF SITES PER GRAIN," in line:
            tns = float(line[64:])
        if "NT = " in line:   # "NT = " will always be last parameter of the header, so we stop reading here
            tmax = int(line[64:])
            break


#create blank pandas dataframe, store conditions data
#create empty lists to add data into them
conditions_df=pd.DataFrame()
it = []
t = []
xnt = []
temp = []
dtemp = []
tau = []
zeta = []
cdh2 = []
cdco = []
dist = []
rx = []
rz = []

#reading condition data over time
j=0
with open(filepath) as myFile:
    #skipping past header and reading conditions
    for line in myFile:
        if "IT=" in line:
            #conditions is a list of conditions for each iteration
            conditions = line.split(",")
            
            current_IT = int(conditions[0].lstrip("IT= "))
            it.append(current_IT)
            
            current_t = float(conditions[1].lstrip("t =").rstrip(" yr"))
            t.append(current_t)
            
            current_xnt = float(conditions[2].lstrip("nH="))
            xnt.append(current_xnt)
            
            current_temp = float(conditions[3].lstrip("T="))
            temp.append(current_temp)
            
            current_dtemp = float(conditions[4].lstrip("DT="))
            dtemp.append(current_dtemp)
            
            current_tau = float(conditions[5].lstrip("AV= "))
            tau.append(current_tau)
            
            current_zeta = float(conditions[6].lstrip("ZETA="))
            zeta.append(current_zeta)
            
            current_cdh2 = float(conditions[7].lstrip("CDH2="))
            cdh2.append(current_cdh2)
            
            current_cdco = float(conditions[8].lstrip("CDCO="))
            cdco.append(current_cdco)
            
            current_dist = float(conditions[9].lstrip("DIST="))
            dist.append(current_dist)
            
            current_rx = float(conditions[10].lstrip("SD="))
            rx.append(current_rx)
    
            current_rz = float(conditions[11].lstrip("DS="))
            rz.append(current_rz)
 
conditions_df["IT"]=it
conditions_df["time"]=t
conditions_df["nH"]=xnt
conditions_df["temperature"]=temp
conditions_df["dust temperature"]=dtemp
conditions_df["visual extinction"]=tau
conditions_df["zeta"]=zeta
conditions_df["CDH2"]=cdh2
conditions_df["CDCO"]=cdco
conditions_df["dist"]=dist
conditions_df["rx"]=rx
conditions_df["rz"]=rz

#reading molecular abundances
myFile = open(filepath).readlines()

all_headers = []
all_xn_data = []
all2_xn_data = []
a_list = []
all_iter = []


# create dataframe for final abundance data
fractional_abundance_df = pd.DataFrame()  


for i, line in enumerate(myFile):
 
    if "TIME EVOLUTION OF FRACTIONAL ABUNDANCE" in line:
        
        ##### READING IN HEADERS (names of molecules) ######
        
        # get header row for each group of molecules
        header_line = myFile[i+2]
        # remove newline character from end of header_line
        header_line = header_line[2:-1]   
        header_items = []
        # use regular expression to remove empty items from header_items
        pattern = re.compile(r'\S+')
        matches = pattern.finditer(header_line)
        for match in matches:
            header_items.append(match.group(0))            
        all_headers.append(header_items)
        
        ### CREATING COLUMN HEADERS ###
        
        #add all molecule names as column headers
        column_headers = []
        for sublist in all_headers:
            for item in sublist:
                column_headers.append(item)
        for column in column_headers:
            fractional_abundance_df[column] = ""  
        
    
###########################################################
################# READING ABUNDANCE DATA ##################
###########################################################

# lines_container holds the lines from the file. This will hold each line of the file as a list item. the length of container will be the number of iterations (tmax + 2) x number of elements (1390 I think) 
lines_container = []  

# this determines the number of lines grabbed after each instance of "time evolution of fractional abundance". The +2 is because the first two lines are intro lines and will be discarded later
iterations = tmax+2   


count = 1  # this helps me determine how many instances of "TIME EVOLUTION..." line. Also helps determine how many chunks to break data into later in chunk_into function
with open(filepath) as myFile:
    
    for line in myFile:
                
        # there are 139 instances of this line in the file
        if "TIME EVOLUTION OF FRACTIONAL ABUNDANCE" in line:
            
            print(count, line)
            count +=1
            for i in range(iterations):
                lines_container.append(next(myFile))




from math import ceil

def chunk_into_n(lst, n):
    """ This function takes a list object (lst) and splits it into n number of chunks.
    The number of chunks will most likely always be count - 1. 
    The end result of container will be the previous container value divided by the number of chunks specified"""
    size = ceil(len(lst) / n)
    return list(
        map(lambda x: lst[x * size:x * size + size],
        list(range(n)))
    )



# split container into n number of chunks. THIS SHOULD PROBABLY ALWAYS BE "COUNT - 1" unless there is a specific reason not to
lines_container = chunk_into_n(lines_container, count-1)

# remove first two items from each item in container. These two items are the empty lines described earlier
lines_container = [i[2:] for i in lines_container]


# The zip() function is used to group the corresponding elements of each iterable into tuples. The * operator unpacks the iterables in container and passes them as separate arguments to zip()."""
results = list(zip(*lines_container))
#Results is currently a list of tuples. Convert list of tuples to list of lists
results = [list(t) for t in results]

results2 = []
# split items in lists based on spaces. All the items in each result is split by spaces. 
for i in results:
    
    # iter_items colects the individual items from each line after they are split on spaces below by the regular expression. 
    iter_items = []
    
    for x in i:
        # this is using a regular expression to search for one or more NOT whitespace characters
        pattern = re.compile(r'\S+')
        matches = pattern.finditer(x)
        
        for match in matches:
            iter_items.append(match.group(0))  # match.group(0) extracts the literal text value that was matched instead of a 'match' python object which is not helpful in this case
            
    results2.append(iter_items)

# Now, need to delete repeated IT and t(yr) value form results2. Keep only the first of those
# basically, all the digits have a length of 10. If a value does not have a length of 10 (which the iteration and the t(yr) values do not), it is dropped)
results3 = []

for i in results2:
    #final holds the data which will be added to the df above
    final = []
    
    # i[0] and i[1] are the IT and t(yr) column value. Append these up front before values are dropped
    final.append(i[0])
    final.append(i[1])    

    # basically, all the digits have a length of 10. If a value does not have a length of 10 (which is for the iteration and the t(yr)), it is dropped)
    for x in i:
        
        # this is looking for the length of each item. Basically, if it is not 10 then drop it. Python was not playing nicely so I had to explicitly specify values of other lengths to drop
        if len(x) != 1 and len(x) != 11 and len(x) != 2 and len(x) != 3 and len(x) != 4:
            final.append(x)
    
    results3.append(final)
    
    
  
# append each item as a row in dataframe
for df_row in results3:
    fractional_abundance_df.loc[len(fractional_abundance_df)] = df_row
        

    










        

#             iter_items = []
#             pattern = re.compile(r'\S+')
#             matches = pattern.finditer(iteration)
#             for match in matches:
#                 iter_items.append(match.group(0))   
#  #           if k > 0:
#             iter_items = iter_items[2:]
#             #put all iterations together here
#             all_iter.extend(iter_items)
#             k += 1


       
# #add all molecule names as column headers
# column_headers = []
# for sublist in all_headers:
#     for item in sublist:
#         column_headers.append(item)
# for column in column_headers:
#     df[column] = ""            
# #split iterations
# xn = np.array_split(all_iter, tmax)











