import re

p = re.compile(".*'\(\?<![^)]*\)[^']*'.*")

file = open('raidboss_data.bundle.js', 'rw')
lines = file.readlines()

for line in lines:
	if p.match(line) or True:
		print(line.strip())
