import numpy as np
import matplotlib.pyplot as plt
import subprocess as sp

# h = 12.00
# command = f'325\n1\n{h:.2f}\n1 1\n'
# sp.run('vaspkit', shell=True, cwd='.', check=True,  input=command.encode())

# imge = np.loadtxt(f'STM_{h:.2f}.grd')
# print(imge.shape)
# plt.imshow(imge, cmap='gray', interpolation='nearest')
# plt.colorbar()
# plt.title('STM Image')
# plt.savefig(f'STM_{h:.2f}.png')
from py4vasp import Calculation
calc: Calculation = Calculation.from_file('vaspout.h5')
calc.partial_charge.to_stm(selection='constant_height(total)', tip_height=4, supercell=[7,7])