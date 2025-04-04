open Test
let isTextEqual: (string, string, ~message: string=?) => unit = (
  originalText,
  textToCompare,
  ~message as msg="",
) => {
  assertion(
    (originalText, textToCompare) => originalText->String.equal(textToCompare),
    originalText,
    textToCompare,
    ~operator="String equals",
    ~message=msg,
  )
}

let isTruthy: (bool, ~message: string=?) => unit = (a, ~message as msg="") => {
  assertion((a, b) => a == b, a, true, ~operator="Equals to true", ~message=msg)
}

let isIntegerEqual: (int, int, ~message: string=?) => unit = (a, b, ~message as msg="") => {
  assertion((a, b) => a == b, a, b, ~operator="Integer equals", ~message=msg)
}
