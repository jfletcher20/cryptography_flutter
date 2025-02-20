# cryptography_flutter
_Screenshots included below._

Initially developed for the Advanced Operating Systems project at the Faculty of Organization and Informatics, Software Engineering graduate study.
This project was further developed and used in the Digital Forensics project to encrpyt and allow for further decrypting and deciphering of clues found at [globa-telecom-official-email-server](https://global-telecom-official.web.app/) (from [this repository](https://github.com/jfletcher20/email-frontend-page-emulation)).

## Project description
Explores the implementation of cryptography features into a multi-platform application.
I was interested in seeing if this was possible in Flutter and it turned out to be fairly straightforward once you understood the libraries and the concepts.

## Features
 * `symmetric` and `asymmetric` key creation (AES and RSA respectively)
 * symmetric and asymmetric `encryption` and `decryption`, `file signing` and `signature verification` across `multiple profiles`
 * `Caesar cipher` to `encipher` and `decipher` text with a slider to `change the shift parameter`

For ease of use, all files that are encrypted/decrypted/signed are saved in your `Documents/cryptography_flutter/{profile}` directory, where `{profile}` represents the selected profile for the person whose keys you are encrypting with.

Additionally, you can click any cryptographic output you see to copy it to your clipboard - anything in a purple box is copiable.

## Release
The release file can be found in the `windows-release` directory. In there you can also find a [link to the website I developed as a demo](https://global-telecom-official.web.app/) for the software.

Run the `cryptography_flutter` application and see if you can [decipher and decrypt all of the evidence behind the crimes of Rodger Lewis of Global Telecom](https://global-telecom-official.web.app/) (*names are fictional and not based on real people or organizations).

## Additional information
Keys, encryption and decryption results are stored in `Documents/cryptography_flutter/{profile name}`, where `{profile name}` is the name of the profile whose keys you were operating with during encryption/decryption or signing. The paths and outputs that result from executing functions can also be easily copied by clicking on them in the GUI, but note that encrypted data uses bits that can't just be pasted directly into notepad so it's recommended to instead find the output file for the encryption or signing functionalities.

## Screenshots
### Asymmetric Keys (Public & Private Key)
![Assymmetric encryption keys](https://github.com/user-attachments/assets/ec5efbb1-d86e-4705-82c6-881efdf9c3c8)
### Symmetric Key (Secret Key)
![Symmetric encryption keys](https://github.com/user-attachments/assets/b66a5697-3489-4f71-8dbe-d1bbf0c186e8)
### Encryption (Asymmetric & Symmetric)
![Encryption](https://github.com/user-attachments/assets/ba302597-a342-4d5d-a6d6-36196b7ab300)
### Decryption (Asymmetric & Symmetric)
![Decryption](https://github.com/user-attachments/assets/11623f96-871f-4f95-bb79-64060263120b)
### Cipher (Encipher)
![Encipher](https://github.com/user-attachments/assets/317ec80c-59ae-4f01-ba1f-41774973842f)
### Cipher (Decipher)
![Decipher](https://github.com/user-attachments/assets/8f876d9e-18b7-4798-8a5f-77f575480c51)
### Sign Document (Digital Signature)
![Sign a document (Digital Signature)](https://github.com/user-attachments/assets/e651aac0-7530-470e-a1c3-68b899ef3243)
### Verify Signature
![Verify Signature](https://github.com/user-attachments/assets/54cc1e66-3420-44a9-869d-51dbe6bd2de6)

