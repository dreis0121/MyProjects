# Create a text file numbered 1-20

with open('number_list.txt','w') as number_list:
    for i in range(1,51):
        number_list.write(str(i)+'.'+' '+'\n')
