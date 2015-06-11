{
module LamParser where
import Data.Char
import Lam
}

%name calc
%tokentype { Token }
%error { parseError }

--Tokens
%token 
      lam             { TokenLam}
      var             { TokenVar $$ }
      '.'             { TokenDot }
      '('             { TokenOpenPar }
      ')'             { TokenClosePar }
      true            { TokenTrue }
      false           { TokenFalse }
      if              { TokenIf }
      then            { TokenThen }
      else            { TokenElse }
      succ            { TokenSucc }
      pred            { TokenPred }
      iszero          { TokenIsZero } 
      int             { TokenNum $$ }
      ':'             { TokenBind }
      ';'             { TokenSeq } 
      let             { TokenLet }
      in              { TokenIn }  
      '='             { TokenEquals } 
      Bool            { TokenBool } 
      Nat			    { TokenNat }
      

--Precedências
--%left var (Nao funcionou)

%%

--Regras de Produção da Gramática
TLamReg : var                                       { Var $1 }
        | '(' var ')'                               { Var $2 }
        
        | lam var ':' Bool '.' TLamReg              { Abs $2 TypeBool $6 }    
        | '(' lam var ':' Bool '.' TLamReg ')'      { Abs $3 TypeBool $7 }
        
        | lam var ':' Nat '.' TLamReg               { Abs $2 TypeNat $6 }    
        | '(' lam var ':' Nat '.' TLamReg ')'       { Abs $3 TypeNat $7 }         
        
        | TLamReg TLamReg                           { App $1 $2 } 
        | '(' TLamReg ')' '(' TLamReg ')'           { App $2 $5 }
        | '(' TLamReg ')' TLamReg                   { App $2 $4 }
        | TLamReg '(' TLamReg ')'                   { App $1 $3 }
        
        | true                                      { TTrue }
        | false                                     { TFalse }
        | if TLamReg then TLamReg else TLamReg      { TIf $2 $4 $6 }
        
        | int                                       { num2lam $1 }
        
        | succ TLamReg                              { TSucc $2 }
        | succ '(' TLamReg ')'                      { TSucc $3 }
        
        | pred TLamReg                              { TPred $2 }
        | pred '(' TLamReg ')'                      { TPred $3 }
        
        | iszero TLamReg                            { TIsZero $2 } 
        | iszero '(' TLamReg ')'                    { TIsZero $3 } 
        
        | TLamReg ';' TLamReg                       { TSeq $1 $3 }
        | '(' TLamReg ')' ';' '(' TLamReg ')'       { TSeq $2 $6 }
        
        | let var '=' TLamReg in TLamReg                 { TLet $2 $4 $6 } 
        | let var '=' '(' TLamReg ')' in TLamReg         { TLet $2 $5 $8 }
        | let var '=' TLamReg in '(' TLamReg ')'         { TLet $2 $4 $7 }
        | let var '=' '(' TLamReg ')' in '(' TLamReg ')' { TLet $2 $5 $9 }  

--Funções e Tipos Haskell
{

--Tratamento de Erros
parseError :: [Token] -> a
parseError _ = error "Parse error"

--Tipo TLam
--Vem do módulo Lam

--Tipo Token
data Token = TokenLam
           | TokenVar Char
           | TokenDot
           | TokenOpenPar
           | TokenClosePar
           | TokenTrue
           | TokenFalse 
           | TokenIf 
           | TokenThen 
           | TokenElse 
           | TokenNum Int
           | TokenSucc 
           | TokenPred 
           | TokenIsZero
           | TokenBind
           | TokenSeq
           | TokenLet 
           | TokenIn
           | TokenEquals
           | TokenBool 
           | TokenNat deriving Show  

lexer :: String -> [Token]
lexer [] = []
lexer (c:cs) 
    | isSpace c = lexer cs
    | isDigit c = lexNum (c:cs)
    | isAlpha c = lexAlpha (c:cs)
lexer ('.':cs) = TokenDot : lexer cs
lexer ('(':cs) = TokenOpenPar : lexer cs
lexer (')':cs) = TokenClosePar : lexer cs
lexer (':':cs) = TokenBind : lexer cs
lexer (';':cs) = TokenSeq : lexer cs
lexer ('=':cs) = TokenEquals : lexer cs

lexAlpha cs =
   case span isAlpha cs of
      ("lam"   ,rest) -> TokenLam : lexer rest
      ("true"  , rest) -> TokenTrue : lexer rest
      ("false" , rest) -> TokenFalse : lexer rest
      ("if"    , rest) -> TokenIf : lexer rest
      ("then"  , rest) -> TokenThen : lexer rest
      ("else"  , rest) -> TokenElse : lexer rest
      ("succ"  , rest) -> TokenSucc : lexer rest
      ("pred"  , rest) -> TokenPred : lexer rest 
      ("iszero", rest) -> TokenIsZero : lexer rest
      ("let"   , rest) -> TokenLet : lexer rest
      ("in"    , rest) -> TokenIn : lexer rest 
      ("Bool"  , rest) -> TokenBool : lexer rest
      ("Nat"   , rest) -> TokenNat : lexer rest 
      (var     , rest) -> if (length var == 1) then TokenVar (head var) : lexer rest else lexer rest 

lexNum cs = TokenNum (read num) : lexer rest
   where (num,rest) = span isDigit cs

num2lam :: Int -> TLam
num2lam n
   | n < 0 = error "Eu não posso converter inteiro negativo para TLam!"
   | n == 0 = TZero
   | otherwise = (TSucc (num2lam (n-1)))

main = getContents >>= print . calc .lexer

--Função para leitura da entrada pelo teclado
calcula = do
  putStr("Informe a expressão: ")
  getLine >>= print .calc .lexer

}
