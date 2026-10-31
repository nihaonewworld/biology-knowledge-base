#!/bin/bash
set -e

while getopts ":s:t:i:f:m:p:o:r:h" opt; do
    case $opt in
        s) serialNumber=$OPTARG ;;
        t) organism=$OPTARG ;;
        i) sawIndexDir=$OPTARG ;;
        f) fastqDir=$OPTARG ;;
        m) maskDir=$OPTARG ;;
        p) imageDir=$OPTARG ;;
        o) output=$OPTARG ;;
        r) imageDir2=$OPTARG ;;
        h) 
            echo "Usage: $0 -s <serialNumber> -t <organism> -i <sawIndexDir> -f <fastqDir> -m <maskDir> -p <imageDir> -o <output>"
            echo "Usage: $0 -s <serialNumber> -r <imageDir2> -o <output>"
            echo "  -s <serialNumber>       : Stereo-seq chip serial number (required)"
            echo "  -t <organism>           : Organism, eg. 'Homo_sapiens', 'Mus_musculus' (required)"
            echo "  -i <sawIndexDir>        : SAW index directory (required)"
            echo "  -f <fastqDir>           : FASTQ directory (required)"
            echo "  -m <maskDir>            : Mask directory (required)"
            echo "  -p <imageDir>           : Image tar file (required)"
            echo "  -o <output>             : Output directory (required)"
            echo "  -r <imageDir2>          : Image tar file for realignment (optional, if provided, only realignment will run)"
            exit 0
            ;;
        \?) 
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

if [ -z "$serialNumber" ] || [ -z "$organism" ] || [ -z "$fastqDir" ] || [ -z "$sawIndexDir" ] || \
        [ -z "$maskDir" ] || [ -z "$imageDir" ] || [ -z "$output" ]; then
    echo "Error: All parameters except imageDir2 are required."
    echo "Use -h for help."
    exit 1
fi

echo "Stereo-seq Chip Serial Number: $serialNumber"
echo "Organism: $organism"
echo "SAW Index Directory: $sawIndexDir"
echo "FASTQ Directory: $fastqDir"
echo "Mask Directory: $maskDir"
echo "Image Directory: $imageDir"
echo "Output Directory: $output"
echo "Image Directory2: $imageDir2"

if [ -z "$imageDir2" ]; then
    echo "Running saw count..."
    saw-8.1.1/bin/saw count \
        --sn=$serialNumber \
        --omics=transcriptomics \
        --kit-version="Stereo-seq T FF V1.2" \
        --sequencing-type="PE100_50+100" \
        --chip-mask=$maskDir \
        --organism=$organism \
        --fastqs=$fastqDir \
        --reference=$sawIndexDir \
        --image-tar=$imageDir \
        --output=$output
else
    echo "Running saw realign..."
    countData="$output/$serialNumber"
    realignOutput="$output/realign"

    ~/saw-8.1.1/bin/saw realign \
        --sn=$serialNumber \
        --count-data=$countData \
        --realigned-image-tar=$imageDir2 \
        --output=$realignOutput
fi
