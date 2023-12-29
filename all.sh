#!/bin/sh
#SBATCH --partition=bstgpu
#SBATCH --gpus=2
#SBATCH --mem=500G

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1

for disease in file_paths:
    sbatch --output={disease}.out --error={disease}.err


module load conda 
conda create --name omic
module activate omic
pip  install -r requirements.txt

# create a dictionary to store the file paths
file_paths = {
    'Breast_riskfactor': '/dcs04/nilanjan/data/ukb_protein_arking/Y_risk/Breast_riskfactor.csv',
    'lung_riskfactor': '/dcs04/nilanjan/data/ukb_protein_arking/Y_risk/lung_riskfactor.csv',
    'colon_riskfactor': '/dcs04/nilanjan/data/ukb_protein_arking/Y_risk/colon_riskfactor.csv',
    'Prostate_riskfactor': '/dcs04/nilanjan/data/ukb_protein_arking/Y_risk/Prostate_riskfactor.csv',
    'death_riskfactor': '/dcs04/nilanjan/data/ukb_protein_arking/Y_risk/death_riskfactor.csv',
    'incCOPD_riskfactor': '/dcs04/nilanjan/data/ukb_protein_arking/Y_risk/incCOPD_riskfactor.csv',
    'incSTR_riskfactor': '/dcs04/nilanjan/data/ukb_protein_arking/Y_risk/incSTR_riskfactor.csv',
    'incCVD_riskfactor': '/dcs04/nilanjan/data/ukb_protein_arking/Y_risk/incCVD_riskfactor.csv',
    'incESRD_riskfactor': '/dcs04/nilanjan/data/ukb_protein_arking/Y_risk/incESRD_riskfactor.csv',
    'incAlzh_riskfactor': '/dcs04/nilanjan/data/ukb_protein_arking/Y_risk/incAlzh_riskfactor.csv',
    'incMI_riskfactor': '/dcs04/nilanjan/data/ukb_protein_arking/Y_risk/incMI_riskfactor.csv',
    'incAsthma_riskfactor': '/dcs04/nilanjan/data/ukb_protein_arking/Y_risk/incAsthma_riskfactor.csv',
    'incParkinson_riskfactor': '/dcs04/nilanjan/data/ukb_protein_arking/Y_risk/incParkinson_riskfactor.csv',
    'all_proteomic_imputed': '/dcs04/nilanjan/data/ukb_protein_arking/all_proteomic_imputed.csv'
}


for key, value in file_paths.items():
    df_pheno=pd.read_csv(value,low_memory=False)
    df_protein=pd.read_csv(file_paths['all_proteomic_imputed'],low_memory=False)
    new_dataset = pd.merge(df_pheno, df_protein, on='Unnamed: 0', how='inner')
    new_dataset.to_csv(key+'.csv', index=False)

from util.preprocess import preprocess_data

# preprocess all the new datasets
for key, value in file_paths.items():
    df = pd.read_csv(value, low_memory=False)
    df = preprocess_data(df)
    df.to_csv(key + '_preprocessed.csv', index=False)


python train_test.py --data_path {key+'.csv'} --output_path output/vae_regression_model.csv --roc_auc {roc_auc} --disease {disease} --epochs 100 --learning_rate 0.001


echo "Accuracy of train file:"
python util/visualizer.py --file_path output/vae_regression_model.csv --mode train --metric accuracy
echo "Accuracy of test file:"
python util/visualizer.py --file_path output/vae_regression_model.csv --mode test --metric accuracy
echo "AUC of train file:"
python util/visualizer.py --file_path output/vae_regression_model.csv --mode train --metric auc
echo "AUC of test file:"
python util/visualizer.py --file_path output/vae_regression_model.csv --mode test --metric auc
echo "MSE of train file:"
python util/visualizer.py --file_path output/vae_regression_model.csv --mode train --metric mse
echo "MSE of test file:"
python util/visualizer.py --file_path output/vae_regression_model.csv --mode test --metric mse

