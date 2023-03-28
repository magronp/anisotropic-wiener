#  Anisotropic Wiener filter

This repository contains the code related to the anisotropic Wiener (AW) filter method for phase-aware audio source separation. AW is the topic of several research papers, that you're encouraged to check and to cite if you use the related content:

- P. Magron, R. Badeau, B. David, [Phase-dependent anisotropic Gaussian model for audio source separation](https://hal.archives-ouvertes.fr/hal-01416355), Proc. IEEE ICASSP 2017.
- P. Magron, J. Le Roux, T. Virtanen, [Consistent anisotropic Wiener filtering for audio source separation](https://hal.archives-ouvertes.fr/hal-01593126), Proc. IEEE WASPAA 2017.
- P. Magron, T. Virtanen, [Bayesian anisotropic Gaussian model for audio source separation](https://hal.archives-ouvertes.fr/hal-01632081), Proc. IEEE ICASSP 2018.
- P. Magron, T. Virtanen, [On modeling the STFT phase of audio signals with the von Mises distribution](https://hal.archives-ouvertes.fr/hal-01763147), Proc. iWAENC 2018.

AW was also used in conjunction with NMF for joint magnitude and phase estimation (see [complex-isnmf](https://github.com/magronp/complex-isnmf) and [complex-beta-nmf](https://github.com/magronp/complex-beta-nmf)), and as post-processing in DNN-based separation (see [phase-madtwinnet](https://github.com/magronp/phase-madtwinnet) and [phase-hpss](https://github.com/magronp/phase-hpss)).


