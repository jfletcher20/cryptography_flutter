// uses Caesar cipher to encrypt and decrypt text
abstract class Cipher {
  static int shift = 3;
  static String encode(String text) {
    return text.split("").map((e) {
      if (e == " ") return e;
      int charCode = e.codeUnitAt(0);
      if (charCode >= 65 && charCode <= 90)
        return String.fromCharCode((charCode - 65 + shift) % 26 + 65);
      else if (charCode >= 97 && charCode <= 122)
        return String.fromCharCode((charCode - 97 + shift) % 26 + 97);
      else
        return e;
    }).join("");
  }

  static String decode(String text) {
    return text.split("").map((e) {
      if (e == " ") return e;
      int charCode = e.codeUnitAt(0);
      if (charCode >= 65 && charCode <= 90)
        return String.fromCharCode((charCode - 65 - shift + 26) % 26 + 65);
      else if (charCode >= 97 && charCode <= 122)
        return String.fromCharCode((charCode - 97 - shift + 26) % 26 + 97);
      else
        return e;
    }).join("");
  }
}
