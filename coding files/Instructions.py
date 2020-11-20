import pandas as pd
filename="Instructions_edited_final.csv"
data=pd.read_csv(filename,encoding='utf-8')
a=list(map(int,(data['Unnamed: 2'][:38]).values.tolist()))
b=(data['Instruction Code'][:38]).values.tolist()
d={}
for g in range(len(a)):
    d[b[g].strip()]="8'b"+str(a[g])
num=int(input("Number of Instructions:").strip())
for k in range(num):
    p=input().strip()
    if(p in d.keys()):
        print("ins_mem["+str(k)+"]="+d[p]+";")
    else:
        print("ins_mem["+str(k)+"]=8'b"+str(p)+";")