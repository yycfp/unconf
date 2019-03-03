module MonadEval
  where

import Control.Monad.Writer
-- |In Haskell, types are defined with the @data@ keyword, product
-- types can be written as tuples. All types and constructors in
-- Haskell have to start with upper case letters.
data Term = Cons Int | Div (Term,Term)

-- |Simple evaluation
evalSim :: Term -> Int
evalSim (Cons x) = x
evalSim (Div (x,y)) = div (evalSim x) (evalSim y)

-- |To handle division by zero and issue a message, the @Either@ type
-- functor is used to construct the return type of the evaluation function
-- It is defined as
-- @data Either a b = Left a|Right b
-- The data functor @Either a@ is a monad in Haskell, so the
-- binding operator >>= is already defined. Note that in Haskell nameless
-- functions are introduced with the @\args -> body@ notation.
-- In @evalSafe@, the dangerous division branch of @evalSim@ is reimplemented
-- and all other results are simply packed into the @Either String@ monad
-- with @return@, which is Haskell's name for the monadic unit.
-- Note that
-- without monadic binding @>>=@, the @case@ match would descend into a nested
-- hell because the results of @evalSafe@ would have to be checked for leftness
-- and rightness in addition to zeroness. If a @Left "Division by zero"@ occurs
-- anywhere in the monadic binding chain, that will be its final result.
evalSafe :: Term -> Either String Int
evalSafe (Div (x,y)) = evalSafe y >>= \ev -> case ev of
                         0 -> Left "Division by zero"
                         rslt -> evalSafe x >>= \nm -> return $ div nm rslt
evalSafe (Cons x) = return x

-- |For logging, the monad to use is @Writer w@ because the logging
-- value of type @w@ is accumulated automatically when chaining through
-- monadic values. That's why @w@ is required to be an instance of @Monoid@,
-- which allows the accumulation of values with the monoidal composition.
-- Whilst @State@ could be used as well, the accumulation would have to be
-- done manually.
-- For counting divisions, a @Writer (Sum Int) Int@ monad is
-- called for because @Sum Int@ is the monoid with @0@ as neutral element
-- and @+@ as operation.
logDivs :: (Term -> Int) -> Term -> Writer (Sum Int) Int
logDivs f arg@(Div (x,y)) = logDivs f x >>= logSecond
  where
    logSecond n = logDivs f y >>= combineWith n
    combineWith nm den = writer (f $  Div (Cons nm, Cons den),1)
-- Which is equivalent to this in imperative notion:
-- logDivs f arg@(Div (x,y)) = do
  -- nm <- logDivs f x
  -- den <- logDivs f y
  -- writer  (f (Div (Cons nm,Cons den)), 1)
logDivs f arg = writer (f arg,0)
-- logDivs f arg = return $ f arg
-- | This can be called on a term and returns a Writer (Sum Int) Int where
-- the first argument represents the division count and the second the result
-- of the evaluation
logDivSim :: Term -> Writer (Sum Int) Int    
logDivSim = logDivs evalSim
-- |Since @Writer (Sum Int) Int@ is not an instance of Show, the REPL will
-- report an error when running logDivSim on a Term. That's why the result
-- of @logDivSim@ should be run through @runWriter@, which transforms the
-- @Writer w a@ monad into a tuple (a,w), which the REPL probably can print
logDivSim4Repl :: Term -> (Int,Sum Int)
logDivSim4Repl = runWriter . logDivSim

-- | Using both logging and safe evaluation can be done with relatively
-- minor code changes to @logDivs@ using the writer monad transformer
-- @WriterT w m a@ which constructs a monad stack from an inner monad @m@,
-- which in our case would be @m ~ Either String@. Note how little the
-- code has to change from @logDivs@ to its universal version @logDivsU@:
-- All the @writer@ functions have to be replaced by the @WriterT@ constructors
-- with some minor adjustments to account for the different argument
-- requirements.
logDivsU :: Monad m => (Term -> m Int) -> Term -> WriterT (Sum Int) m Int
logDivsU f arg@(Div (x,y)) = logDivsU f x >>= logSecond
  where
    logSecond n = logDivsU f y >>= combineWith n
    combineWith nm den = WriterT (f (Div (Cons nm, Cons den)) >>= packTup)
    packTup x = return (x,1)
logDivsU f arg = WriterT $ f arg >>= \x -> return (x,0)

-- | This can be used with @evalSafe@
logDivUSafe :: Term -> WriterT (Sum Int) (Either String) Int
logDivUSafe = logDivU evalSafe

-- | But also with @evalSim@, however @logDivUSim=logDivU evalSim@ does not
-- work because the value returned by @evalSim@ is not monadic. This is
-- where the @Identity@ monad comes in handy because it allows to
-- pack the value of @evalSim@ for use with @logDivsU@:
logDivUSim :: Term -> WriterT (Sum Int) Identity Int
logDivUSim = logDivU (Identity . evalSim)

-- Note that the result typw @WriterT (Sum Int) Identity Int@ is none other
-- than our old @Writer (Sum Int) Int@, @Writer w a@ being defined as
-- @newtype Writer w a = WriterT w Identity a@. As for unwrapping the values in
-- the monad, use @runWriterT@ the same way @runWriter@ was used, it will
-- provide the values in a tuple wrapped in the @Either String@ monad.
