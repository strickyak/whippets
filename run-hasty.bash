#!/bin/bash
set -eux -o pipefail
export SHELF="$(cd $(dirname $0)/.. ; /bin/pwd )"
export PATH="$SHELF/bin:/usr/bin:/bin"
T=$(date +hasty-%Y%m%d-%H%M%S)

TESTS=
TRACE_TAGS=
TRACE_ARGS=
while [[ $# != 0 ]]
do
  case "$1" in
        -t )  # enable trace
                TRACE_TAGS=trace,d
                TRACE_ARGS="-t=1 --borges=$HOME/borges"
                ;;
        [a-z]* )
                TESTS="$TESTS $(basename $1)"
                ;;
        * )
                echo "$0: Unknown argument: $1" >&2
		exit 13
                ;;
  esac
  shift
done

RAN=0

rm -rfv /tmp/for-$T
mkdir -p /tmp/for-$T

cd $SHELF/gomar
go build --tags=coco3,level2,vdg,cocoio,gime,$TRACE_TAGS  -o /tmp/for-$T/gomar.coco3.level2.vdg  gomar.go

cd ../frobio/frob3/lemma/waiter/
GOBIN=$SHELF/bin GOPATH=$SHELF /usr/bin/go build -o /tmp/for-$T/waiter -x lemma-waiter.go

cd /tmp/for-$T/
./waiter -cards=1 -lemmings_root=$SHELF/build-frobio/lemma/LEMMINGS -lan=127.0.0.1 -config_by_dhcp=0 >waiter.log 2>&1 &
DAEMON=$!
trap "EXIT=\$? ; kill $DAEMON ; exit \$EXIT" 0 1 2 3 15

count=0
for x in $TESTS
do
	rm -rfv /tmp/for-$T/$x
	mkdir -p /tmp/for-$T/$x
	cd /tmp/for-$T/$x

	cp -vf $SHELF/nitros9/level2/coco3/NOS9_6809_L2_80d.dsk L2.dsk
	os9 copy -l -r $SHELF/whippets/hasty/$x/startup L2.dsk,startup

	cp -v $SHELF/whippets/hasty/$x/inkey inkey
	cp -v $SHELF/whippets/hasty/$x/expect expect
	cp -v $SHELF/toolshed/cocoroms/coco3.rom  coco3.rom
	cp -v $SHELF/toolshed/cocoroms/coco3.rom.list  coco3.rom.list
	cp -v $SHELF/toolshed/hdbdos/hdbsdc.rom  hdbsdc.rom
	cp -v $SHELF/toolshed/hdbdos/hdbsdc.rom.list  hdbsdc.rom.list
	cp -v $SHELF/build-frobio/axiom41.rom axiom41.rom
	cp -v $SHELF/build-frobio/axiom41.rom.list axiom41.rom.list

	../gomar.coco3.level2.vdg  $TRACE_ARGS -disk L2.dsk  -rom_8000 coco3.rom -internal_rom_listing coco3.rom.list  -cart axiom41.rom  -external_rom_listing axiom41.rom.list -n --inkey_file=inkey -max 180'000'000 --show_vdg_screen=1 --bracket_terminal --expect_file=expect | tee _out

	count=$(( $count + 1 ))
	echo "OKAY -- TEST (#$count) /tmp/for-$T/$x" >&2
done
echo "OKAY -- RAN $count TESTS: /tmp/for-$T" >&2
