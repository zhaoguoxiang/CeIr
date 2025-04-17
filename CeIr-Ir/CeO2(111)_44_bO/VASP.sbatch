#!/bin/bash
#SBATCH --partition=workq
#SBATCH --job-name=vasp
#SBATCH --nodes=4
#SBATCH --time=24:00:00
#SBATCH --exclusive
#SBATCH --err=std.err
#SBATCH --output=std.out
#----------------------------------------------------------#
module switch PrgEnv-cray PrgEnv-intel
module switch intel intel/19.0.5.281
export PATH=/sw/ex111genoa/vasp/tools/util/bin:$PATH
export FI_CXI_RX_MATCH_MODE=software
export MKL_DEBUG_CPU_TYPE=5
export MKL_CBWR=auto
export OMP_NUM_THREADS=1
export LD_LIBRARY_PATH=/opt/cray/pe/netcdf/4.9.0.7/INTEL/2022.2/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/opt/cray/pe/hdf5/1.12.2.7/INTEL/2022.2/lib:$LD_LIBRARY_PATH
export VASP_HOME=/scratch/liy0w/VASP/vasp.6.4.3/bin
export VASP_PP_PATH=/scratch/liy0w/VASP/pot64
export VASP_POT=/scratch/liy0w/VASP/pot64
#--------------assign the number of tasks based on the number of nodes------------------------#
ntasks=$(( SLURM_JOB_NUM_NODES * 192 ))

#--------------run in the directory in which invoked from----------------------------#
cd "$SLURM_SUBMIT_DIR"
#----- Automatically generate the POTCAR file from the POSCAR element order -----#
# Extract the element symbols from the 6th line of POSCAR
elems=$(sed -n '6p' POSCAR)
echo "Elements in order: $elems"
# Remove any existing POTCAR file to avoid appending to an old one
rm -f POTCAR
# Remove carriage returns from VASP input files
for file in POSCAR INCAR KPOINTS VASP.sbatch; do
    if [ -f "$file" ]; then
        sed -i 's/\r//g' "$file"
        echo "Cleaned carriage returns from $file"
    fi
done
# Loop over each element and concatenate its POTCAR file
for elem in $elems; do
    # Trim whitespace from the element symbol
    elem=$(echo "$elem" | tr -d '\r' | xargs)
    filepath="${VASP_POT}/potpaw_PBE/${elem}/POTCAR"
    echo "Looking for: $filepath"
    if [ -f "$filepath" ]; then
        cat "$filepath" >> POTCAR
        echo "Added POTCAR for $elem"
    else
        echo "Warning: Normal POTCAR for $elem not found at $filepath. Switching to _sv version."
        filepath_sv="${VASP_POT}/potpaw_PBE/${elem}_sv/POTCAR"
        echo "Looking for: $filepath_sv"
        if [ -f "$filepath_sv" ]; then
            cat "$filepath_sv" >> POTCAR
            echo "Added _sv POTCAR for $elem"
        else
            echo "Error: Neither normal nor _sv POTCAR for $elem found. Check your POTCAR files."
        fi
    fi
done
#----------------------------------------------------------#
echo "The job "${SLURM_JOB_ID}" is running on "${SLURM_JOB_NODELIST}
#----------------------------------------------------------#
srun --ntasks=${ntasks} --map-by-numa --hint=nomultithread ${VASP_HOME}/vasp_std| tee vasp.out

#----------------------------------------------------------#
# Print a final message indicating that the calculation is finished.
echo "Calculation finished on $(date). Please check the OUTCAR file for details."
