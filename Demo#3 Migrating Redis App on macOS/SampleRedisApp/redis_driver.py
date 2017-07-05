# The MIT License (MIT)
#
# Copyright (c) 2017 Redis Labs
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Author: Cihan Biyikoglu - github:(cihanb)
# Thanks for chars and inspiration to @ttscoff

import sys
import redis
import random
from termcolor import colored, cprint

#read db port
db_port=12000

char=[ 'ｱ', 'ｲ', 'ｳ', 'ｴ', 'ｵ', 'ｶ', 'ｷ', 'ｸ',  'ｹ', 'ｺ', 'ｻ', 'ｼ', 'ｽ',  
    'ｾ', 'ｿ',  'ﾀ', 'ﾁ', 'ﾂ', 'ﾃ',  'ﾄ', 'ﾅ', 'ﾆ', 'ﾇ',  'ﾈ', 'ﾉ', 'ﾊ',  
    'ﾋ', 'ﾌ', 'ﾍ',  'ﾎ', 'ﾏ', 'ﾐ', 'ﾑ', 'ﾒ', 'ﾓ', 'ﾔ', 'ﾕ', 'ﾖ', 'ﾗ', 
    'ﾘ', 'ﾙ','ﾚ', 'ﾛ', 'ﾜ', 'ﾝ']
color=['grey', 'green']
attribs=['bold','dark']
r = redis.StrictRedis(host="localhost", port=db_port, db=0)

for i in range(1,1000000):
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

print (" ")
