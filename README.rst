           ============
             Gitson
           ============

Ultralite distributed DNS syndication.

Gitson sprung from the wish to have a resilient and scalable DNS infrastructure.
Released under the Affero GNU Public License.

What is Gitson?
=================

Gitson is a DNS server with domain records managed in git repos,
supervised by a shell script that validates said records.

Quick install
=============

1. install and set up daemontools, ucscpi-tcp and tinydns. 
   The best way to do it is through running the following scripts:
   https://github.com/comotion/gone/blob/HEAD/modules/daemontools
   https://github.com/comotion/gone/blob/HEAD/modules/ucspi
   https://github.com/comotion/gone/blob/HEAD/modules/tinydns

   These scripts will configure up-to-date, patched versions of the software!

2. create git repos for your domain records
3. git clone git://github.com/comotion/gitson /etc/gitson
4. clone your and my domain git repos into /etc/dns/zones/<repo>
5. check that everything works by running /gitson/gitson in /etc/dns
6. cp gitson.cron /etc/cron.d/gitson # to periodically sync and validate repos

Motivation
==========

Let's say I own hackeriet.org and you own foo.no

I'm running ns0.hackeriet.org and ns1.hackeret.org
You are running ns[123].foo.no.

It sucks to have so few DNS servers, 
   obviously we would benefit from backing each other up
   by being each other's secondary DNS servers.

Sure, we could AXFR, despite that whole protocol sucking ass. Yes, it has its
shortcomings, the primary one being that FTP is about as good or better.
So far we've preferred rsync but it's time to up the steaks.

Even if you're my friend, and I have to trust you to a point when I'm 
delegating my domains to your servers, suppose we are managing a ton of domains,
some are yours, some are mine, some we share control over, some we want to
let other people update despite being managed on our servers.

I'm not gonna give you admin on my DNS server, and you are definitely not giving
admin to the people who occasionally have to update one or two records that we're
authoratative for. 

We want to easily change any record in our control, and have that change
  propagate throughout our DNS syndication quickly and reliably.
We want to limit changes to those with write access, and
we want to track those changes over time.

Also, we find that BIND sucks a whole new league of ass, primarily but certainly not 
limited to it's asenine zone records. Most DNS servers' downfall is the parser
for this ridiculous format, which usually is about as large as the rest of the
server. Only exception is BIND itself, which somehow manages to be ten times 
larger than its parser.

Furthermore, we really don't like putting our DNS records in SQL, 
despite the fact that Maintain, NicTool and Sauron may be perfectly decent programs.

So, we base ourselves on git and TinyDNS, and we write a script to validate
domain records before turning them /live/ on our server.

How it works
============

First, you and I both set up our DNS software, and to make it easy to interoperate
we both use TinyDNS. Yes, TinyDNS  is old school, but we've patched and batched it,
see https://github.com/comotion/gone/blob/HEAD/modules/tinydns
for a one-liner installation procedure.

Once we have running DNS servers,
we both create git repos containing our DNS zones. Each git repo
contains (sub)domains that a particular group of people have access to.

The origin git repo is hosted by whoever is authorative for those zones,
for instance, you would create a foo.no repo and host it on your server,
   and I would create a hackeriet.org repo and host it on my server.

Then we clone each others' domain repos and pull them periodically,
validating them with gitson before 

For our scripts to work, your TinyDNS root should be symlinked to
/etc/dns

Gitson should be in
/etc/dns/gitson/

and all domain record repos should be cloned into

/etc/dns/zones/<repo>

Additional features
===================

conip
-----

conip is a script to update DNS records with ssh clients. it is still work in progress

fp2djb
------

convert ssh fingerprints to tinydns records.

legend
------

just an example zone file for use with TinyDNS

Credits
=======

Gitson by krav and comotion, Fall 2011.
Renamed to Gitson, July 2015
