#!/usr/bin/env python3
import subprocess
import time
import os, stat
from collections import Counter


class MyElement:
    def __init__(self, count=1, freq=0, owner=''):
        self.count = count
        self.freq = freq
        self.owner = owner
    def __repr__(self):
        return repr(self.count)


## 此类有很大优化空间
class MyCounter(dict):
    MAX_SIZE=20
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
    def update(self, arg):
        if isinstance(arg, (list,tuple)):
            for ele in arg:
                uid, key = ele
                if int(key) < 100 or int(uid) == 0:
                    continue
                if key in self:
                    self[key].count += 1
                else:
                    if len(self) >= self.MAX_SIZE:
                        self.clean()
                    if len(self) < self.MAX_SIZE:
                        self[key] = MyElement(1,0,uid)
        else:
            super().update(arg)
    def most_common(self):
        mc = max(self, key=lambda x: self.get(x).count)
        return mc if self.get(mc).count > 10 else None
    def step(self):
        for ele in self.values():
            ele.freq += 1
    def clean(self):
        for pid, ele in list(self.items()):
            if ele.count < 5 and ele.freq > 20:
                self.pop(pid)
            elif ele.freq > 50:
                self.pop(pid)

pid_counter = MyCounter()
# watch_list = []

_cnt = 0
flag = False

while True:
    proc_query = subprocess.Popen(
        r"""ps -p "$(top -b -n 2 -d 0.2 | awk '{if(flag==2) print $1,$9,$10,$2; if($1=="PID") flag++}' | awk '$2>900 {print $1}')" -o uid= -o pid= | awk '{printf "%s|%d\n",$1,$2}' """,
        # r"""ps -eo uname:20,uid,pid,pcpu,pmem,cmd| grep -v PID | sort -rnk4,5 | head -n 10 | awk '$4>900 {printf "%s|%d\n",$2,$3}'""", 
        shell=True, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )

    try:
        outs, errs = proc_query.communicate(timeout=15)
        if outs.strip():
            pid_counter.update([line.strip().split('|') for line in outs.strip().split('\n')])
            flag = True
        else:
            flag = False
    except subprocess.TimeoutExpired:
        proc_query.kill()
        outs, errs = proc_query.communicate()
        continue

    if len(pid_counter) > 0:
        if flag:
            the_god_damn_one = pid_counter.most_common()
            if the_god_damn_one is not None:
                proc_kill = subprocess.Popen(["/bin/kill", "--", '-'+the_god_damn_one, the_god_damn_one])
                proc_kill.wait()
                that_guy = pid_counter[the_god_damn_one].owner
                rc = '/etc/profile.d/message_to_{}.sh'.format(that_guy)
                if not os.path.exists(rc) or os.path.getsize(rc) < 5:
                    with open(rc, 'w') as f:
                        print('#!/bin/bash', file=f)
                        print('if [ $UID = {} ];then'.format(that_guy), file=f)
                        print('echo -e "\033[31m警告：监测到您近期存在CPU使用量过高的情况，请注意遵守规则！\033[0m"', file=f)
                        print('> {}'.format(rc), file=f)
                        print('fi', file=f)
                    os.chown(rc, int(that_guy), -1)
                    os.chmod(rc, stat.S_IRUSR|stat.S_IWUSR)
                proc_mesg = subprocess.Popen(["/home/linmanhui/Tools/send_mesg.sh", that_guy, '\033[31m警告：由于占用过多CPU资源，您的程序可能已被强制终止，请注意遵守规则！\033[0m'])
                proc_mesg.wait()
                pid_counter.pop(the_god_damn_one)
                print('{} {} {}'.format(that_guy, the_god_damn_one, time.strftime('%Y-%m-%d_%H:%M:%S')), flush=True)

        pid_counter.step()
        _cnt += 1
        if _cnt == 50:
            pid_counter.clean()
            _cnt = 0
   
    time.sleep(10)
