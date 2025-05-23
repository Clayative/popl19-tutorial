-- Type checker and interpreter for WHILE language.
{-# OPTIONS --sized-types #-}

module runwhile where

open import Library
open import WellTypedSyntax using (Program)
open import TypeChecker     using (checkProgram)

import AST as A
import Parser
open import Interpreter using (runProgram)

-- Other modules, not used here.
import Value
import UntypedInterpreter

-- Parse.

parse : String → IO A.Program
parse contents = do
  case Parser.parse contents of λ where
    (bad cs) → do
      putStrLn "SYNTAX ERROR"
      putStrLn (String.fromList cs)
      exitFailure
    (ok prg) → return prg
  where
  open Parser using (Err; ok; bad)

-- Type check.

check : A.Program → IO Program
check prg = do
  case checkProgram prg of λ where
    (fail err) → do
      putStrLn "TYPE ERROR"
      putStr   (print prg)
      putStrLn "The type error is:"
      putStrLn (print err)
      exitFailure
    (ok prg') → return prg'
  where
  open ErrorMonad using (fail; ok)

-- Interpret.

run : Program → IO ⊤
run prg' = putStrLn (print (runProgram prg'))

-- Display usage information and exit.

usage : IO ⊤
usage = do
  putStrLn "Usage: runwhile <SourceFile>"
  exitFailure

-- Parse command line argument and send file content through pipeline.

runwhile : IO ⊤
runwhile = do
  file ∷ [] ← getArgs where _ → usage
  run =<< check =<< parse =<< readFiniteFile file
  return _

main = runwhile


-- -}
