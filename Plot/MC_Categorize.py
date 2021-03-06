def MC_Cat(bkg): 
    bkg_cat_ = ''
    bkg_cat_ = bkg.split('_')[0] # background label 
    #print'bkg_cat = ',bkg

    # bkg_categories = { 
    # # "<category name>" : [ '<category_index>','<category_color>','<Bkg_1>','<Bkg_2>', ... '<Bkg_N>']   
    #     "reds": ['0','kRed','DiPhotonJetsBox','GJet','QCD','DYToLL','DYJetsToLL'],
    #     "blues": ['1','kBlue','GluGluHToGG','VBFHToGG','VHToGG','TTGG'],
    #     "greens": ['2','kGreen','TTGJets','TGJets','TTJets','ttHJetToGG']
    #     }

    bkg_categories = { 
    # "<category name>" : [ '<category_index>','<category_color>','<Bkg_1>','<Bkg_2>', ... '<Bkg_N>']   
        "SM_H#gamma#gamma": ['0','kRed','GluGluHToGG','VBFHToGG','VHToGG'],
        "QCD": ['1','kBlue','QCD'],
        "DY": ['2','kGreen','DYToLL','DYJetsToLL'],
        "g+j": ['3','kYellow','GJet','TTGJets','TGJets'],
        "gg+j": ['4','kViolet','ttHJetToGG','DiPhotonJetsBox'],
        "other": ['5','kCyan','TTGG','TTJets']

        }

    

    # 'DiPhotonJetsBox','GJet','QCD','DYToLL','DYJetsToLL','GluGluHToGG','VBFHToGG','VHToGG','TTGG', 
    # 'TTGJets','TGJets','TTJets','ttHJetToGG'

    icat, cat, color = '', '', '' 
    for ik,key in enumerate(bkg_categories):
        for ibk,bk in enumerate(bkg_categories[key]):
            if ibk == 0: continue # color 
            if ibk == 1: continue # category index 
            if bk == bkg_cat_:
                cat = key 
                icat = bkg_categories[key][0]
                color = bkg_categories[key][1] 

    if icat == '':
        print'I couldn\'t find the background category:',bkg_cat_
        print'Exiting'
        exit(0)

    return cat, icat, color

# Before '-' to '_' conversion:
#
# DiPhotonJetsBox_M40_8 0-Sherpa
# DiPhotonJetsBox_MGG-80toInf_13TeV-Sherpa
# GJet_Pt-20to40_DoubleEMEnriched_MGG-80toInf_TuneCUETP8M1_13TeV_Pythia8
# GJet_Pt-20toInf_DoubleEMEnriched_MGG-40to80_TuneCUETP8M1_13TeV_Pythia8
# GJet_Pt-40toInf_DoubleEMEnriched_MGG-80toInf_TuneCUETP8M1_13TeV_Pythia8
# QCD_Pt-30to40_DoubleEMEnriched_MGG-80toInf_TuneCUETP8M1_13TeV_Pythia8
# QCD_Pt-30toInf_DoubleEMEnriched_MGG-40to80_TuneCUETP8M1_13TeV_Pythia8
# QCD_Pt-40toInf_DoubleEMEnriched_MGG-80toInf_TuneCUETP8M1_13TeV_Pythia8
#  "DYToLL"   : [ "/DYJetsToLL_M-50_TuneCUETP8M1_13TeV-amcatnloFXFX-pythia8/sethzenz-RunIISummer16-2_4_1-25ns_Moriond17-2_4_1-v0-RunIISummer16MiniAODv2-PUMoriond17_80X_mcRun2_asymptotic_2016_TrancheIV_v6_ext2-v1-74c0514daa3d87bd951f57782e8afcd5/USER" ]
# GluGluHToGG_M-125_13TeV_powheg_pythia8
# VBFHToGG_M-125_13TeV_powheg_pythia8
# VHToGG_M125_13TeV_amcatnloFXFX_madspin_pythia8
# TTGG_0Jets_TuneCUETP8M1_13TeV_amcatnlo_madspin_pythia8
# TTGJets_TuneCUETP8M1_13TeV-amcatnloFXFX-madspin-pythia8
# TGJets_TuneCUETP8M1_13TeV_amcatnlo_madspin_pythia8
# TTJets_TuneCUETP8M1_13TeV-madgraphMLM-pythia8
# ttHJetToGG_M125_13TeV_amcatnloFXFX_madspin_pythia8_v2

    # bkg_categories = {
    #     "DiPhoton":['DiPhotonJetsBox_M40_80_Sherpa'],
    #     "DiPhoton":['DiPhotonJetsBox_MGG_80toInf_13TeV_Sherpa'],
    #     "GJet":['GJet_Pt_20to40_DoubleEMEnriched_MGG_80toInf_TuneCUETP8M1_13TeV_Pythia8'],
    #     "GJet":['GJet_Pt_20toInf_DoubleEMEnriched_MGG_40to80_TuneCUETP8M1_13TeV_Pythia8'],
    #     "GJet":['GJet_Pt_40toInf_DoubleEMEnriched_MGG-80toInf_TuneCUETP8M1_13TeV_Pythia8'],
    #     "QCD":['QCD_Pt_30to40_DoubleEMEnriched_MGG_80toInf_TuneCUETP8M1_13TeV_Pythia8'], 
    #     "QCD":['QCD_Pt_30toInf_DoubleEMEnriched_MGG_40to80_TuneCUETP8M1_13TeV_Pythia8'], 
    #     "QCD":['QCD_Pt_40toInf_DoubleEMEnriched_MGG_80toInf_TuneCUETP8M1_13TeV_Pythia8'], 
    #     #"":[''], # reserved for DYToLL
    #     "":['GluGluHToGG_M_125_13TeV_powheg_pythia8'], 
    #     "":['VBFHToGG_M_125_13TeV_powheg_pythia8'], 
    #     "":['VHToGG_M125_13TeV_amcatnloFXFX_madspin_pythia8'], 
    #     "":['TTGG_0Jets_TuneCUETP8M1_13TeV_amcatnlo_madspin_pythia8'], 
    #     "":['TTGJets_TuneCUETP8M1_13TeV_amcatnloFXFX_madspin_pythia8'], 
    #     "":['TGJets_TuneCUETP8M1_13TeV_amcatnlo_madspin_pythia8'], 
    #     "":['TTJets_TuneCUETP8M1_13TeV_madgraphMLM_pythia8'], 
    #     "":['ttHJetToGG_M125_13TeV_amcatnloFXFX_madspin_pythia8_v2'], 
    # }