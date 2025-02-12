# cryptography_flutter
Initially developed for the Advanced Operating Systems project at the Faculty of Organization and Informatics, Software Engineering graduate study.
This project was further developed and used in the Digital Forensics project to encrpyt and allow for further decrypting and deciphering of clues found at [globa-telecom-official-email-server](https://global-telecom-official.web.app/) (from [this repository](https://github.com/jfletcher20/email-frontend-page-emulation)).

## Project description
Explores the implementation of cryptography features into a multi-platform application.
I was interested in seeing if this was possible in Flutter and it turned out to be fairly straightforward once you understood the libraries and the concepts.

## Features
 * `symmetric` and `asymmetric` key creation (AES and RSA respectively)
 * symmetric and asymmetric `encryption` and `decryption`, `file signing` and `signature verification` across `multiple profiles`
 * `Caesar cipher` to `encipher` and `decipher` text with a slider to `change the shift parameter`

## Release
The release file can be found in the `windows-release` directory. In there you can also find a [link to the website I developed as a demo](https://global-telecom-official.web.app/) for the software.

Run the `cryptography_flutter` application and see if you can [decipher and decrypt all of the evidence behind the crimes of Rodger Lewis of Global Telecom](https://global-telecom-official.web.app/) (*names are fictional and not based on real people or organizations).

## Additional information
Keys, encryption and decryption results are stored in `Documents/cryptography_flutter/{profile name}`, where `{profile name}` is the name of the profile whose keys you were operating with during encryption/decryption or signing. The paths and outputs that result from executing functions can also be easily copied by clicking on them in the GUI, but note that encrypted data uses bits that can't just be pasted directly into notepad so it's recommended to instead find the output file for the encryption or signing functionalities.
