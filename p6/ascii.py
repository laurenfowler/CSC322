art = open("ascii_input.txt", "r")
counter = 0


for line in art:
	curr_line = line
	line_counter = 0;
	output = '' 
	for i in range(len(curr_line)-1):
		output += 'db 1bh, "['
		output += str(counter).zfill(2)
		output += ';'
		output += str(i).zfill(2)
		output += 'H'
		output += curr_line[i]
		output += '" '
		print output
		output = ''
	counter = counter + 1
