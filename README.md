#  Anisotropic Wiener filter

<p align="center" width="100%">
    <img width="50%" src="aw.png">
</p>

This repository contains the code related to the anisotropic Wiener (AW) filter method for phase-aware audio source separation. AW is the topic of several research papers, that you're encouraged to check and to cite if you use the related content (see [below](#references)).


## Setup

Even though this code was primarly developed with Matlab, we've adapted it to Octave. To fully use it, you need several Octave packages, which we can install as follow:

	sudo apt install liboctave-dev
	sudo apt install octave-control
	sudo apt install octave-resample
	sudo apt install octave-statistics

The experiments use the [Dexmixing Secret Database (DSD100)](http://www.sisec17.audiolabs-erlangen.de/) for music separation. Download it, and unzip it in the `data` folder (or change the dataset path accordingly in the `global_setup.m` file).

## Usage

This repository contains several general functions to benchmark certain algorithms and/or magnitude estimation scenarios. You can simply run the main script `run_all.m` in order to train all methods (= learn the optimal hyperparameters), evaluate them on the test set (it will record estimated audio and scores), and display the results (reported bellow).

If you're only interested in reproducing a specific paper's results, simply run the corresponding script. For instance, if you want to reproduce the experiments from our ICASSP 2018 paper, then run `icassp18.m`.

Note that `icassp17.m`, `icassp18.m`, and `iwaenc18.m` perform separation into 4 stems (bass, drums, other, and vocals), while `waspaa17.m` performs singing voice separation, thus it produces two stems (vocals and accompaniment).


## Scenarios

Oracle
(true magnitudes)

Informed
Magnitudes estimated with NMF



## References

The results from this project have been published in the following papers:

<details><summary>P. Magron, R. Badeau, B. David, [Phase-dependent anisotropic Gaussian model for audio source separation](https://hal.archives-ouvertes.fr/hal-01416355), Proc. IEEE ICASSP 2017.</summary>
```latex
@inproceedings{Magron2021,  
  author={P. Magron and P.-H. Vial and T. Oberlin and C. F{\'e}votte},  
  title={Phase recovery with Bregman divergences for audio source separation},  
  booktitle={Proc. IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP)},  
  year={2021},
  month={June}
}
```
</p>
</details>
<details><summary>P. Magron, J. Le Roux, T. Virtanen, [Consistent anisotropic Wiener filtering for audio source separation](https://hal.archives-ouvertes.fr/hal-01593126), Proc. IEEE WASPAA 2017.</summary>
```latex
@inproceedings{Magron2021,  
  author={P. Magron and P.-H. Vial and T. Oberlin and C. F{\'e}votte},  
  title={Phase recovery with Bregman divergences for audio source separation},  
  booktitle={Proc. IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP)},  
  year={2021},
  month={June}
}
```
</p>
</details>
<details><summary>P. Magron, T. Virtanen, [Bayesian anisotropic Gaussian model for audio source separation](https://hal.archives-ouvertes.fr/hal-01632081), Proc. IEEE ICASSP 2018.</summary>
```latex
@inproceedings{Magron2021,  
  author={P. Magron and P.-H. Vial and T. Oberlin and C. F{\'e}votte},  
  title={Phase recovery with Bregman divergences for audio source separation},  
  booktitle={Proc. IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP)},  
  year={2021},
  month={June}
}
```
</p>
</details>
<details><summary>P. Magron, T. Virtanen, [On modeling the STFT phase of audio signals with the von Mises distribution](https://hal.archives-ouvertes.fr/hal-01763147), Proc. iWAENC 2018.</summary>
```latex
@inproceedings{Magron2021,  
  author={P. Magron and P.-H. Vial and T. Oberlin and C. F{\'e}votte},  
  title={Phase recovery with Bregman divergences for audio source separation},  
  booktitle={Proc. IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP)},  
  year={2021},
  month={June}
}
```
</p>
</details>


### Related projects

- [complex-isnmf](https://github.com/magronp/complex-isnmf) uses the anisotropic Gaussian model in conjunction with NMF modeling of the variance in order to perform joint magnitude and phase estimation.
- [complex-beta-nmf](https://github.com/magronp/complex-beta-nmf) extends the above by introducing beta-divergences in the inference process. It therefore generalizes complex NMF to any beta-divergence.
- [phase-madtwinnet](https://github.com/magronp/phase-madtwinnet) combines DNN-based magnitude estimation and phase recovery (using anisotropic Wiener filtering) for singing voice separation.
- [phase-hpss](https://github.com/magronp/phase-hpss) proposes a similar framework for harmonic-percussive source separation.


