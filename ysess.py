#!/usr/bin/env python2

import subprocess as sp, os, math, sys, re
from ConfigParser import ConfigParser
from cStringIO import StringIO
from optparse import OptionParser

DBUS = 'qdbus org.kde.yakuake '

class SortedDict(dict):
    def __init__(self, *args, **kwargs):
        dict.__init__(self, *args, **kwargs)
        self.keyOrder = dict.keys(self)
    def keys(self):
        return self.keyOrder
    def iterkeys(self):
        for key in self.keyOrder:
            yield key
    __iter__ = iterkeys
    def items(self):
        return [(key, self[key]) for key in self.keyOrder]
    def iteritems(self):
        for key in self.keyOrder:
            yield (key, self[key])
    def values(self):
        return [self[key] for key in self.keyOrder]
    def itervalues(self):
        for key in self.keyOrder:
            yield self[key]
    def __setitem__(self, key, val):
        self.keyOrder.append(key)
        dict.__setitem__(self, key, val)
    def __delitem__(self, key):
        self.keyOrder.remove(key)
        dict.__delitem__(self, key)


def get_stdout(cmd, **opts):
    opts.update({'stdout': sp.PIPE})
    if 'env' in opts:
        env, opts['env'] = opts['env'], os.environ.copy()
        opts['env'].update(env)
    quoted = re.findall(r'".+"', cmd)
    for q in quoted:
        cmd = cmd.replace(q, '%s')
    cmd = cmd.split()
    for i, part in enumerate(cmd):
        if part == '%s':
            cmd[i] = quoted.pop(0)[1:-1]
    proc = sp.Popen(cmd, **opts)
    return proc.communicate()[0].strip()

def get_yakuake(cmd):
    return get_stdout(DBUS + cmd)

def get_sessions():
    tabs = []
    sessnum = len(get_yakuake('/yakuake/sessions terminalIdList').split(','))
    activesess = int(get_yakuake('/yakuake/sessions activeSessionId'))

    sessions = sorted(int(i) for i in get_yakuake('/yakuake/sessions sessionIdList').split(','))
    ksessions = sorted(int(line.split('/')[-1]) for line in get_yakuake('').split('\n') if '/Sessions/' in line)
    session_map = dict(zip(sessions, ksessions))

    for i in range(sessnum):
        sessid = int(get_yakuake('/yakuake/tabs sessionAtTab %d' % i))
        ksess = '/Sessions/%d' % session_map[sessid]
        pid = get_yakuake(ksess+' processId')
        fgpid = get_yakuake(ksess+' foregroundProcessId')
        tabs.append({
            'title': get_yakuake('/yakuake/tabs tabTitle %d' % sessid),
            'sessionid': sessid,
            'active': sessid == activesess,
            'cwd': get_stdout('pwdx '+pid).partition(' ')[2],
            'cmd': '' if fgpid == pid else get_stdout('ps '+fgpid, env={'PS_FORMAT': 'command'}).split('\n')[-1],
        })
    return tabs

def format_sessions(tabs, fp):
    cp = ConfigParser(dict_type=SortedDict)
    tabpad = int(math.log10(len(tabs))) + 1
    for i, tab in enumerate(tabs):
        section = ('Tab %%0%dd' % tabpad) % (i+1)
        cp.add_section(section)
        cp.set(section, 'title', tab['title'])
        cp.set(section, 'active', 1 if tab['active'] else 0)
        cp.set(section, 'cwd', tab['cwd'])
        cp.set(section, 'cmd', tab['cmd'])
    cp.write(fp)


def clear_sessions():
    ksessions = [line for line in get_yakuake('').split('\n') if '/Sessions/' in line]
    for ksess in ksessions:
        get_yakuake(ksess+' close')

def load_sessions(file):
    cp = ConfigParser(dict_type=SortedDict)
    cp.readfp(file)
    sections = cp.sections()
    if not sections:
        print >>sys.stderr, "No tab info found, aborting"
        sys.exit(1)

    # Clear existing sessions, but only if we have good info (above)
    clear_sessions()
    for section in sections:
        get_yakuake('/yakuake/sessions addSession')
    import time
    time.sleep(5)

    # Map the new sessions to their konsole session objects
    sessions = sorted(int(i) for i in get_yakuake('/yakuake/sessions sessionIdList').split(','))
    ksessions = sorted(int(line.split('/')[-1]) for line in get_yakuake('').split('\n') if '/Sessions/' in line)
    session_map = SortedDict(zip(sessions, ksessions))

    active = 0
    # Repopulate the tabs
    for i, section in enumerate(sections):
        sessid = int(get_yakuake('/yakuake/tabs sessionAtTab %d' % i))
        ksessid = '/Session/%d' % session_map[sessid]
        opts = dict(cp.items(section))
        get_yakuake('/yakuake/sessions raiseSession %d' % sessid)
        get_yakuake('/yakuake/tabs setTabTitle %d "%s"' % (sessid, opts['title']))
        if opts['cwd']:
            get_yakuake('/yakuake/sessions runCommand "cd %s"' % opts['cwd'])
        if opts['cmd']:
            get_yakuake('/yakuake/sessions runCommand "%s"' % opts['cmd'])
        if opts['active'].lower() in ['y', 'yes', 'true', '1']:
            active = sessid
    if active:
        get_yakuake('/yakuake/sessions raiseSession %d' % active)


if __name__ == '__main__':
    # TODO: also store shell environment (for virtualenvs and such)
    # ps e 20017 | awk '{for (i=1; i<6; i++) $i = ""; print}'

    op = OptionParser(description="Save and load yakuake sessions.  Settings are exported in INI format.  Default action is to print the current setup to stdout in INI format.")
    op.add_option('-i', '--in-file', dest='infile', help='File to read from, or "-" for stdin', metavar='FILE')
    op.add_option('-o', '--out-file', dest='outfile', help='File to write to, or "-" for stdout', metavar='FILE')
    op.add_option('--force-overwrite', dest='force_overwrite', help='Do not prompt for confirmation if out-file exists', action="store_true", default=False)
    opts, args = op.parse_args()

    if opts.outfile is None and opts.infile is None:
        format_sessions(get_sessions(), sys.stdout)
    elif opts.outfile:
        fp = sys.stdout
        if opts.outfile and opts.outfile != '-' and (
            not os.path.exists(opts.outfile)
            or opts.force_overwrite
            or raw_input('Specified file exists, overwrite? [y/N] ').lower().startswith('y')):
            fp = open(opts.outfile, 'w')
        format_sessions(get_sessions(), fp)
    elif opts.infile:
        fp = sys.stdin
        if opts.infile and opts.infile != '-':
            if not os.path.exists(opts.infile):
                print >>sys.stderr, "ERROR: Input file (%s) does not exist." % opt.infile
                sys.exit(1)
            fp = open(opts.infile, 'r')
        load_sessions(fp)

