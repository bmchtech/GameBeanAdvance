# get arguments
FILE=$(readlink -f $1)
NUM_INSTRUCTIONS=$2

# run the modified version of visualboyadvance
visualboyadvance-m $1 $2