#! /bin/bash -l

# This is a small script using vcftools to remove indels

set +e
set -x

#SBATCH -A b2011141
#SBATCH -p core
#SBATCH -o ldhat.summary.anno.tremuloides.out
#SBATCH -e ldhat.summary.anno.tremuloides.err
#SBATCH -J ldhat.summary.anno.tremuloides.job
#SBATCH -t 1-00:00:00
#SBATCH --mail-user jing.wang@emg.umu.se
#SBATCH --mail-type=ALL

window=$1
anno=$2

ld_Dir="/proj/b2010014/GenomePaper/population_genetics/GATK/HC/snp_filter/tremuloides/annotation/ldhat/$anno/$window/interval"
ld_bed="/proj/b2010014/GenomePaper/population_genetics/GATK/HC/snp_filter/tremuloides/ldhat/bed/$1"
Output="/proj/b2010014/GenomePaper/population_genetics/GATK/HC/snp_filter/tremuloides/annotation/ldhat/$anno/summary/$window"

if [ ! -d "$Output" ]; then
mkdir -p $Output
fi

mean="/proj/b2011141/tools/mean"

echo -e "Chr\tWin\tScaffold\tNum\tldhat" > $Output/ldhat.tremuloides.$anno.$window.summary.txt

for file in $ld_Dir/*res.txt
do
input=${file##*/}
chr_out=${input%%.res.txt}
number=${chr_out##*.}
chr_n=${chr_out#tremuloides_}
chr_number=${chr_n%.*}
echo $chr_number
chr="Chr"$chr_number
echo $chr

line=$(cat $file | wc -l)
echo $line
n=$(echo "$line-2" | bc)
echo $n
ldhat_mean=$($mean col=2 header=2 $file | sed '1,2d')

scaffold=$(sed '1d' $ld_bed/${chr_out}.bed |cut -f 2 )
echo $scaffold

if [ $1 == "10kb" ] ; then
middle_scaffold=$(echo $scaffold+5001 |bc)
fi
if [ $1 == "100kb" ] ; then
middle_scaffold=$(echo $scaffold+50001 |bc)
fi
if [ $1 == "500kb" ] ; then
middle_scaffold=$(echo $scaffold+250001 |bc)
fi
if [ $1 == "1Mb" ] ; then
middle_scaffold=$(echo $scaffold+500001 |bc)
fi

echo $middle_scaffold
echo -e "$chr\t$number\t$middle_scaffold\t$n\t$ldhat_mean" >> $Output/ldhat.tremuloides.$anno.$window.summary.txt
done

sort -k1,1V -k2,2n $Output/ldhat.tremuloides.$anno.$window.summary.txt > $Output/temp && mv $Output/temp $Output/ldhat.tremuloides.$anno.$window.summary.txt


