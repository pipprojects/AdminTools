#!/bin/bash
#
   volsize="$1"
   #volsized="$(echo "$volsize" | awk '{
   echo "$volsize" | awk '{
                                SIZE=$1
                                SHOW=$2
				SMULT=1
				SMULT=1
#
				FNN=match(SIZE,"[a-zA-Z]")
                                lastc=substr(SIZE,FNN,length(SIZE)-FNN+1)
printf "%s\n",lastc
                                SIZEN=substr(SIZE,1,FNN-1)
                                if ( FNN == 0 ) {
				 lastc="B"
                                 SIZEN=SIZE
				}
                                if ( lastc ~ /[Bb]*/ ) {
                                 SMULT=1
                                }
                                if ( lastc ~ /[Kk][Bb]*/ ) {
                                 SMULT=1024
                                }
                                if ( lastc ~ /[Mm][Bb]*/ ) {
                                 SMULT=1024*1024
                                }
                                if ( lastc ~ /[Gg][Bb]*/ ) {
                                 SMULT=1024*1024*1024
                                }
                                if ( lastc ~ /[Tt][Bb]*/ ) {
                                 SMULT=1024*1024*1024*1024
                                }
#
                                if ( SHOW ~ /[Bb]/ ) {
                                 HMULT=1
                                 MULT="B"
                                }
                                if ( SHOW ~ /[Kk]/ ) {
                                 HMULT=1024
                                 MULT="K"
                                }
                                if ( SHOW ~ /[Mm]/ ) {
                                 HMULT=1024*1024
                                 MULT="M"
                                }
                                if ( SHOW ~ /[Gg]/ ) {
                                 HMULT=1024*1024*1024
                                 MULT="G"
                                }
                                if ( SHOW ~ /[Tt]/ ) {
                                 HMULT=1024*1024*1024*1024
                                 MULT="T"
                                }
#
                                printf "%f%s\n",SIZEN*SMULT/HMULT,MULT
				}'
#				}')"
#echo $volsized
#
