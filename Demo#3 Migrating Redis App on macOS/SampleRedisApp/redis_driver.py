import sys
import redis
import random
from termcolor import colored, cprint

char=[ 'ｱ', 'ｲ', 'ｳ', 'ｴ', 'ｵ', 'ｶ', 'ｷ', 'ｸ',  'ｹ', 'ｺ', 'ｻ', 'ｼ', 'ｽ',  'ｾ', 'ｿ',  'ﾀ', 'ﾁ', 'ﾂ', 'ﾃ',  'ﾄ', 'ﾅ', 'ﾆ', 'ﾇ',  'ﾈ', 'ﾉ', 'ﾊ',  'ﾋ', 'ﾌ', 'ﾍ',  'ﾎ', 'ﾏ', 'ﾐ', 'ﾑ', 'ﾒ', 'ﾓ', 'ﾔ', 'ﾕ', 'ﾖ', 'ﾗ', 'ﾘ', 'ﾙ','ﾚ', 'ﾛ', 'ﾜ', 'ﾝ']
color=['grey', 'green']
attribs=['bold','dark']
r = redis.StrictRedis(host="localhost", port=6379, db=0)

for i in range(1,10000):
    r.set (i, random.randint(0,40))
    print (
        colored( char[int(r.get(i))] + " ", 
                color[random.randint(0,1)], 
                attrs=[attribs[random.randint(0,1)]]),
        sep='', 
        end='', 
        file=sys.stdout, 
        flush=True)
    if (i % 60 == 0):
        print("")
print(" ") 