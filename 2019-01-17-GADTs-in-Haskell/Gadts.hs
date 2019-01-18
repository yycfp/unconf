{-# OPTIONS_HADDOCK show-extensions, ignore-exports #-}
-- | Below is a collection of examples where Generalised Algebraic
-- Datatypes  (GADTs), are used. This collection aims to be short and
-- to the point, leaving out unnecessary detail.
{-# LANGUAGE GADTs #-} -- Enable Gadts syntax and pattern matching
{-# LANGUAGE FlexibleInstances #-} -- This is necessary for instantiating type-classes for phantom types
{-# LANGUAGE MultiParamTypeClasses #-} 
{-# LANGUAGE StandaloneDeriving #-} -- We want to derive @Show@ instances for GADTs necessary for REPL use.
{-# LANGUAGE KindSignatures #-} --needed for type arithmetic
{-# LANGUAGE DataKinds #-}      --needed for type arithmetic
{-# LANGUAGE ScopedTypeVariables #-}      --needed for type arithmetic
{-# LANGUAGE TypeOperators #-}  --needed to use + on types
{-# LANGUAGE FlexibleContexts #-}  --dito
{-# LANGUAGE TypeFamilies #-}  --dito
{-# LANGUAGE PolyKinds #-} --using kind variables in type family Cmp
{-# Options_GHC -fplugin GHC.TypeLits.Normalise #-}
-- check
-- http://mstksg.github.io/hmatrix/Numeric-LinearAlgebra-Static.html
-- for how to use GHC.TypeLits

module Gadts where

import GHC.TypeLits (type (+), type (-))
import qualified GHC.TypeLits as TL --module implementing type arithmetic
import Data.Proxy (Proxy(..))

import Data.List

-- |The main point of a Gadt: Constructors can have any signature as
-- long as they return the right type, in this case @Term something@.
-- In particular, a Gadt provides full control over the return type
-- within this constraint.
data Term a where
  Lit :: Int -> Term Int
  IsZero :: Bool -> Term Bool
  TermSum :: Term Int -> Term Int -> Term Int
  TermEq :: Eq a => Term a -> Term a -> Term Bool
  -- |even type variables can be introduced
  TermPair :: Term b -> Term c -> Term (b,c)
-- | This hugely simplifies pattern matching, as in
--
-- > eval :: Term a -> a
--
-- > eval (Lit i) = i
--
-- > eval (IsZero b) = b
--
-- > eval (TermPair t1 t2) = (eval t1, eval t2)
-- and yes, this compiles (and works, after all, this is Haskell)
-- despite the seemingly different return types. However, the type
-- annotation is necessary. Actually, the type variable would be
-- useful just so we can write the type @Term a -> a@.
eval :: Term a -> a
eval (Lit i) = i
eval (IsZero b) = b
eval (TermSum i1 i2) = eval i1 + eval i2
eval (TermEq i1 i2) = eval i1 == eval i2
eval (TermPair t1 t2) = (eval t1, eval t2)
-- |Compare this to the traditional approach, where the type variable is
-- totally redundant. Note that there would be no way to prevent a
-- TermSumTr of a LitTr and an IsZeroTr because they both construct
-- a TermTr a which can be unified to an Int. This needs logic outside
-- of the constructors to prevent that.
data TermTr a  = LitTr Int
               | IsZeroTr Bool
               | TermSumTr (TermTr Int) (TermTr Int)
               | TermPairTr (TermTr a) (TermTr a)
               deriving Show
-- |Now evaluation like in Term doesn't even compile:
-- evalTr :: TermTr a -> a
-- evalTr (LitTr i)= i
-- evalTr (IsZeroTr b) =  b -- conflict in branch return types: Int vs Bool
-- evalTr (TermPairTr t1 t2) = (evalTr t1, evalTr t2)
-- ^ Last one doesn't compile, even by itself because TermPairTr now has
-- type TermTr a and not type TermTr (b,c) because there is no way to
-- construct a TermTr (b,c) without a Gadt.
-- So the result needs to be packed into a type
data Result  = ResultI Int | ResultB Bool | ResultP (Result , Result )
-- | And can be evaluated like below, without much gain, it ends up as nested
-- tuples of Booleans and integers packed into type Result a.
evalTr (TermPairTr t1 t2) = ResultP ((evalTr t1), (evalTr t2))
evalTr (LitTr i ) = ResultI i
evalTr (IsZeroTr b ) = ResultB b

-- Uses: constructor tracking in union types, phantom type handling,
-- existential datatypes, dictionary passing

-- |Dictionary handling
-- Want to make sure sets can only be constructed from ordered data, like so:
-- data Ord a => Set a = MkSet [a]
-- |Alas, constraint needs to be dragged about even if not needed:
-- tailSet :: Ord a => Set a -> Set a
-- tailSet (MkSet l) = MkSet $ tail l
-- These kind of constraints on a type have become obsolete and now
-- require a compiler extension to compile.
-- Replacement for that is a Gadt:
data Set a where
  MkSet :: Ord a => [a] -> Set a
-- Note:
-- data Set a = Ord a => MkSet [a] works, too, in this case.

-- |But here we could also gain some flexibility with a phantom type
data FSet t a where
  MkFSet :: Eq a => [a] -> FSet Plain a
  MkFSetO :: Ord a => [a] -> FSet Sortable a
-- |The point: algorithms like searching, removing duplicates and others
-- are more efficient on ordered data.
-- These are the types for the different FSets.
data Plain
-- |As Vinicius pointed out, the original
-- @MkFSetO@ return type of @FSet Ordered a@ was misleading because a
-- constructor can't be made to do any sorting, it just constructs. Hence the
-- additional @Sortable@ type, which better expresses what the constructor does.
data Sortable
-- |This is for actually ordered sets, which can't be constructed but have to
-- be generated by some @sort::FSet Sortable a -> FSet Ordered a@ function.
data Ordered

-- |Now we can use type-classes to track the type of flexible sets and apply
-- the proper search function
class Searcher s a where
  search :: a -> s a -> Maybe a
instance Searcher (FSet Plain) a where
  search e (MkFSet l) = find ( e == ) l
instance Searcher (FSet Ordered) a where
  search e (MkFSetO l)= binarySearch e l

binarySearch :: (Foldable f, Ord a) => a -> f a -> Maybe a
binarySearch = undefined
-- |And then there is the whole issue of phantom types used to track state.
-- For example input from some external source that needs to be processed
-- in a number of stages, for example e-mail addresses, which need to be parsed
-- and validated. One way to keep track of progress is by using a phantom
-- parameter p in an input data type:
data Input c p where
  Fresh :: String -> Input String Raw
  Correct :: String -> Input String Parsed
  Valid :: String -> Input String Validated

deriving instance Show (Input a b) --so the REPL will print results

data InputTypes = Raw|Parsed|Validated
  deriving Show

class Validator a where
  validate :: a -> Input String Validated

instance Validator (Input String Validated) where
  validate=id

validateParsed :: Input String Parsed -> Input String Validated
validateParsed (Correct s) = Valid $ s ++ " :: Valid"

instance Validator (Input String Parsed) where
  validate = validateParsed


-- |A redefinition of lists as GADT. Compare to the regular definition as
-- union type ie
-- data List content = Nil|Con content (List content)
-- Here the union type is generalised to a GADT and returns different types.
data List state content where
  Nil :: List Empty content
  Con :: content -> List state content -> List Populated content
  -- deriving Show: doesn't work for GADTs need standalone deriving
  -- deriving Instance Show (List state content): content needs to be showable
  -- state needs to be showable
-- |This needs datatypes to track the state of the list
data Empty
data Populated
-- |Point of this: checking applicability of @head@ during compile time
-- In contrast to the partial function @head@ for regular lists [], @headGadt@
-- is fully defined on its datatype.
headGadt :: List Populated a -> a
headGadt (Con x _) = x

-- |Problem: the tail function. Sometimes, the tail of a @List@ will be
-- populated, sometimes not. So we need a Tail type that includes both.
data Tail a = TailP (List Populated a) | TailE (List Empty a)
tailGadt :: List s a -> Tail a
tailGadt Nil = TailE Nil
tailGadt (Con _ Nil) = TailE Nil
tailGadt (Con _ (Con x xs)) = TailP (Con x xs)

-- |Better use an Either, now we can use fmap on a tailGE
tailGE :: List s a -> Either (List Empty a) (List Populated a)
tailGE (Con _ (Con x xs)) = Right (Con x xs)
tailGE _ =Left Nil
-- That's where inductive types come in handy
-- because the @state@ index of @List@ could be populated with an integer
-- instead of a type. Currently the only way to do that in Haskell is via
-- Presburger arithmetic at the type-level. See module GHC.TypeLits, which
-- actually implements type-level Peano arithmetic

--TODO: check the experimental static part of HMatrix to see how tailN
--could be made to work.
data ListN (n :: TL.Nat) content where
  NilN :: ListN 0 content
  ConN :: content -> ListN n content -> ListN  (n + 1) content
  --Note this wouldn't be good, m would not be instantiated
  --ConN :: content -> ListN n content -> ListN  m content

-- |The length function for ListN getting the length from the type.
-- Note that the forall quantifier is needed to trigger
-- the scoping of type variables over the whole expressions. This happens
-- because the ScopedTypeVariables extension is active in this module.
-- The KnownNat constrained allows the use of natVal to retrieve an
-- integer value from the type.
lengthN :: forall n a. TL.KnownNat n => ListN n a -> Integer
lengthN  _ = TL.natVal (Proxy::Proxy n)
-- |Again a version of a head that doesn't compile for empty lists because
-- n+1 cannot be unified with 0
headN :: ListN (n + 1) a -> a
headN (ConN x _)= x

-- |Another implementation of @head@, this time using type constraints
-- to exclude the empty list. This time EQ cannot be unified with GT
-- if n is zero
headN2 :: (TL.KnownNat n, TL.CmpNat n 0 ~ GT) => ListN n a -> a
headN2 (ConN x _)= x

-- |Here a version of tailN for nonempty lists. Note that, GHC cannot
-- unify Nat expressions containing type variables yet, (2+1) ~ 3 is ok
-- but (n+1) ~ (1+n) is a no-go at the moment, so a compiler plugin like
-- GHC.TypeLits.Normalise is needed.
tailN :: ListN (n+1) a -> ListN n a
tailN (ConN _  xs) = xs

-- |The problem with the tail is that its type can be ListN (n+1) a -> ListN n a
-- but also ListN n a -> List n a, namely when n=0. These types don't unify, so
-- some construct like the @Either@ above is needed.
tailNE :: ListN n a -> Either (ListN 0 a) (ListN (n-1) a)
tailNE (ConN _ (ConN x xs)) = Right (ConN x xs)
tailNE _ = Left NilN

-- |Using type-arithmetic:
type family Cmp o l e g where
  Cmp 'LT l e g = l
  Cmp 'EQ l e g = e
  Cmp 'GT l e g = g

-- | Almost works, compiler doesn't recurse but every instance below works
-- so this looks like a case for templates or another compiler extension
-- handling type families in addition to Nats
tailNC :: ListN n a -> ListN (Cmp (TL.CmpNat n 0) 0 0 (n-1)) a
tailNC NilN = NilN
tailNC (ConN _ (ConN x NilN)) = ConN x NilN
tailNC (ConN _ (ConN x (ConN y NilN)))= ConN x (ConN y NilN)
-- tailNC (ConN _ (ConN x xs)) = ConN x xs --this one fails to compile

-- TODO: write a list-type just wrapping regular lists and managing the
-- length type with the reflection and reification mechanisms provided
-- by GHC.TypeLits
-- |Or could we just wrap a list? with a Length type family
-- data ListW n a where
  -- Wrap :: [a] -> ListW (Length [a]) a
