type piece = {
  name: string,
  viewBox: string,
  shape: string
}

type chessPieces = {
  king: piece,
  queen: piece,
  rook: piece,
  bishop: piece,
  pawn: piece,
  knight: piece,
  blank: piece
}

// let chessPieces: chessPieces
let chessboard: array<piece>
