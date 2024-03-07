while getopts s:l: flag
do
    case "${flag}" in
        s) samples=${OPTARG};;
	l) location=${OPTARG};; 
    esac
done

if [ -f "$samples" ]
then
    echo "samples.tsv found"
else
    echo "samples.tsv not found"
fi


if [ -d "results/" ] 
then
    echo "Directories all set-up" 
else
    mkdir results
    echo "setting up directories"
fi

if [ -d "temp/" ]
then
    echo "Temporary data there"
else
    echo "Sample data missing"
    mkdir temp
    rsync -avP --password-file /cluster/home/anjohn/rsync.pass -e "ssh -i ${HOME}/.ssh/id_ed25519_trans -l anjohn@d" automaticuser@bs-bewi08.ethz.ch::bfabric-downloads/p23224/$location/*bam ./temp/
   rsync -avP --password-file /cluster/home/anjohn/rsync.pass -e "ssh -i ${HOME}/.ssh/id_ed25519_trans -l anjohn@d" automaticuser@bs-bewi08.ethz.ch::bfabric-downloads/p23224/$location/*bai ./temp/

fi


#2. Set up your directory for your local copy of the data (where you'll run v-pipe later). Directory structure: work-ont_order_run/v-pipe/results
#create sub-directory structure (probs could also do it directly with samples.tsv
while read s b o; do mkdir -p results/$s/$b/alignments; done < $samples

#3. copy bam and bam.bai files to respective directory
while read s b o; do rsync -vPz temp/${s%%_*}.primertrimmed.rg.sorted.{bam,bam.bai} results/${s}/$b/alignments/; done < $samples

#4. renaming to fit v-pipe convention
while read s b o; do mv results/$s/$b/alignments/{${s%%_*}.primertrimmed.rg.sorted.bam,REF_aln_trim.bam} ;done < $samples
while read s b o; do mv results/$s/$b/alignments/{${s%%_*}.primertrimmed.rg.sorted.bam.bai,REF_aln_trim.bam.bai} ;done < $samples

#5. Preparing v-pipe

if [ -f "vpipe-test.sbatch" ]
then
    echo "vpipe-test.sbatch found"
else
    cp ../../v-pipe_essentials/Apr23/vpipe-test.sbatch ./	
    echo "vpipe-test.sbatch NOT found, copying from ../../v-pipe_essentials/Apr23/"
fi

if [ -f "vpipe" ]
then
    echo "vpipe found"
else
    cp ../../v-pipe_essentials/Apr23/vpipe ./
    echo "vpipe NOT found, copying from ../../v-pipe_essentials/Apr23/"
fi

if [ -f "vpipe.config" ]
then
    echo "vpipe.config found"
else
    cp ../../v-pipe_essentials/Apr23/vpipe.config ./
    echo "vpipe.config NOT found, copying from ../../v-pipe_essentials/Apr23/"
fi

if [ -f "variant_config.yaml" ]
then
    echo "variant_config.yaml found"
else
    cp ../../v-pipe_essentials/Apr23/variant_config.yaml ./
    echo "variant_config.yaml NOT found, copying from ../../v-pipe_essentials/Apr23/"
fi

if [ -f "var_dates.yaml" ]
then
    echo "var_dates.yaml found"
else
    cp ../../v-pipe_essentials/Apr23/var_dates.yaml ./
    echo "var_dates.yaml NOT found, copying from ../../v-pipe_essentials/Apr23/"
fi

if [ -d "references/" ]
then
    echo "references/ found"
else
    cp -r ../../v-pipe_essentials/Apr23/references ./
    echo "references/ NOT found, copying from ../../v-pipe_essentials/Apr23/"
fi

if [ -f "regex.yaml" ]
then
    echo "regex.yaml found"
else
    cp ../../v-pipe_essentials/Apr23/regex.yaml ./
    echo "regex.yaml NOT found, copying from ../../v-pipe_essentials/Apr23/"
fi

if [ -f "ww_locations.tsv" ]
then
    echo "ww_locations.tsv found"
else
    cp ../../v-pipe_essentials/Apr23/ww_locations.tsv ./
    echo "ww_locations.tsv NOT found, copying from ../../v-pipe_essentials/Apr23/"
fi

if [ -f "deconv_linear_logit_quasi_strat.yaml" ]
then
    echo "deconv_linear_logit_quasi_strat.yaml found"
else
    cp ../../v-pipe_essentials/Apr23/deconv_linear_logit_quasi_strat.yaml ./
    echo  "deconv_linear_logit_quasi_strat.yaml NOT found, copying from ../../v-pipe_essentials/Apr23/"
fi

if [ -f "amplicon_covs_new.py" ]
then
    echo "amplicon_covs_new.py found"
else
    cp ../../v-pipe_essentials/Apr23/amplicon_covs_new.py ./
    echo "amplicon_covs_new.py NOT found, copying from ../../v-pipe_essentials/Apr23/"
fi


#7.Vpipe Dryrun
./vpipe --dryrun allCooc tallymut deconvolution

#if no errors run 
#sbatch vpipe-test.sbatch

#8. Remove temporary files 
#rm -r temp/
