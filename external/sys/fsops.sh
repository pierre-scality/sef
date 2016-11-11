#!/bin/bash

# monitor activity from sfused stats files:
# operation counts, throughputs, parallel ops

# defaults
file=""
clist=""
tlist=" "
plist=" "
ulist=" "
llist=" "
slist=" "
width=9
section=1
tp=0
disk=""

########

tool=$(basename $0)

usage() {
    echo "usage: $tool -f <stats file> [options]"
    echo "	-c <ops>	report ops counts"
    echo "	-t <ops>	report ops throughputs"
    echo "	-T 		report global throughput"
    echo "	-p <ops>	report parallel ops"
    echo "	-u <ops>	report ops usage"
    echo "	-L <ops>	report ops latency"
    echo "	-S <ops>	report ops size"
    echo "	-l <screen lines>"
    echo "	-w <column width>"
    echo "	-s <subsection>"
    echo "	-d <disk> (for bizio stats)"
    echo "	-h 		show usage"
    echo "The 'stats file' can be:"
    echo "	a local pseudo-file:"
    echo "		$ fsops -f /run/scality/.../misc/stats_sfused"
    echo "	a HTTP URL:"
    echo "		$ fsops -f  http://localhost:8001/bizobj"
    echo "	a bizobj descriptor:"
    echo "		$ fsops -f bizobj://ring:0 -d disk1"
    exit 1
}

args=$(getopt -o "f:c:t:Tp:u:L:S:l:w:s:hd:" -- "$@")
[ $? = 0 ] || usage
eval set -- "$args"

while : ; do
    case "$1" in
        "-f")   file="$2" ; shift 2 ;;
        "-c")   clist="$2" ; shift 2 ;;
        "-t")   tlist="$2" ; shift 2 ;;
        "-T")   tp=1 ; shift ;;
        "-p")   plist="$2" ; shift 2 ;;
        "-u")   ulist="$2" ; shift 2 ;;
        "-L")   llist="$2" ; shift 2 ;;
        "-S")   slist="$2" ; shift 2 ;;
        "-l")   lines="$2" ; shift 2 ;;
        "-w")   width="$2" ; shift 2 ;;
        "-s")   section="$2" ; shift 2 ;;
        "-d")   disk="$2" ; shift 2 ;;
        "-h")   usage ;;
        "--")   shift ; break ;;
        *)      echo "$tool: invalid argument '$1'" ; exit 1 ;;
    esac
done

if [ $# != 0 ]; then
    echo "$tool: extra arguments: $@"
    echo "run $tool -h for help"
    exit 1
fi

case "$file" in
    "")
	echo "$tool: missing argument: -f <stats file>"
	echo "run $tool -h for help"
	exit 1
	;;
    "http"*)
	if ! curl -s -f -I "$file" > /dev/null ; then
	    echo "$tool: could not fetch stats url $file"
	    exit 1
	fi
	;;
    "bizobj"*)
	if [ -z "$disk" ]; then
	    echo "$tool: must provide disk name (-d) when polling bizobj stats"
	    exit 1
	fi
	if ! bizioctl -c bizobj_advanced_stats -N "$disk" "$file" > /dev/null ; then
	    echo "$tool: could not fetch stats from $file disk $disk"
	    exit 1
	fi
	;;
    *)
	if [ ! -e "$file" ]; then
	    echo "$tool: could not find stats file $file"
	    exit 1
	fi
	;;
esac

case "$file" in
    *pipe)
	delay=0.1
	;;
    *)
	delay=1
	;;
esac

l=${lines:-$LINES}
if [ -z "$l" ]; then
    l=$(stty size|cut -d' ' -f1)
fi
if [ -z "$l" ]; then
    l=25
fi
l=$((l-4))

getstats() {
    case "$file" in
	"http"*)
	    curl -s "$file"
	    ;;
	*"pipe")
	    awk '{print}/^Total/{exit}' "$file"
	    ;;
	"bizobj"*)
	    bizioctl -c bizobj_advanced_stats -N "$disk" "$file"
	    ;;
	*)
	    cat "$file"
	    ;;
    esac | awk -v s=$section '/timestamp/{t++} t==s'
}
export -f getstats
export file

oplist=$(getstats | awk '
# ignore last lines of /sys/stats_sfused
/^total number / { next }
/^for the last /  { next }

/^Total / { next }

$1 == "operation" { p = 1; next }
p && $2 != "<" && $2 != ">=" { printf "%s ",$1 }
')

clist="${clist:-$oplist}"
tlist="${tlist:-$oplist}"
plist="${plist:-$oplist}"
ulist="${ulist:-$oplist}"
llist="${llist:-$oplist}"
slist="${slist:-$oplist}"

echo reading stats from "$file"

(getstats; while sleep $delay; do
    getstats
done) | awk -v l=$l -v w=$width -v tp=$tp -v oplist="$oplist" \
 -v coplist="$clist" -v toplist="$tlist" -v poplist="$plist" \
 -v uoplist="$ulist" -v loplist="$llist" -v soplist="$slist" '
BEGIN{
	split(oplist, opslist);
	for (i in opslist)
		isop[opslist[i]] = 1;
	ncops = split(coplist, clist);
	ntops = split(toplist, tlist);
	npops = split(poplist, plist);
	nuops = split(uoplist, ulist);
	nlops = split(loplist, llist);
	nsops = split(soplist, slist);
}

$1 == "timestamp:" { ts = $2 }

isop[$1] && $2 != "<" && $2 != ">=" {
	par[$1] = $3;
	cnt[$1] = $2 - counters[$1]; counters[$1] = $2;
	vol[$1] = $9 - volumes[$1]; volumes[$1] = $9;
	tm[$1] = $8 - times[$1]; times[$1] = $8;
	lat[$1] = cnt[$1] ? tm[$1]/cnt[$1] : 0.0;
	siz[$1] = cnt[$1] ? vol[$1]/cnt[$1] : 0;
}

!p && /Total/{
	# skip output on first iteration
	if (tp) {
		inp=$3;
		out=$5;
	}
	p++;
	next;
}

/Total/{
	# print column titles every 'l' lines
	if ((line++ % l) == 0) {
		if (tp)
			printf "%15s %10s %10s", "", "MB/s", "MB/s";
		else
			printf "%15s", "";
		if (ntops) printf "|%*s", w, "MiB/s";
		for(i = 2; i <= ntops; i++) printf " %*s", w, "";
		if (ncops) printf "|%*s", w, "count";
		for(i = 2; i <= ncops; i++) printf " %*s", w, "";
		if (npops) printf "|%*s", w, "// ops";
		for(i = 2; i <= npops; i++) printf " %*s", w, "";
		if (nlops) printf "|%*s", w, "lat (ms)";
		for(i = 2; i <= nlops; i++) printf " %*s", w, "";
		if (nuops) printf "|%*s", w, "time (s)";
		for(i = 2; i <= nuops; i++) printf " %*s", w, "";
		if (nsops) printf "|%*s", w, "size (b)";
		for(i = 2; i <= nsops; i++) printf " %*s", w, "";
		printf "\n";
		if (tp)
			printf "%15s %10s %10s", "", "readmbs", "writembs";
		else
			printf "%15s", "";
		for(i = 1; i <= ntops; i++)
			printf " %*s", w, tlist[i];
		for(i = 1; i <= ncops; i++)
			printf " %*s", w, clist[i];
		for(i = 1; i <= npops; i++)
			printf " %*s", w, plist[i];
		for(i = 1; i <= nlops; i++)
			printf " %*s", w, llist[i];
		for(i = 1; i <= nuops; i++)
			printf " %*s", w, ulist[i];
		for(i = 1; i <= nsops; i++)
			printf " %*s", w, slist[i];
		printf "\n";
	}
	if (tp) {
		printf "%15s %10.1f %10.1f", ts, ($3-inp)/1e+6, ($5-out)/1e+6;
		inp=$3;
		out=$5;
	} else
		printf "%15s", ts;
	for(i = 1; i <= ntops; i++)
		printf " %*.1f", w, vol[tlist[i]]/1e+6;
	for(i = 1; i <= ncops; i++)
		printf " %*d", w, cnt[clist[i]];
	for(i = 1; i <= npops; i++)
		printf " %*d", w, par[plist[i]];
	for(i = 1; i <= nlops; i++)
		printf " %*.1f", w, lat[llist[i]];
	for(i = 1; i <= nuops; i++)
		printf " %*.2f", w, tm[ulist[i]]/1000;
	for(i = 1; i <= nsops; i++)
		printf " %*d", w, siz[slist[i]];
	printf "\n";
	fflush();
}'

