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

for x in $TESTS
do
	rm -rfv /tmp/for-$T/$x
	mkdir -p /tmp/for-$T/$x
	cd /tmp/for-$T/$x

	cp -vf $SHELF/nitros9/level2/coco3/NOS9_6809_L2_80d.dsk L2.dsk

	( cd /home/strick/go/src/github.com/strickyak/doing_os9/bootdisk_to_sbc09_file
	  GOPATH=$SHELF go install bootdisk_to_sbc09_file.go
	)
	bootdisk_to_sbc09_file --level=2 < L2.dsk > L2.boot

	#( cd /home/strick/go/src/github.com/strickyak/doing_os9/grok_os9_disk/ ; go build -x )
	#/home/strick/go/src/github.com/strickyak/doing_os9/grok_os9_disk/grok_os9_disk < /tmp/L2.dsk > /tmp/for-$T-$x/manifest /tmp/for-$T-$x/disk

	os9 copy -l -r $SHELF/whippets/hasty/$x/startup L2.dsk,startup

	cp -v $SHELF/whippets/hasty/$x/inkey inkey
	cp -v $SHELF/toolshed/cocoroms/coco3.rom  coco3.rom
	cp -v $SHELF/toolshed/cocoroms/coco3.rom.list  coco3.rom.list
	cp -v $SHELF/toolshed/hdbdos/hdbsdc.rom  hdbsdc.rom
	cp -v $SHELF/toolshed/hdbdos/hdbsdc.rom.list  hdbsdc.rom.list
	cp -v $SHELF/build-frobio/axiom41.rom axiom41.rom
	cp -v $SHELF/build-frobio/axiom41.rom.list axiom41.rom.list

	../gomar.coco3.level2.vdg  $TRACE_ARGS -disk L2.dsk  -rom_8000 coco3.rom -internal_rom_listing coco3.rom.list  -cart axiom41.rom  -external_rom_listing axiom41.rom.list --inkey_file=inkey -max 180000000 --show_vdg_screen=1 --bracket_terminal --expect='Level 2 V3;April 04, 2024  00:00;Shell+ v2.2a;{Term|02}/DD:' | tee _out

	# ../gomar.coco3.level2.vdg  $TRACE_ARGS -disk L2.dsk  -rom_8000 coco3.rom -internal_rom_listing coco3.rom.list  -cart axiom41.rom  -external_rom_listing axiom41.rom.list --inkey_file=inkey -max 180000000 --show_vdg_screen=1 --bracket_terminal --expect="$(cat expect)" | tee _out

	# ../gomar.coco3.level2.vdg  $TRACE_ARGS -disk L2.dsk  -rom_8000 coco3.rom -cart hdbsdc.rom  -max 50000000  --bracket_terminal --expect='Level 2 V3;Module Directory at;DeIniz;Free Blocks;megaread;Module Directory at;1 MDir;Shell+ v;Term'| tee _out

	# ../gomar.coco3.level2.vdg  $TRACE_ARGS -boot /tmp/B2  -disk /tmp/L2.dsk  -max 50000000  --bracket_terminal --expect='Level 2 V3;Module Directory at;DeIniz;Free Blocks;megaread;Module Directory at;1 MDir;Shell+ v;Term'| tee _out

	echo $T/$x OKAY.
done

######################## OLD
# go run -x --tags=coco3,level2,trace,d  gomar.go -t 1  -boot  ~/MIRROR/gomar-data/boot2coco3  -disk ~/coco-shelf/nitros9/level2/coco3/NOS9_6809_L2_80d.dsk | tee _out
# time go run -x --tags=coco3,level2  gomar.go -boot  ~/MIRROR/gomar-data/boot2coco3  -disk /tmp/L2.dsk -max 50000000 --bracket_terminal --expect='Level 2 V3;Module Directory at;DeIniz;Free Blocks;megaread;Module Directory at;1 MDir;Shell+ v;Term'| tee _out
