from ase.io import read

atoms = read("stm/1/POSCAR")
print(atoms)
from gpaw import GPAW
calc = GPAW(mode='pw',
            kpts=(4, 4, 1),
            symmetry='off',
            txt='al111.txt')
atoms.calc = calc
energy = atoms.get_potential_energy()
calc.write('al111.gpw', 'all')