def lsfr(seed, polynom, count):
    result = list()

    data = seed
    poly = polynom

    for i in range( count - 1 ):
        lsb = data & 1
        data = data >> 1
        if lsb != 0:
          data = data ^ poly
        result.append( lsb )
    return( result )

reference_results = lsfr( 1, 0b100010000, 1000 )

print( reference_results )

with open("ref_results.txt","w") as f:
    for l in reference_results:
        f.write( str(l) + "\n" )

# Полиномы:
#    2  : 0b11,
#    3  : 0b110,
#    4  : 0b1100,
#    5  : 0b10100,
#    6  : 0b110000,
#    7  : 0b1100000,
#    8  : 0b10111000,
#    9  : 0b100010000,
#    10 : 0b1001000000,
#    11 : 0b10100000000,
#    12 : 0b111000001000,
#    13 : 0b1110010000000,
#    14 : 0b11100000000010,
#    15 : 0b110000000000000,
#    16 : 0b1011010000000000,
#    17 : 0b10010000000000000,
#    18 : 0b100000010000000000,
#    19 : 0b1110010000000000000,
