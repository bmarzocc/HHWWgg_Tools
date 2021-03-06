#!/bin/bash
# Abe Tishelman-Charny
# 16 January 2019
# 
# The purpose of this script is to run the CRAB steps to create gen miniAOD's of WWgg for different decay channels. This is so variables can be plotted to see the differences in the processes. 

# Want to change to CMSSW directory which python config file was created in. 

# Location of my pythia fragments 
#/afs/cern.ch/work/a/atishelm/private/HH_WWgg/CMSSW_7_1_25/src/Configuration/GenProduction/python/ggF_X1000_WWgg_enuenugg.py
#/afs/cern.ch/work/a/atishelm/private/HH_WWgg/CMSSW_7_1_25/src/Configuration/GenProduction/python/ggF_X1000_WWgg_jjenugg.py

## Location of my CRAB configuration files (maybe not)
##/afs/cern.ch/work/a/atishelm/private/CRAB/CrabConfig.py

submit_crab_GEN(){

    cmssw_v=$3
    chosen_threads=$4 
    num_jobs=$5
    LocalGridpackPath=$6
    Campaign=$7
    dryRun=$8
    Year=$9 

    echo "Submit_Crab_GEN variable check"
    echo "cmssw_v: $cmssw_v"
    echo "chosen threads: $chosen_threads "
    echo "num_jobs: $num_jobs"
    echo "LocalGridpackPath: $LocalGridpackPath"
    echo "Campaign: $Campaign"
    echo "dryRun: $dryRun"

    localWorkingArea="/afs/cern.ch/work/a/atishelm/private/HHWWgg_Tools/Production/"

    cd $localWorkingArea$cmssw_v/src/ # Directory where config file was conceived. Need to be in same CMSSW for crab config 
    #echo "pwd = $PWD"
    #cmsenv

    # Check if there is a VOMS proxy for using CRAB 
    check_proxy 

    # Source CRAB 
    # echo "Sourcing crab"
    #source /cvmfs/cms.cern.ch/crab3/crab.sh
    # echo "Just sourced crab"
    cmsenv

    # Create CRAB Config file 
    echo "1: $1"
    IDName=$1 # Decay identifying name. Anything unique about the process should be contained in the pythia fragment file name 
    IDName=${IDName#"cmssw_configs/"} # Remove cmssw folder part from eventual crab config path
    #echo "IDName = $IDName"
    IDName=${IDName%???} # Remove .py 

    echo "IDName = $IDName"

    # This naming convention assumes IDName of the form:
    # <ProductionProcess>_<ResonantParticle>_<ResonantDecay>_<Channel>_<numEvents>_<Step>
    # ex: ggF_X1250_WWgg_enuenugg_10000events_GEN
    primdset=`echo $IDName | cut -d _ -f 3-6` # Primary dataset name  # assumes campaign of form <a>_<b>
    snddset=`echo $IDName | cut -d _ -f 7-` # Secondary dataset name 

    # fullsnddset # $Campaign
    fullSndDset="${Campaign}_${snddset}" # add campaign name 
    fullIDName=$IDName
    # fullIDName="${Campaign}_${IDName}"

    echo "fullIDName: $fullIDName"

    echo "primary dataset name = $primdset"
    echo "secondary dataset name = $fullSndDset"

    ccname=$fullIDName
    ccname+="_CrabConfig.py" # Crab Configuration file name 

    #echo "Total events = $2"
    totevts=$2 
    njobs=$num_jobs # Predetermined number of files to spread MC events over. Allows for parallel jobs. Very powerful..
    #njobs=1 # Predetermined number of files to spread MC events over 

    echo "totevts = $totevts"
    echo "njobs = $njobs"

    EvtsPerJob=$((totevts/njobs))
    echo "EvtsPerJob = $EvtsPerJob"

    #echo "from CRABClient.UserUtilities import config, getUsernameFromSiteDB" >> TmpCrabConfig.py
    echo "from CRABClient.UserUtilities import config" >> TmpCrabConfig.py
    echo "config = config()" >> TmpCrabConfig.py
    echo " " >> TmpCrabConfig.py

    #echo "IDName = $IDName"

    # if crab working area already exists, increment to unique name 
    working_area=$localWorkingArea$cmssw_v/src/crab_projects/crab_$fullIDName
    # working_area=/afs/cern.ch/work/a/atishelm/private/HH_WWgg/$cmssw_v/src/crab_projects/crab_$IDName

    # Do until unused working area name is found 
    # Make into some unique name function? Don't need to yet I guess 
    i=$((0))
    while : ; do

        if [ $i == 0 ]; then

            # If default working area doesn't exist, use this name 
            if [ ! -d $working_area ]; then 

                echo "Creating crab working area: '$working_area' for this crab request"
                # No need to increment IDName 
                break 
        
            fi

        else 
        
            tmp_IDName=$fullIDName
            tmp_IDName+=_$i 
            working_area=$localWorkingArea$cmssw_v/src/crab_projects/crab_$tmp_IDName 
            # working_area=/afs/cern.ch/work/a/atishelm/private/HH_WWgg/$cmssw_v/src/crab_projects/crab_$tmp_IDName 
            if [ ! -d $working_area ]; then

                echo "Creating crab working area: '$working_area' for this crab request"
                fullIDName=$tmp_IDName 
                # Use incremented IDName 
                break 

            fi 
    
        fi

    i=$((i+1))

    #echo "i = $i"
    #if [ $i == 2 ]; then
    #    break 
    #fi

    done

    echo "config.General.requestName = '$fullIDName'" >> TmpCrabConfig.py # If workArea/requestName exists already, this will not go through 
    echo "config.General.workArea = 'crab_projects'" >> TmpCrabConfig.py  
    echo "config.General.transferOutputs = True" >> TmpCrabConfig.py
    echo "config.General.transferLogs = False" >> TmpCrabConfig.py
    echo " " >> TmpCrabConfig.py
    
    echo "config.JobType.pluginName = 'PrivateMC'" >> TmpCrabConfig.py

    # If the input gridpack is a local path (non-cvmfs), need to place it in the crab sandbox
    # if [ $LocalGridpackPath != "" ]
    # then 
    #     echo "Using local gridpack, so setting crab project type to Analysis"
    #     echo "config.JobType.pluginName = 'Analysis'" >> TmpCrabConfig.py

    # else 
    #     echo "Not using local gridpack, so setting crab project tpye to PrivateMC"
    #     echo "config.JobType.pluginName = 'PrivateMC'" >> TmpCrabConfig.py

    # fi 

    # If the input gridpack is a local path (non-cvmfs), need to place it in the crab sandbox
    if [ $LocalGridpackPath != "none" ]
    then 
        echo "Adding gridpack: $LocalGridpackPath to crab sandbox"
        echo "config.JobType.inputFiles = [$LocalGridpackPath]" >> TmpCrabConfig.py  
    fi 

    echo "config.JobType.psetName = '$localWorkingArea$1'" >> TmpCrabConfig.py # Depends on where config file was created  
    # echo "config.JobType.psetName = '/afs/cern.ch/work/a/atishelm/private/HH_WWgg/$1'" >> TmpCrabConfig.py # Depends on where config file was created  

    echo "Year: $Year"
    
    ##-- couldn't find nthreads option in 2016 cmsDriver setup (CMSSW_7_X_X)
    if [ $Year == "2017" ] || [ $Year == "2018" ]
    then 
        if [ $chosen_threads != noval ]
        then
            echo "config.JobType.numCores = $chosen_threads" >> TmpCrabConfig.py  
            echo "config.JobType.maxMemoryMB = 8000" >> TmpCrabConfig.py
        else
            echo "no thread customization chosen. Not including numCores or maxMemory options in crab config file."
        fi 
    fi 

    echo " " >> TmpCrabConfig.py
    #echo "config.Data.outputPrimaryDataset = 'GEN_Outputs'" >> TmpCrabConfig.py # primdset
    echo "config.Data.outputPrimaryDataset = '$primdset'" >> TmpCrabConfig.py # primdset
    echo "config.Data.splitting = 'EventBased'" >> TmpCrabConfig.py

    #echo "number of events per job = $((EvtsPerJob))"
    #echo "config.Data.unitsPerJob = 100" >> TmpCrabConfig.py # Hardcoding to test cause of missing events 

    echo "config.Data.unitsPerJob = $((EvtsPerJob))" >> TmpCrabConfig.py # number of events per job for MC 
    echo "NJOBS = $njobs  # This is not a configuration parameter, but an auxiliary variable that we use in the next line." >> TmpCrabConfig.py
    #echo "NJOBS = 1  # This is not a configuration parameter, but an auxiliary variable that we use in the next line." >> TmpCrabConfig.py
    echo "config.Data.totalUnits = config.Data.unitsPerJob * NJOBS" >> TmpCrabConfig.py # Total number of events over all jobs (files) 
    #echo "#config.Data.outLFNDirBase = '/store/user/%s/' % (getUsernameFromSiteDB()) " >> TmpCrabConfig.py
    echo "config.Data.outLFNDirBase = '/store/group/phys_higgs/resonant_HH/RunII/MicroAOD/HHWWggSignal/'" >> TmpCrabConfig.py
    #echo "config.Data.outLFNDirBase = '/store/user/atishelm/'" >> TmpCrabConfig.py
    #echo "config.Data.outLFNDirBase = '/store/user/atishelm/'" >> TmpCrabConfig.py
    echo "config.Data.publication = False" >> TmpCrabConfig.py
    #echo "config.Data.outputDatasetTag = '$IDName'" >> TmpCrabConfig.py
    echo "config.Data.outputDatasetTag = '$fullSndDset'" >> TmpCrabConfig.py

    # config.JobType.inputFiles = ['/uscms_data/d3/fravera/NMSSM_XYH_bbbb_MCproduction_Run2016/CMSSW_7_1_19/src/GridPacks/NMSSM_XYH_bbbb_MX_300_MY_60_slc6_amd64_gcc481_CMSSW_7_1_30_tarball.tar.xz']

    #echo "config.Data.userInputFiles = ['/store/group/phys_higgs/resonant_HH/RunII/MicroAOD/HHWWggSignal/MinBias/ggF_X1000_WWgg_enuenugg_woPU_10000events_woPU/190116_184220/0000/ggF_X1000_WWgg_enuenugg_woPU_10000events_1.root'] # If DR1 step, this should be GEN file " >> TmpCrabConfig.py
    echo " " >> TmpCrabConfig.py
    echo "config.Site.whitelist = ['T2_CH_CERN']" >> TmpCrabConfig.py # 939   
    echo "config.Site.storageSite = 'T2_CH_CERN'" >> TmpCrabConfig.py

    # cp TmpCrabConfig.py $ccname
    # mkdir -p ../../crab_configs/ # make directory if it doesn't already exist 
    # mv $ccname ../../crab_configs/$ccname  # Will this work? 
    # rm TmpCrabConfig.py 

    #crab submit -c $ccname 
    # crab submit -c ../../crab_configs/$ccname
    # crab status 
#####################################################################
    echo "ccname: $ccname"
    cp TmpCrabConfig.py $ccname
    mkdir -p crab_configs 
    #mv $ccname ../../crab_configs/$ccname  
    mv $ccname crab_configs/$ccname  
    rm TmpCrabConfig.py 

    #crab submit -c ../../crab_configs/$ccname 

    # Just need last two 

    if [ $dryRun == "1" ]; then 
        echo "DRY RUN: Not submitting"
        echo "Was going to submit: crab_configs/$ccname "
    else 

        crab submit -c crab_configs/$ccname 
        crab status

    fi 
 
    }
