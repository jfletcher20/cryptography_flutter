# cryptography_flutter

Project repository for the advanced operating systems assignment on cryptography.

Most students chose C#/.NET for their projects; I was interested in seeing if this was possible in Flutter and it turned out to be fairly straightforward once you understood the libraries.

Allows for symmetric and asymmetric key creation (AES and RSA respectively) for purposes of encryption, decryption, signing and verifying signatures across multiple users.

**A minor change was made to one of the libraries used where I extracted the function for calculating the digest, since it was required to save the digest to a separate file and then read it from there before signing it. If you wish to run this code, I included the changes in a comment in the method responsible for digest calculation - or you can simply remove that in-between-step and run it that way.
