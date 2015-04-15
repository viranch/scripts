#!/usr/bin/python
import sys
import json

info = json.loads(sys.stdin.read())
if len(info) == 0:
    sys.exit(0)
else:
    info = info[0]

name = info['Name'].split('/',1)[-1]

blacklist = [x+'=' for x in 'PATH TZ DOCKER_GEN_VERSION DOCKER_HOST NGINX_VERSION GOLANG_VERSION GOPATH DEBIAN_FRONTEND VERSION HOME JAVA_HOME ES_PKG_NAME'.split()]
envs =  ' '.join(["-e "+env for env in filter(lambda e: not any([e.startswith(x) for x in blacklist]), info['Config']['Env'])])

vols =  ' '.join(["-v "+vol for vol in (info['HostConfig']['Binds'] or [])])

ports = [(port.split('/',1)[0], hp['HostIp'], hp['HostPort']) for port, hostports in (info['HostConfig']['PortBindings'] or {}).iteritems() for hp in hostports]
ports = ' '.join(["-p "+hostip+":"+hostport+":"+port if hostip!="" else "-p "+hostport+":"+port for port, hostip, hostport in ports])

links = ' '.join(["--link "+':'.join([l.rsplit('/',1)[-1] for l in link.split(':')]) for link in (info['HostConfig']['Links'] or [])])

image = info['Config']['Image']

base_cmd = 'docker run -d --name %s %s %s %s %s %s' % (name, envs, vols, ports, links, image)

ept  = info['Config']['Entrypoint']
if ept == []:
    args = info['Config']['Cmd']
else:
    args = info['Args']

if args != None and args != []:
    base_cmd += ' "%s"' % (' '.join(args))

print base_cmd

