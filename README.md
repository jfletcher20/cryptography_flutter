# cryptography_flutter

## Project description
Project repository for the advanced operating systems assignment on cryptography.

Most students chose C#/.NET for their projects; I was interested in seeing if this was possible in Flutter and it turned out to be fairly straightforward once you understood the libraries.

Allows for symmetric and asymmetric key creation (AES and RSA respectively) for purposes of encryption, decryption, signing and verifying signatures across multiple users.

**A minor change was made to one of the libraries used where I extracted the function for calculating the digest, since it was required to save the digest to a separate file and then read it from there before signing it. If you wish to run this code, I included the changes in a comment in the method responsible for digest calculation - or you can simply remove that in-between-step and run it that way.

## Upute
U direktoriju "izvrsi_program" se nalaze datoteke potrebne za izvršavanje programa. Potrebno je samo pokrenuti "cryptography_flutter.exe" datoteku.

Potreban je Windows OS za pokrenuti program.
Pokretanjem .exe datoteke, automatski ćete biti ulogirani u jedan od "računa" (Joshua).

VAŽNO:
Ako se prvi put ulogirate u neki račun, potrebno je generirati njegove ključeve prije pokušaja obrade datoteka kroz sučelje (aplikacija se neće zablokirati ili zatvoriti, nego enkripcija/dekripcija/potpisivanje/verifikacija datoteka jednostavno neće funkcionirati).

Otvorite "Documents" direktorij i u njemu ćete naći novokreirani direktorij "cryptography_folder".
U njoj će se generirati direktorij nekog računa pri prvom ulogiranju u taj račun.
U tom direktoriju će se pohranjivati ključevi te rezultati enkripcije i dekripcije, izračunavanja sažetka i stvaranja potpisa.

Račun mijenjate klikom na ikonu za profil u gornjem desnom kutu sučelja.
Drugi računi mogu služiti za dodatnu verifikaciju da se datoteka ne može dekriptirati tuđim ključem i za dodatni način verifikacije potpisa. U protivnom, nisu potrebni te nije potrebno na njih obraćati pažnju.

Generirani sažetak datoteke se sprema odvojeno od potpisa pod "{korisnik}/signature/digest.txt".
Potpis se sprema pod "{korisnik}/signature/digest/{datoteka}".

Ako je unesena datoteka dovoljno dugačka, može se preko sučelja pregledati u cijelosti pomoću "scroll" na mišu.

Za pregled programskog koda, želite otvoriti direktorij "/kod/cryptography_flutter/lib".

S poštovanjem,
Joshua Lee Fletcher
