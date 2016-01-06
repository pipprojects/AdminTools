#!/bin/awk -f
# bits2str --- turn a byte into readable 1's and 0's
function bits2str(bits,        data, mask)
{
         if (bits == 0)
             return "0"
     
         mask = 1
         for (; bits != 0; bits = rshift(bits, 1))
             data = (and(bits, mask) ? "1" : "0") data
     
         while ((length(data) % 8) != 0)
             data = "0" data
     
         return data
}
BEGIN {
#         printf "123 = %s\n", bits2str(123)
#         printf "0123 = %s\n", bits2str(0123)
#         printf "0x99 = %s\n", bits2str(0x99)
#         comp = compl(0x99)
#         printf "compl(0x99) = %#x = %s\n", comp, bits2str(comp)
#         shift = lshift(0x99, 2)
#         printf "lshift(0x99, 2) = %#x = %s\n", shift, bits2str(shift)
#         shift = rshift(0x99, 2)
#         printf "rshift(0x99, 2) = %#x = %s\n", shift, bits2str(shift)
}
{
	FUNC=tolower($1)
	RES1=bits2str($2)
	RES2=bits2str($3)
	printf "%s %s\n",RES1,RES2
	if ( FUNC == "and" ) {
	 ANS=and(RES1,RES2)
	} else if ( FUNC == "or" ) {
	 ANS=or(RES1,RES2)
	} else if ( FUNC == "xor" ) {
	 ANS=xor(RES1,RES2)
	} else if ( FUNC == "not" ) {
	 ANS=compl(RES1)
	}
	printf "%s\n",ANS
}
#
